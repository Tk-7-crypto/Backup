/**
* This test class is used to test all methods in UTL_CRM_OpportunityRenewalTestData.
* version : 1.0
*/
@isTest
private class TST_UTL_CRM_OpportunityRenewalTestData {
    
    /**
    * This method is testing all StageName constant in CON_CRM
    */
    static testMethod void testGeneralMethods() {
        
        Account testAcc = UTL_CRM_OpportunityRenewalTestData.setupAccount('Detail Controller Account');
        List<Opportunity> oppList = UTL_CRM_OpportunityRenewalTestData.setupOpportunity(testAcc , 1);
        Test.startTest();
        Product2 prod = UTL_CRM_OpportunityRenewalTestData.getProdRecord();
        PricebookEntry PE1 = UTL_CRM_OpportunityRenewalTestData.getPbEntryRecord(prod);
        List<Renewal_Task__c> rtList = UTL_CRM_OpportunityRenewalTestData.setupRenewalTasks(testAcc , 1);
        Test.stopTest(); 
    }
}