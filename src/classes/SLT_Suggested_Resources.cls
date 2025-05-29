/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Suggested Resources
 */
public class SLT_Suggested_Resources extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Suggested_Resources() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Suggested_Resources(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_Suggested_Resources(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return Suggested_Resources__c.sObjectType;
    }
    
    /**
     * This method used to get Suggested Resources by Resource Request IdSet
     * @params  Set<Id> resourceRequestIdset
     * @params  Set<String> suggestedResourceFieldSet
     * @return  Map<Id, pse__Resource_Request__c>
     */
    public List<Suggested_Resources__c> getSuggestedResourcesByResourceRequestID(Set<ID> resourceRequestIdset, Set<String> suggestedResourceFieldSet) {
        fflib_QueryFactory resourceRequestQueryFactory = newQueryFactory(true);
        String queryString = resourceRequestQueryFactory.selectFields(suggestedResourceFieldSet).setCondition('Resource_Request__c in :resourceRequestIdset').toSOQL();
        return (List<Suggested_Resources__c>) Database.query(queryString);
    }

    
}