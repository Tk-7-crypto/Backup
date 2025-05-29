public class SLT_PricingAssistant extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    public SLT_PricingAssistant() {
        super(true, false, false);
    }
    public Schema.SObjectType getSObjectType() {
        return PC_Pricing_Calculator__x.sObjectType;
    }
    public static List<PC_Pricing_Calculator__x> getPricingAssistantRecord(String oppId){
        return [SELECT Id FROM PC_Pricing_Calculator__x WHERE  Opportunity__c = :oppId];
    }
}