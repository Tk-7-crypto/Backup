/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Agreement_Type_Bid_Mapping
 */
public class SLT_Agreement_Type_Bid_Mapping extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Agreement_Type_Bid_Mapping() {
        super(false, true, true);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_Agreement_Type_Bid_Mapping(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return Agreement_Type_Bid_Mapping__mdt.sObjectType;
    }
    
    /**
     * This method used to get all Agreement_Type_Bid_Mapping
     * @return  List<Agreement_Type_Bid_Mapping__mdt>
     */
    public List<Agreement_Type_Bid_Mapping__mdt> getAgreementTypeBidMappings(Set<String> fieldSet) {
        return new List<Agreement_Type_Bid_Mapping__mdt>((List<Agreement_Type_Bid_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()));
    }
}