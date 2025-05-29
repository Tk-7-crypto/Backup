@isTest(seeAllData = false)
public class TST_SLT_TPAAMAClientVendorMatch {
    @isTest
    static void testSLT_TPAAMAClientVendorMatch() {
            SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchData('Client_Name__c');
        String condition = 'Client_Name__c = \'test\'';
        SLT_TPAAMAClientVendorMatch.instance.getTPAAMAClientVendorMatchDataByCondition(condition);
    }
    
}