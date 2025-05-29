public class QUE_PSA_AsyncUpdateEventJournals implements Queueable {
    
    List<Event_Journals__c> eventJournalsList = new List<Event_Journals__c>();
    Map<String, Journals_Main_Catalogue__c> keyToJMCRecMap = new Map<String, Journals_Main_Catalogue__c>();
    
    public QUE_PSA_AsyncUpdateEventJournals(List<Event_Journals__c> eventJournalsList, Map<String, Journals_Main_Catalogue__c> keyToJMCRecMap) {
        this.eventJournalsList = eventJournalsList;
        this.keyToJMCRecMap = keyToJMCRecMap;
    }
    
    public void execute(QueueableContext qc) {
        Set<Id> eventJournalidSet = new Set<Id>();
        map<Id, Event_Journals__c> eventJournalIdToDataMap = new map<Id, Event_Journals__c>();
        String key;
        for(Event_Journals__c ej:eventJournalsList){
            eventJournalIdToDataMap.put(ej.id, ej);
        }
        Set<String> lrEJRFieldSet = new Set<String>{'id', 'LR_Status__c', 'Event_Journals_M__c'};
        List<LR_Event_Journals_Relationship__c> lrEJList = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromEJId(eventJournalIdToDataMap.keySet(), lrEJRFieldSet);
        Set<String> lrStatus = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
            for(LR_Event_Journals_Relationship__c lrej: lrEJList){
                if(!lrStatus.contains(lrej.LR_Status__c)){
                    eventJournalidSet.add(lrej.Event_Journals_M__c);
                }            
            }
        List<Event_Journals__c> updateEjList = new List<Event_Journals__c>();
        for(Id ejId: eventJournalidSet){
            Event_Journals__c tempEj = eventJournalIdToDataMap.get(ejId);
            key = tempEj.Country__c+''+tempEj.Paper_Journal__c+''+tempEj.Name+''+tempEj.Journal_Name__c+''+tempEj.URL__c+''+tempEj.Periodicity__c+''+tempEj.Regulatory_requirement__c+''+tempEj.Subscription__c+''+tempEj.Therapeutic_Area__c;
            Journals_Main_Catalogue__c tempJMC = keyToJMCRecMap.get(key);
            
            tempEj.Country__c = tempJMC.Country__c;
            tempEj.Paper_Journal__c = tempJMC.Paper_Journal__c;
            tempEj.Name = tempJMC.Name;
            tempEj.Journal_Name__c = tempJMC.Journal_Name__c;
            tempEj.URL__c = tempJMC.URL__c;
            tempEj.Periodicity__c = tempJMC.Periodicity__c;
            tempEj.Regulatory_requirement__c = tempJMC.Regulatory_requirement__c;
            tempEj.Subscription__c = tempJMC.Subscription__c;
            tempEj.Therapeutic_Area__c = tempJMC.Therapeutic_Area__c;
            
            updateEjList.add(tempEj);
        }
        
        if(updateEjList.size() > 0)
            update updateEjList;
        
    }
}