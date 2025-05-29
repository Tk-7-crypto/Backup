/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Potential_Region_To_BD_Lead_Mapping
 */
public class SLT_Potential_Region_To_BD_Lead_Mapping extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Potential_Region_To_BD_Lead_Mapping() {
        super(false, true, true);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_Potential_Region_To_BD_Lead_Mapping(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return Potential_Region_To_BD_Lead_Mapping__mdt.sObjectType;
    }
    
    /**
     * This method used to get all Potential_Region_To_BD_Lead_Mapping__mdt
     * @return  List<Potential_Region_To_BD_Lead_Mapping__mdt>
     */
    public List<Potential_Region_To_BD_Lead_Mapping__mdt> getPotentialRegionToBDLeadMappings(Set<String> fieldSet) {
        return new List<Potential_Region_To_BD_Lead_Mapping__mdt>((List<Potential_Region_To_BD_Lead_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }
}