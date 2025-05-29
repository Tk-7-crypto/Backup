@isTest
public class TST_DAOH_DrugProductName {
    
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
        opp = [SELECT Id, Drug_Product_Name__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(opp.Drug_Product_Name__c.contains(DrugProduct.International_Drug_Name__c));
        
        delete OpportunityDrugProduct;
        opp = [SELECT Id, Drug_Product_Name__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, opp.Drug_Product_Name__c);
        Test.stopTest();
    }
    
}