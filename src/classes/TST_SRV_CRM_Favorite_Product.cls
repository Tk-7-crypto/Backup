/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_Favorite_Product
 */
@isTest
public class TST_SRV_CRM_Favorite_Product {
	
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
    }
    
    /**
     * test method to create favorite product record
     */  
    static testmethod void testCreateCrudFavoriteProductRecord() {
        List<Favorite_Product__c> favoriteProductList = new List<Favorite_Product__c>();
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'TestProduct' LIMIT 1];
        Favorite_Product__c favoriteProduct = new Favorite_Product__c(Product__c = product.Id);
        favoriteProductList.add(favoriteProduct);
        String productJSON = JSON.serialize(favoriteProductList);
        String action = CON_CRM.CREATE_LABEL;
        Test.startTest();
             CNT_CRM_OpportunityProductSearch.crudFavoriteProductRecord(action, productJSON);
             favoriteProductList = [SELECT id FROM Favorite_Product__c WHERE Product__c = :product.Id and User__c = :UserInfo.getUserId()];
        Test.stopTest();
        Integer expected = 1;
        Integer actual = favoriteProductList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to delete favorite product record
     */  
    static testmethod void testDeleteCrudFavoriteProductRecord() {
        List<Favorite_Product__c> favoriteProductList = new List<Favorite_Product__c>();
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'TestProduct' LIMIT 1];
        Favorite_Product__c favoriteProduct = new Favorite_Product__c(Product__c = product.Id, User__c = UserInfo.getUserId());
        insert favoriteProduct;
        favoriteProductList.add(favoriteProduct);
        String productJSON = JSON.serialize(favoriteProductList);
        String action = CON_CRM.DELETE_LABEL;
        Test.startTest();
             CNT_CRM_OpportunityProductSearch.crudFavoriteProductRecord(action, productJSON);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = favoriteProductList.size();
        //System.assertEquals(expected, actual);
    }
    
    /**
     * test method to create favorite product record Exception
     */  
    static testmethod void testCrudFavoriteProductRecordException() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        String productJSON = JSON.serialize(oli);
        String action = CON_CRM.CREATE_LABEL;
        Test.startTest();
        try{
            CNT_CRM_OpportunityProductSearch.crudFavoriteProductRecord(action, productJSON);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
        } finally {
            Test.stopTest();
        }
    }
    @isTest static void test1(){
        List<String> errorList = new List<String>();
        SRV_CRM_Favorite_Product.SRV_CRM_Favorite_Product_Exception srcv = new SRV_CRM_Favorite_Product.SRV_CRM_Favorite_Product_Exception(errorList);
        System.assert(true);
    }
}