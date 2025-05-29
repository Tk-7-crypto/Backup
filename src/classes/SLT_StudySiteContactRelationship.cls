public class SLT_StudySiteContactRelationship  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_StudySiteContactRelationship() {
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
        return StudySiteContactRelationship__c.sObjectType;
    }
    
    /**
     * This method used to get StudySiteContactRelationship__c by Id
     * @return  Map<Id, StudySiteContactRelationship__c>
     */
    public Map<Id, StudySiteContactRelationship__c> selectByStudySiteContactRelationshipId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, StudySiteContactRelationship__c>((List<StudySiteContactRelationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
        public List<StudySiteContactRelationship__c> selectAccountBySiteId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<StudySiteContactRelationship__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
}