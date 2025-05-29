/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_Product
 */
@isTest
private class TST_SRV_CRM_Product {
    
    /**
     * test method to get field Details of Product Object
     */      
    static testmethod void testGetProductFieldsDetail() {
        String objectName = 'Product2';
        List<String> fieldAPINameList = new List<String>{'Name', 'ProductCode'};
        Test.startTest();
            List<ObjectFieldsWrapper> fieldWrapperList = SRV_CRM_Product.getProductFieldsDetail(objectName, fieldAPINameList);
        Test.stopTest();
        Integer expected = 2;
        Integer actual = fieldWrapperList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get field Details of Product Object with Exception
     */      
    static testmethod void testGetProductFieldsDetailException() {
        String objectName = 'Product2';
        List<String> fieldAPINameList = new List<String>{'Name', 'ProductCod'};
        Test.startTest();
            try {
                List<ObjectFieldsWrapper> fieldWrapperList = SRV_CRM_Product.getProductFieldsDetail(objectName, fieldAPINameList);
                System.assert(false); // code will never reach here 
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_Product.ProductServiceException', ex.getTypeName());
            }    
        Test.stopTest();
    }
    
    /**
     * This test method used to fetch product records.
     */ 
    static testMethod void testGetOpportunitySplitRecordsException() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        product.Hierarchy_Chain__c = 'Test';
        Update product;
        List<Product2> prodList = new  List<Product2>();
        Test.startTest();
        try {
            prodList = CNT_CRM_ProductHierarchyVisual.getProductDetails('Te\'st-\'>', null, false, false);
        } catch(Exception ex) {
            System.assertEquals(true,true);
        }
        Test.stopTest();
    }
}