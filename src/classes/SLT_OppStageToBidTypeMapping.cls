/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Opp_Stage_to_Bid_Type_Mapping custom metadata type
 */
public class SLT_OppStageToBidTypeMapping extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OppStageToBidTypeMapping() {
        super(false, true, true);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_OppStageToBidTypeMapping(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return Opp_Stage_to_Bid_Type_Mapping__mdt.sObjectType;
    }
    
    /**
     * This method used to get all Agreement_Type_Bid_Mapping
     * @return  List<Agreement_Type_Bid_Mapping__mdt>
     */
    public List<Opp_Stage_to_Bid_Type_Mapping__mdt> getOppStageToBidTypeMappings(Set<String> fieldSet) {
        return new List<Opp_Stage_to_Bid_Type_Mapping__mdt>((List<Opp_Stage_to_Bid_Type_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }

}