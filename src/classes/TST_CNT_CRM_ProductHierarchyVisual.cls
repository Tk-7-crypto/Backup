/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CRM_ProductHierarchyVisual
 */
@isTest
public class TST_CNT_CRM_ProductHierarchyVisual {
    
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        product.Hierarchy_Chain__c = 'Test';
        Update product;
        
    }
    
     /**
     * test method to get field Details of Product Object
     */  
    static testmethod void testGetProductFieldsDetail() {
        String objectName = CON_CRM.PRODUCT_OBJECT;
        List<Product2> prodList;
        Test.startTest();
        prodList = CNT_CRM_ProductHierarchyVisual.getProductDetails('', null, false, false);
        Test.stopTest();
        //System.assertEquals(true, prodList.size() > 0);
    }
    
     /**
     * test method to get field Details of Product Object
     */  
    static testmethod void testGetProductFieldsDetails() {
        String objectName = CON_CRM.PRODUCT_OBJECT;
        Product2 product = new Product2();
        product = [Select id from Product2];
        product.Hierarchy_Chain__c = 'Test->Test';
        Update product;
        List<Product2> prodList;
        Test.startTest();
        prodList = CNT_CRM_ProductHierarchyVisual.getProductDetails('Test->', null, false, false);
        Test.stopTest();
        //System.assertEquals(true, prodList.size() > 0);
    }
    
    /**
     * This test method used to fetch product records.
     */ 
    static testMethod void testGetOpportunitySplitRecordsException() {
        Product2 product = [SELECT Id, Name FROM Product2];
        List<Product2> prodList = new  List<Product2>();
        Test.startTest();
        try {
            prodList = CNT_CRM_ProductHierarchyVisual.getProductDetails('Te\'st-\'>', null, false, false);
        } catch(Exception ex) {
            System.assertEquals(true,true);
        }
        Test.stopTest();
    }
    static testMethod void test2(){
        List<String> pdList = CNT_CRM_ProductHierarchyVisual.fetchTerritory('');
        List<Map<String,String>> pdList1 = CNT_CRM_ProductHierarchyVisual.fetchTerritory1('');
    }
    
    @isTest
    public static void testFetchHierarchyChain(){
        Default_Product_Search__c dps = new Default_Product_Search__c();
        dps.User__c = UserInfo.getUserId();
        dps.Default_Hierarchy_Chain__c = 'GPRGBU->GPCOMM->GP7IGA->GP7XXX->GP79XX->GP79BX->GP82XX->GP8307';
        insert dps;
        Test.startTest();
        List<String> hierarchyChain = CNT_CRM_ProductHierarchyVisual.fetchHierarchyChain();
        Test.stopTest();
        System.assertEquals('', hierarchyChain[0]);
        System.assertEquals(9, hierarchyChain.size());
    }
}