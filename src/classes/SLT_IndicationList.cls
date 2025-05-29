/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Indication List
 */
 public class SLT_IndicationList extends fflib_SObjectSelector{
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Indication_List__c.Id,
            Indication_List__c.Name,
            Indication_List__c.Rare_Disease__c,
            Indication_List__c.Therapy_Area__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Indication_List__c.sObjectType;
    }
     
    /**
     * This method used to get Indication_List__c by Id
     * @return Map<Id, Indication_List__c>
     */ 
    public Map<Id, Indication_List__c> selectById(Set<Id> idSet){
        return new Map<Id, Indication_List__c>((List<Indication_List__c>) selectSObjectsById(idSet));
    }

    /**
     * This method used to get Indication_List__c by Name
     * @return  List<Indication_List__c>
     */
    public List<Indication_List__c> selectByName(Set<String> nameSet, Set<String> fieldSet) {
        return (List<Indication_List__c>)Database.query(newQueryFactory(false, false, false).selectFields(fieldSet).setCondition('Name IN :nameSet').toSOQL());
        //return (List<Indication_List__c>) selectSObjectsByName(nameSet);
    }
}