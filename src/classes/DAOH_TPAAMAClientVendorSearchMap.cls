public class DAOH_TPAAMAClientVendorSearchMap {

    public static void onAfterInsert(List<TPA_AMA_Client_Vendor_Search_Map__c> newRecords) {
        TGRH_TPAAMAClientVendorSearchMap.updateAMAAccountFlagOnAccount(newRecords, null);
        TGRH_TPAAMAClientVendorSearchMap.removeNewClientVendorRecords(newRecords);
    }

    public static void onAfterUpdate(List<TPA_AMA_Client_Vendor_Search_Map__c> newRecords, List<TPA_AMA_Client_Vendor_Search_Map__c> oldRecords, Map<Id, TPA_AMA_Client_Vendor_Search_Map__c> newMap, Map<Id, TPA_AMA_Client_Vendor_Search_Map__c> oldMap) {
            TGRH_TPAAMAClientVendorSearchMap.updateAMAAccountFlagOnAccount(newRecords, oldMap);
            TGRH_TPAAMAClientVendorSearchMap.removeNewClientVendorRecords(newRecords);
    }
}