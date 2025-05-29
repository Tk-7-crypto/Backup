public with sharing class SLT_PSA_ArchiveSearchStrategy extends fflib_SObjectSelector {
    
    //constructor to initialize CRUD and FLS
    public SLT_PSA_ArchiveSearchStrategy() {
        super(false, true, true);
    }
    
    //constructor to initialise CRUD and FLS with a parameter for FLS.
    public SLT_PSA_ArchiveSearchStrategy(Boolean enforceFLS, Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Archive_Search_Strategy__c.Id, Archive_Search_Strategy__c.Name};
    }
    
    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Archive_Search_Strategy__c.sObjectType;
    }
    
    /**
    * This method used to query Search_Strategy__c
    * @return  List<Search_Strategy__c>
    */
    public List<Archive_Search_Strategy__c> getArchiveSearchStrategies(Set<String> fieldSet){
        return (List<Archive_Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /*
    * This method used to query Search_Strategy__c By lRProjectOverViewIds
    * @return  Search_Strategy__c 
    */
    public List<Archive_Search_Strategy__c> getArchiveSSRecordsFromLRIdForListView(String recordId, Set<String> fieldSet){
        return (List<Archive_Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c =: recordId AND Inactive__c = false').setLimit(5).toSOQL());
    }
    
    public Integer getTotalNumberOfRecords(Set<id> archiveSsIdSet){
        Integer NumberOfRecords = 0;
        NumberOfRecords = [SELECT COUNT() FROM Archive_Search_Strategy__c WHERE Id =: archiveSsIdSet];
        return NumberOfRecords;
    }
    
    public List<Archive_Search_Strategy__c> getArchiveSSByIdsForPagination(Set<id> archiveSsFieldSet, Set<String> fieldSet, Integer pageSize, Integer offset){
        return (List<Archive_Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : archiveSsFieldSet').setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
    
    public List<Archive_Search_Strategy__c> getArchiveSSByLRIDS(Set<id> lrIds, Set<String> fieldSet, String whereClause, String orderByField){
        return (List<Archive_Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereClause).addOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING).toSOQL());
    }
    
    public List<Archive_Search_Strategy__c> getArchiveSSByLRID(Set<id> lrIds, Set<String> fieldSet){
        return (List<Archive_Search_Strategy__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c IN : lrIds AND Inactive__c =false').toSOQL());
    }
}
