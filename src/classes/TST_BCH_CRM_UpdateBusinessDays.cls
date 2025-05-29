/**
 * This test class is used to test SCH_CRM_OpportunityStage
 * version : 1.0
 */
@isTest
private class TST_BCH_CRM_UpdateBusinessDays {
    
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
        cntrt.Specific_Contract_Type__c = 'Master Independent Contractor Agreement';
        cntrt.ContractTerm = 12;
        insert cntrt;
    }
    
    /**
    * This method used to get User Metric By Id
    */    
    @IsTest
    static void testUpdateBusinessDays() {
        Contract cnt = [select id , Initial_revenue_captured__c from Contract];
        System.debug(cnt.Initial_revenue_captured__c);
        Test.startTest();
            String cronExp = '0 0 13 * * ?';
            String jobId = System.schedule('testBasicScheduledApex', cronExp, new SCH_CRM_UpdateBusinessDays());
            Database.executeBatch(new BCH_CRM_UpdateBusinessDays());
        Test.stopTest();
    }
}