/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Asset
 */
@isTest
private class TST_SLT_Asset {
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
     * This method used to get Asset by AccountId and Product2 ID
     */    
    @IsTest
    static void testSelectByAccountIdAndProductId() {
    	List<Asset> assets = new  List<Asset>();
    	Product2 product = [SELECT id, Name FROM Product2 WHERE name = 'TestProduct'];
    	Account account = [SELECT id FROM Account WHERE name = 'TestAccount']; 	
        Test.startTest();
        assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {account.Id},new Set<Id> {product.Id});
        new SLT_Asset().selectById(new Set<Id> {assets[0].Id});
        new SLT_Asset().selectByAssetId(new Set<Id> {assets[0].Id},new Set<String> {'Id','Name'});
        new SLT_Asset().selectByDataAccountId(new Set<Id> {assets[0].Id},product.Id);
        new SLT_Asset().selectByAccountId(new Set<Id> {assets[0].Id});
        new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {account.Id},new Set<Id> {assets[0].Id});
        new SLT_Asset().getAssetsWithFilter(new Set<String> {'Id','Name'}, 'Id = \''+assets[0].Id+'\'');
        new SLT_Asset().selectByAccountIdAndProductNameList(new Set<Id> {account.Id}, new Set<String> {product.Name});
        
        Test.stopTest();
        Integer expected = 1;
        Integer actual = assets.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testSelectByAccountIdAndProductName(){
        Product2 productRecord = [SELECT Id, Name FROM Product2 WHERE name = 'TestProduct'];
    	Account accountRecord = [SELECT id FROM Account WHERE name = 'TestAccount'];
        
        Asset assetRecord = new Asset();
        assetRecord.AccountId = accountRecord.Id;
        assetRecord.Product2Id = productRecord.Id;
        assetRecord.Name = 'Test';
        assetRecord.Status = 'Purchased';
        insert assetRecord;
        
        Test.startTest();
        new SLT_Asset().selectByAccountIdAndProductName(accountRecord.Id, productRecord.Name);
        Test.stopTest();
    }
    
    @isTest
    static void testSelectAssetByProductId(){
        Product2 productRecord = [SELECT Id, Name FROM Product2 WHERE name = 'TestProduct'];
    	Account accountRecord = [SELECT id FROM Account WHERE name = 'TestAccount'];
        
        Asset assetRecord = new Asset();
        assetRecord.AccountId = accountRecord.Id;
        assetRecord.Product2Id = productRecord.Id;
        assetRecord.Name = 'Test';
        assetRecord.Status = 'Purchased';
        insert assetRecord;
        
        Test.startTest();
        new SLT_Asset().selectAssetByProductId(new Set<Id>{productRecord.Id});
        Test.stopTest();
    }
}
