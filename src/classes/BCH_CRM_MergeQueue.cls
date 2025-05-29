/*
 * Version       : 1.0
 * Description   : This Batch Apex class is selector layer for Account
 */
public class BCH_CRM_MergeQueue  implements Database.Batchable<Sobject> , Database.Stateful  {
    
    @TestVisible List<String> exception_List;
    
    /**
     * Constructor
     */
    public BCH_CRM_MergeQueue() {
      exception_List = new List<String>();
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        //list of all accounts to be merged
        return Database.getQueryLocator([SELECT MasterRecordId__c, Dupe_Id_1__c, Dupe_Id_2__c, LI_AccountId__c, LQ_AccountId__c,  Masterrecordid__r.lq_Account_id__c, Masterrecordid__r.Li_Account_id__C, Merge_Error_message__c FROM Merge_Queue__c where Sobjecttype__c = 'Account' and Merge_status__c = 'Pending' and MasterRecordId__c != '' and (Dupe_Id_1__c != '' or Dupe_Id_2__c != '')]);
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public void execute(Database.BatchableContext context, List<Merge_Queue__c> records) {
        List<Account> updatedAccountList = new List<Account>();
        set<Id> masterAccoutSet = new set<Id>();
        set<Id> duplicateAccountSet = new set<Id>();
        for(Merge_Queue__c record : records) {
            if(record.MasterRecordId__c != null) {
                masterAccoutSet.add(record.MasterRecordid__C);
            }
            if(!String.isBlank(record.Dupe_id_1__c)) {
                duplicateAccountSet.add(record.Dupe_id_1__c); 
            }            
            if(!String.isBlank(record.Dupe_id_2__c)) {
                duplicateAccountSet.add(record.Dupe_id_2__c);
            }    
        }
        Map<Id, Account> masterAccountMap = new Map<Id, Account>([select Id, lq_account_id__c, li_account_id__c from Account where Id in :masterAccoutSet]);
        
        Map<Id, Account> duplicateAccountMap = new Map<Id, Account>([select id, lq_account_id__c, li_account_id__c from Account where Id in :duplicateAccountSet]);  
        try {
            for(Merge_Queue__c record : records) { 
                List<Account> duplicateList = new List<Account>();
                if(!String.isBlank(record.Dupe_id_1__c)) {
                    duplicateList.add(duplicateAccountMap.get(record.Dupe_id_1__c));
                }
                if(!String.isBlank(record.Dupe_id_2__c)) {
                    duplicateList.add(duplicateAccountMap.get(record.Dupe_id_2__c));  
                }
                if(duplicateList.size() > 0 ) {
                    Database.MergeResult[] results = Database.merge(new Account(Id = record.MasterRecordId__c), duplicateList, false);
                    for(Database.MergeResult res : results) {
                        if(res.isSuccess()) {
                            record.Merge_status__c = 'Completed';
                            Account acc = masterAccountMap.get(record.MasterrecordId__C);
                            //if survivor account has balnk LQ_account_id__C and any of du account has a valid lq_account_id__C
                            if(String.isBlank(record.masterrecordid__r.lq_Account_id__c) && !String.isBlank(record.lq_Accountid__c)) {
                                acc.lq_Account_id__c = record.lq_Accountid__c;
                            }
                            //if survivor account has balnk LI_account_id__C and any of dup account has a valid li_account_id__C
                            if(String.isBlank(record.Masterrecordid__r.li_Account_id__c) && !String.isBlank(record.li_Accountid__c)) {
                                acc.li_Account_id__c = record.li_Accountid__c;
                            }
                            updatedAccountList.add(acc);
                        }
                        else {
                            record.Merge_status__c = 'Failed';
                            for(Database.Error err : res.getErrors()) {
                                record.Merge_Error_message__c += err;
                            }
                        }
                    }
                } 
                
            } 
            if(updatedAccountList.size() > 0) {
                update updatedAccountList;
            }
            update records;
        }
        catch(Exception ex) {
            exception_List.add(ex.getmessage()); 
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if(exception_List.size() > 0){
            sendMailOnException(exception_List);
        }
    }
    
    /*
     * To send emails
     */
   @TestVisible    
    private void sendMailOnException(List<String> exception_List) {
        String BodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Account_Setting__c accSetting = Account_Setting__c.getOrgDefaults();
        String emails = accSetting.Exception_Email_Notifier__c;
        List<String> exceptionEmailList = emails.split(':');        
        String[] toAddresses = exceptionEmailList;
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);       
        BodyText = '';
        mail.setSubject('\nExceptions were thrown in Batch Class BCH_CRM_MergeQueue');                       
        BodyText += '============== Exception ==============\n';
        for(String exp : exception_List){              
            BodyText += exp;      
        }               
        mail.setPlainTextBody(BodyText);   
        if(!Test.isRunningTest()) {  
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }       
    }
}