/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Default_Product_Search
 */
public class SLT_Default_Product_Search extends fflib_SObjectSelector {
    
    /**
     * constructor
     */    
    public SLT_Default_Product_Search(){
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
        return Default_Product_Search__c.sObjectType;
    }
    
    /**
     * This method used to get Default Product Search By Users
     * @return List<Default_Product_Search__c>
     */
    public List<Default_Product_Search__c> getDefaultProductSearchByUsers(Set<ID> userIdSet, Set<String> fieldSet) {
        return (List<Default_Product_Search__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('User__c in :userIdSet').toSOQL());
    }
}