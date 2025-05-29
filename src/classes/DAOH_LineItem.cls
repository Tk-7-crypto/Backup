public class DAOH_LineItem {
    public static void trackChangeOnLineItem(List<Apttus_Config2__LineItem__c> newQuoteList, Map<Id, Apttus_Config2__LineItem__c> oldMap) {
        Set<Id> configId = new Set<Id>();
        if (newQuoteList.size() > 0) {
            for (Apttus_Config2__LineItem__c linItem : newQuoteList) {
                configId.add(linItem.Apttus_Config2__ConfigurationId__c);
            } 
            if (configId.size() > 0) {
                Map<Id, String> configIdToPricingToolMap = getPricingToolByConfigId(configId);
                for (Apttus_Config2__LineItem__c lineItem : newQuoteList) {
                    if (configIdToPricingToolMap != null && configIdToPricingToolMap.containsKey(lineItem.Apttus_Config2__ConfigurationId__c) && (configIdToPricingToolMap.get(lineItem.Apttus_Config2__ConfigurationId__c) == CON_CPQ.Complete_Consent || configIdToPricingToolMap.get(lineItem.Apttus_Config2__ConfigurationId__c) == CON_CPQ.Q2_Solutions) && lineItem.Apttus_Config2__LineType__c == CON_CPQ.OPTION) {
                        if (oldMap == null) {
                            lineItem.Change_From_Previous__c = 'Added';
                        } else if (oldMap != null && lineItem.Apttus_Config2__PricingStatus__c == CON_CPQ.PENDING && oldMap.get(lineItem.Id).Change_From_Previous__c == null) {
                            lineItem.Change_From_Previous__c = 'Updated';
                        }
                    }
                }
            }
        }
    }
    public static Map<Id, String> getPricingToolByConfigId(Set<Id> configId) {
        String condition = 'Id IN :configId AND Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c = ' + '\'' + CON_CPQ.CHANGE_ORDER + '\'';
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.PRODUCT_CONFIG_TO_QUOTE_PRICING_TOOL};
        List<Apttus_Config2__ProductConfiguration__c> productConfigList = new SLT_ProductConfiguration().getProductConfigByCondition(configId, condition, fieldSet);
        Map<Id, String> pricingToolToConfigIdMap = new Map<Id, String>();
        if (productConfigList.size() > 0) {
            pricingToolToConfigIdMap.put(productConfigList[0].Id, productConfigList[0].Apttus_QPConfig__Proposald__r.Select_Pricing_Tool__c);
            return pricingToolToConfigIdMap;
        } 
        return pricingToolToConfigIdMap;
    }
}