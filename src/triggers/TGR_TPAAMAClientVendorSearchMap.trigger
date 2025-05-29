trigger TGR_TPAAMAClientVendorSearchMap on TPA_AMA_Client_Vendor_Search_Map__c (after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TPAAMAClientVendorSearchMap.class);
}