/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Information_Offering_Forms__c
 */
public without sharing class SLT_InformationOfferingForm extends fflib_SObjectSelector  {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Information_Offering_Forms__c.Form_Request_Type__c,
            Information_Offering_Forms__c.Name,
            Information_Offering_Forms__c.Id,
            Information_Offering_Forms__c.Case__c,
            Information_Offering_Forms__c.LastModifiedDate
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Information_Offering_Forms__c.sObjectType;
    }
    
    /**
     * This method used to get Information_Offering_Forms__c by Id
     * @return  List<Information_Offering_Forms__c>
     */
    public List<Information_Offering_Forms__c> selectById(Set<ID> idSet) {
        return (List<Information_Offering_Forms__c>) selectSObjectsById(idSet);
    }
    
    /**
    * This method used to get list of Information Offering Forms
    * @return  list
    */
    public List<Information_Offering_Forms__c> getInformationOfferingByCondition(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    
    /**
    * This method used to get lists of Information Offering Forms
    * @return  list
    */
    public List<Information_Offering_Forms__c> getOfferingsById(Set<String> fieldSet, Set<Id> idSet) {
        return (List<Information_Offering_Forms__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
}