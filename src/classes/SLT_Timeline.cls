/**
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AgreementLineItems
 */
public class SLT_Timeline extends fflib_SObjectSelector{
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Timeline() {
        super(false, true, false);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Timeline(Boolean enforceFLS) {
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
        return Timeline__c.sObjectType;
    }
    
    /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<OpportunityLineItem>
     */
    public List<Timeline__c> selectByAgreementIds(Set<Id> parentIdsSet, Set<String> fieldSet, String condition) {
        return (List<Timeline__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
    
    /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<OpportunityLineItem>
     */
    public List<Timeline__c> selectByAgreementIdAndTimelineNames(Set<Id> parentIdsSet, Set<String> fieldSet, Set<String> timelineSet, String condition) {
        return (List<Timeline__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}