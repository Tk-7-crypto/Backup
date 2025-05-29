public class CNT_CRM_Pricing_Tool_Recommendation {
    
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> getPricingTool(Id recordId) {
        Map < String, Object > returnMap = new Map<String, Object>();
        Opportunity oppRecord = new SLT_Opportunity().getOpportunityDetails(recordId, new Set<String> {'Id', 'Name', 'Business_Unit__c', 'Main_Delivery_Country__c','PA_Required__c','Pricing_Tool_Recommended__c'});
        Map<Id,String> pricingToolMap = DAOH_Opportunity.getPricingTools(new List<Opportunity>{oppRecord});
        String recommendedTool;
        
        if(pricingToolMap.containsKey(oppRecord.Id)){
            recommendedTool = pricingToolMap.get(oppRecord.Id);
            if(recommendedTool == ''){
                returnMap.put('OtherPricingTool', (Object)new Set < String > {'Pricing Assistant', 'Pricing Template'});
            }
            else if(recommendedTool == 'Pricing Assistant') {
                returnMap.put('RecommenedPricingTool', (Object)'Pricing Assistant');
                returnMap.put('OtherPricingTool', (Object)new Set < String > {'Pricing Template'});
            }
            else if(recommendedTool == 'Pricing Template') {
                returnMap.put('RecommenedPricingTool', (Object)'Pricing Template');
                returnMap.put('OtherPricingTool', (Object)new Set < String > {'Pricing Assistant'});
            }
        }
        return returnMap;
    }
    
    @AuraEnabled(cacheable = false)
    public static String setPricingTool(Id recordId, String pricingToolSelected) {
        Opportunity Opp = new Opportunity(Id = recordId, Pricing_Tool_Last_Selected__c = pricingToolSelected, Pricing_Tool_Last_Selected_DateTime__c = System.Now());
        update opp;
        if(pricingToolSelected != 'Pricing Assistant'){
            List < Pricing_Tool_Links__c > ptls = Pricing_Tool_Links__c.getAll().values();
            for (Pricing_Tool_Links__c ptl : ptls) {
                if (ptl.Pricing_Tool_Name__c == pricingToolSelected) {
                    return ptl.Pricing_Tool_URL__c;
                }
            }
        }
        return null;
    }
}