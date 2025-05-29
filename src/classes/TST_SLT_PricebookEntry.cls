/*
 * Version       : 1.0
 * Description   : test class for PriceBookEntry selector
 */
@isTest
private class TST_SLT_PricebookEntry {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        product.CurrencyIsoCode = 'USD';
        update product;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product.id);
        insert pbe;
    }
    
    /**
    * test method to get filter products
    */  
    static testmethod void testGetProductsBySearchFilter() {
        PriceBookEntry pbe = [SELECT Id, CurrencyIsoCode, Product2.Name, Product2.ProductCode FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        String fiterObjString = JSON.serialize(pbWrapper);
        Test.startTest();
        List<PriceBookEntryWrapper> wrapperList = CNT_CRM_OpportunityProductSearch.getPriceBookEntriesBySearchFilter(fiterObjString, new List<String>{'Product2.Name'}, new List<String>{'Name','ProductCode'}, new List<String>{'CurrencyIsoCode'}, 50, 'AND');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * test method to get filter products
    */  
    static testmethod void testGetProductsByIds() {
        Product2 prod = [Select id from Product2];
        Set<Id> prodIdSet = new Set<Id>();
        prodIdSet.add(prod.id);
        Test.startTest();
        List<PriceBookEntry> pbeList = new SLT_PriceBookEntry().getPbEntriesByProductIds(prodIdSet,new Set<String>{'id'},'USD');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = pbeList.size();
        System.assertEquals(expected, actual);
    }
        
    /**
    * test method to get Map of PricebookEntries
    */  
    @IsTest
    private static void testGetMapOfPbEntriesByProductIdSet() {
        PricebookEntry pbe = [SELECT id FROM PricebookEntry];
        Set<Id> pbeIdSet = new Set<Id>();
        pbeIdSet.add(pbe.id);
        Test.startTest();
        Map<Id, PriceBookEntry> pricebookEntryMap = new SLT_PriceBookEntry().getMapOfPbEntriesByProductIdSet(pbeIdSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = pricebookEntryMap.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testGetStandardPriceBookByName(){
        
        Product2 prod = [Select id from Product2];
        Set<Id> prodIdSet = new Set<Id>();        
        prodIdSet.add(prod.id);
        List<String> currencyCode = new List<String> {CON_CPQ.USD};
        
        Test.startTest();
            List<PriceBookEntry> pbeList = new SLT_PriceBookEntry().getStandardPriceBookByName(new Set<String>{CON_CPQ.ID}, prodIdSet, Test.getStandardPricebookId(), currencyCode);
        Test.stopTest();
        
        system.assertEquals(1, pbeList.size(), 'Should Return Price Book Entry');
    }

    @IsTest
    static void testGetPricebookEntriesForProducts() {
        Product2 product = [SELECT Id FROM Product2];
        Set<Id> productIds = new Set<Id>{product.Id};
        Set<String> currencyCodes = new Set<String> {CON_CPQ.USD};

        Test.startTest();
        List<PricebookEntry> resultEntries = new SLT_PriceBookEntry().getPricebookEntriesForProducts(
            Test.getStandardPricebookId(), productIds, currencyCodes, CPQ_Utility.getIdFieldSet());
        Test.stopTest();
        System.assertEquals(1, resultEntries.size(), 'Should return Pricebook Entry');
    }
}