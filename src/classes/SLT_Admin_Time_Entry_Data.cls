/**
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Admin_Time_Entry_Data__c
 */
public class SLT_Admin_Time_Entry_Data extends fflib_SObjectSelector{
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Admin_Time_Entry_Data() {
        super(false, true, false);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Admin_Time_Entry_Data(Boolean enforceFLS) {
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
        return Admin_Time_Entry_Data__c.sObjectType;
    }
    
    /**
     * This method used to get Admin_Time_Entry_Data__c Records by condition
     * @return  List<Admin_Time_Entry_Data__c>
     */
    public List<Admin_Time_Entry_Data__c> selectByCondition(Set<Id> parentIdsSet, Set<String> fieldSet, String condition) {
        return (List<Admin_Time_Entry_Data__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}