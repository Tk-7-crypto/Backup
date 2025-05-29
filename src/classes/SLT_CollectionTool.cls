public class SLT_CollectionTool extends fflib_SObjectSelector {

    //constructor to initialize CRUD and FLS
    public SLT_CollectionTool() {
        super(false, true, true);
    }
    
	//constructor to initialise CRUD and FLS with a parameter for FLS.
    public SLT_CollectionTool(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    public SLT_CollectionTool(Boolean enforceFLS,Boolean enforceCRUD) {
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
        return CollectionTool__c.sObjectType;
    }
    
    public List<CollectionTool__c> getCollectionToolsByCondition(Id bidHistoryId, Set<String> fieldSet, String condition) {
        fflib_QueryFactory ctQueryFactory = newQueryFactory(true);
        String queryString = ctQueryFactory.selectFields(fieldSet).setCondition('Bid_History__c = :bidHistoryId ' + condition).setOrdering('Scenario_Number__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        System.debug('queryString:'+queryString);
        return new List<CollectionTool__c>((List<CollectionTool__c>) Database.query(queryString));
    }

    public List<CollectionTool__c> getCollectionToolsByConditionOrderByStudyNumber(Id bidHistoryId, Set<String> fieldSet, String condition) {
        fflib_QueryFactory ctQueryFactory = newQueryFactory(true);
        String queryString = ctQueryFactory.selectFields(fieldSet).setCondition('Bid_History__c = :bidHistoryId ' + condition).setOrdering('Study_Number__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return new List<CollectionTool__c>((List<CollectionTool__c>) Database.query(queryString));
    }
    
    public List<CollectionTool__c> getCollectionToolsByBidHistoryId(Id bidHistoryId, Set<String> fieldSet){
        return (List<CollectionTool__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Bid_History__c = :bidHistoryId').toSOQL());
	}
    public List<CollectionTool__c> getCollectionToolsByBidHistoryIdandType(Id bidHistoryId, Set<String> fieldSet,String type){
        return (List<CollectionTool__c>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Bid_History__c = :bidHistoryId and Type__c =: type').toSOQL());
	}

    public List<CollectionTool__c> getCollectionToolRecords(String condition , Set<String> fieldSet) {
        fflib_QueryFactory quoteQueryFactory = newQueryFactory(true);
        String queryString = quoteQueryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Scenario_Number__c',  fflib_QueryFactory.SortOrder.DESCENDING, true).toSOQL();
        return (List<CollectionTool__c>)Database.query(queryString);
    }
    public List<CollectionTool__c> getCollectionToolRecordsbycondition(String condition , Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        String queryString = queryFactory.selectFields(fieldSet).setCondition(condition).setOrdering('Scenario_Number__c', fflib_QueryFactory.SortOrder.ASCENDING, true).toSOQL();
        return (List<CollectionTool__c>)Database.query(queryString);
    }
}