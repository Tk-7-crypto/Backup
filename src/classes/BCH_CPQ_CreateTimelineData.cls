public class BCH_CPQ_CreateTimelineData implements Database.Batchable<sobject>, Database.Stateful {
    private Set<Id> recordIds = new Set<Id>();
    Boolean createTimeline = false;
    Boolean updateALIPhases = false;
    private Boolean fetchAllRecords;							

    public BCH_CPQ_CreateTimelineData(Set<String> recordIdSet, Boolean createTimeline, Boolean updateALIPhases) {
        fetchAllRecords = false;
        if (recordIdSet.size() > 0) {
            for (String record : recordIdSet) {
                if (record == CON_CPQ.ALL) {
                    fetchAllRecords = true;																					  
                    break;
                } else {
                    recordIds.add(Id.valueOf(record));
                }
            }
        }
        this.updateALIPhases = updateALIPhases;
        this.createTimeline = createTimeline;
    }
    
    public Database.Querylocator start (Database.BatchableContext BC) {
        String whereClause = fetchAllRecords ? '' : ' AND Id IN :recordIds';				  
        return Database.getQueryLocator('SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c = \'' + CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT + '\' ' + whereClause ) ;	 
    }
    
    public void execute (Database.BatchableContext BC, List<sobject> SObjectList) {
        Set<Id> recordIdsSet = new Set<Id>();
        for (sobject record : SObjectList) {
            recordIdsSet.add((Id)record.get(CON_CPQ.Id));
        }
        CPQ_RMUtility.deleteTimelineByOrder(recordIdsSet);                                                             					  
        CPQ_RMUtility.createTimelineAndPhaseQuoteData(recordIdsSet, createTimeline, updateALIPhases);																										 
    }
    
    public void finish(Database.BatchableContext BC) {}
}