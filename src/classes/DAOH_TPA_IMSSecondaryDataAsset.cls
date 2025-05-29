public class DAOH_TPA_IMSSecondaryDataAsset {
    static TGRH_TPA_IMSSecondaryDataAsset triggerHelper = new TGRH_TPA_IMSSecondaryDataAsset();
    
    public static void onAfterUpdate(List<IMS_Secondary_Data_Asset__c> newRecords, List<IMS_Secondary_Data_Asset__c> oldRecords, Map<Id, IMS_Secondary_Data_Asset__c> newMap, Map<Id, IMS_Secondary_Data_Asset__c> oldMap) {
        triggerHelper.onAfterUpdate(oldRecords, newRecords, oldMap, newMap);
    }

}