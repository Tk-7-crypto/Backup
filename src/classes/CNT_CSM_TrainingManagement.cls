public class CNT_CSM_TrainingManagement {
    @AuraEnabled
    public static List<TS_LMS_Catalog_Relationship__c> getLearningCatalogRelationships(Id trainingManagementId) {
        List<TS_LMS_Catalog_Relationship__c> learningCatalogList = [SELECT Id, Name, Catalog__r.Product__r.Name, Catalog__r.Catalog__c, Licenses__c,Training_Management__r.Account_Name__r.Type2__c FROM TS_LMS_Catalog_Relationship__c WHERE Training_Management__c =: trainingManagementId];
        return learningCatalogList;        
    }
    
    @AuraEnabled
    public static List<ProductRelatedBundles> getProductsAndBundles() {
        Map<String, Set<String>> productBundleMap = new Map<String, Set<String>>();
        List<ProductRelatedBundles> productRelatedBundlesList = new List<ProductRelatedBundles>();
        List<TS_LMS_Category__c> categories = [SELECT Product__c, Product__r.Name, Catalog__c, Bundle__c FROM TS_LMS_Category__c ORDER BY Product__c];
        for(TS_LMS_Category__c category: categories) {
            if(productBundleMap.containsKey(category.Product__r.Name)) {
                productBundleMap.get(category.Product__r.Name).add(category.Bundle__c);
            }
            else {
                productBundleMap.put(category.Product__r.Name, new Set<String>{category.Bundle__c});
            }
        }
        for(String productName: productBundleMap.keySet()) {
            ProductRelatedBundles productBundleWrapper = new ProductRelatedBundles();
            productBundleWrapper.productName = productName;
            productBundleWrapper.bundles = new List<String>(productBundleMap.get(productName));
            productRelatedBundlesList.add(productBundleWrapper);
        }
        return productRelatedBundlesList;
    }
    
    @AuraEnabled
    public static List<TS_LMS_Category__c> getRelatedCatalogs(String selectedProduct, String selectedBundle,String account_type) {
        String query = 'SELECT Id, Name, Catalog__c,Account_Type__c FROM TS_LMS_Category__c WHERE Active__c = true AND Product__r.Name = \'' + selectedProduct + '\'';
        String acc_condition = ' AND Account_Type__c = \'';
        if(account_type == 'Customer'){
            acc_condition += 'Customer';
        }else if(account_type == 'Tech Partner' || account_type == 'Data Partner' || account_type == 'Integrator' || account_type == 'CLM Agency'){
            acc_condition += 'Partner';
        }
        query = selectedBundle != null && selectedBundle != '' && selectedBundle != 'Please Specify' ? query + ' AND Bundle__c = \'' + selectedBundle + '\''+acc_condition+ '\'' : query;
        query += ' ORDER BY Catalog__c'; 
        List<TS_LMS_Category__c> categories = Database.query(query);
        List<SelectOption> catalogOptions = new List<SelectOption>();
        for(TS_LMS_Category__c category: categories) {
            catalogOptions.add(new SelectOption(category.Catalog__c, category.Id));
        }
        return categories;
    }
    
    @AuraEnabled
    public static void saveLearningCatalogRelationships(String learningCatalogRelationshipsJSON) {
        if(learningCatalogRelationshipsJSON != null && learningCatalogRelationshipsJSON != '') {
            List<TS_LMS_Catalog_Relationship__c> learningCatalogList = (List<TS_LMS_Catalog_Relationship__c>) 
                System.JSON.deserialize(learningCatalogRelationshipsJSON, List<TS_LMS_Catalog_Relationship__c>.class);
            if(learningCatalogList != null && learningCatalogList.size() > 0) {
                insert learningCatalogList;
            }
        }
    }
    
    public class ProductRelatedBundles {
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Id productId;
        @AuraEnabled
        public List<String> bundles;
    }
    
    public class TrainingManagementWrapper {
        @AuraEnabled
        public String selectedProduct;
        @AuraEnabled
        public String selectedBundle;
        @AuraEnabled
        public List<TS_LMS_Category__c> catalogs;
    }
    
    public class SelectOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
