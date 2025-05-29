/**
 * This class is used to Test DAOH_OpportunityTeamMember class
 * Production Deployment Testing 18-10-2019
 */ 
@isTest
private class TST_DAOH_OpportunityTeamMember {

    @testSetup
    private static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.ProductCode = 'Test01';
        insert product;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product.Id);
        insert pbe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        insert oli;
        List<User> userList = UTL_TestData.createUser('Sales User', 1);
        insert userList;
        OpportunityTeamMember otm = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert otm;
        PrivacyAnalyticsProductCode__c papc = new PrivacyAnalyticsProductCode__c();
        papc.Name = 'Test01';
        papc.Product_Code__c = 'Test01';
        insert papc;
    }
    
    /**
     * This method is used to test verifyPrivacyAnalyticsProducts method
     */ 
    @isTest
    private static void testVerifyPrivacyAnalyticsProducts() {
        User user = [SELECT Id FROM USER WHERE LastName = 'lastName123' LIMIT 1];
        List<OpportunityTeamMember> otmList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember WHERE UserId = :user.Id];
        Test.startTest();
        DAOH_OpportunityTeamMember.verifyPrivacyAnalyticsProducts(otmList);
        Test.stopTest();
    }
}