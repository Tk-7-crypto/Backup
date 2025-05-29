@isTest
private class TST_DAOH_TPAAMAClientVendorSearchMap {
    static testMethod void myUnitTest() {
        List<TPA_AMA_Client_Vendor_Search_Map__c> record = new List<TPA_AMA_Client_Vendor_Search_Map__c>{UTL_TPA_SetupTestData.getTpaAmaClientVendSearchMap()};
        insert record;
        update record;
    }
}