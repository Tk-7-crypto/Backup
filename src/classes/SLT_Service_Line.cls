/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Service Line
 */
public class SLT_Service_Line extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Service_Line() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Service_Line(Boolean enforceFLS) {
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
        return Service_Line__c.sObjectType;
    }

    /**
    * Method to get Service Lines by Id 
    * @return List<Service_Line__c>
    */
    public List<Service_Line__c> selectById(Set<Id> idSet, Set<String> fieldSet){
        return (List<Service_Line__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :idSet').toSOQL());
    }

    /**
    * Method to get Service Lines by Name 
    * @return List<Service_Line__c>
    */
    public List<Service_Line__c> selectByName(Set<String> nameSet, Set<String> fieldSet){
        return (List<Service_Line__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name IN :nameSet').toSOQL());
    }
}