@isTest
public class TST_DAOH_OpportunitySplit {
    
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
    }
    
    @isTest
    private static void testvalidateOppSplit() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<User> userList = UTL_TestData.createUser('Sales User', 1);
        insert userList;
        
        Test.startTest();
        try {
            Id splitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
            OpportunitySplit otm = UTL_TestData.createOpportunitySplit(opp.Id, userList[0].Id, splitTypeId);
            insert otm;
        } catch (Exception ex) {}
        Test.stopTest();
    }
}