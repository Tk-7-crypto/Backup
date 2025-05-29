/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_PriceBookEntry
 */
@isTest
private class TST_SRV_CRM_PriceBookEntry {
    
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Territory__c = 'Albania';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Favorite_Product__c favProduct = UTL_TestData.createFavoriteProduct(product);
        insert favProduct;
    }
    
    
   /**
    * test method to get filter products
    */  
    static testmethod void testGetProductsBySearchFilter() {
        PriceBookEntry pbe = [SELECT Id, CurrencyIsoCode, Product2.Name, Product2.ProductCode, Product2.Territory__c FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        Test.startTest();
            List<PriceBookEntryWrapper> wrapperList = SRV_CRM_PriceBookEntry.getFilteredPriceBookEntries(pbWrapper, new Set<String>{'Product2.Name'}, new List<String>{'Name','ProductCode', 'Territory__c'}, new List<String>{'CurrencyIsoCode'}, 50, 'AND');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * test method to get filter products
    */  
    static testmethod void testGetProductsBySearchFilter1() {
        Product2 product = [Select Id FROM Product2 limit 1];
        product.Territory__c = 'Global';
        update product;
        PriceBookEntry pbe = [SELECT Id, CurrencyIsoCode, Product2.Name, Product2.ProductCode, Product2.Territory__c FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        Test.startTest();
            List<PriceBookEntryWrapper> wrapperList = SRV_CRM_PriceBookEntry.getFilteredPriceBookEntries(pbWrapper, new Set<String>{'Product2.Name'}, new List<String>{'Name','ProductCode', 'Territory__c'}, new List<String>{'CurrencyIsoCode'}, 50, 'AND');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
   /**
    * test method to get filter products WIth Exception
    */  
    static testmethod void testGetProductsBySearchFilterException() {
        PriceBookEntry pbe = [SELECT Id, CurrencyIsoCode, Product2.Name, Product2.ProductCode FROM PriceBookEntry LIMIT 1];
        PriceBookEntryWrapper pbWrapper = new PriceBookEntryWrapper(pbe.Product2, pbe);
        Test.startTest();
            try {
                List<PriceBookEntryWrapper> wrapperList = SRV_CRM_PriceBookEntry.getFilteredPriceBookEntries(pbWrapper, new Set<String>{'Product2.Name'}, new List<String>{'Name','ProductCod'}, new List<String>{'CurrencyIsoCode'}, 50, 'AND');
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_PriceBookEntry.PriceBookEntryServiceException', ex.getTypeName());
            }
        Test.stopTest();
    }
    
   /**
    * test method to get GetUserFavoriteProducts
    */  
    static testmethod void testGetUserFavoriteProducts() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            List<PriceBookEntryWrapper> wrapperList = SRV_CRM_PriceBookEntry.getUserFavoriteProducts(opp.Id, 'Opportunity');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = wrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * test method to get GetUserFavoriteProducts Exception
    */  
    static testmethod void testGetUserFavoriteProductsException() {
        Test.startTest();
            try {
                List<PriceBookEntryWrapper> wrapperList = SRV_CRM_PriceBookEntry.getUserFavoriteProducts(null, 'Opportunity');
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_PriceBookEntry.PriceBookEntryServiceException', ex.getTypeName());
            }
        Test.stopTest();
    }
}