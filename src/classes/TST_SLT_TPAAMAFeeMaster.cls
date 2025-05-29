@isTest(seeAllData = false)
public class TST_SLT_TPAAMAFeeMaster {
    @isTest
    static void testSLT_TPAAMAContractsAttachments() {
        SLT_TPAAMAFeeMaster.instance.selectByFilter(new Set<String>(), 'year__c = \'2019\' ', 'CreatedDate');
    }
}