/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ProxyPricingAssistant
 */
public class SLT_ProxyPricingAssistant extends fflib_SObjectSelector {

    /**
     * constructor
     */    
    public SLT_ProxyPricingAssistant() {
        super(false, true, true); 
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Proxy_Pricing_Assistant__c.sObjectType;
    }
    
    /**
     * This method to get Proxy Pricing Assistant by opportunityId
     * @return  List<Proxy_Pricing_Assistant__c>
     */
    public List<Proxy_Pricing_Assistant__c> selectByOpportunityIds(Set<Id> oppIdSet, Set<String> fieldSet) {
        return (List<Proxy_Pricing_Assistant__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Opportunity__c IN :oppIdSet').toSOQL());
    }

    /**
     * This method to get Proxy Pricing Assistant by opportunityId
     * @return  List<Proxy_Pricing_Assistant__c>
     */
    public List<Proxy_Pricing_Assistant__c> getByOpportunityIds(Set<String> fieldSet, String condition, Set<Id> opportunityIdSet) {
        return new List<Proxy_Pricing_Assistant__c>((List<Proxy_Pricing_Assistant__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
}