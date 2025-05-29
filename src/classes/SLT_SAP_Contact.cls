/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SAP Contact
 */
public without sharing class SLT_SAP_Contact extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SAP_Contact__c.Id,
            SAP_Contact__c.Name
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return SAP_Contact__c.sObjectType;
    }
    
    /**
     * This method used to get Account by Id
     * @return  Map<Id, SAP_Contact__c>
     */
    public Map<Id, SAP_Contact__c> selectBySapContactId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, SAP_Contact__c>((List<SAP_Contact__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    /**
     * This method used to get SAP Contact by address Id Set
     * @param Set<String> fieldSet
     * @param String condition
     * @param Set<Id> addressIdSet
     * @return  List<SAP_Contact__c>
     */
    public List<SAP_Contact__c> getSapContactByAddressIdSet(Set<String> fieldSet, String condition, Set<Id> addressIdSet){
        return ((List<SAP_Contact__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL()));
    }
    
}