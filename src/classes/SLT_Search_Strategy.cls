public with sharing class SLT_Search_Strategy extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Search_Strategy() {
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Search_Strategy(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Search_Strategy__c.Id, Search_Strategy__c.Name};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Search_Strategy__c.sObjectType;
    }
    
    /**
     * This method used to query Search_Strategy__c
     * @return  List<Search_Strategy__c>
     */
    public List<Search_Strategy__c> getSearchStrategies(Set<String> fieldSet){
        return (List<Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to query Search_Strategy__c By lRProjectOverViewIds
     * @return  Search_Strategy__c 
     */
    public List<Search_Strategy__c> getSearchStrategiesBylRProjectOverViewIds( Set<String> lRProjectOverViewIds, Set<String> fieldSet ){
        return (List<Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c IN : lRProjectOverViewIds').toSOQL());
    }
    
    /**
     * This method used to query Search_Strategy__c By Search Strategy Ids
     * @return  Search_Strategy__c 
     */
    public List<Search_Strategy__c> getSearchStrategiesByIds(Set<id> searchStrategyIds, Set<String> fieldSet ){
        return (List<Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : searchStrategyIds').setLimit(5).toSOQL());
    }
    /**
     * This method used to query Search_Strategy__c By Search Strategy Ids
     * @return  Search_Strategy__c 
     */
    public List<Search_Strategy__c> getSearchStrategiesByIdsForPagination(Set<id> searchStrategyIds, Set<String> fieldSet,Integer pageSize, Integer offset ){
        return (List<Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : searchStrategyIds').setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
}
