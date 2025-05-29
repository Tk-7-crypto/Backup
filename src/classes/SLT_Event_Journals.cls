public with sharing class SLT_Event_Journals extends fflib_SObjectSelector {
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Event_Journals() {
        super(false, true, true);
    }
    public override String getOrderBy() {
        return 'Date_Initial_Search_Started__c  ASC';
    }
    /**
	 * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Event_Journals(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Event_Journals__c.Id, Event_Journals__c.Name, Event_Journals__c.Country__c};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Event_Journals__c.sObjectType;
    }
    
    /**
     * This method used to query Event_Journals__c
     * @return  List<Event_Journals__c>
     */
    public List<Event_Journals__c> getEventJournals(Set<String> fieldSet){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
    
    /**
     * This method used to query Event_Journals__c By lRProjectOverViewIds
     * @return  Event_Journals__c 
     */
    public List<Event_Journals__c> getEventJournalsBylRProjectOverViewId(Set<String> lRProjectOverViewIds, Set<String> fieldSet){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LR_Project_Overview__c IN : lRProjectOverViewIds').toSOQL());
    }
    
    /**
     * This method used to query Event_Journals__c By Ids
     * @return  Event_Journals__c 
     */
    public List<Event_Journals__c> getEventJournalsByIds(Set<id> eventJournalsIds, Set<String> fieldSet){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : eventJournalsIds').setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).setLimit(5).toSOQL());
    }
    
    /**
     * This method used to query Event_Journals__c By Ids
     * @return  Event_Journals__c 
     */
    public List<Event_Journals__c> getEventJournalsByIdsForPagination(Set<id> eventJournalsIds, Set<String> fieldSet,Integer pageSize, Integer offset ){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN : eventJournalsIds').setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING, true).setLimit(pageSize).setOFFSET(offset).toSOQL());
    }
    
    /**
     * This method used to query Event_Journals__c By Ids
     * @return  Event_Journals__c 
     */
    public List<Event_Journals__c> getEventJournalsByMainJournalValues(Set<String> countrySet, Set<String> pJournalSet, Set<String> nameSet, Set<String> journalNameSet, Set<String> uRLSet, Set<String> periodicitySet, Set<String> regulatoryRequirementSet, Set<String> subscriptionSet, Set<String> therapeuticAreaSet, Set<String> fieldSet ){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Country__c In:countrySet And Paper_Journal__c In:pJournalSet and Name In:nameSet and Journal_Name__c In:journalNameSet and URL__c In:uRLSet and Periodicity__c In:periodicitySet and Regulatory_requirement__c In:regulatoryRequirementSet and Subscription__c in:subscriptionSet and Therapeutic_Area__c In:therapeuticAreaSet').setLimit(50000).toSOQL());
    }
    
    /**
     * This method used to query Event_Journals__c
     * @return  Event_Journals__c 
     */
    public List<Event_Journals__c> getEventJournalsForCalendar(String serviceLineProjectId, String condition, Set<String> fieldSet ){
        return (List<Event_Journals__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
}
