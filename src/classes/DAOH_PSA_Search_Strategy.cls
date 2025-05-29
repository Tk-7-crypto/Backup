/**
* This is Search Strategy trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Search_Strategy {

    private static List<PSA_Event__c> psaEvents;
    private static Set<String> eventDateFields;
    private static Map<String, PSA_Event__c> dateFieldToPSAEventMap;
    private static Map<Id, PSA_Event__c> psaIdToPsaEventMap;

    public static void setDefaultFieldsValue(List<Search_Strategy__c> newList, Map<Id, Search_Strategy__c> oldMap){
        Date newDate;
        for(Search_Strategy__c newRec : newList){
            if((trigger.isInsert && newRec.Date_Search_Strategy_got_Client_Approval__c != null) || 
               (trigger.isUpdate && 
                (newRec.Date_Search_Strategy_got_Client_Approval__c != oldMap.get(newRec.Id).Date_Search_Strategy_got_Client_Approval__c || newRec.Date_Annual_Search_Strategy_Due__c != oldMap.get(newRec.Id).Date_Annual_Search_Strategy_Due__c) && 
                newRec.Date_Search_Strategy_got_Client_Approval__c != Null)){
                newRec.Date_Annual_Search_Strategy_Due__c = newRec.Date_Search_Strategy_got_Client_Approval__c.addYears(1).addDays(1);
            }
        }
    }
    
    public static void createLRSSRelationshipRecord(List<Search_Strategy__c> newList, Map<Id, Search_Strategy__c> oldMap){
        Set<Id> projectIdSet = new Set<Id>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> productIdSet = new Set<String>();
        Set<String> lrTypeSet = new Set<String>();
        Map<String, Id> keyToSSMap = new Map<String, Id>();
        Set<String> lrStatus = new Set<String>{CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED, CON_PSA.LR_PROJECT_REVIEW_STATUS_CANCELLED};
        for(Search_Strategy__c newRec : newList){
            projectIdSet.add(newRec.Project__c);
            accountIdSet.add(newRec.Account__c);
            productIdSet.add(newRec.Product__c);
            lrTypeSet.add(newRec.LR_Type__c);
            string Key = newRec.Account__c+''+newRec.Product__c+''+newRec.Project__c+''+newRec.LR_Type__c;
            keyToSSMap.put(Key, newRec.Id);
        }
        Map<Id, list<LR_Project_Overview__c>> projectIdToLRListMap = new Map<Id, list<LR_Project_Overview__c>>();
        //list<LR_Project_Overview__c> lrList = [Select id, Project__c, Account__c, Product__c, LR_Type__c From LR_Project_Overview__c where Project__c in :projectIdSet];
        Set<String> lrFieldSet = new Set<String>{'Id', 'Project__c', 'Account__c', 'Product__c', 'LR_Type__c', 'Status__c'};
        list<LR_Project_Overview__c> lrList = new SLT_LR_Project_Overview().getLRProjectOverViewFromKey(projectIdSet, accountIdSet, productIdSet, lrTypeSet, lrFieldSet);
        if(lrList.size() > 0){
            for(LR_Project_Overview__c newRec : lrList){
                list<LR_Project_Overview__c> temp = new list<LR_Project_Overview__c>();
                if(projectIdToLRListMap.containsKey(newRec.Project__c)){
                    temp = projectIdToLRListMap.get(newRec.Project__c);
                    temp.add(newRec);
                    projectIdToLRListMap.put(newRec.Project__c, temp);
                }else{
                    temp.add(newRec);
                    projectIdToLRListMap.put(newRec.Project__c, temp);
                }            
            }
        }
        List<LR_Search_Strategy_Relationship__c> LRSSListToCreate = new List<LR_Search_Strategy_Relationship__c>();
        String keySS;
        for(Search_Strategy__c newRec : newList){
            if(projectIdToLRListMap.containsKey(newRec.Project__c)){
                keySS = newRec.Account__c+''+newRec.Product__c+''+newRec.Project__c+''+newRec.LR_Type__c;
                List<LR_Project_Overview__c> lrList2 = projectIdToLRListMap.get(newRec.Project__c);
                for(LR_Project_Overview__c lrRec : lrList2){
                    if(!lrStatus.contains(lrRec.Status__c) && ( lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_YES || lrRec.Search_Strategy_Created__c == CON_PSA.LR_PROJECT_REVIEW_SEARCH_STRATEGY_PENDING )){
                        string Key = lrRec.Account__c+''+lrRec.Product__c+''+lrRec.Project__c+''+lrRec.LR_Type__c;
                        if(keyToSSMap.containsKey(Key) && keySS == Key){
                            LR_Search_Strategy_Relationship__c temp = new LR_Search_Strategy_Relationship__c(LR_Project_Overview_M__c = lrRec.Id, Project__c = lrRec.Project__c , Search_Strategy_M__c = newRec.Id, Account__c = newRec.Account__c, product__c = newRec.Product__c, LR_Type__c = newRec.LR_Type__c);
                            LRSSListToCreate.add(temp);                    
                        }                        
                    }                
                }                
            }            
        }        
        if(LRSSListToCreate.size() > 0){
            insert LRSSListToCreate;
        }
    }
    
    public static void deleteLRSSRelationshipRecord(List<Search_Strategy__c> newList, Map<Id, Search_Strategy__c> oldMap){
        // We are Deleting These Record as their Search Strategy has been already Deleted and these records are not Required as these Record are not Valid releationship Record.
        Set<String> fieldSet = new Set<String>{'Id'};
        List<LR_Search_Strategy_Relationship__c> lrSSDeleteRecord = new SLT_LR_Search_Strategy_Relationship().getLRSSRelationshipDataWhereSSIdNull(fieldSet);
        //List<LR_Search_Strategy_Relationship__c> lrSSDeleteRecord = [Select Id From LR_Search_Strategy_Relationship__c Where Search_Strategy__c = null];
        delete lrSSDeleteRecord;
    }
    /*
    * Story IQVIAPSA-4963
    * Start
    */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event().getAllPSAEvents('Search_Strategy__c');
        }
        
    }
    private static void buildDateFieldMap(){
        fetchPSAEvents();
        if(dateFieldToPSAEventMap == null){
            dateFieldToPSAEventMap = new Map<String, PSA_Event__c>(); 
        }
        for(PSA_Event__c event : psaEvents){
            if(event.Planned_Date_Field__c != null && dateFieldToPSAEventMap.get(event.Planned_Date_Field__c) == null){
                dateFieldToPSAEventMap.put(event.Planned_Date_Field__c, event);
            }
        }
    }
    private static void buildPSAIdToPSAMap(){
        fetchPSAEvents();
        psaIdToPsaEventMap = new Map<Id, PSA_Event__c>();
        for(PSA_Event__c event : psaEvents){
            psaIdToPsaEventMap.put(event.Id, event);
        }
    }
    private static void setEventDateFields(){
        Set<String> searchStrategyFields = Schema.SObjectType.Search_Strategy__c.fields.getMap().keySet();
        Set<String> invalidFields = new Set<String>();
        fetchPSAEvents();
        
        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if ( !searchStrategyFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                invalidFields.add(event.Name+':'+event.Planned_Date_Field__c);
            } else {
                eventDateFields.add(event.Planned_Date_Field__c);
            }
        }
        if(invalidFields.size() > 0){
            throw new SearchStrategyFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    static void validatePSAEvent( PSA_Event__c psaEvent, Set<String> validFields ){
        Set<String> invalidFields = new Set<String>();
        Set<String> psaEventFieldValues = new Set<String>();
        Set<String> psaEventFieldNames = new Set<String>{
            'Actual_Date_Field__c',
            'Planned_Date_Field__c'
        };
        for ( String fieldName : psaEventFieldNames ){
            if ( psaEvent.get(fieldName) != null ){
                psaEventFieldValues.add( String.valueOf( psaEvent.get(fieldName) ) );
            }
        }
        if( psaEvent.Stakeholder_Fields__c != null ){
            for ( String stakeholder : psaEvent.Stakeholder_Fields__c.split(',')) {
                psaEventFieldValues.add( stakeholder.trim() );
            }            
        }
        for ( String fieldValue : psaEventFieldValues ) {
            if ( !validFields.contains( fieldValue.toLowerCase() ) ) {
                invalidFields.add( fieldValue );
            }
        }
        if( invalidFields.size() > 0 ){
            throw new SearchStrategyFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    public static void synchronizeProjectEvent( List<Search_Strategy__c> newList, Map<Id, Search_Strategy__c> oldMap ){
        List<Search_Strategy__c> searchStrategyToSync = new List<Search_Strategy__c>();
        Set<Id> searchStrategyToProjectIdSet = new Set<Id>();
        for( Search_Strategy__c ss : newList ){
            if( ss.Date_Annual_Search_Strategy_Due__c != null 
               || ( Trigger.isUpdate && ss.Date_Annual_Search_Strategy_Due__c != oldMap.get( ss.Id ).Date_Annual_Search_Strategy_Due__c ) ){
                   searchStrategyToSync.add(ss);
                   searchStrategyToProjectIdSet.add(ss.Project__c);
               }
        }
        if( searchStrategyToSync.size() > 0 ){
            fetchPSAEvents();
            buildDateFieldMap();
            buildPSAIdToPSAMap();
            Id userId = UserInfo.getUserId();
            try {
                setEventDateFields();
            } catch (Exception e) {
                System.debug('Error '+e.getMessage());
                Search_Strategy__c ss = searchStrategyToSync.get(0);
                ss.addError(e.getMessage());
                return;
            }
            
            Set<String> searchStrategyFields = Schema.SObjectType.Search_Strategy__c.fields.getMap().keySet();
            Map<Id,Map<Id,Project_Event__c>> searchStrategyToProjectEventMap = getProjectEventsBySS(searchStrategyToSync);
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Project_Event__c.SObjectType }
            );
            
            for( Search_Strategy__c ssRecords : searchStrategyToSync ){
                for(Id psaEvId : psaIdToPsaEventMap.keySet()){
                    PSA_Event__c psaEvent = psaIdToPsaEventMap.get(psaEvId);
                    Project_Event__c projectEvent= ( searchStrategyToProjectEventMap.get(ssRecords.Id) != null && psaEvent != null) ? searchStrategyToProjectEventMap.get(ssRecords.Id).get(psaEvent.Id) : null;
                    
                    if( psaEvent != null ) {
                        
                        try {
                            validatePSAEvent(psaEvent, searchStrategyFields);
                        } catch (SearchStrategyFieldException e){
                            ssRecords.addError(e.getMessage());
                            continue;
                        }
                        
                        if(projectEvent == null){
                            projectEvent = populateProjectEvent( ssRecords, psaEvent);
                            uow.registerNew(projectEvent);
                        } else {
                            //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                            //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                            populateProjectEvent( ssRecords, psaEvent, projectEvent );
                            uow.registerDirty(projectEvent);
                        }
                    }
                    
                    else if ( projectEvent != null ){
                        //Note, this will catch any Project Events whose PSA Event now indicate a blank date field. 
                        projectEvent.ownerId = userId;
                        uow.registerDirty(projectEvent);
                        uow.registerDeleted(projectEvent);
                    }
                }
            }
            uow.commitWork(); 
        }
        
    }
    private static Project_Event__c populateProjectEvent( Search_Strategy__c ssRecords, PSA_Event__c psaEvent){
        return populateProjectEvent( ssRecords, psaEvent, new Project_Event__c());
    }
    
    private static Project_Event__c populateProjectEvent( Search_Strategy__c ssRecords, PSA_Event__c psaEvent, Project_Event__c projectEvent) {
        if ( psaEvent.Actual_Date_Field__c != null && ssRecords.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)ssRecords.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }
        
        if ( psaEvent.Planned_Date_Field__c != null && ssRecords.get(psaEvent.Planned_Date_Field__c) != null) { 
            projectEvent.Event_Due_Date__c = (Date)ssRecords.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }
        
        if ( psaEvent.Planned_Date_Field__c != null && ssRecords.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)ssRecords.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }
        
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(ssRecords.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.Search_Strategy__c = ssRecords.Id;
        projectEvent.Project__c = (ssRecords.Project__c != null) ? String.valueOf(ssRecords.Project__c) : null;
        
        return projectEvent;
    }
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsBySS(List<Search_Strategy__c> records ){
        Set<Id> ssIds = new Set<Id>(new Map<Id,Search_Strategy__c>(records).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsBySS( ssIds, eventFields );
        for(Project_Event__c event : events){
            if(projectEventsMap.get(event.Search_Strategy__c) == null){
                projectEventsMap.put(event.Search_Strategy__c, new Map<Id,Project_Event__c>());
            }
            projectEventsMap.get(event.Search_Strategy__c).put(event.PSA_Event__c, event);
        }
        return projectEventsMap;
    }
    
    public class SearchStrategyFieldException extends Exception {}
    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Search Strategy
    **/
    public static void insertAuditLog(List<Search_Strategy__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Search Strategy
    **/
    public static void insertAuditLogOnUpdate(List<Search_Strategy__c> updatedList,Map<Id,Search_Strategy__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }
}
