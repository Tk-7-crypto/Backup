/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Proxy BNF Object.
 */
public class SLT_ProxySCMAgreement extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_ProxySCMAgreement() {
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
        return Proxy_SCM_Agreement__c.sObjectType;
    }
    
    /**
     * This method used to get Proxy SCM Agreement by OpportunityId
     * @return List<Proxy_SCM_Agreement__c>
     */
    public List<Proxy_SCM_Agreement__c> selectByFilter(Set<ID> oppIdSet, Set<String> fieldSet ,String filterCondition) {
        return (List<Proxy_SCM_Agreement__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
}