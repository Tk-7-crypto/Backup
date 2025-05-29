/*
 * Author		: 
 * Purpose		: Batch to maintain Revenue Analyst Users according to Queue
 */
global class BCH_CRM_RevenueAnalystSBSQueueSync implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    String emailAddress;
    @TestVisible List<String> exception_List;
    String exceptionMsg ; 
    Static String EMAIL_SUBJECT = '\nExceptions were thrown in BCH_CRM_RevenueAnalystSBSQueueSync';
    Static String EMAIL_BODY_TEXT = '============== Exception ==============\n';
   
    public BCH_CRM_RevenueAnalystSBSQueueSync() {
    	exception_List = new List<String>();
    }
    
    /*
     * To instantiate the Database.QueryLocator object
     */    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        emailAddress = BNF_Settings__c.getInstance().Revenue_Analyst_Exception_Email__c; 
        String query = 'Select id From Revenue_analyst__c where owner.type = \'Queue\' ';
        return Database.getQueryLocator(query);
    }
    
    /*
     * process each batch of records
     */
    global void execute(Database.BatchableContext bc, List<Revenue_analyst__c> revenueAnalystList){
        try {
            update revenueAnalystList;
        } catch(Exception e) {
            exceptionMsg = '\nBCH_CRM_RevenueAnalystSBSQueueSync ' + '\n';
            exception_List.add(exceptionMsg);
            exception_List.add(e.getmessage()); 
        }       
    }
    
    /*
     * To send emails on exception. This method is called after all batches are processed.
     */
    global void finish(Database.BatchableContext BC) {  
        if(exception_List.size() > 0){
            sendMailOnException(exception_List);
        }
    }

    /*
     * To send emails
     */    
    private void sendMailOnException(List<String> exception_List){
        String BodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
        String[] toAddresses = new String[] {emailAddress}; 
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);       
        BodyText = '';
        mail.setSubject(EMAIL_SUBJECT);                       
        BodyText += EMAIL_BODY_TEXT; 
        for(String exp : exception_List){              
            BodyText += exp;      
        }               
     
        mail.setPlainTextBody(BodyText);   
        if(!Test.isRunningTest()) {  
            if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
                try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } catch(Exception e) {
                    System.debug('Email Failed: ' + e.getMessage());
                }
            }
        }       
    }
    
    //To handle BCH_CRM_RevenueAnalystSBSQueueSync Exception 
    public class RevenueAnalystSBSQueueSyncException extends Exception {}    
}