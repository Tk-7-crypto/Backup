/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-17772
* Purpose 1    : Batch to Send Email To Opportunity Owner where Opportunity Owner's Profile Sales/RDS user and Their Opportunity is on Stage = 7b closed lost with Loss Type = 'Loss details to be confirmed'.
*/
global class BCH_CRM_SendEmailLostfor30days implements Database.Batchable<Sobject>,Database.RaisesPlatformEvents {
    
    String query = null;
    public BCH_CRM_SendEmailLostfor30days() {        
    }   
    
    public BCH_CRM_SendEmailLostfor30days(String query) {
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
     * 
    */
    global void execute(Database.BatchableContext bc,List<User> userList) { 
        List<Opportunity> userToOpportunityList = [Select id,Name,OwnerId,Owner.Name,Legacy_Quintiles_Opportunity_Number__c,AccountId,Account.Name,Lost_Date__c,Loss_Type__c,StageName,Owner_Email__c,Owner.IsActive,Last_Modified_By_USER__r.Email from Opportunity where StageName = '7b. Closed Lost' AND X7b_Closed_Lost_Stage_Entry__c =: Date.Valueof(System.today().addDays(-30)) AND OwnerId IN : userList AND Loss_Type__c = 'Loss details to be confirmed' AND Line_of_Business__c IN ('Clinical','Clinical Technology','Connected Devices','Data Sciences','Early Clinical Development','Patient & DCT Solutions','Regulatory & Drug Development Solutions','Safety & Med Info')];
        Map<id,List<Opportunity>> userToOpportunityMap = new Map<id,List<Opportunity>>();
        
        if(userToOpportunityList.size() > 0){
            For(Opportunity opp : userToOpportunityList){
                if(!userToOpportunityMap.containsKey(opp.OwnerId)){
                    userToOpportunityMap.put(opp.OwnerId,new List<Opportunity>());
                }
                userToOpportunityMap.get(opp.OwnerId).add(opp);
            }
        }
        
         if(userToOpportunityMap.size() > 0){
            
            List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
            
            for(Id op : userToOpportunityMap.keyset()){
                Integer i = 1 ;
                String emailBody = '';
                String subject = '';
                List<Opportunity> opp = userToOpportunityMap.get(op);
                if(opp.Size() > 0){
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    if(opp[0].Owner.IsActive){
                        message.toEmails = new List<String>{opp[0].Owner_Email__c};
                    }else{
                        message.toEmails = new List<String>{opp[0].Last_Modified_By_USER__r.Email};
                    }
                    subject = 'Opportunity Loss details require updating';
                    emailBody = 'Dear '+ opp[0].Owner.Name +'<br/><br/>';
                    emailBody += 'Please can you review the following opportunity(s) and update the Loss details with correct Loss details.<br/><br/>';
                    emailBody += '<table cellspacing="2" cellpadding="3" width="720" align="center" border="1">';     
                    emailBody += '<tr style="text-align:center;border: 0.1px solid black;"><th> Legacy Quintiles Opportunity Number </th><th> Account Name </th><th> Opportunity Name </th><th> Opportunity Stage </th><th> Loss Type </th><th> Loss Date </th><tr>'; 
                    for(Opportunity opps : opp){
                        emailBody += '<tr style="text-align:left;border: 0.1px solid black;"><td>'+ (opps.Legacy_Quintiles_Opportunity_Number__c == Null ? '' : opps.Legacy_Quintiles_Opportunity_Number__c) +'</td><td>'+ '<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+opps.AccountId+'">'+opps.Account.Name+'</a>' +'</td><td>'+ '<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+opps.Id+'">'+opps.Name+'</a>'+'</td><td>'+ opps.StageName +'</td><td>'+ opps.Loss_Type__c + '</td><td>'+ String.valueOf(opps.Lost_Date__c) +'<br/></td></tr>';
                    }
                    emailBody +='</table> <br/><br/>';
                    emailBody += 'Thank You';
                    CRM_Config__c csSetting = CRM_Config__c.getOrgDefaults();
                    if(String.isNotBlank(csSetting.Closed_Lost_Opportunity_Email_Recipient__c)){
                        message.ccEmails = new List<String>{csSetting.Closed_Lost_Opportunity_Email_Recipient__c};   
                    }
                    message.subject = subject;
                    message.staticContent = emailBody;
                    messageList.add(message);
                }
            }
            
            if(messageList.size()>0){
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