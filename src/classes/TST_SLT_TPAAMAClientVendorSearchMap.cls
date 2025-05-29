@isTest(seeAllData = false)
public class TST_SLT_TPAAMAClientVendorSearchMap {
    @isTest
    static void testSLT_TPAAMAClientVendorSearchMap() {
        String condition = 'AMA_Account_Search_Text__c = \'test\'';
        SLT_TPAAMAClientVendorSearchMap.instance.getTPAAMAClientVendorSearchMapDataByCondition(condition);
    }
    
}