/*
 * Version       : 1.0
 * Description   : Test Class for PriceBookEntryWrapper
 */
@isTest
private class TST_PriceBookEntryWrapper {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product.id);
        insert pbe;
    }
    
    /**
     * This method used to test constructor with product as parameter
     */    
    @IsTest
    static void testConstructorWithProd() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];  
        Test.startTest();
            PriceBookEntryWrapper pbeWrapper = new PriceBookEntryWrapper(prod);
        Test.stopTest();
    }
    
    /**
     * This method used to test constructor with product and pricebook entry as parameters
     */    
    @IsTest
    static void testConstructorWithProdAndPbe() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Favorite_Product__c fv = new Favorite_Product__c(Product__c=Prod.Id, User__c = UserInfo.getUserId());
        insert fv;
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        Test.startTest();
            PriceBookEntryWrapper pbeWrapper = new PriceBookEntryWrapper(prod, pbe);
            pbeWrapper = new PriceBookEntryWrapper(prod, pbe, fv);
        Test.stopTest();
    }
    
    @IsTest
    static void testConstructorWithProdAndProdId() {
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<String> pid = new List<String>{prod.id};
        Test.startTest();
            PriceBookEntryWrapper pbeWrapper = new PriceBookEntryWrapper(prod, pid);
        Test.stopTest();
    }
}