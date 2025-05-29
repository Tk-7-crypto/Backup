/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Product_Group_Relationship__c
 */
public without sharing class SLT_ProductGroupRelationship extends fflib_SObjectSelector  {
    /**
* This method used to get field list of sobject
* @return  List<Schema.SObjectField>
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product_Group_Relationship__c.Product__c,
            Product_Group_Relationship__c.Name,
            Product_Group_Relationship__c.Id,
            Product_Group_Relationship__c.Collaboration_Group_Id__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Product_Group_Relationship__c.sObjectType;
    }
    
    /**
     * This method used to get Product_Group_Relationship__c by Id
     * @return  List<Product_Group_Relationship__c>
     */
    public List<Product_Group_Relationship__c> selectById(Set<ID> idSet) {
        return (List<Product_Group_Relationship__c>) selectSObjectsById(idSet);
    }
    
    /**
    * This method used to get listsof Product_Group_Relationship__c
    * @return  list
    */
    public List<Product_Group_Relationship__c> getProductRelationships(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
}