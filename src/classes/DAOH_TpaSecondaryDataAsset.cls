public class DAOH_TpaSecondaryDataAsset {

	static TGRH_TPASecDataAsset triggerHelper = new TGRH_TPASecDataAsset();
    
    public static void onAfterInsert(List<TPA_Secondary_Data_Asset__c> newRecords) {
        triggerHelper.onAfterInsert(newRecords);
    }
    
    public static void onBeforeDelete(List<TPA_Secondary_Data_Asset__c> oldRecords, Map<Id, TPA_Secondary_Data_Asset__c> oldMap) {
        triggerHelper.onBeforeDelete(oldRecords, oldMap);
    }
}