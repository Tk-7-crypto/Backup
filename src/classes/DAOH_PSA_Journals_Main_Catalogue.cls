/**
* This is Journals Main Catalogue trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Journals_Main_Catalogue {
    
    public static void synchValueForEJ(List<Journals_Main_Catalogue__c> newList, Map<Id, Journals_Main_Catalogue__c> oldMap){
        Set<Id> journalIdSet = new Set<Id>();
        Set<String> countrySet = new Set<String>();
        Set<String> pJournalSet = new Set<String>();
        Set<String> nameSet = new Set<String>();
        Set<String> journalNameSet = new Set<String>();
        Set<String> uRLSet = new Set<String>();
        Set<String> periodicitySet = new Set<String>();
        Set<String> regulatoryRequirementSet = new Set<String>();
        Set<String> subscriptionSet = new Set<String>();
        Set<String> therapeuticAreaSet = new Set<String>();		
        Map<String, Journals_Main_Catalogue__c> keyToJMCRecMap = new Map<String, Journals_Main_Catalogue__c>();
        String key;
		
        for(Journals_Main_Catalogue__c jmcRec : newList){
            if(jmcRec.Country__c != oldMap.get( jmcRec.Id ).Country__c || jmcRec.Paper_Journal__c != oldMap.get( jmcRec.Id ).Paper_Journal__c || 
               jmcRec.Name != oldMap.get( jmcRec.Id ).Name || jmcRec.Journal_Name__c != oldMap.get( jmcRec.Id ).Journal_Name__c || 
               jmcRec.URL__c != oldMap.get( jmcRec.Id ).URL__c || jmcRec.Periodicity__c != oldMap.get( jmcRec.Id ).Periodicity__c || 
               jmcRec.Regulatory_requirement__c != oldMap.get( jmcRec.Id ).Regulatory_requirement__c || jmcRec.Subscription__c != oldMap.get( jmcRec.Id ).Subscription__c || 
               jmcRec.Therapeutic_Area__c != oldMap.get( jmcRec.Id ).Therapeutic_Area__c){
                   key = oldMap.get(jmcRec.Id).Country__c+''+oldMap.get(jmcRec.Id).Paper_Journal__c+''+oldMap.get(jmcRec.Id).Name+''+oldMap.get(jmcRec.Id).Journal_Name__c+''+oldMap.get(jmcRec.Id).URL__c+''+oldMap.get(jmcRec.Id).Periodicity__c+''+oldMap.get(jmcRec.Id).Regulatory_requirement__c+''+oldMap.get(jmcRec.Id).Subscription__c+''+oldMap.get(jmcRec.Id).Therapeutic_Area__c;
                   keyToJMCRecMap.put(key, jmcRec);
                   journalIdSet.add(jmcRec.Id);
                   countrySet.add(oldMap.get(jmcRec.Id).Country__c);
                   pJournalSet.add(oldMap.get(jmcRec.Id).Paper_Journal__c);
                   nameSet.add(oldMap.get(jmcRec.Id).Name);
                   journalNameSet.add(oldMap.get(jmcRec.Id).Journal_Name__c);
                   uRLSet.add(oldMap.get(jmcRec.Id).URL__c);
                   periodicitySet.add(oldMap.get(jmcRec.Id).Periodicity__c);
                   regulatoryRequirementSet.add(oldMap.get(jmcRec.Id).Regulatory_requirement__c);
                   subscriptionSet.add(oldMap.get(jmcRec.Id).Subscription__c);
                   therapeuticAreaSet.add(oldMap.get(jmcRec.Id).Therapeutic_Area__c);
               }
        }
        Set<String> fieldSet = new Set<String>{'Id', 'Country__c', 'Paper_Journal__c', 'Name', 'Journal_Name__c', 'URL__c', 'Periodicity__c', 'Regulatory_requirement__c', 'Subscription__c', 'Therapeutic_Area__c'};
        List<Event_Journals__c> eventJournalList = new SLT_Event_Journals().getEventJournalsByMainJournalValues(countrySet, pJournalSet, nameSet, journalNameSet, uRLSet, periodicitySet, regulatoryRequirementSet, subscriptionSet, therapeuticAreaSet, fieldSet );
        
        if(eventJournalList.size() > 0){
            if(eventJournalList.size() < 2000){
                Set<Id> eventJournalidSet = new Set<Id>();
                map<Id, Event_Journals__c> eventJournalIdToDataMap = new map<Id, Event_Journals__c>();
                for(Event_Journals__c ej:eventJournalList){
                    eventJournalIdToDataMap.put(ej.id, ej);
                }
                Set<String> lrEJRFieldSet = new Set<String>{'id', 'LR_Status__c', 'Event_Journals_M__c'};
                Set<String> lrStatus = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
                List<LR_Event_Journals_Relationship__c> lrEJList = new SLT_LR_Event_Journals_Relationship().getLREJRelationshipFromEJId(eventJournalIdToDataMap.keySet(), lrEJRFieldSet);                
                
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
                    //tempEj.Name = tempJMC.Name;
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
            }else{
                System.enqueueJob( new QUE_PSA_AsyncUpdateEventJournals(eventJournalList, keyToJMCRecMap));
            }
        }
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Journals Main Catalogue
    **/
    public static void insertAuditLog(List<Journals_Main_Catalogue__c> insertList,String operation){
        if(!UTL_ExecutionControl.stopAuditTriggerExecution){
            SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
        }
        
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Journals Main Catalogue
    **/
    public static void insertAuditLogOnUpdate(List<Journals_Main_Catalogue__c> updatedList,Map<Id,Journals_Main_Catalogue__c> existingRecords){
        if(!UTL_ExecutionControl.stopAuditTriggerExecution){
            SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords); 
        }
    }
}
