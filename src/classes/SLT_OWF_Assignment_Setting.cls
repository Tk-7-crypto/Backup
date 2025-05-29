/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OWF Assignment Setting (Custom Metadata Type)
 */
public class SLT_OWF_Assignment_Setting extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OWF_Assignment_Setting() {
        super(false, true, true);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_OWF_Assignment_Setting(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
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
        return OWF_Assignment_Setting__mdt.sObjectType;
    }
    
    /**
     * Method to override OrderBy
     */
    public override String getOrderBy() {
        return 'Complexity_Score__c DESC';
    }
    
    /**
     * This method used to get all OWF Assignment Setting records
     * @return  List<OWF_Resource_Setting__mdt>
     */
    public List<OWF_Assignment_Setting__mdt> getOWFAssignmentSettingRecords(Set<String> fieldSet) {
        return new List<OWF_Assignment_Setting__mdt>((List<OWF_Assignment_Setting__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }
}