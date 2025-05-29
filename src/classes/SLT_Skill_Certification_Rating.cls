/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Skill / Certification Rating
 */
public class SLT_Skill_Certification_Rating extends fflib_SObjectSelector {
    
    public String orderByField = 'Name';
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Skill_Certification_Rating() {
        super(false, true, true);
    }
    public SLT_Skill_Certification_Rating(Boolean enforceFLS,Boolean enforceCRUD) {
        super(true, enforceFLS, enforceCRUD);
    }
    public override String getOrderBy() {
        return orderByField;
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Skill_Certification_Rating(Boolean enforceFLS) {
        super(false, true, enforceFLS);
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
        return pse__Skill_Certification_Rating__c.sObjectType;
    }
    /**
     * This method used to get Skill Certification Rating records by Resource(Contact)
     * @params  Set<Id> sObjectIdset
     * @params  String skillCertRatingCondition
     * @params  Set<String> skillCertRatingFieldSet
     * @params  Used For RADDS Module
     * @return  List<pse__Skill_Certification_Rating__c>
     */
    public List<pse__Skill_Certification_Rating__c> getSkillCertificationRatingsByResourceIds(Set<ID> resourceIdSet, String skillCertRatingCondition, Set<String> skillCertRatingFieldSet,Boolean isNeedLimit) {
        orderByField ='LastModifiedDate DESC';
        fflib_QueryFactory skillCertRatingQueryFactory = newQueryFactory(true);
        String queryString ='';
        if(isNeedLimit){
            queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).setLIMIT(8).toSOQL();
        }else{
           queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).toSOQL(); 
        }
        return ((List<pse__Skill_Certification_Rating__c>) Database.query(queryString));
    }
    /**
     * This method used to get Skill Certification Rating records by Resource(Contact)
     * @params  Set<Id> sObjectIdset
     * @params  String skillCertRatingCondition
     * @params  Set<String> skillCertRatingFieldSet
     * @return  Map<Id, pse__Skill_Certification_Rating__c>
     */
    public Map<Id, pse__Skill_Certification_Rating__c> getSkillCertificationRatingsByContactIds(Set<ID> sObjectIdset, String skillCertRatingCondition, Set<String> skillCertRatingFieldSet) {
        orderByField = 'pse__Resource__c, pse__Skill_Certification__c,pse__Rating__c DESC';
        if(skillCertRatingCondition != null && skillCertRatingCondition != ''){
            if(!skillCertRatingCondition.contains('Is_Duplicate__c')){
                skillCertRatingCondition += ' AND Is_Duplicate__c = FALSE';
            }
            if(!skillCertRatingCondition.contains('pse__Is_Resource__c')){
                skillCertRatingCondition += ' AND pse__Resource__r.pse__Is_Resource__c = TRUE';
            }
            if(!skillCertRatingCondition.contains('pse__Is_Resource_Active__c')){
                skillCertRatingCondition += ' AND pse__Resource__r.pse__Is_Resource_Active__c = TRUE';
            }
            if(!skillCertRatingCondition.contains('Active__c')){
                skillCertRatingCondition += ' AND Active__c = TRUE';
            }
        }else{
            skillCertRatingCondition += ' pse__Resource__r.pse__Is_Resource__c = TRUE AND pse__Resource__r.pse__Is_Resource_Active__c = TRUE AND Is_Duplicate__c = FALSE';
        }
        fflib_QueryFactory skillCertRatingQueryFactory = newQueryFactory(true);
        String queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).toSOQL();
        //system.assert(false,queryString);
        return new Map<Id, pse__Skill_Certification_Rating__c>((List<pse__Skill_Certification_Rating__c>) Database.query(queryString));
    }
    
    /**
     * This method used to get Skill Certification Rating records by Skills
     * @params  Set<Id> sObjectIdset
     * @params     String skillCertRatingCondition
     * @params  Set<String> skillCertRatingFieldSet
     * @return  Map<Id, pse__Skill_Certification_Rating__c>
     */
    public Map<Id, pse__Skill_Certification_Rating__c> getSkillCertificationRatingsBySkills(Set<ID> sObjectIdset, String skillCertRatingCondition, Set<String> skillCertRatingFieldSet, Set<String> subGroupSet) {
        fflib_QueryFactory skillCertRatingQueryFactory = newQueryFactory(true);
        String queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).toSOQL();
        return new Map<Id, pse__Skill_Certification_Rating__c>((List<pse__Skill_Certification_Rating__c>) Database.query(queryString));
    }
    
    public Map<Id, pse__Skill_Certification_Rating__c> getSkillCertificationRatingsBySkillsContact(Set<ID> resourceIdSet, Set<Id> skillIdSet, String skillCertRatingCondition, Set<String> skillCertRatingFieldSet) {
        orderByField = 'pse__Resource__c, pse__Skill_Certification__c, pse__Numerical_Rating__c desc';
        fflib_QueryFactory skillCertRatingQueryFactory = newQueryFactory(true);
        String queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).toSOQL();
        return new Map<Id, pse__Skill_Certification_Rating__c>((List<pse__Skill_Certification_Rating__c>) Database.query(queryString));
    }
    /**
     * This method used to get Skill Certification Rating records by contactIds
     * @params  Set<Id> sObjectIdset
     * @params     String skillCertRatingCondition
     * @params  Set<String> skillCertRatingFieldSet
     * @return  Map<Id, pse__Skill_Certification_Rating__c>
     */
     
    public Map<Id, pse__Skill_Certification_Rating__c> getSkillCertificationRatingsByContactIdsOrdering(Set<Id> resourceIdSet, Set<Id> ratingIdSet, String skillCertRatingCondition, Set<String> skillCertRatingFieldSet) {
        orderByField = 'pse__Resource__c, pse__Skill_Certification__c, pse__Numerical_Rating__c desc';
        fflib_QueryFactory skillCertRatingQueryFactory = newQueryFactory(true);
        String queryString = skillCertRatingQueryFactory.selectFields(skillCertRatingFieldSet).setCondition(skillCertRatingCondition).toSOQL();
        //system.assert(false,queryString );
        System.debug('queryString @@' + queryString);
        return new Map<Id, pse__Skill_Certification_Rating__c>((List<pse__Skill_Certification_Rating__c>) Database.query(queryString));
    }
}
