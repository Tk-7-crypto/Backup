public class DAOH_TPADataAsset {
    static TGRH_TPADataAsset triggerHelper = new TGRH_TPADataAsset();

    public static void onBeforeUpdate(List<TPA_Data_Asset__c> newRecords, List<TPA_Data_Asset__c> oldRecords, Map<Id, TPA_Data_Asset__c> newMap, Map<Id, TPA_Data_Asset__c> oldMap) {
        triggerHelper.onBeforeUpdate(oldRecords, newRecords, oldMap, newMap);
    }

    public static void onBeforeDelete(List<TPA_Data_Asset__c> oldRecords, Map<Id, TPA_Data_Asset__c> oldMap) {
        triggerHelper.onBeforeDelete(oldRecords, oldMap); 
    }

    // public static void onAfterUpdate(List<TPA_Data_Asset__c> newRecords, List<TPA_Data_Asset__c> oldRecords, Map<Id, TPA_Data_Asset__c> newMap, Map<Id, TPA_Data_Asset__c> oldMap) {
    //     triggerHelper.onAfterUpdate(oldRecords, newRecords, oldMap, newMap);
    // }

    // public static void onAfterDelete(List<TPA_Data_Asset__c> oldRecords) {
    //     triggerHelper.onAfterDelete(oldRecords);
    // }
}