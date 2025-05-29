/*
* Author       : Balkrishan Gohil
* Story        : ESPSFDCQI-17052
* Purpose 1    : Batch to Send Email To Opportunity Owner where Opportunity is on Stage = 7B. Closed Lost And have FPI Date > Today + 6 Months .
*/
global class BCH_CRM_SendEmailToClosedOpp implements Database.Batchable<Sobject>,Database.Stateful {
    
    private Date highestFpiDate ;
    private DateTime recentLastModifiedDate;
    
    String query = null;
    public BCH_CRM_SendEmailToClosedOpp() {        
    }   
    
    public BCH_CRM_SendEmailToClosedOpp(String query) {
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
        Date opp_FPI_Date = CRM_Config__c.getOrgDefaults().Opportunity_FPI_date__c ;
        DateTime opp_Latest_Opp_Modified_Date = CRM_Config__c.getOrgDefaults().Opportunity_Last_Modified_Date__c ;
        if(highestFpiDate == Null){
            highestFpiDate = CRM_Config__c.getOrgDefaults().Opportunity_FPI_date__c;
        }
        if(recentLastModifiedDate == Null){
            recentLastModifiedDate = CRM_Config__c.getOrgDefaults().Opportunity_Last_Modified_Date__c ;
        }
        
        List<Opportunity> userToOppList = new List<Opportunity>();
        Map<Id,List<Opportunity>> userToOppMap = new Map<Id,List<Opportunity>>();
        if(opp_FPI_Date == Null || opp_Latest_Opp_Modified_Date == Null){
            userToOppList = [Select id,FPI_Date__c,LastModifiedDate,Account.Name,Name,Legacy_Quintiles_Opportunity_Number__c,StageName,Owner_Email__c,Owner.Name from Opportunity where StageName = '7b. Closed Lost' AND OwnerId IN : userList AND Line_of_Business__c in ('Clinical','Early Clinical Development','Data Sciences','Safety & Med Info','Patient & DCT Solutions','Regulatory & Drug Development Solutions') AND Loss_Type__c NOT IN ('Operational Cleaning','Duplicate Opportunity') AND FPI_Date__c > NEXT_N_DAYS:180];
        }
        if(opp_FPI_Date != Null && opp_Latest_Opp_Modified_Date != Null){
            userToOppList = [Select id,FPI_Date__c,LastModifiedDate,Account.Name,Name,Legacy_Quintiles_Opportunity_Number__c,StageName,Owner_Email__c,Owner.Name from Opportunity where StageName = '7b. Closed Lost' AND OwnerId IN : userList AND Line_of_Business__c in ('Clinical','Early Clinical Development','Data Sciences','Safety & Med Info','Patient & DCT Solutions','Regulatory & Drug Development Solutions') AND Loss_Type__c NOT IN ('Operational Cleaning','Duplicate Opportunity') AND FPI_Date__c > :opp_FPI_Date AND LastModifiedDate > :opp_Latest_Opp_Modified_Date AND FPI_Date__c > NEXT_N_DAYS:180];
        }

        if(userToOppList.size() > 0){
            For(Opportunity opp : userToOppList){
                if(!userToOppMap.containsKey(opp.OwnerId)){
                    userToOppMap.put(opp.OwnerId,new List<Opportunity>());
                }
                userToOppMap.get(opp.OwnerId).add(opp);
            }
        }
        
        if(userToOppMap.size() > 0){
            
            List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
            
            for(Id op : userToOppMap.keyset()){
                Integer i = 1 ;
                String emailBody = '';
                String subject = '';
                List<Opportunity> opp = userToOppMap.get(op);
                if(opp.Size() > 0){
                    UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                    message.toEmails = new List<String>{opp[0].Owner_Email__c};
                    subject = 'Opportunity review - Study Progress';
                    emailBody = 'Dear '+ opp[0].Owner.Name +'<br/><br/>';
                    emailBody += 'It is important that we follow up with Customers regarding the opportunities listed below, based on their upcoming FPI date. Please inquire about the progress of the study and offer any assistance that IQVIA can provide to ensure its success. By checking in with the customer, we can demonstrate our commitment to their project, even though it has been lost or stopped and build a stronger relationship with them. Approach the follow-up with a proactive and collaborative mindset, seeking to understand their needs and offering solutions that align with their goals. By doing so, we can position ourselves as a trusted partner and increase the like likelihood of future business opportunities.<br/><br/>';
                    emailBody += '<table cellspacing="2" cellpadding="3" width="720" align="center" border="1">';     
                    emailBody += '<tr style="text-align:center;border: 0.1px solid black;"><th> # </th><th> Account Name </th><th> Opportunity Name </th><th> Legacy Quintiles Opportunity Number </th><th> Opportunity Stage </th><th> FPI Date (DD-MM-YYYY) </th><tr>'; 
                    for(Opportunity opps : opp){
                        if(highestFpiDate == Null){
                            highestFpiDate = opps.FPI_Date__c;
                        }else{
                            highestFpiDate = highestFpiDate < opps.FPI_Date__c ? opps.FPI_Date__c : highestFpiDate ;
                        }
                        if(recentLastModifiedDate == Null){
                            recentLastModifiedDate = opps.LastModifiedDate;
                        }else{
                            recentLastModifiedDate = recentLastModifiedDate < opps.LastModifiedDate ? opps.LastModifiedDate : recentLastModifiedDate ;
                        }
                        DateTime dt = Date.valueOf(opps.FPI_Date__c);
                        String fpiDate = dt.format('dd-MM-YYYY');
                        emailBody += '<tr style="text-align:left;border: 0.1px solid black;"><td>'+ i +'</td><td>' + opps.Account.Name +'</td><td>'+ '<a href="'+URL.getOrgDomainURL().toExternalForm()+'/'+opps.Id+'">'+opps.Name+'</a>'+'</td><td>'+ opps.Legacy_Quintiles_Opportunity_Number__c +'</td><td>'+ opps.StageName + '</td><td>' + fpiDate + '<br/></td></tr>';
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
        CRM_Config__c crmConfigCS = CRM_Config__c.getOrgDefaults();
        if(highestFpiDate != Null){
            crmConfigCS.Opportunity_FPI_date__c = highestFpiDate;
        }
        if(recentLastModifiedDate != Null){
            crmConfigCS.Opportunity_Last_Modified_Date__c = recentLastModifiedDate;   
        }       
        Upsert crmConfigCS CRM_Config__c.Id;
    }
}