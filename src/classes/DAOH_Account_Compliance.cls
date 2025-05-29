public class DAOH_Account_Compliance {
	static TGRH_Account_Compliance triggerHelper = new TGRH_Account_Compliance();
    
    public static void onBeforeInsert(List<Account_Compliance__c> newRecordsToInsert){
        triggerHelper.onBeforeInsert(newRecordsToInsert);
    }
    
    public static void onBeforeUpdate(List<Account_Compliance__c> newRecords, List<Account_Compliance__c> oldRecords, Map<Id, Account_Compliance__c> newMap, Map<Id, Account_Compliance__c> oldMap) {
    	triggerHelper.onBeforeUpdate(newRecords, oldRecords, newMap, oldMap);
    }

    public static void onAfterUpdate(List<Account_Compliance__c> newRecords, List<Account_Compliance__c> oldRecords, Map<Id, Account_Compliance__c> newMap, Map<Id, Account_Compliance__c> oldMap) {
    	triggerHelper.onAfterUpdate(newRecords, oldRecords, newMap, oldMap);
    }
    
    public static void onAfterInsert(List<Account_Compliance__c> newRecords) {
        triggerHelper.onAfterInsert(newRecords);
    }    
}