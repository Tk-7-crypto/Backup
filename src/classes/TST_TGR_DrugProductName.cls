@isTest
public class TST_TGR_DrugProductName {
    
    @isTest
    public static void testTrigger() {
        Account ac = UTL_TestData.createAccount();
        insert ac;
        Opportunity opp = UTL_TestData.createOpportunity(ac.Id);
        insert opp;
        Drug_Product__c DrugProduct=  UTL_testData.createDrugProducts();
        insert DrugProduct;
        Test.startTest();
        Drug_Product_Name__c OpportunityDrugProduct = UTL_TestData.createOpportunityDrugProduct(DrugProduct, opp);
        insert OpportunityDrugProduct;
        Test.stopTest();
    }
    
}