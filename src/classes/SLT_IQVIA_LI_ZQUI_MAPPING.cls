/*
* Version       : 1.0
* Description   : This Apex class is selector layer for IQVIA_LI_ZQUI_MAPPING__c
*/
public class SLT_IQVIA_LI_ZQUI_MAPPING extends fflib_SObjectSelector {
    
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
        return IQVIA_LI_ZQUI_MAPPING__c.sObjectType;
    }
    
    public Map<Id, IQVIA_LI_ZQUI_MAPPING__c> zquiMappingByLiOLIId(Set<Id> oliIds, Set<String> fieldSet,String condition){
        return new Map<Id, IQVIA_LI_ZQUI_MAPPING__c>((List<IQVIA_LI_ZQUI_MAPPING__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition+' LI_OpportunityLineItem_Id__c IN : oliIds').toSOQL()));
    }
}