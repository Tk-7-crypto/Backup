/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Resource Skill Request
 */

public class SLT_Resource_Skill_Request extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Resource_Skill_Request() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Resource_Skill_Request(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_Resource_Skill_Request(Boolean enforceFLS,Boolean enforceCRUD) {
        super(true, enforceCRUD, enforceFLS);
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
        return pse__Resource_Skill_Request__c.sObjectType;
    }
    
    /**
     * This method used to get Resource Skill Request by Resource Request Id
     * @params  Set<Id> rrIdset
     * @params  Set<String> rsrFieldSet
     * @return  Map<Id, pse__Resource_Skill_Request__c>
     */
    public Map<Id, pse__Resource_Skill_Request__c> getResourceSkillRequestByRrID(Set<ID> rrIdset, Set<String> rsrFieldSet) {
        fflib_QueryFactory rsrQueryFactory = newQueryFactory(true);
        String queryString = rsrQueryFactory.selectFields(rsrFieldSet).setCondition('pse__Resource_Request__c in :rrIdset').toSOQL();
        return new Map<Id, pse__Resource_Skill_Request__c>((List<pse__Resource_Skill_Request__c>) Database.query(queryString));
    }
}