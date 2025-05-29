@isTest(SeeAllData=false)

public class TST_CNT_TPA_AccountOnHoldReport {
    @TestSetup
    static void setupTestData(){
        Account acc = new Account(Name = 'TestAccount',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        Account_Compliance__c accComp = new Account_Compliance__c(Account__c = acc.Id,Vendor_TPA_Compliance_Hold__c=true, Vendor_TPA_Compliance_Hold_Date__c = Date.today());
        insert accComp;
    }
    
    @isTest
    public static void testGetComplianceHoldData() {
        Test.StartTest();
        System.debug(CNT_TPA_AccountOnHoldReport.baseURL());
        List<Account_Compliance__c> testData = CNT_TPA_AccountOnHoldReport.getComplianceHoldData('ASC');
        Assert.areEqual(testData.size(), 1, 'Unable to fetch data');
        Test.stopTest();
    }
}