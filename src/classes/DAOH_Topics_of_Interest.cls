/**
* This is Topics_of_Interest trigger handler class.
* version : 1.0
*/
public class DAOH_Topics_of_Interest {
    
    /**
    * This method is used to populate TOI_Unique_ID__c
    * @params List<Topics_of_Interest__C> newList
    * @return void
    */
    public static void populateTOIUniqueId(List<Topics_of_Interest__C> newList,Map<Id, Topics_of_Interest__C> oldMap){
        Set<String> accountIdSet = new Set<String>();
        Set<String> uniqueIdSet = new Set<String>();
        Map<String,String> accountIdToTOIUniqueNameMap = new Map<String,String>();
        Map<String,String> accountIdToNameMap = new Map<String,String>();
        for(Topics_of_Interest__C toi : newList) {
            if(toi.Account__c != null) {
                   accountIdSet.add(toi.Account__c);
            }            
        }
        if(accountIdSet.size() > 0){
            Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,Name from Account where Id in: accountIdSet]);
            for(Id acc : accountMap.keySet()){
                String subName;
                if(accountMap.get(acc).Name.length() >= 5)
                	subName = accountMap.get(acc).Name.substring(0,5)+'%';
                else
                    subName = accountMap.get(acc).Name+'%';
                uniqueIdSet.add(subName);
            }
            for(Topics_of_Interest__c toi : [SELECT Id, Account__c,Account__r.Name,TOI_Unique_ID__c
                                   FROM Topics_of_Interest__C
                				   WHERE TOI_Unique_ID__c like: uniqueIdSet]){
                String initialFiveCharOfAccountName;
                if(toi.Account__r.Name.length() >= 5)
                	initialFiveCharOfAccountName = toi.Account__r.Name.substring(0,5);
                else
                    initialFiveCharOfAccountName = toi.Account__r.Name;                        
                if(accountIdToTOIUniqueNameMap.containsKey(initialFiveCharOfAccountName)) {
                    if(accountIdToTOIUniqueNameMap.get(initialFiveCharOfAccountName) < toi.TOI_Unique_ID__c ) {
                        accountIdToTOIUniqueNameMap.put(initialFiveCharOfAccountName,toi.TOI_Unique_ID__c);
                    }     
                }     
                else{
                     accountIdToTOIUniqueNameMap.put(initialFiveCharOfAccountName,toi.TOI_Unique_ID__c);                    
                }  
            }
            for(Topics_of_Interest__c toi : newList) {              
                String accountNameSubstring;
                if(accountMap.containsKey(toi.Account__c)){
                    accountNameSubstring = accountMap.get(toi.Account__c).Name.substring(0,5);
                }                
                if(accountIdToTOIUniqueNameMap.containsKey(accountNameSubstring) && accountIdToTOIUniqueNameMap.get(accountNameSubstring) != null){
                    Integer lastIndex = accountIdToTOIUniqueNameMap.get(accountNameSubstring).lastIndexOf('-') + 1;
                    Integer uniqueNumber = Integer.valueof(accountIdToTOIUniqueNameMap.get(accountNameSubstring).substring(lastIndex,17))+1;
                    String uniqueNumberString = String.valueOf(uniqueNumber).leftPad(5, '0');
                    toi.TOI_Unique_ID__c = accountNameSubstring+'-TOPIC-'+uniqueNumberString;
                    accountIdToTOIUniqueNameMap.put(accountNameSubstring,toi.TOI_Unique_ID__c);
                }
                else{
                    toi.TOI_Unique_ID__c = accountNameSubstring+'-TOPIC-'+String.valueOf(1).leftPad(5, '0');
                    accountIdToTOIUniqueNameMap.put(accountNameSubstring,toi.TOI_Unique_ID__c);
                }                
            }
        }
    }
    
    /**
    * This method is used to validate Topics_of_Interest fields on insertion and updation.
    * @params List<Topics_of_Interest__C> newList
    * @params Map<Id, PSSF__c> oldMap
    * @return void
    */
    public static void validateTopicsOfInterestFields(List<Topics_of_Interest__c> newList,Map<Id, Topics_of_Interest__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Topics_of_Interest__c toiRec : newList){
               // if(Trigger.isInsert){
                    if(toiRec.Product__c == null || toiRec.Status__c == null || toiRec.Topic_Term__c == null || toiRec.Topic_Category__c == null || toiRec.Search_Variable_in_Data_Source__c == null || toiRec.Type_of_MedDRA_Query__c == null || toiRec.MedDRA_Search_Specifications__c == null || toiRec.Date_Started__c == null || toiRec.Part_of_Additional_RMM__c == null || toiRec.In_RMP__c == null || toiRec.Part_of_Commitment_to_HA__c == null){
                        toiRec.addError('\'Product \',  \'Status\',  \'Topic Term \',  \'Topic Category \',  \'Search Variable in Data Source \',  \'Type of MedDRA Query \',  \'MedDRA Search Specification \',  \'Date Started \',  \'Is Topic part of aRMM? \',  \'Is Topic in RMP \',  \'Part of Commitment to HA? \' fields cannot be empty.'); 
                    }
               // }
                if(toiRec.Topic_Category__c == 'Other (specify)' && toiRec.Other_Topic_Category__c == null ){
                    toiRec.addError('\'Other Topic Category (Specify)\' cannot be empty as \'Other (specify)\' as the Topic Category.');
                }
            	if(toiRec.Search_Variable_in_Data_Source__c != null && toiRec.Search_Variable_in_Data_Source__c.contains('Other (specify)') && toiRec.Other_Search_Variable_in_Data_Source__c == null ){
                    toiRec.addError('\'Other Search Variable in Data Source\' cannot be empty as \'Other (specify)\' as the \'Search Variable in Data Source\'.');
                }
                if(toiRec.Date_Started__c != null && toiRec.Rationale_Started__c == null ){
                    toiRec.addError('\'Rationale Started\' cannot be empty.');
                }
                if(toiRec.Date_Stopped__c != null && toiRec.Rationale_Stopped__c == null ){
                    toiRec.addError(' \'Rationale Stopped\' cannot be empty as the \'Date Stopped\' is present.');
                }
                if(toiRec.Date_Started__c > toiRec.Date_Stopped__c){
                    toiRec.addError(' \'Date Started\' cannot be after the \'Date Stopped\'.');
                }
                if(toiRec.Date_Started__c > Date.today() || toiRec.Date_Stopped__c > Date.today()){
                    toiRec.addError(' \'Date Started\' and \'Date Stopped\' cannot be in the future.');
                }
                if(toiRec.Date_Reminder_Calendar__c < toiRec.Date_Started__c ){
                    toiRec.addError('\'Date Reminder Calendar\' cannot be before the \'Date Started\'.');
                }
                if(toiRec.Date_Reminder_Calendar__c > toiRec.Date_Stopped__c ){
                    toiRec.addError('\'Date Reminder Calendar\' cannot be after the \'Date Stopped\'.');
                }
                if(( toiRec.Document_Link_1__c == null || toiRec.Document_Name_1__c == null ) && toiRec.Date_Started__c != null){
                    toiRec.addError('The status will be marked as active after saving the record, \'Document Name\', \'Document Link\' cannot be empty as the \'Status\' is \'Active\'.');
                }
                if(( toiRec.Document_Link_1__c == null || toiRec.Document_Name_1__c == null ) && toiRec.Date_Stopped__c != null){
                    toiRec.addError('The status will be marked as Completed after saving the record, \'Document Name\', \'Document Link\' cannot be empty as the \'Status\' is \'Completed\'.');
                }
            }  
        }
    }
    public static void autoPopulateTopicsOfInterestFields(List<Topics_of_Interest__c> newList,Map<Id, Topics_of_Interest__c> oldMap){
        for(Topics_of_Interest__c toiRec : newList){
            if(toiRec.Date_Started__c != null && toiRec.Date_Stopped__c == null){
                toiRec.Status__c = 'Active';
            }
            if(toiRec.Date_Started__c != null && toiRec.Date_Stopped__c != null){
                toiRec.Status__c = 'Completed';
            }
        }
    }
    /**
    * This method will insert record in Audit Log on Inserting/Updating PSSF record
    **/
    public static void insertAuditLogOnUpdate(List<Topics_of_Interest__c> updatedList,Map<Id,Topics_of_Interest__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Project Log
    **/
    public static void insertAuditLog(List<Topics_of_Interest__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
} 
