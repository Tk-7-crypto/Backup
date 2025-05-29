public class DAOH_TPAMasterExtensionInformation { 
    public static void onBeforeUpdate(List<TPA_Master_Extension_Information__c> newRecords, List<TPA_Master_Extension_Information__c> oldRecords, Map<Id, TPA_Master_Extension_Information__c> newMap, Map<Id, TPA_Master_Extension_Information__c> oldMap) {
        TGRH_TPAMasterExtensionInformation.onBeforeUpdate(newRecords,oldRecords,newMap,oldMap);
    }

    public static void onAfterUpdate(List<TPA_Master_Extension_Information__c> newRecords, List<TPA_Master_Extension_Information__c> oldRecords, Map<Id, TPA_Master_Extension_Information__c> newMap, Map<Id, TPA_Master_Extension_Information__c> oldMap) {
        if(!TGRH_TPARequest.isOnHoldFieldUpdate) {
            TGRH_TPAMasterExtensionInformation.updatePendingTPARequests(newRecords,oldRecords,newMap,oldMap);
        }
    }
}