@isTest
public with sharing class TST_CNT_CPQ_PricingAdminScreen {

    @testSetup
    static void dataSetup() {
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = CON_CPQ.CPQ_SETTINGS;
        cpqSetting.Key_Generation_Org__c = UserInfo.getOrganizationId();
        insert cpqSetting;

        CPQ_Pricing_Admin_Settings__c adminSetting = new CPQ_Pricing_Admin_Settings__c(
            Name = 'Test Setting',
            Pricing_Tool__c = CON_CPQ.Q2_Solutions,
            Last_Stored_Migration_Id__c = 'MIG-0001',
            Permission_Set_Name__c = 'TestPermissionSet',
            Section_1_Api_Name__c = 'Business_Unit__c',
            Section_2_Api_Name__c = 'Business_Unit__c',
            Section_3_Api_Name__c = 'Business_Unit__c',
            Section_4_Api_Name__c = 'Business_Unit__c',
            Bundle_Products_Section_Label__c = 'Bundle Products'
        );
        insert adminSetting;

        Account acc = UTL_TestData.createAccount();
        insert acc;

        List<Product2> productList = new List<Product2>();
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', CON_CPQ.BUNDLE, 'Q_123', 'US', 'Go Blue');
        prod1.CPQ_Product_Type__c = CON_CPQ.BIOSCIENCE_BUSINESS_UNIT;
        productList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('SL-InVitro', CON_CPQ.OPTION, 'Q_123', 'US', 'Go Blue');
        prod2.CPQ_Product_Type__c = CON_CPQ.BIOSCIENCE_BUSINESS_UNIT;
        productList.add(prod2);
        insert productList;

        IQVIA_Price_Matrix__c priceMatrix = new IQVIA_Price_Matrix__c(
            Account__c = acc.Id,
            Bundle_Product__c = prod1.Id,
            Option_Product__c = prod2.Id,
            Product_Code__c = 'Q_123',
            Bundle_Product_Code__c = 'Q_123',
            Service_line__c = 'SL-Development Metabolism',
            Site__c = 'Site2',
            Base_Price__c = 20,
            Pricing_Tool__c = CON_CPQ.Q2_Solutions,
            Business_Unit__c = CON_CPQ.BIOSCIENCE_BUSINESS_UNIT,
            Migration_Id__c = 'IMP002',
            Discount__c = null,
            Cost_Price__c = 80,
            Min_site_count__c = 0,
            Max_site_count__c = 9999,
            Min_document_count__c = 0,
            Max_document_count__c = 9999,
            Min_consent_count__c = 0,
            Max_consent_count__c = 9999,
            Breakdown__c = 10,
            CurrencyIsoCode = CON_CPQ.USD
        );
        insert priceMatrix;

        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(testUser) {
            PermissionSet permissionSet = new PermissionSet(Name = 'TestPermissionSet', Label = 'TestPermissionSet');
            insert permissionSet;

            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = permissionSet.Id
            );
            insert psa;
        }
    }

    @isTest
    static void testGetAvailableAccounts() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
            List<Account> result = CNT_CPQ_PricingAdminScreen.getAvailableAccounts(CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.areNotEqual(0, result.size(), 'Result size should not be zero');
        Assert.areEqual(acc.Id, result[0].Id, 'Expected result is not returned');
    }

    @isTest
    static void testGetAvailableSectionsAndOptions() {
        Test.startTest();
            Map<String, List<String>> result = CNT_CPQ_PricingAdminScreen.getAvailableSectionsAndOptions(CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
        Assert.areEqual(true, result.values()[0].contains(CON_CPQ.BIOSCIENCE_BUSINESS_UNIT), 'Expected result is not returned');
    }

    @isTest
    static void testGetLastStoredMigrationId() {
        Test.startTest();
            String lastMigrationId = CNT_CPQ_PricingAdminScreen.getLastStoredMigrationId(CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.areEqual('MIG-0001', lastMigrationId, 'Expected result is not returned');
    }

    @isTest
    static void testGetBundleProductSectionLabel() {
        Test.startTest();
            String result = CNT_CPQ_PricingAdminScreen.getBundleProductSectionLabel(CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.areEqual('Bundle Products', result, 'Expected result is not returned');
    }

    @isTest
    static void testGetServiceLines() {
        Test.startTest();
            Map<String, String> serviceLines = CNT_CPQ_PricingAdminScreen.getServiceLines(CON_CPQ.Q2_Solutions, CON_CPQ.BIOSCIENCE_BUSINESS_UNIT);
        Test.stopTest();
        Assert.areEqual(1, serviceLines.size(), 'There should be one service line');
        Assert.areNotEqual(null, serviceLines, 'Service line should not be null');
    }

    @isTest
    static void testGetColumns() {
        Test.startTest();
            List<CPQ_Mapping_Field_Set__mdt> columns = CNT_CPQ_PricingAdminScreen.getColumns(CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.areNotEqual(0, columns.size(), 'Result should not be null');
        Assert.areNotEqual(null, columns[0], 'Expected result is not returned');
    }

    @isTest
    static void testGetIqviaPriceMatrices() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
            List<Map<String, Object>> priceMatrices = CNT_CPQ_PricingAdminScreen.getIqviaPriceMatrices(acc.Id, CON_CPQ.Q2_Solutions, CON_CPQ.BIOSCIENCE_BUSINESS_UNIT, 'Q_123');
        Test.stopTest();
        Assert.areEqual(1, priceMatrices.size(), 'There should be one price matrix');
        Assert.areNotEqual(null, priceMatrices[0], 'Price matrix should not be null');
    }

    @isTest
    static void testUpdateIqviaPriceMatrices() {
        IQVIA_Price_Matrix__c priceMatrix = [SELECT Id, Base_Price__c FROM IQVIA_Price_Matrix__c LIMIT 1];
        Map<String, Object> recordDetail = new Map<String, Object>{
                CON_CPQ.ID => priceMatrix.Id,
                'Base_Price__c' => 10
        };
        Test.startTest();
            Boolean result = CNT_CPQ_PricingAdminScreen.updateIqviaPriceMatrices(new List<Map<String, Object>>{recordDetail});
        Test.stopTest();
        IQVIA_Price_Matrix__c updatedPriceMatrix = [SELECT Id, Base_Price__c FROM IQVIA_Price_Matrix__c LIMIT 1];
        Assert.areEqual(true, result, 'Expected result is not returned');
        Assert.areNotEqual(priceMatrix.Base_Price__c, updatedPriceMatrix.Base_Price__c, 'Expected result should not be equal to the actual result');
    }

    @isTest
    static void testUpdateLastStoredMigrationId() {
        Test.startTest();
            CNT_CPQ_PricingAdminScreen.updateLastStoredMigrationId(CON_CPQ.Q2_Solutions, 'MIG-0002');
        Test.stopTest();
        CPQ_Pricing_Admin_Settings__c updatedSetting = [SELECT Last_Stored_Migration_Id__c FROM CPQ_Pricing_Admin_Settings__c WHERE Pricing_Tool__c = :CON_CPQ.Q2_Solutions LIMIT 1];
        Assert.areEqual('MIG-0002', updatedSetting.Last_Stored_Migration_Id__c, 'Migration ID should be updated');
    }

    @isTest
    static void testGetFieldValuesFromPriceMatrix() {
        Test.startTest();
            Map<String, List<String>> result = CNT_CPQ_PricingAdminScreen.getFieldValuesFromPriceMatrix(new Set<String>{CON_CPQ.PRICING_TOOL}, CON_CPQ.Q2_Solutions);
        Test.stopTest();
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
        Assert.areEqual(true, result.values()[0].contains(CON_CPQ.Q2_Solutions), 'Expected result is not returned');
    }
}