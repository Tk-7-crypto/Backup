public class SLT_ECOA_Collection_Tool  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_ECOA_Collection_Tool() {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_ECOA_Collection_Tool(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    public SLT_ECOA_Collection_Tool(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
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
        return ECOA_Collection_Tool__c.sObjectType;
    }
    
    public List<ECOA_Collection_Tool__c> getEcoaCollectionToolByBidHistoryId(Id bidHistoryId, Set<String> fieldSet, String condition) {
        fflib_QueryFactory ctQueryFactory = newQueryFactory(true);
        String queryString = ctQueryFactory.selectFields(fieldSet).setCondition('Bid_History__c = :bidHistoryId '+condition).setOrdering('Scenario_Number__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return new List<ECOA_Collection_Tool__c>((List<ECOA_Collection_Tool__c>) Database.query(queryString));
    }

}