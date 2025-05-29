@isTest
public class TST_LMSCategoryWebService {
    @testSetup
    static void setUpTestData() {
        Product2 p = new product2();
        p.name ='test';
        p.productcode='test_pc';
        insert p;
    }
    
    @isTest
    static void testOnPointIdMissing() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost(null, 'test_catalog', 'test_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 0);
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testCatalogMissing() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost('test_onpoint', null, 'test_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 0);
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testProductCodeMissing() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost('test_onpoint', 'test_catalog', null);
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 0);
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testInvalidProductCode() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost('test_onpoint', 'test_catalog', 'invalid_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 0);
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testOnPointIdAlreadyExists() {
        Test.startTest();
        Product2 product = [SELECT Id FROM Product2 where ProductCode = 'test_pc'][0];
        TS_LMS_Category__c lmsCategory = new TS_LMS_Category__c();
        lmsCategory.OnPoint_Skill_Profile_Id__c = 'test_onpoint';
        lmsCategory.Catalog__c = 'test_catalog';
        lmsCategory.Product__c = product.Id;
        insert lmsCategory;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost('test_onpoint', 'test_catalog', 'test_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 1);
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testValidPostRequest() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPost('test_onpoint', 'test_catalog', 'test_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.size(), 1);
        System.assertEquals(RestContext.response.StatusCode, 201);
    }
    
    @isTest
    static void testRecordIdMissingPutRequest() {
        Test.startTest();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPut(null, 'test_catalog', 'test_pc');
        Test.stopTest();
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testValidPutRequest() {
        Test.startTest();
        Product2 product = [Select Id from Product2 where ProductCode = 'test_pc' limit 1];
        TS_LMS_Category__c lmsCategory = new TS_LMS_Category__c();
        lmsCategory.OnPoint_Skill_Profile_Id__c = 'test_onpoint';
		lmsCategory.Product__c = product.Id;
        lmsCategory.Catalog__c = 'test_catalog';
        insert lmsCategory;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doPut(lmsCategory.Id, 'test_catalog_update', 'test_pc');
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id, Catalog__c, Product__c from TS_LMS_Category__c];
       	System.assertEquals(lmsCategories.get(0).Catalog__c, 'test_catalog_update');
        System.assertEquals(RestContext.response.StatusCode, 204);
    }
    
    @isTest
    static void testInvalidDeleteRequest() {
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doDelete();
        Test.stopTest();
        System.assertEquals(RestContext.response.StatusCode, 400);
    }
    
    @isTest
    static void testValidDeleteRequest() {
        Test.startTest();
        
        Product2 product = [Select Id from Product2 where ProductCode = 'test_pc' limit 1];
        TS_LMS_Category__c lmsCategory = new TS_LMS_Category__c();
        lmsCategory.OnPoint_Skill_Profile_Id__c = 'test_onpoint';
		lmsCategory.Product__c = product.Id;
        lmsCategory.Catalog__c = 'test_catalog';
        insert lmsCategory;
        
        RestRequest req = new RestRequest();
        req.params.put('recordId', lmsCategory.Id+'');
        RestResponse res = new RestResponse();   
        req.requestURI = '/services/apexrest/lmscategory';
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = res;
        LMSCategoryWebService.doDelete();
        Test.stopTest();
        List<TS_LMS_Category__c> lmsCategories = [SELECT Id from TS_LMS_Category__c];
        System.assertEquals(lmsCategories.size(), 0);
        System.assertEquals(RestContext.response.StatusCode, 202);
    }
}