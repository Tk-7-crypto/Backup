/*
 * Version       : 1.0
 * Description   : Test Class for SLT_CaseCategorization
 */
@isTest
private class TST_SLT_CaseCategorization {
	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
    	Product2 product = UTL_TestData.createProduct();
        insert product;
        CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify', SubType3__c='--none--',RecordTypeId__c='Techno',Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,Type__c = 'Categorization');
        insert categorization;
        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Test subtype 1', SubType2__c='Test subtype 2 v1', SubType3__c='--none--',RecordTypeId__c='Techno',Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,Type__c = 'Categorization');
        insert categorization;
        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Test subtype 1', SubType2__c='Test subtype 2 v2',SubType3__c='--none--',RecordTypeId__c='Techno',Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,Type__c = 'Categorization');
        insert categorization;
    }
    
    /**
     * This method used to get distinct subType1 by ProductName
     */    
    @IsTest
    static void testGetSubType1CategorizationByProductName() {
    	List<AggregateResult> subtype1List = new  List<AggregateResult>();
        Test.startTest();
        subtype1List = new SLT_CaseCategorization().getSubType1ByProductName('TestProduct');
        Test.stopTest();
        Integer expected = 2;
        Integer actual = subtype1List.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get disctinct products by filter parameters
     */    
    @IsTest
    static void testGetCaseCategorizationByFilter() {
    	String productName='TestProduct';
    	String subtype1='Test subtype 1';
    	String subtype2='Test subtype 2 v2';
    	String subtype3='--none--';
    	List<CSM_QI_Case_Categorization__c> categorization = new List<CSM_QI_Case_Categorization__c>(); 
        Test.startTest();
        categorization = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\'');
        SLT_CaseCategorization cc = new SLT_CaseCategorization();
        cc.getAllCaseCategorization();
        if(!categorization.isEmpty()){
            cc.selectById(new Set<ID>{categorization[0].Id});
            cc.getCSHSubTypeByProductName(productName);
            cc.getSubType2BySubtype1Name(productName,subtype1);
            cc.getProducts(new Set<String>{productName});
            cc.getProducts(null);
            cc.getProducts(new Set<String>{productName},'Techno');
            cc.getProducts(null,'Techno');
            cc.getCaseCategorizationDetails(productName,subtype1,subtype2,subtype3,'Techno');
            cc.getPEPSubTypeByProductName(productName);
            cc.selectWithAggregate('select SubType1__c  from CSM_QI_Case_Categorization__c group by SubType1__c Limit 1');
            cc.getById(new Set<ID>{categorization[0].Id},new Set<string>{'Id'});
            cc.getProductLevelRestrict();
            cc.getCountryofTheRequester2(new Set<String>{},'Techno');
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = categorization.size();
        System.assertEquals(expected, actual);
    }
    
    
    /**
     * This method used to get disctinct products By ProductNames
     */    
    @IsTest
    static void testGetProductsCategorization() {
    	Set<String> c = new Set<String>();
    	c.add('TestProduct');
    	List<AggregateResult> products = new  List<AggregateResult>();
        Test.startTest();
        products = new SLT_CaseCategorization().getProducts(c);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }

     @IsTest
    static void testGetSelectById() {
        CSM_QI_Case_Categorization__c cate = [Select Id,Product__c from CSM_QI_Case_Categorization__c Limit 1];
        Test.startTest();
        List<CSM_QI_Case_Categorization__c> categories = new SLT_CaseCategorization().selectById(new Set<Id> {cate.Id});
        new SLT_CaseCategorization().getCSHSubTypeByProductId(cate.Product__c);
        new SLT_CaseCategorization().getActiveCaseCategorization(new Set<Id> {cate.Id});
        new SLT_CaseCategorization().getCaseListForActivitesbyLosTemp(new Set<String> {'EDC Support'}, new Set<String> {'Create User'});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = categories.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetAllCaseCategorization() {
        Test.startTest();
        List<CSM_QI_Case_Categorization__c> categories = new SLT_CaseCategorization().getAllCaseCategorization();
        Test.stopTest();
    }

    @IsTest
    static void testGetCSHSubTypeByProductName() {
        Test.startTest();
        List<AggregateResult> categories = new SLT_CaseCategorization().getCSHSubTypeByProductName('TestProduct');
        Test.stopTest();
    }

    @IsTest
    static void testGetSubType1ByProductName() {
        Test.startTest();
        List<AggregateResult> categories = new SLT_CaseCategorization().getSubType1ByProductName('TestProduct');
        Test.stopTest();
    }

    @IsTest
    static void testGetSubType2BySubtype1Name() {
        Test.startTest();
        List<AggregateResult> categories = new SLT_CaseCategorization().getSubType2BySubtype1Name('TestProduct','Test subtype 1');
        Test.stopTest();
    }
    
}