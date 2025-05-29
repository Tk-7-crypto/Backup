/**
* This class is used to test TGR_Revenue_Analyst Trigger
*/ 
@isTest
private class TST_TGR_Revenue_Analyst {
    
    static testMethod void testRevenueAnalyst() {
        Test.startTest();
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        revenueAnalyst.Name='SAPRAUser, Test1';
        update revenueAnalyst;
        revenueAnalyst = [SELECT Id, Name FROM Revenue_Analyst__c LIMIT 1];
        System.assertEquals('SAPRAUser, Test1', revenueAnalyst.Name);
        Test.stopTest();
    }
}