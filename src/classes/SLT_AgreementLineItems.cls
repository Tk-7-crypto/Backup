/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AgreementLineItems
 */public class SLT_AgreementLineItems extends fflib_SObjectSelector{

     /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_AgreementLineItems() {
        super(false, true, false);
    }
     
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_AgreementLineItems(Boolean enforceFLS) {
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
        return Apttus__AgreementLineItem__c.sObjectType;
    }
     
    /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<OpportunityLineItem>
     */
    public List<Apttus__AgreementLineItem__c> selectByIds(Set<ID> agreementLineItemIdsSet, Set<String> fieldSet) {
        return (List<Apttus__AgreementLineItem__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :agreementLineItemIdsSet').toSOQL());
    }
     
     /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<OpportunityLineItem>
     */
    public List<Apttus__AgreementLineItem__c> selectByAgreementIds(Set<ID> agreementIdsSet, Set<String> fieldSet) {
        return (List<Apttus__AgreementLineItem__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Apttus__AgreementId__c in :agreementIdsSet').toSOQL());
    }
	
    /**
     * This method used to get AgreementLineItem Records by agreement Id
     * @return  List<Apttus__AgreementLineItem__c>
     */
    public List<Apttus__AgreementLineItem__c> selectByAgreementId(Id agreementID) {
        return [Select id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c = : agreementID];
    }	
   
    /**
     * This method is used to get all Schedule1 AgreementLineItem records for agreement Id
     * 
     */
    public List<Apttus__AgreementLineItem__c> selectSchedule1ByAgreementIds(Set<ID> agreementLineItemIdsSet, Set<String> fieldSet) {
        return (List<Apttus__AgreementLineItem__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Apttus__AgreementId__c in :agreementLineItemIdsSet AND Schedule1_Id__c != NULL').toSOQL());
    }
    
}