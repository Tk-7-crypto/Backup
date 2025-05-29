public class DAOH_TPA_IMSDataAsset {

    static TGRH_TPA_IMSDataAsset triggerHelper = new TGRH_TPA_IMSDataAsset();
    
    public static void onAfterUpdate(List<IMS_Data_Asset__c> newRecords, List<IMS_Data_Asset__c> oldRecords, Map<Id, IMS_Data_Asset__c> newMap, Map<Id, IMS_Data_Asset__c> oldMap) {
        triggerHelper.onAfterUpdate(oldRecords, newRecords, oldMap, newMap);
    }

}
