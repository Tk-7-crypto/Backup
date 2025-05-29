global class BCH_PSA_DeleteToLrRelations implements Database.batchable<SObject>, Database.Stateful, BatchMode{
    global  String mode;
    global void ExecuteMode(List<String> modeOfBatch)
    {
        if(modeOfBatch != null && modeOfBatch.size() > 0){
            mode = modeOfBatch[0];
        }else{
            mode = 'SEARCH_STRATEGY';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        if(mode == 'SEARCH_STRATEGY'){
            query = 'SELECT id, Name FROM Search_Strategy__c';
        }
        if(mode == 'EVENT_JOURNAL'){
            query = 'SELECT id, Name FROM Event_Journals__c';  
        }
        return Database.getQueryLocator(query); 
    }     
    
    global void execute(Database.batchableContext info, List<SObject> records){
        Set<String> eventJournalIds = new Set<String>();
        Set<String> searchStrategyIds = new Set<String>();
        List<Search_Strategy__c> sslstToDelete = new List<Search_Strategy__c>();
        List<Event_Journals__c> ejlstToDelete = new List<Event_Journals__c>();
        if(mode == 'SEARCH_STRATEGY'){
            for(SObject sOb : records){
                searchStrategyIds.add(sOb.Id);
            } 
            AggregateResult[] groupedResultsForSS = [SELECT count(Id),Search_Strategy_M__c 
                                                     FROM LR_Search_Strategy_Relationship__c 
                                                     WHERE Search_Strategy_M__c  IN : searchStrategyIds 
                                                     GROUP BY Search_Strategy_M__c];
            for(AggregateResult ar : groupedResultsForSS){
                if(searchStrategyIds.contains(String.valueOf(ar.get('Search_Strategy_M__c')))){
                    searchStrategyIds.remove(String.valueOf(ar.get('Search_Strategy_M__c')));
                }
            }
            if(searchStrategyIds.size() > 0){
                for(String notLinkId : searchStrategyIds){
                    Search_Strategy__c ssRecord = new Search_Strategy__c(Id = notLinkId);
                    sslstToDelete.add(ssRecord);
                }
            }
            if(sslstToDelete.size() > 0){
                delete sslstToDelete;
            }
        }
        if(mode == 'EVENT_JOURNAL'){
            for(SObject sOb : records){
                eventJournalIds.add(sOb.Id);
            }
            AggregateResult[] groupedResultsForEJ = [SELECT count(Id),Event_Journals_M__c 
                                                     FROM LR_Event_Journals_Relationship__c 
                                                     WHERE Event_Journals_M__c  IN : eventJournalIds 
                                                     GROUP BY Event_Journals_M__c];
            for (AggregateResult ar : groupedResultsForEJ)  {
                if(eventJournalIds.contains(String.valueOf(ar.get('Event_Journals_M__c')))){
                    eventJournalIds.remove(String.valueOf(ar.get('Event_Journals_M__c')));
                }
            }
            
            if(eventJournalIds.size() > 0){
                for(String notLinkId : eventJournalIds){
                    Event_Journals__c ejRecord = new Event_Journals__c(Id = notLinkId);
                    ejlstToDelete.add(ejRecord);
                }
            }
            if(ejlstToDelete.size() > 0){
                delete ejlstToDelete;
            }
        }
    }     
    global void finish(Database.batchableContext info){
        if(mode == 'SEARCH_STRATEGY'){
            BCH_PSA_DeleteToLrRelations ob = new BCH_PSA_DeleteToLrRelations();
            ob.ExecuteMode(new List<String>{'EVENT_JOURNAL'});
            Database.executeBatch(ob);
        }
    } 
}