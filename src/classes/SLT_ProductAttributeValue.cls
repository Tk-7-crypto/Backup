public class SLT_ProductAttributeValue extends fflib_SObjectSelector {
     /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus_Config2__ProductAttributeValue__c.Id,
            Apttus_Config2__ProductAttributeValue__c.Market_Share__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Apttus_Config2__ProductAttributeValue__c.SObjectType;
    }

    /**
    * This method used to get Line Item by Id
    * @return  List<ATC_OTC_Classification__c>
    */
    public List<Apttus_Config2__ProductAttributeValue__c> selectById(Set<Id> idSet) {
        return (List<Apttus_Config2__ProductAttributeValue__c>) selectSObjectsById(idSet);
    }
	
    /**
    * This method used to get Line Item by Id
    * @return  Apttus_Config2__ProductAttributeValue__c
    */
    public Apttus_Config2__ProductAttributeValue__c selectedProductAttributeRecords(Id lineItemId, Set<String> fieldSet) {
        return (Apttus_Config2__ProductAttributeValue__c) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('Apttus_Config2__LineItemId__c =: lineItemId')
            .toSOQL());
    }
    //Method use to return Product Attribute Value record based on Id and FieldSet.
    public Map<Id,Apttus_Config2__ProductAttributeValue__c> getProductAttributeRecords(Set<Id> recordIds, Set<String> fieldSet) {
        return new Map<Id, Apttus_Config2__ProductAttributeValue__c>((List<Apttus_Config2__ProductAttributeValue__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :recordIds').toSOQL()));
    }																			   
}