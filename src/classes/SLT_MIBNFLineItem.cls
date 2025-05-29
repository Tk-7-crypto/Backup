/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for MI_BNF_LineItem__c Object.
 */
public class SLT_MIBNFLineItem extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_MIBNFLineItem() {
        super(false, false, false);
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
        return MI_BNF_LineItem__c.sObjectType;
    }
    
    /**
    * This method used to get MI_BNF_LineItem__c by OpportunityId
    * @return List<MI_BNF_LineItem__c>
    */
    public List<MI_BNF_LineItem__c> selectByFilter(Set<Id> oliIdsSet, Set<String> fieldSet ,String filterCondition) {
        return (List<MI_BNF_LineItem__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
}