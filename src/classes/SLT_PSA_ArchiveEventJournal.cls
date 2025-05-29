public with sharing class SLT_PSA_ArchiveEventJournal extends fflib_SObjectSelector{
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_PSA_ArchiveEventJournal(){
        super(false, true, true);
    }

    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_PSA_ArchiveEventJournal(Boolean enforceFLS, Boolean enforceCRUD){
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{Archive_Event_Journal__c.Id, Archive_Event_Journal__c.Name};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType(){
        return Archive_Event_Journal__c.sObjectType;
    }
    
    /**
     * This method used to query Search_Strategy__c
     * @return  List<Search_Strategy__c>
     */
    public List<Archive_Event_Journal__c> getArchiveEJ(Set<String> fieldSet){
        return (List<Archive_Event_Journal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to query Search_Strategy__c By lRProjectOverViewIds
     * @return  Search_Strategy__c 
     */
    public List<Archive_Event_Journal__c> getArchiveEJRecordsFromLRIdForListView(String recordId, Set<String> fieldSet){
        return (List<Archive_Event_Journal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c =: recordId AND Inactive__c = false').setLimit(5).toSOQL());
    }
    
    
    public Integer getTotalNumberOfRecords(Set<id> archiveEjIdSet){
        Integer NumberOfRecords = 0;
        NumberOfRecords = [SELECT COUNT() FROM Archive_Event_Journal__c WHERE Id =: archiveEjIdSet];
        return NumberOfRecords;
    } 
    
    public List<Archive_Event_Journal__c> getArchiveEJByIdsForPagination(Set<id> archiveEjFieldSet, Set<String> fieldSet, Integer pageSize, Integer offset){
        return (List<Archive_Event_Journal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : archiveEjFieldSet').setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
    
    
    public List<Archive_Event_Journal__c> getArchiveEJByLRIDS(Set<id> lrIds, Set<String> fieldSet, String whereClause, String orderByField){
        return (List<Archive_Event_Journal__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(whereClause).addOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING).toSOQL());
    }
}
