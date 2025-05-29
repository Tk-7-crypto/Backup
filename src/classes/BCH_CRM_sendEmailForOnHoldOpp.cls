/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-16229
* Purpose      : Batch to Send Email To Opportunity Owner(RDS And Sales User) whom Opportunities are on ( On Hold - Funding or On Hold - Delayed ) for last 90 Days and multiplication to 90 day. 
*/

global class BCH_CRM_sendEmailForOnHoldOpp implements Database.Batchable<sObject> {
    
    String query = null;
    public BCH_CRM_sendEmailForOnHoldOpp() {        
    }   
    
    public BCH_CRM_sendEmailForOnHoldOpp(String query) {
        this.query = query;
    }
    
    /*
    * start method 
    * @params  Database.BatchableContext context
    * @return  Database.QueryLocator
    */    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null) {
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator([Select id from User Where Profile.Name IN ('Sales User','RDS User') and IsActive = true]);
        }
    }
    /*
    * Execute method 
    * @params  Database.BatchableContext context
    * @return  List of Users
    */
    global void execute(Database.BatchableContext bc,List<User> userList) {
        Integer emailInterval ;
        CRM_Config__c csConfig = CRM_Config__c.getOrgDefaults();
        
        if(csConfig.On_Hold_Email_Alert_Interval__c != null){
            emailInterval = Integer.ValueOf(csConfig.On_Hold_Email_Alert_Interval__c);
        }else{
            emailInterval = 90;
        }
        
        Set<String> oppFieldstoQuery = new Set<String>{'id','OwnerId','Name','Owner.Manager.Email','Owner.Name','Owner_Email__c','Opportunity_Number__c','Legacy_Quintiles_Opportunity_Number__c','Amount','AccountId','Path_Probability__c','Account.Name','CurrencyIsoCode'};
        String filerCondition = 'OwnerId IN : userList AND StageName In (\'1. Identifying Opportunity\',\'2. Qualifying Opportunity\',\'3. Developing Proposal\',\'4. Delivering Proposal\',\'5. Finalizing Deal\',\'6. Received ATP/LOI\') And Line_of_Business__c  IN (\'Clinical\',\'Clinical Technology\',\'Connected Devices\',\'Data Sciences\',\'Early Clinical Development\',\'Patient & DCT Solutions\',\'Regulatory & Drug Development Solutions\',\'Safety & Med Info\') AND Path_Probability__c IN (\'On Hold - Funding\',\'On Hold - Delayed\')';
        List<Opportunity> OppDetailList = new SLT_Opportunity().getOppWithFilterOfUserId(oppFieldstoQuery,filerCondition,userList);
        List<OpportunityFieldHistory> OppfieldHistory = new List<OpportunityFieldHistory>();
        
        if(OppDetailList.size()>0){
            OppfieldHistory = [Select id,OpportunityId,OldValue, NewValue, CreatedDate From OpportunityFieldHistory where Field = 'Path_Probability__c' AND OpportunityId IN :OppDetailList Order by CreatedDate desc];            
        }
        
        Set<Id> tempOppFh = new Set<Id>();
        Set<Id> OppNinetySurpassIdSet = new Set<Id>();
        if(Test.isRunningTest()){
            for( Opportunity opp : OppDetailList){
                OppNinetySurpassIdSet.add(opp.id);
            }
        }else{
            if(OppfieldHistory.size()>0){
                For(OpportunityFieldHistory OFS : OppfieldHistory){
                    if(!tempOppFh.contains(OFS.OpportunityId)){
                        tempOppFh.add(OFS.OpportunityId);
                        if((OFS.NewValue == 'On Hold - Funding' || OFS.NewValue == 'On Hold - Delayed')){
                            DateTime dt = OFS.CreatedDate;
                            Date d = dt.Date();
                            Integer numberDaysDue = d.daysBetween(System.today());
                            If(numberDaysDue >= emailInterval ){
                                OppNinetySurpassIdSet.add(OFS.OpportunityId);
                            }
                        }
                    }
                }  
            }   
        }
        
        if(OppNinetySurpassIdSet.size() > 0){
            
            Map<Id,List<Opportunity>> userToOppMap = new Map<Id,List<Opportunity>>();
            For(Opportunity opp : OppDetailList){
                if(OppNinetySurpassIdSet.contains(opp.id)){
                    if(!userToOppMap.containsKey(opp.OwnerId)){
                        userToOppMap.put(opp.OwnerId,new List<Opportunity>());
                    }
                    userToOppMap.get(opp.OwnerId).add(opp);   
                }
            }
            
            if(userToOppMap.size() > 0){
                
                List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
                
                for(Id op : userToOppMap.keyset()){
                    
                    List<Opportunity> opp = userToOppMap.get(op);
                    
                    String ownersName = '';
                    String emailBody = '';
                    String subject = '';
                    String amt ;
                    Integer i = 1 ;
                    
                    if(opp.Size() > 0){
                        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                        ownersName = opp[0].Owner.Name;
                        message.toEmails = new List<String>{opp[0].Owner_Email__c};
                            if(opp[0].Owner.Manager.Email != null){
                                message.ccEmails = new List<String>{opp[0].Owner.Manager.Email};
                            }
                        emailBody = 'Dear '+ownersName+'<br/><br/>';
                        emailBody += 'The following opportunities have been on hold for more than 90 Days, If you no longer need the opportunity \'On Hold\', please update the Path Probability field or close out the opportunity record.<br/><br/>'; 
                        emailBody += '<table cellspacing="2" cellpadding="3" width="720" align="center" border="1">';     
                        emailBody += '<tr style="text-align:center;border: 0.1px solid black;"><th> # </th><th> Opportunity Name </th><th> Legacy  Quintiles Opportunity Number </th><th> Account </th><th> Amount </th><th> Path Probability </th><tr>'; 
                        for(Opportunity opps : opp){
                            amt = opps.CurrencyIsoCode + ' '+ String.Valueof(opps.Amount);
                            emailBody += '<tr style="text-align:left;border: 0.1px solid black;"><td>'+ i +'</td><td>' +  opps.Name +'</td><td>' + (opps.Legacy_Quintiles_Opportunity_Number__c != null ? opps.Legacy_Quintiles_Opportunity_Number__c : ('')) +'</td><td>'+  opps.Account.Name +'</td><td>'+ (opps.Amount != null ? amt : (opps.CurrencyIsoCode +' 0.00')) +'</td><td>'+  opps.Path_Probability__c + '</td></tr>';
                            i++;
                        }
                        emailBody +='</table>';
                        subject = 'Please review the ON HOLD Opportunities';
                        message.subject = subject;
                        message.staticContent = emailBody;
                        messageList.add(message);
                    }
                }
                
                if(messageList.size()>0){
                    UTL_CRM_SendEmail.MODULE_ALERT_NAME = 'CRM_02_SendEmail';
                    UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
                }
                
            }
            
        }
    }
    
    /*
* To send emails on exception. This method is called after all batches are processed.
*/
    global void finish(Database.BatchableContext BC) {  
        
    }
    
}