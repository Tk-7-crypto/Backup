/*
 * Version       : 1.0
 * Description   : test class for Product selector
 */
@isTest
public class TST_SLT_FavoriteProduct {
	
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        Favorite_Product__c favProduct = UTL_TestData.createFavoriteProduct(product);
        insert favProduct;
    }
    
    /**
     * This method used to get products by filter parameters
     */    
    @IsTest
    static void testGetUserFavoriteProducts() {
        Test.startTest();
            List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().getUserFavoriteProducts();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = favoriteProductList.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testselectByProductId() {
        Id pId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Test.startTest();
        List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().selectByProductId(new Set<Id>{pId});
        Test.stopTest();
        System.assertEquals(1, favoriteProductList.size());
    }
    
    @IsTest
    static void testselectByProduct2Id() {
        id pId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Test.startTest();
            List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().selectByProduct2Id(pId);
        Test.stopTest();
        System.assertEquals(1, favoriteProductList.size());
    }
}