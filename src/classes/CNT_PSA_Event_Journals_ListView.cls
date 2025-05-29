public class CNT_PSA_Event_Journals_ListView {
    
    @AuraEnabled(cacheable=true)
    public static List<Event_Journals__c> getEventJournalData(String recordId){
        Set<String> lrEjFieldSet = new Set<String>{'Id', 'Event_Journals_M__c'};
        Set<Id> lridSet = new Set<Id>();
        lridSet.add(recordId);
        List<LR_Event_Journals_Relationship__c> lrEjList = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromLrId(lridSet, lrEjFieldSet);
        Set<Id> eventJournalIdSet = new Set<Id>();
        for(LR_Event_Journals_Relationship__c lrEjRec : lrEjList){
            eventJournalIdSet.add(lrEjRec.Event_Journals_M__c);
        }
        Set<String> ejFieldSet = new Set<String>{'Id', 'Name', 'Country__c', 'Journal_Name__c', 'URL__c', 'Frequency_of_Journal__c', 'Date_Initial_Search_Started__c', 'Date_Last_Journal_Search_was_Performed__c', 'Date_Next_Journal_Search_is_Due__c', 'Active__c'};
        return new SLT_Event_Journals().getEventJournalsByIds(eventJournalIdSet, ejFieldSet);
    }
    @AuraEnabled(cacheable=false)
    public static String getEventJournalDataForView( String recordId, Integer pageSize, Integer pageNumber, Integer totalRecords ){
       String jsonObjItm = '';
        Set<String> lrEjFieldSet = new Set<String>{'Id', 'Event_Journals_M__c'};
        Set<Id> lridSet = new Set<Id>();
        lridSet.add(recordId);
        List<LR_Event_Journals_Relationship__c> lrEjList = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromLrId(lridSet, lrEjFieldSet);
        Set<Id> eventJournalIdSet = new Set<Id>();
        for(LR_Event_Journals_Relationship__c lrEjRec : lrEjList){
            eventJournalIdSet.add(lrEjRec.Event_Journals_M__c);
        }
        
        Set<String> ejFieldSet = new Set<String>{'Id', 'Name', 'Country__c', 'Journal_Name__c', 'URL__c', 'Frequency_of_Journal__c', 'Date_Initial_Search_Started__c', 'Date_Last_Journal_Search_was_Performed__c', 'Date_Next_Journal_Search_is_Due__c', 'Active__c','LastModifiedDate'};
        Integer offset = (pageNumber - 1) * pageSize;  
        
        if( totalRecords == 0 ){
         	totalRecords = [SELECT COUNT() FROM Event_Journals__c WHERE Id =: eventJournalIdSet];
        }
        Integer recordEnd = pageSize * pageNumber;
       	EventItemWrapper ejObj =  new EventItemWrapper();  
        ejObj.pageNumber = pageNumber;
        ejObj.pageSize = pageSize;        
        ejObj.recordStart = offset + 1;
        ejObj.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        ejObj.totalRecords = totalRecords;
        ejObj.eventJournals = new SLT_Event_Journals().getEventJournalsByIdsForPagination(eventJournalIdSet, ejFieldSet,pageSize,offset );
        jsonObjItm = JSON.serialize(ejObj);
        return jsonObjItm;
    }
    public class EventItemWrapper {       
        public Integer recordStart {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordEnd {get;set;}
        public Integer pageSize {get;set;}       
        public List<Event_Journals__c> eventJournals {get;set;}
    }
}