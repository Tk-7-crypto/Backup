/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Skill / Certification.
 */
public class SLT_Skill extends fflib_SObjectSelector {
	/**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Skill() {
        super(false, true, true);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_Skill(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return pse__Skill__c.sObjectType;
    }
    
    /**
     * This method used to get all Skill records
     * @return  Map<Id, pse__Skill__c>
     */
    public Map<Id, pse__Skill__c> getAllSkillRecords(Set<String> fieldSet) {
        return new Map<Id, pse__Skill__c>((List<pse__Skill__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }
    
    /**
     * This method used to get Skills by Id
     * @return  Map<Id, pse__Skill__c>
     */
    public Map<Id, pse__Skill__c> getSkillsByCondition(Set<ID> idSet, Set<String> fieldSet, String skillCondition) {
        return new Map<Id, pse__Skill__c>((List<pse__Skill__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(skillCondition).toSOQL()));
    }

}