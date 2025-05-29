/*
 * Version       : 1.0
 * Description   : Batch Class 
 */
public class BCH_CRM_Unsigned_Contract_Alert implements Database.Batchable<Sobject>, Database.stateful {
    
    Unsigned_Contract_Alert__c unsignedSettings;
    Date dtContractExecActualExpected;
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        unsignedSettings = Unsigned_Contract_Alert__c.getOrgDefaults();
        dtContractExecActualExpected = System.today() - Integer.valueOf(unsignedSettings.Days_Before_Signature_Alert__c);
        return Database.getQueryLocator([SELECT Id, IQVIA_Project_Manager_Contact__c, IQVIA_Project_Finance_Manager__c, IQVIA_Project_Manager_Contact__r.Email, IQVIA_Project_Finance_Manager__r.Email, Contract_Execution_Date_Actual_Expected__c FROM Contract
                                         WHERE Contract_Execution_Date_Actual_Expected__c != null AND Contract_Execution_Date_Actual_Expected__c =: dtContractExecActualExpected AND Migration_Status__c = NULL]);
    }
    
    /**
     * execute method 
     * @params  Database.BatchableContext context
     * @params  List<Contract> records
     * @return  void
     */
    public void execute(Database.BatchableContext context, List<Contract> contractList) {
        List<EmailTemplate> emailTemplateList = [Select id from EmailTemplate where DeveloperName = 'CTR_ET01_CRM_Contracts_Unsigned_Contracts_Alert'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage singleEmail  = null;
        List<String> emailToSentList = null;
        if(emailTemplateList.size() > 0 ) {
            for(Contract cntrt : contractList) {
                emailToSentList = new List<String>();
                if(cntrt.IQVIA_Project_Manager_Contact__r.Email != null)
                    emailToSentList.add(cntrt.IQVIA_Project_Manager_Contact__r.Email);
                if(cntrt.IQVIA_Project_Finance_Manager__r.Email != null)
                    emailToSentList.add(cntrt.IQVIA_Project_Finance_Manager__r.Email);
                if(emailToSentList.size() > 0) {
                    singleEmail = new Messaging.SingleEmailMessage();
                    singleEmail.setToAddresses(emailToSentList);
                    singleEmail.setTargetObjectId(cntrt.IQVIA_Project_Manager_Contact__c);
                    singleEmail.setTreatTargetObjectAsRecipient(false);
                    singleEmail.setWhatId(cntrt.Id);
                    singleEmail.setTemplateId(emailTemplateList[0].Id);
                    emailList.add(singleEmail);
                }
            }
        }
        if(emailList.size() > 0) {
            try{
                Messaging.sendEmail(emailList);
            } catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
        }
            
    }
    
    /**
     * finish method 
     * @params  Database.BatchableContext context
     * @return  void
     */
    public void finish(Database.BatchableContext context) {
       
    }
}