/**
 * This test class is used to test SCH_CRM_UpdateBusinessDays
 * version : 1.0
 */
@isTest
private class TST_SCH_CRM_UpdateBusinessDays {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
        Contract cntrt = new Contract();
        cntrt.AccountId = acc.Id;
        cntrt.Status = 'Activated';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        insert cntrt;
    }
    
    /**
    * This method used to get User Metric By Id
    */    
    @IsTest
    static void testUpdateBusinessDays() {
        Contract cnt = [select id , Initial_revenue_captured__c from Contract];
        Test.startTest();
            String cronExp = '0 0 13 * * ?';
            String jobId = System.schedule('testBasicScheduledApex', cronExp, new SCH_CRM_UpdateBusinessDays());
        Test.stopTest();
    }
}