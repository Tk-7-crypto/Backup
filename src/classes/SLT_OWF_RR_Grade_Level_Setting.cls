/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OWF GBO Resource Request Setting (Custom Metadata Type)
 */
public class SLT_OWF_RR_Grade_Level_Setting extends fflib_SObjectSelector {
    
    
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_OWF_RR_Grade_Level_Setting(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return OWF_RR_Grade_Level_Setting__mdt.sObjectType;
    }
    
    /**
     * This method used to get all OWF Resource Setting records
     * @return  List<OWF_Resoure_Request_Grade_Level_Setting__mdt>
     */
    public List<OWF_RR_Grade_Level_Setting__mdt> getOWFResourceRequestGradeLevelSettingRecords(Set<String> fieldSet) {
        return new List<OWF_RR_Grade_Level_Setting__mdt>((List<OWF_RR_Grade_Level_Setting__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }
}