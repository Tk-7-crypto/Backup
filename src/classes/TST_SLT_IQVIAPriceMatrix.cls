@isTest 
private class TST_SLT_IQVIAPriceMatrix {
    
    @testSetup
    static void setupTestData() {
        List<IQVIA_Price_Matrix__c> priceMatrixList = new List<IQVIA_Price_Matrix__c>();
        priceMatrixList.add(new IQVIA_Price_Matrix__c(
            Product_Code__c = 'Code1',
            Service_line__c = 'Service1',
            Site__c = 'Site1',
            Base_Price__c = 20,
            Migration_Id__c = 'IMP001',
            Start_Date__c = Date.today()
        ));
        priceMatrixList.add(new IQVIA_Price_Matrix__c(
            Product_Code__c = 'Code2',
            Service_line__c = 'Service2',
            Site__c = 'Site2',
            Base_Price__c = 20,
            Migration_Id__c = 'IMP002',
            Start_Date__c = Date.today()
        ));
        insert priceMatrixList;
    }
    
    @isTest
    static void testConstructor() {
        SLT_IQVIAPriceMatrix priceMatrixWithFLS = new SLT_IQVIAPriceMatrix(true);
        System.assertNotEquals(null, priceMatrixWithFLS);
        SLT_IQVIAPriceMatrix priceMatrixWithoutFLS = new SLT_IQVIAPriceMatrix(false);
        System.assertNotEquals(null, priceMatrixWithoutFLS);
        SLT_IQVIAPriceMatrix priceMatrixWithCRUDAndFLS = new SLT_IQVIAPriceMatrix(true, true);
        System.assertNotEquals(null, priceMatrixWithCRUDAndFLS);
        SLT_IQVIAPriceMatrix priceMatrixWithoutCRUDAndWithFLS = new SLT_IQVIAPriceMatrix(false, true);
        System.assertNotEquals(null, priceMatrixWithoutCRUDAndWithFLS);
    }
    
    @isTest
    static void testGetIqviaPriceMatrixByCondition() {
        Set<String> fieldSet = new Set<String>{'Id', 'Product_Code__c', 'Service_line__c', 'Site__c'};
        String condition = 'Service_line__c=\'Service1\'';
        Set<String> productCodeSet = new Set<String>{'Code1'};
        Set<String> serviceLineNameSet = new Set<String>{'Service1'};
        Set<String> siteSet = new Set<String>{'Site1'};
                    
        Test.startTest();
            List<IQVIA_Price_Matrix__c> result = new SLT_IQVIAPriceMatrix().getIqviaPriceMatrixByCondition(fieldSet, condition, productCodeSet, serviceLineNameSet, siteSet, null, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, result.size());
        IQVIA_Price_Matrix__c matrix = result[0];
        System.assertEquals('Code1', matrix.Product_Code__c);
        System.assertEquals('Service1', matrix.Service_line__c);
        System.assertEquals('Site1', matrix.Site__c);
    }

    @isTest
    static void testGetIqviaPriceMatrixByConditionOrderByStartDate() {
        Set<String> fieldSet = new Set<String>{'Id', 'Product_Code__c', 'Service_line__c', 'Site__c', 'Start_Date__c'};
        String condition = 'Service_line__c=\'Service1\'';
        Set<String> productCodeSet = new Set<String>{'Code1'};
        Set<String> serviceLineNameSet = new Set<String>{'Service1'};
        Set<String> siteSet = new Set<String>{'Site1'};
                    
        Test.startTest();
            List<IQVIA_Price_Matrix__c> result = new SLT_IQVIAPriceMatrix().getIqviaPriceMatrixByConditionOrderByStartDate(fieldSet, condition, productCodeSet, serviceLineNameSet, siteSet, null, null, null, null, null);
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected result size is not returned.');
        IQVIA_Price_Matrix__c matrix = result[0];
        Assert.areEqual('Code1', matrix.Product_Code__c, 'Expected result is not returned.');
        Assert.areEqual('Service1', matrix.Service_line__c, 'Expected result is not returned.');
        Assert.areEqual('Site1', matrix.Site__c, 'Expected result is not returned.');
        Assert.areEqual(Date.today(), matrix.Start_Date__c, 'Expected result is not returned.');
    }
    
    @isTest
    static void testGetIQVIAPriceMatrix() {
        Set<String> fieldSet = new Set<String>{'Id', 'Product_Code__c', 'Service_line__c', 'Site__c'};
        String condition = 'Base_Price__c != null';
                    
        Test.startTest();
            List<IQVIA_Price_Matrix__c> result = new SLT_IQVIAPriceMatrix().getIQVIAPriceMatrix(fieldSet, condition);
        Test.stopTest();
    }
}