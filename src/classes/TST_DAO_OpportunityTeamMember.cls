/**
 * This class is used to Test DAO_OpportunityTeamMember class
 */ 
@isTest
private class TST_DAO_OpportunityTeamMember {

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
     * This method is used to test OpportunityTeamMember before delete
     */ 
    @isTest
    private static void test() {
        User user = [SELECT Id FROM USER WHERE LastName = 'lastName123' LIMIT 1];
        List<OpportunityTeamMember> otmList = [SELECT ID, OpportunityId, UserId FROM OpportunityTeamMember WHERE UserId = :user.Id];
        Test.startTest();
        try {   
            delete otmList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Cannot remove PA team member from Opportunity with PA products'));
        }
        Test.stopTest();
    }
}