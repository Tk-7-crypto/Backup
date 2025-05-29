public with sharing class CNT_CPQ_PricingAdminScreen {

    private static List<CPQ_Pricing_Admin_Settings__c> pricingAdminSettings = CPQ_Pricing_Admin_Settings__c.getall().values();
    private static List<CPQ_Mapping_Field_Set__mdt> mappingFieldSetDetails = CPQ_Mapping_Field_Set__mdt.getall().values();
    private static Map<String, Schema.SObjectField> sObjectFields = CPQ_Utility.getFields(CON_CPQ.IQVIA_PRICE_MATRIX_API_NAME);

    @AuraEnabled
    public static List<Account> getAvailableAccounts(String pricingTool){
        try {
            Set<Id> accountIds = new Set<Id>();
            Map<Id,Account> accountDetails = new Map<Id,Account>();
            String condition = 'Pricing_Tool__c = \'' + pricingTool + '\' AND Account__c != null';
            for (IQVIA_Price_Matrix__c iqviaPriceMatrix : new SLT_IQVIAPriceMatrix().getIQVIAPriceMatrix(new Set<String>{CON_CPQ.ACCOUNT_FIELD}, condition)) {
                accountIds.add(iqviaPriceMatrix.Account__c);
            }
            if (!accountIds.isEmpty()) {
                accountDetails = new SLT_Account().selectByAccountId(accountIds, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
            }
            return accountDetails.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<String>> getAvailableSectionsAndOptions(String pricingTool) {
        try {
            Set<String> fieldApiNames = new Set<String>();
            for (CPQ_Pricing_Admin_Settings__c adminSetting : pricingAdminSettings) {
                if (adminSetting.Pricing_Tool__c == pricingTool) {
                    if (adminSetting.Section_1_Api_Name__c != null) {
                        fieldApiNames.add(adminSetting.Section_1_Api_Name__c);
                    }
                    if (adminSetting.Section_2_Api_Name__c != null) {
                        fieldApiNames.add(adminSetting.Section_2_Api_Name__c);
                    }
                    if (adminSetting.Section_3_Api_Name__c != null) {
                        fieldApiNames.add(adminSetting.Section_3_Api_Name__c);
                    }
                    if (adminSetting.Section_4_Api_Name__c != null) {
                        fieldApiNames.add(adminSetting.Section_4_Api_Name__c);
                    }
                    break;
                }
            }
            return getFieldValuesFromPriceMatrix(fieldApiNames, pricingTool);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getLastStoredMigrationId(String pricingTool){
        try {
            String lastStoredMigrationId = CON_CPQ.BLANK;
            for (CPQ_Pricing_Admin_Settings__c adminSetting : pricingAdminSettings) {
                if (adminSetting.Pricing_Tool__c == pricingTool) {
                    lastStoredMigrationId = adminSetting.Last_Stored_Migration_Id__c;
                }
            }
            return lastStoredMigrationId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getServiceLines(String pricingTool, String section1Value){
        try {
            Map<String, String> serviceLineDetails = new Map<String, String>();
            Set<String> productCodeSet = new Set<String>();
            String condition = 'Pricing_Tool__c = \'' + pricingTool + '\' AND Bundle_Product__c != null';
            if (pricingTool == CON_CPQ.Q2_Solutions) {
                condition += ' AND Business_Unit__c = \'' + section1Value + '\'';
            }
            for (IQVIA_Price_Matrix__c iqviaPriceMatrix : new SLT_IQVIAPriceMatrix().getIQVIAPriceMatrix(new Set<String>{CON_CPQ.BUNDLE_PRODUCT_CODE}, condition)) {
                productCodeSet.add(iqviaPriceMatrix.Bundle_Product_Code__c);
            }
            String condition2 = 'ProductCode IN :productCodeSet AND Apttus_Config2__ConfigurationType__c = \'Bundle\'';
            for (Product2 product : new SLT_Product2().getProductsByCondition(new Set<String>{CON_CPQ.NAME, CON_CPQ.PRODUCTCODE}, condition2, productCodeSet)) {
                if (!serviceLineDetails.containsKey(product.Name)) {
                    serviceLineDetails.put(product.Name, product.ProductCode);
                }
            }
            return serviceLineDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getBundleProductSectionLabel(String pricingTool){
        try {
            for (CPQ_Pricing_Admin_Settings__c adminSetting : pricingAdminSettings) {
                if (adminSetting.Pricing_Tool__c == pricingTool) {
                    if (adminSetting.Bundle_Products_Section_Label__c != null && adminSetting.Bundle_Products_Section_Label__c != CON_CPQ.BLANK) {
                        return adminSetting.Bundle_Products_Section_Label__c;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CPQ_Mapping_Field_Set__mdt> getColumns(String pricingTool){
        try {
            List<CPQ_Mapping_Field_Set__mdt> fieldSetDetails = new List<CPQ_Mapping_Field_Set__mdt>();
            for (CPQ_Mapping_Field_Set__mdt mappingFieldSet : mappingFieldSetDetails) {
                if (mappingFieldSet.Feature_Selection__c == CON_CPQ.PRICING_ADMIN_FEATURE_SELECTION && mappingFieldSet.Pricing_Tool__c.contains(pricingTool)) {
                    fieldSetDetails.add(mappingFieldSet);
                }
            }
            return fieldSetDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> getIqviaPriceMatrices(String account, String pricingTool, String section1Value, String bundleProductCode) {
        try {
            List<IQVIA_Price_Matrix__c> iqviaPriceMatrices = new List<IQVIA_Price_Matrix__c>();
            List<Map<String, Object>> responseList = new List<Map<String, Object>>();
            Set<String> productCodeSet = new Set<String>();
            Map<String, String> productCodeToProductNameDetails = new Map<String, String>();
            if (String.isNotBlank(pricingTool) && String.isNotBlank(bundleProductCode)) {
                String condition = (account != null ? 'Account__c = \'' + account + '\'' : 'Account__c = null') + ' AND Pricing_Tool__c = \'' + pricingTool + '\' AND Bundle_Product_Code__c = \'' + bundleProductCode + '\'';
                if (pricingTool == CON_CPQ.Q2_Solutions) {
                    condition += ' AND Business_Unit__c = \'' + section1Value + '\'';
                }
                iqviaPriceMatrices = new SLT_IQVIAPriceMatrix().getIQVIAPriceMatrix(new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.PRODUCT_CODE, CON_CPQ.BASE_PRICE, CON_CPQ.START_DATE, CON_CPQ.END_DATE, CON_CPQ.PRICING_TOOL, CON_CPQ.BUSINESS_UNIT, CON_CPQ.BUNDLE_PRODUCT_CODE, CON_CPQ.ACCOUNT_FIELD, CON_CPQ.CLINICAL_TYPE, CON_CPQ.IPM_NUMBER_OF_ANALYTE, CON_CPQ.SPECIMEN_TYPE, CON_CPQ.IPM_PREMIUM, CON_CPQ.IPM_SITE}, condition);
                for (IQVIA_Price_Matrix__c iqviaPriceMatrix : iqviaPriceMatrices) {
                    if (String.isNotBlank(iqviaPriceMatrix.Product_Code__c)) {
                        productCodeSet.add(iqviaPriceMatrix.Product_Code__c);
                    }
                }
                if (!productCodeSet.isEmpty()) {
                    for (Product2 product : new SLT_Product2().getProductsByProductCode(new Set<String>{CON_CPQ.NAME, CON_CPQ.PRODUCTCODE}, productCodeSet)) {
                        productCodeToProductNameDetails.put(product.ProductCode, product.Name);
                    }
                }
                for (IQVIA_Price_Matrix__c matrix : iqviaPriceMatrices) {
                    Map<String, Object> recordMap = new Map<String, Object>(matrix.getPopulatedFieldsAsMap());
                    if (productCodeToProductNameDetails.containsKey(matrix.Product_Code__c)) {
                        recordMap.put(CON_CPQ.IPM_PRODUCT_COLUMN_APINAME, productCodeToProductNameDetails.get(matrix.Product_Code__c));
                    }
                    responseList.add(recordMap);
                }
            }
            return responseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateIqviaPriceMatrices(List<Map<String, Object>> updatedDetails){
        try {
            if (!updatedDetails.isEmpty()) {
                List<IQVIA_Price_Matrix__c> recordsToUpsert = new List<IQVIA_Price_Matrix__c>();
                for (Map<String, Object> updatedDetail : updatedDetails) {
                    IQVIA_Price_Matrix__c iqviaPriceMatrix = new IQVIA_Price_Matrix__c();
                    for (String field : updatedDetail.keySet()) {
                        iqviaPriceMatrix.put(field, CPQ_Utility.parseFieldValue(sObjectFields.get(field).getDescribe().getType().name(), updatedDetail.get(field)));
                    }
                    recordsToUpsert.add(iqviaPriceMatrix);
                }
                upsert recordsToUpsert;
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateLastStoredMigrationId(String pricingTool, String migrationId){
        try {
            for (CPQ_Pricing_Admin_Settings__c adminSetting : pricingAdminSettings) {
                if (adminSetting.Pricing_Tool__c.equals(pricingTool)) {
                    adminSetting.Last_Stored_Migration_Id__c = migrationId;
                    update adminSetting;
                    return;
                }
            }
            throw new AuraHandledException('No matching pricing tool found.');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String, List<String>> getFieldValuesFromPriceMatrix(Set<String> fieldApiNames, String pricingTool) {
        Map<String, List<String>> fieldValuesMap = new Map<String, List<String>>();
        if (fieldApiNames == null || fieldApiNames.isEmpty()) {
            return fieldValuesMap;
        }
        try {
            String query = 'SELECT ';
            query += String.join(new List<String>(fieldApiNames), ', ');
            query += ' FROM IQVIA_Price_Matrix__c WHERE Pricing_Tool__c = :pricingTool AND ';
            List<String> nonNullConditions = new List<String>();
            for (String fieldName : fieldApiNames) {
                nonNullConditions.add(fieldName + ' != NULL');
            }
            query += String.join(nonNullConditions, ' AND ');
            List<IQVIA_Price_Matrix__c> priceMatrixRecords = Database.query(query);
            Map<String, Set<String>> tempFieldValuesMap = new Map<String, Set<String>>();
            for (String fieldName : fieldApiNames) {
                tempFieldValuesMap.put(fieldName, new Set<String>());
            }
            for (IQVIA_Price_Matrix__c record : priceMatrixRecords) {
                for (String fieldName : fieldApiNames) {
                    Object fieldValue = record.get(fieldName);
                    if (fieldValue != null) {
                        tempFieldValuesMap.get(fieldName).add(String.valueOf(fieldValue));
                    }
                }
            }
            for (String fieldName : fieldApiNames) {
                String fieldLabel = sObjectFields.get(fieldName).getDescribe().getLabel();
                fieldValuesMap.put(fieldLabel, new List<String>(tempFieldValuesMap.get(fieldName)));
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field values: ' + e.getMessage());
        }
        return fieldValuesMap;
    }
}