/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-15872 / ESPSFDCQI-15936
* Purpose 1    : Batch to Send Email To Opportunity Owner where Opportunity Owner's Country is in EMEA/Latin America Region and the Opportunity have CloseDate Before This Quarter with Stage 1 to 5.
* Purpose 2    : Batch to Send Email To Opportunity Owner where Opportunity Owner's Profile is RWS User and the Opportunity have CloseDate Before This Quarter with Stage 1 to 5.
*/
global class BCH_CRM_sendEmailToOppOwner implements Database.Batchable<sObject> {
    
    String query = null;
    public BCH_CRM_sendEmailToOppOwner() {        
    }   
    
    public BCH_CRM_sendEmailToOppOwner(String query) {
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
            return Database.getQueryLocator([Select id from User Where ((Region__c IN ('Europe/Middle East/Africa EMEA','Latin America') AND Profile.Name IN ('Sales User','Commercial Operations User','Marketing User IQVIA','GMI User')) OR Profile.Name = 'RWS User') and IsActive = true]);
        }
    }
    /*
     * Execute method 
     * @params  Database.BatchableContext context
     * 
    */
    global void execute(Database.BatchableContext bc,List<User> userList) {
        
        List<Opportunity> OppList = [Select OwnerId,id,Name,Owner.Name,Owner.LocaleSidKey,Owner_Email__c,Opportunity_Number__c, StageName, CloseDate,CreatedDate,Owner.Region__c,CurrencyIsoCode,Amount,Gross_Quarterly_Impact__c,Next_Quarterly_Impact__c from Opportunity where OwnerId IN : userList AND StageName In ('1. Identifying Opportunity','2. Qualifying Opportunity','3. Developing Proposal','4. Delivering Proposal','5. Finalizing Deal')  And CloseDate < THIS_QUARTER AND In_Hand_Stage_Entry__c = null ];
        Map<Id,List<Opportunity>> userToOppMap = new Map<Id,List<Opportunity>>();
        For(Opportunity opp : OppList){
            if(!userToOppMap.containsKey(opp.OwnerId)){
                userToOppMap.put(opp.OwnerId,new List<Opportunity>());
            }
            userToOppMap.get(opp.OwnerId).add(opp);
        }
        if(userToOppMap.size() > 0){
            
            List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
            for(Id op : userToOppMap.keyset()){
                Integer i = 1 ;
                String ownersName = '';
                String emailBody = '';
                String subject = '';
                String dateStr = '';
                String localFormat = '' ;
                List<Opportunity> opp = userToOppMap.get(op);
                if(opp.Size() > 0){
                    localFormat = UTL_CRM.getDateFormatFromLocale(opp[0].Owner.LocaleSidKey);
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.toEmails = new List<String>{opp[0].Owner_Email__c};
                    subject = 'Please update expected closed date and revenue schedule date on each Opportunity (product) given below';
                    emailBody = ' Please update expected closed date and revenue schedule date on each Opportunity (product) given below.<br/><br/>';
                    emailBody += 'Any questions, please contact your local commercial operations contact<br/><br/>';
                    emailBody += '<table cellspacing="2" cellpadding="3" width="720" align="center" border="1">';     
                    emailBody += '<tr style="text-align:center;border: 0.1px solid black;"><th> # </th><th> Opportunity Number </th><th> Opportunity Name </th><th> Stage </th><th> Expected Close Date </th><th> Amount </th><th> Opportunity Gross Quarterly Impact </th><th> Next Quarterly Impact </th><th> Link of Opportunity </th><tr>'; 
                    for(Opportunity opps : opp){
                        dateStr = '';
                        DateTime dt = Date.valueOf(opps.CloseDate);
                        String amt ;
                        amt = opps.CurrencyIsoCode + ' '+ String.Valueof(opps.Amount);
                        String GQI;
                        String NQI;
                        GQI = opps.CurrencyIsoCode + ' '+String.Valueof(opps.Gross_Quarterly_Impact__c);
                        NQI = opps.CurrencyIsoCode + ' '+ String.Valueof(opps.Next_Quarterly_Impact__c);
                        if(localFormat != ''){
                            dateStr = dt.format(localFormat);
                        }else
                        {
                            dateStr = String.valueOf(opps.CloseDate);
                        }
                        emailBody += '<tr style="text-align:left;border: 0.1px solid black;"><td>'+ i +'</td><td>' + opps.Opportunity_Number__c +'</td><td>'+ opps.Name +'</td><td>'+ opps.StageName +'</td><td>'+ dateStr + '</td><td>' + amt + '</td><td>' + GQI + '</td><td>' + NQI + '</td><td>' + '<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+opps.Id+'">'+opps.Name+'</a><br/>' +'</td></tr>';
                        i++;
                    }
                    emailBody +='</table>';
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
    
    /*
    * To send emails on exception. This method is called after all batches are processed.
    */
    global void finish(Database.BatchableContext BC) {  
        
    }
}