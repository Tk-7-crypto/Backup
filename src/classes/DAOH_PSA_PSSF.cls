/**
* This is PSSF trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_PSSF{
    
    /**
* This method is used to validate fields before publish of PSSF.
* @params List<PSSF__c> newList
* @return void
*/
    public static void validateFieldsPSSF(List<PSSF__c> newList,Map<Id, PSSF__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        String errorMessage;
        Boolean showError;
        //insert case
        if(trigger.isInsert && !mulesoftSetting.Ignore_Validation_Rules__c){
            for(PSSF__c pssfRec : newList){
                errorMessage = '';
                showError = false;
                if(pssfRec.Account__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Account' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.Project_Name__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Project Name' + '\'' +' ';
                    showError = true;
                }
                if(showError){
                    pssfRec.addError(errorMessage + ' is required to publish PSSF.');
                }
            }
        }
        //update case
        if(!mulesoftSetting.Ignore_Validation_Rules__c && trigger.isUpdate){
            for(PSSF__c pssfRec : newList){
                errorMessage = '';
                showError = false;
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Account__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Account' + '\'' +', ';
                    showError = true;
                    //pssfRec.addError('\'' + 'Account' + '\'' + ' is required.');
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Project_Name__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Project Name' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Prepared_by_IQVIA_SM_Lead__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Prepared by' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.QCed_by_SM_QC_Reviewer__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'QCed by' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Reviewed_by_Medical_Safety_Advisor__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Reviewed by Medical Safety Advisor' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && String.isBlank(pssfRec.MedDRA_version_used_in_current_PSSF__c) && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'MedDRA version used in current PSSF' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Date_QC_Completed__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Date QC Completed' + '\'' +', ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && pssfRec.Date_Medical_Review_Completed__c == null && pssfRec.PSSF_Parent__c == null){
                    errorMessage = errorMessage  + '\'' + 'Date Medical Review Completed' + '\'' +' ';
                    showError = true;
                }
                if(pssfRec.PSSF_Status__c == 'Published' && showError){
                    pssfRec.addError(errorMessage + ' is required to publish PSSF.');
                }
            }
        }
    }
    
    
    public static void ClonePSSFRecord(List<PSSF__c> newList,Map<Id, PSSF__c> oldMap){
        Set<id> projectSet = new Set<id>();
        for(PSSF__c pssfRec : newList){
           if(pssfRec.PSSF_Status__c == 'Published'){
                projectSet.add(pssfRec.Project_Name__c);
            }
           else{
                projectSet.add(pssfRec.Project_ID__c);
            }
        }
        
        list<PSSF__c> pssfList = new list<PSSF__c>();
        //list<PSSF__c> parentPSSF = [select id,PSSF_Version__c from PSSF__c where PSSF_Status__c = : 'Published' and Project_Name__c in : projectSet order by CreatedDate desc limit 1];
        //list<PSSF__c> publishedPSSF = [select id,PSSF_Version__c from PSSF__c where PSSF_Status__c = : 'Published' and Project_Name__c in : projectList];
        list<PSSF__c> publishedPSSF  = new SLT_PSSF().getPSSFByProject(projectSet, new Set<String>{'PSSF_Version__c'});

        Integer versionNumber = 0;
        if(publishedPSSF.size()>0){
            string version = publishedPSSF[0].PSSF_Version__c;
            list<string> versionList = version.split(' ');
            versionNumber = Integer.valueOf(versionList[2]);
        }
        for(PSSF__c pssfRec : newList){
            if(pssfRec.PSSF_Status__c == 'Published Child' && publishedPSSF.size()>0){
                PSSF__c pssfCloneRec = pssfRec.clone(false, true, false, false);
                pssfCloneRec.PSSF_Parent__c= publishedPSSF[0].id;
                pssfList.add(pssfCloneRec);
                pssfRec.PSSF_Status__c = 'Draft Child';
            }
            if(pssfRec.PSSF_Status__c == 'Published'){
                string version = '';
                version = 'PSSF Version ' +  (versionNumber + 1);
                PSSF__c pssfCloneRec = pssfRec.clone(false, true, false, false);
                pssfCloneRec.PSSF_Version__c = version;
                pssfList.add(pssfCloneRec);
                pssfRec.PSSF_Status__c = 'Draft';
            }
        }
        if(pssfList.size()>0){
            insert pssfList;
        }
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating PSSF record
    **/
    public static void insertAuditLogOnUpdate(List<PSSF__c> updatedList,Map<Id,PSSF__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Project Log
    **/
    public static void insertAuditLog(List<PSSF__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    
    private static Map<String,Map<String,PSA_Event__c>> dateFieldToPSAEventMap;
    private static List<PSA_Event__c> psaEvents;
    private static Set<String> eventDateFields;
    
    public static void synchronizeProjectEvents(List<PSSF__c> updatedList, Map<Id,PSSF__c> existingRecords){
        
        List<PSSF__c> pssfToSync = new List<PSSF__c>();
        for(PSSF__c pssfRec : updatedList){
            if(pssfRec.PSSF_Effective_Date__c != null){
                pssfToSync.add(pssfRec);
            }
        }
        if(pssfToSync.size() > 0) {
            fetchPSAEvents();
            buildDateFieldMap();
            Id userId = UserInfo.getUserId();
    
            try {
                setEventDateFields();
            } catch (Exception e) {
                PSSF__c pssfRec = pssfToSync.get(0);
                pssfRec.addError( e.getMessage());
                return;
            }
    
            Set<String> pssfFields = Schema.SObjectType.PSSF__c.fields.getMap().keySet();
            Map<Id,Map<Id,Project_Event__c>> reportToProjectEventMap = getProjectEventsByPSSF(pssfToSync);
    
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Project_Event__c.SObjectType }
            );
    
            for(PSSF__c pssfRec : pssfToSync){
                for(String dateField : eventDateFields){
                    Date dateFieldContents = (Date) pssfRec.get(dateField);
                    //PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get(recordTypeName) : null;
                    PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get('NA') : null;
                    
                    Project_Event__c projectEvent= ( reportToProjectEventMap.get(pssfRec.Id) != null && psaEvent != null) ? reportToProjectEventMap.get(pssfRec.Id).get(psaEvent.Id) : null;
    
                    if( dateFieldContents != null && psaEvent != null ) {
    
                        try {
                            validatePSAEvent(psaEvent, pssfFields);
                        } catch (pssfFieldException e){
                            pssfRec.addError(e.getMessage());
                            continue;
                        }
    
                        if(projectEvent == null){
                            projectEvent = populateProjectEvent(pssfRec, psaEvent);
                            uow.registerNew(projectEvent);
                        } else {
                            //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                            //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                            populateProjectEvent(pssfRec, psaEvent, projectEvent);
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

    /**
     * This method retrieves all Project_Event__c objects for the pssf, and maps them by pssf Id followed by PSA Event Id
     * This allows us to validate them against both the pssf and the PSA Event, in case either has changed
     * @params List<PSSF__c> reports
     * @return Map<Id,Map<Id,Project_Event__c>>
     */ 
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsByPSSF(List<PSSF__c> pssf ){
        Set<Id> reportIds = new Set<Id>(new Map<Id,PSSF__c>(pssf).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsByPSSF(reportIds, eventFields);
        for(Project_Event__c event : events){
            if(projectEventsMap.get(event.PSSF__c) == null){
                projectEventsMap.put(event.PSSF__c, new Map<Id,Project_Event__c>());
            }
            projectEventsMap.get(event.PSSF__c).put(event.PSA_Event__c, event);
        }
        return projectEventsMap;
    }
    
    /**
     * This method builds a map of Planned_Date_Field__c to RecordTypeName to PSA_Event__c
     * It allows you to filter PSA Events by both field and recordtype when trying to match up with pssf
     */
    private static void buildDateFieldMap(){
        fetchPSAEvents();
        if(dateFieldToPSAEventMap == null){
            dateFieldToPSAEventMap = new Map<String,Map<String,PSA_Event__c>>(); 
        }
        for(PSA_Event__c event : psaEvents){
            if(dateFieldToPSAEventMap.get(event.Planned_Date_Field__c) == null){
                dateFieldToPSAEventMap.put(event.Planned_Date_Field__c, new Map<String, PSA_Event__c>());
            }
            Map<String, PSA_Event__c> recordTypeMap = dateFieldToPSAEventMap.get(event.Planned_Date_Field__c);
            recordTypeMap.put('NA', event);
            /*List<String> recordTypes = event.RecordTypes__c.split(',');
            for(String recordType : recordTypes){
                recordTypeMap.put(recordType, event);
            }*/
        }
    }
    
    /**
     * Retrieves all the PSA Events that could be applied to an pssf
     */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event().getAllPSAEvents('PSSF__c');
        }
    }
    
    /**
     * Compiles a list of the Due Date fields from a list of PSA events
     * These are the fields that we will be examining on pssf for changes
     */
    private static void setEventDateFields(){
        Set<String> pssfFields = Schema.SObjectType.PSSF__c.fields.getMap().keySet();
        Set<String> invalidFields = new Set<String>();
        fetchPSAEvents();

        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if ( !pssfFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                invalidFields.add(event.Name+':'+event.Planned_Date_Field__c);
            } else {
                eventDateFields.add(event.Planned_Date_Field__c);
            }
        }

        if(invalidFields.size() > 0){
            throw new pssfFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    /**
     * Validates that the target fields in a PSA Event are valid field names
     * @params PSA_Event__c psaEvent
     */
    static void validatePSAEvent( PSA_Event__c psaEvent, Set<String> validFields ){
        Set<String> invalidFields = new Set<String>();
        Set<String> psaEventFieldValues = new Set<String>();
        Set<String> psaEventFieldNames = new Set<String>{
            'Actual_Date_Field__c',
            'Planned_Date_Field__c',
            'Primary_Resource_Field__c',
            'Secondary_Resource_Field__c',
            'Other_Resource_Field__c'
        };

        for ( String fieldName : psaEventFieldNames ){
            if ( psaEvent.get(fieldName) != null ){
                psaEventFieldValues.add( String.valueOf( psaEvent.get(fieldName) ) );
            }
        }
    if(psaEvent.Stakeholder_Fields__c != null && psaEvent.Stakeholder_Fields__c != ''){
            for ( String stakeholder : psaEvent.Stakeholder_Fields__c.split(',')) {
                psaEventFieldValues.add( stakeholder.trim() );
            }
        }
        for ( String fieldValue : psaEventFieldValues ) {
            if ( !validFields.contains( fieldValue.toLowerCase() ) ) {
                invalidFields.add( fieldValue );
            }
        }

        if(invalidFields.size() > 0){
            throw new pssfFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    /**
     * Populate fields on a project event given an aggregate report and a psa event
     * @params PSSF__c pssf
     * @params PSA_Event__c psaEvent
     * @params Project_Event__c projectEvent
     * 
     * @return Project_Event__c
     */
    private static Project_Event__c populateProjectEvent( PSSF__c pssf, PSA_Event__c psaEvent){
        return populateProjectEvent( pssf, psaEvent, new Project_Event__c());
    }

    private static Project_Event__c populateProjectEvent( PSSF__c pssf, PSA_Event__c psaEvent, Project_Event__c projectEvent) {

        if ( psaEvent.Actual_Date_Field__c != null && pssf.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)pssf.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && pssf.get(psaEvent.Planned_Date_Field__c) != null) { 
                projectEvent.Event_Due_Date__c = (Date)pssf.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && pssf.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)pssf.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }

        projectEvent.Primary_Resource__c = (psaEvent.Primary_Resource_Field__c != null) ? String.valueOf(pssf.get(psaEvent.Primary_Resource_Field__c)) : null;
        projectEvent.Secondary_Resource__c = (psaEvent.Secondary_Resource_Field__c != null) ? String.valueOf(pssf.get(psaEvent.Secondary_Resource_Field__c)) : null;
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(pssf.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.Stakeholder_ID__c = getStakeholderIds(pssf, psaEvent.Stakeholder_Fields__c);

        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.PSSF__c = pssf.Id;
        projectEvent.Project__c = (pssf.Project_Name__c != null) ? String.valueOf(pssf.Project_Name__c) : null;
        return projectEvent;
    }
    
    /**
     * Retrieve user Ids for stakeholders based on a list of fields to check
     * @return String
     */
    private static String getStakeholderIds(PSSF__c pssf, String fields){
        Set<Id> contactIds = new Set<Id>();
        String ids = '';
        if(fields != null) {
            for(String field : fields.split(',')){
                String fieldName = field.trim();
                if(pssf.get(fieldName) != null && pssf.get(fieldName) InstanceOf Id){
                    contactIds.add((Id)pssf.get(fieldName));
                }
            }
    
            for( Contact stakeholder : new SLT_Contact().selectByContactIdList(contactIds, new Set<String>{'pse__Salesforce_User__c'}) ){
                if(ids != ''){
                    ids += ',';
                }
                ids += String.valueOf(stakeholder.pse__Salesforce_User__c);
            }
        }
        return ids;
    }
    

    /**
     * update PJE on change of recipients so the updated recipient receives the notification
     * 
     */
    public static void updtRltdPJEToUpdtReciepients(List<PSSF__c> updatedList, Map<Id,PSSF__c> existingRecords){
        List<PSSF__c> pssfToUpdtLst = new List<PSSF__c>();
        fetchPSAEvents();
        
        for(PSA_Event__c event : psaEvents){
            for(PSSF__c pssf : updatedList){
                Boolean plannedDtChanged = false, primaryResChanged = false, secResChanged = false, otherResChanged = false;
                if(event.Planned_Date_Field__c != null){
                    plannedDtChanged = pssf.get(event.Planned_Date_Field__c) != (existingRecords.get(pssf.Id)).get(event.Planned_Date_Field__c);
                }
                if(event.Primary_Resource_Field__c != null){
                    primaryResChanged = pssf.get(event.Primary_Resource_Field__c) != (existingRecords.get(pssf.Id)).get(event.Primary_Resource_Field__c);
                }
                if(event.Secondary_Resource_Field__c != null){
                    secResChanged = pssf.get(event.Secondary_Resource_Field__c) != (existingRecords.get(pssf.Id)).get(event.Secondary_Resource_Field__c);
                }           
                if(event.Other_Resource_Field__c != null){
                    otherResChanged = pssf.get(event.Other_Resource_Field__c) != (existingRecords.get(pssf.Id)).get(event.Other_Resource_Field__c);
                }
                if(plannedDtChanged || primaryResChanged || secResChanged || otherResChanged){
                    if(!pssfToUpdtLst.contains(pssf)){
                       pssfToUpdtLst.add(pssf);
                    }
                }
                
            }
        }
        
        Set<Id> reportIds = new Set<Id>(new Map<Id,PSSF__c>(pssfToUpdtLst).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Date> projectEventsToActualDateMap = new Map<Id,Date>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsByPSSF(reportIds, eventFields);
        
        Map<Id, List<Project_Event__c>> pssfToPJEMap = new Map<Id, List<Project_Event__c>>();
        for (Project_Event__c pje : events) {
            List<Project_Event__c> tempMSList = pssfToPJEMap.get(pje.PSSF__c);

            if (tempMSList != null) {
                tempMSList.add(pje);
                pssfToPJEMap.put(pje.PSSF__c,tempMSList);
            } else {
                pssfToPJEMap.put(pje.PSSF__c, new List<Project_Event__c>{pje});
            }
        }
        
        List<Project_Event__c> allPjeEvents = new List<Project_Event__c>();
        for(PSSF__c pssf : pssfToUpdtLst){
            if( pssfToPJEMap.containsKey( pssf.Id ) && pssfToPJEMap.get(pssf.Id) != null ){
                List<Project_Event__c> pjeEvents = pssfToPJEMap.get(pssf.Id);
                if( pjeEvents.size() > 0 ){
                    for(Project_Event__c pje : pjeEvents){
                        projectEventsToActualDateMap.put(pje.Id, pje.Event_Actual_Date__c);
                        allPjeEvents.add(pje);
                    } 
                }
            }
        }
        
        for(Project_Event__c pJeAll : allPjeEvents){
            pJeAll.Event_Actual_Date__c = System.Today();
        }
        update allPjeEvents;
                
        for(Project_Event__c pJeAll : allPjeEvents){
            pJeAll.Event_Actual_Date__c = (projectEventsToActualDateMap.get(pJeAll.Id) != null) ? ((Date) projectEventsToActualDateMap.get(pJeAll.Id)) : null;
        }
        update allPjeEvents;
        
    }    

    public class pssfFieldException extends Exception {}

}
