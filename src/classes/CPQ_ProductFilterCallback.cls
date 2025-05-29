global with sharing class CPQ_ProductFilterCallback implements Apttus_Config2.CustomClass.IProductFilterCallback {
    /**
     * Callback to return part of SOQL filter clause
     * This filter is used in listing catalog products
     */
    
    global String getProductFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
        return '';
    }
 
    /**
     * Callback to return part of SOQLfilter clause
     * This filter is used in listing option products
     */
    global String getOptionFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
        List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: CON_CPQ.DPS_Permission_Set];
        if (psaList.size() > 0) {
            List<Apttus_Config2__ProductConfiguration__c> productConfiguration = new SLT_ProductConfiguration().selectFieldSetById(new Set<Id>{params.ConfigurationId}, new Set<String>{CON_CPQ.Id, CON_CPQ.PRODUCT_CONFIG_TO_QUOTE_PRICING_TOOL, CON_CPQ.IQVIA_QUOTE_LICENSE_TYPE, CON_CPQ.IQVIA_QUOTE_DOCUMENT_TYPE});
            String pricingTool = productConfiguration[0].Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c;
            String licenseType = productConfiguration[0].Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.License_Type__c;
            String documentType = productConfiguration[0].Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Document_Type__c;
            if (pricingTool == CON_CPQ.COMPLETE_CONSENT && licenseType != null) {
                String products = UTL_CPQ_ProductFilterCallback.productsExcludeForDPS(licenseType, documentType);
                return products;
            } 
        }
        return '';
    }
}