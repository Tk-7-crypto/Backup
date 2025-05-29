/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Product2
 */ 
@isTest
private class TST_SLT_Product2 {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        Account account = UTL_TestData.createAccount();
        insert account;
        Asset asset = new Asset(Name='TestAsset', AccountId = account.Id, Product2Id = product.id);
        insert asset;
    }
    
    /**
     * This method used to test sobject field list
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
            SLT_Product2 sltProduct = new SLT_Product2();
            sltProduct.getSObjectFieldList();
        Test.stopTest();
    }
    
    /**
     * This method used to test SObjectType
     */    
    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
            SLT_Product2 sltProduct = new SLT_Product2();
            sltProduct.getSObjectType();
        Test.stopTest();
    }
    
    /**
     * This method used to get Product by id
     */    
    @IsTest
    static void testSelectById() {
        List<Product2> products = new  List<Product2>();
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];  
        Test.startTest();
            products = new SLT_Product2().selectById(new Set<Id> {prod.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get Product2 by accountId
     */    
    @IsTest
    static void testSelectByAccountId() {
        List<Product2> products = new  List<Product2>();
        Account account = [SELECT id FROM Account WHERE name = 'TestAccount'];  
        Test.startTest();
        products = new SLT_Product2().selectByAccountId(new Set<Id> {account.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get Product2 by Filter Condition
     */    
    @IsTest
    static void testGetProductWithFilter() {
        List<Product2> products = new List<Product2>();
        Test.startTest();
            products = new SLT_Product2().getProductWithFilter(new Set<String> {'Id','Name'}, 'isActive = true');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testGetAllFieldValues() {
        Test.startTest();
        	List<AggregateResult> agrList = new SLT_Product2().getAllFieldValues('ProductCode');
        Test.stopTest();
        System.assertEquals(true, agrList.size() > 0);
    }
    
    @IsTest
    static void testGetProductsByProductCode() {
        Product2 pro = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
        Test.startTest();
        List<Product2> proList = new SLT_Product2().getProductsByProductCode(new set<String>{'Id', 'ProductCode'}, new Set<String>{pro.ProductCode});
        Test.stopTest();
        System.assertEquals(true, proList.size() > 0);
    }
    @IsTest
    static void testGetProductsByProductName() {
        Product2 pro = [SELECT Id, ProductCode, Name FROM Product2 LIMIT 1];
        Test.startTest();
            List<Product2> proList = new SLT_Product2().getProductsByProductName(new set<String>{CON_CPQ.Id, CON_CPQ.NAME}, new Set<String>{pro.Name});
        Test.stopTest();
        System.assertEquals(true, proList.size() > 0);
    }

    @IsTest
    static void testGetProductsByCondition() {
        Product2 pro = [SELECT Id, ProductCode, Name FROM Product2 LIMIT 1];
        Test.startTest();
            List<Product2> proList = new SLT_Product2().getProductsByCondition(new set<String>{CON_CPQ.Id, CON_CPQ.NAME}, 'isActive = true', null);
        Test.stopTest();
        System.assertEquals(true, proList.size() > 0);
    }
}