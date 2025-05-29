/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Investigator Grant Object.
 */
 
 
public class SLT_InvestigatorGrant extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_InvestigatorGrant() {
       super(false, true, true);
    }
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_InvestigatorGrant(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return Investigator_Grant__c.sObjectType;
    }
    
    /**
    * This method used to get Investigator Grant by Id
    * @return  Map<Id, Investigator_Grant__c>
    */
    public Map<Id, Investigator_Grant__c> getInvestigatorGrantById(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Investigator_Grant__c>((List<Investigator_Grant__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Investigator_Grant__c> getInvestigatorGrantByBidHistoryId(Set<Id> sObjectIdset, String condition, Set<String> fieldSet) {
        return new List<Investigator_Grant__c>((List<Investigator_Grant__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
}