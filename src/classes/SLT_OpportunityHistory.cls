/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OpportunityHistory
 */
public class SLT_OpportunityHistory extends fflib_SObjectSelector{
 
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_OpportunityHistory() {
        super(false, true, false);
    }
    
   /**
    * constructor to initialize CRUD and FLS
    */
   public SLT_OpportunityHistory(Boolean enforceCRUD, Boolean enforceFLS) {
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
        return OpportunityHistory.sObjectType;
    }
}