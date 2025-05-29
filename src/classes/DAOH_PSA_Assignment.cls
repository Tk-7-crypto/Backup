/**
* This is Assignment trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Assignment {
    /**
     * Method to automatically set some fields upon creation and update
     */
    public static void fieldAutomations(List<pse__Assignment__c> newList, Map<Id,pse__Assignment__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        for(pse__Assignment__c assignment : newList){
            if (assignment.RecordTypeId == null || 
                methodToRecordTypeMap == null || 
                methodToRecordTypeMap.get('fieldAutomations') == null ||
                !methodToRecordTypeMap.get('fieldAutomations').contains(Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosById().get(assignment.RecordTypeId).getDeveloperName()) ) {
                continue;
            }

            pse__Assignment__c old = (assignment.Id != null && oldMap != null) ? oldMap.get(assignment.Id) : null;
            //if is new OR if role was set to service line lead
            if ( assignment.pse__Role__c == 'Service Line Lead' && 
                 assignment.Primary_Service_Line_Lead__c == false && 
                 (old == null || old.pse__Role__c != 'Service Line Lead' )
                ) {
                assignment.Primary_Service_Line_Lead__c = true;
            }
			
            //Populate 'Internal Publisher' in the 'Oversight Dashboard Role' field if the Role on Assignment is 'Project Manager'.
            if(assignment.pse__Role__c == 'Project Manager'
                && (old == null || old.pse__Role__c != 'Project Manager') ) {
                    assignment.Oversight_Dashboard_Role__c = 'Internal Publisher';
            }
        }
    }
    //set active checkbox to true and status to scheduled when an assignment is created.
    public static void fieldUpdateOnCreation(List<pse__Assignment__c> newList, Map<Id,pse__Assignment__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        for(pse__Assignment__c assignment : newList){
            if(assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS){
            	assignment.Active__c = true;
            	assignment.pse__Status__c = 'Scheduled';
            }
        }  
    }
    /**
     * Method to set the Service Line Lead on an assignment's project if it is created with role 'Service Line Lead' or has the 'Primary Service Line Lead' box checked
     */
    public static void syncServiceLineLeads(List<pse__Assignment__c> newList, Map<Id,pse__Assignment__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        List<pse__Assignment__c> inScopeAssignmentsList = new List<pse__Assignment__c>();
        Set<Id> inScopeAssignmentIds = new Set<Id>();
        Set<Id> inScopeProjectIds = new Set<Id>();

        for(pse__Assignment__c assignment : newList){
            if (assignment.RecordTypeId == null || 
                methodToRecordTypeMap == null || 
                methodToRecordTypeMap.get('syncServiceLineLeads') == null ||
                !methodToRecordTypeMap.get('syncServiceLineLeads').contains(Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosById().get(assignment.RecordTypeId).getDeveloperName()) ) {
                continue;
            }

            pse__Assignment__c old = (assignment.Id != null && oldMap != null) ? oldMap.get(assignment.Id) : null;

            // Criteria: 
            //  New assignments with Role of Service Line Lead
            //  Existing assignments changed to Role of Service Line Lead
            //  Existing assignments with Role of Service Line Lead that have Primary Service Line Lead newly checked
            if( assignment.pse__Role__c == 'Service Line Lead' && ( 
                    ( old == null ) ||
                    ( assignment.Primary_Service_Line_Lead__c == true && old.Primary_Service_Line_Lead__c == false ) ||
                    ( old.pse__Role__c != 'Service Line Lead' )
                ) ) {

                inScopeAssignmentsList.add(assignment);
                inScopeAssignmentIds.add(assignment.Id);
                inScopeProjectIds.add(assignment.pse__Project__c);
            }
        }

        if(inScopeAssignmentsList.size() > 0){
            //Get list of projects for these assignments
            Map<Id,pse__Proj__c> projectMap = new SLT_Project(false,false).getProjectById(inScopeProjectIds, new Set<String>{'Id', 'Service_Line_Lead__c'});
            List<pse__Proj__c> projectsToUpdate = new List<pse__Proj__c>();
            List<pse__Assignment__c> assignmentsToUpdate = new List<pse__Assignment__c>();

            //Fetch all Service Line Lead assignments for those projects that have the checkbox set
            Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Project__c', 'Primary_Service_Line_Lead__c'};
            List<pse__Assignment__c> existingLeadAssignments = new SLT_Assignment(false,false).selectAssignmentsByIdSet(inScopeProjectIds, 'pse__Project__c IN :sObjectIdset AND Primary_Service_Line_Lead__c = true', assignmentFieldSet).values(); 

            for(pse__Assignment__c leadAssignment : existingLeadAssignments){
                if( !inScopeAssignmentIds.contains(leadAssignment.Id) ){
                    leadAssignment.Primary_Service_Line_Lead__c = false;
                    assignmentsToUpdate.add(leadAssignment);
                }
            }

            for(pse__Assignment__c assignment : inScopeAssignmentsList){
                pse__Proj__c project = projectMap.get(assignment.pse__Project__c);
                if( project != null && !projectsToUpdate.contains(project) ){
                    project.Service_Line_Lead__c = assignment.pse__Resource__c;
                    projectsToUpdate.add(project);
                }
            }
            
            // For updating Service line leads on related project's RDS Project tasks
            Map<Id, List<pse__Project_Task__c>> projIdToProjectTasksMap = new Map<Id, List<pse__Project_Task__c>>();
            Set<String> projIdSet = new Set<String>();
            List<pse__Project_Task__c> projTaskToUpdtList = new List<pse__Project_Task__c>();
            for(pse__Proj__c proj : projectsToUpdate){
                projIdSet.add(proj.Id);
            }
            if(projIdSet != null){
                projIdToProjectTasksMap = new SLT_Project_Task().selectProjTasksByProjId(projIdSet, new Set<String>{'Id', 'Service_Line_Lead__c','pse__Project__c'});
                for(pse__Proj__c project :  projectsToUpdate){
                    List<pse__Project_Task__c> projTaskList = new List<pse__Project_Task__c>();
                    projTaskList = projIdToProjectTasksMap.get(project.Id);
                    if(projTaskList != null){
                        for(pse__Project_Task__c tskToUpdt : projTaskList){
                            tskToUpdt.Service_Line_Lead__c = project.Service_Line_Lead__c;
                            projTaskToUpdtList.add(tskToUpdt);
                        }
                    }
                }
            }

            if(projectsToUpdate.size() > 0){
                update projectsToUpdate;
            }

            if(assignmentsToUpdate.size() > 0){
                update assignmentsToUpdate;
            }
            
            if(projTaskToUpdtList.size()>0){
                update projTaskToUpdtList;
            }
        }
    }
    
    /**
    * This method is used to update EndDate of schedule on status changed to closed of Assignment.
    * @params  newList List<pse__Assignment__c>
    * @params  oldMap Map<Id, pse__Assignment__c>
    * @return  void
    */
    public static void updateScheduleEndDateWhenStatusClosed(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap) {
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
        Set<String> scheduleFieldSet = new Set<String>{'Id','pse__End_Date__c'};
        Set<Id> scheduleIdSet = new Set<Id>();
        //scheduleIdSet contains schedule to be updated. 
        for(pse__Assignment__c assignment : newList){
            if(assignment.pse__Status__c == CON_PSA.ASSIGNMENT_STATUS_CLOSED && assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS) {
                if(oldMap == null || (oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c)){
                    scheduleIdSet.add(assignment.pse__Schedule__c);
                }
            }
        }
        Map<Id, pse__Schedule__c> scheduleIdToScheduleMap = new SLT_Schedule(false).selectScheduleById(scheduleIdSet,scheduleFieldSet);
        
        if(!scheduleIdToScheduleMap.isEmpty()){
            for(pse__Assignment__c assignment : newList){
                if(assignment.pse__Status__c == CON_PSA.ASSIGNMENT_STATUS_CLOSED && assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS
                   && oldMap == null || (oldMap != null && assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c)
                   && scheduleIdToScheduleMap.get(assignment.pse__Schedule__c) != null){
                       pse__Schedule__c schedule = scheduleIdToScheduleMap.get(assignment.pse__Schedule__c);
                       schedule.pse__End_Date__c = System.today();
                       scheduleList.add(Schedule);
                   }
            }
        }
        if(scheduleList.size() > 0){
            update scheduleList;
        }
    }

    //This method updates active to false when status is set to closed
    public static void updateActiveWhenStatusClosed(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        for(pse__Assignment__c assignment : newList){
            if(assignment.pse__Status__c == CON_PSA.ASSIGNMENT_STATUS_CLOSED && assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS) { 
                assignment.Active__c = false;
            }
        }
    }
    // validate RDS Assignment on insert and edit
    public static void validate_RDS_Assignment(List<pse__Assignment__c> newList, Map<Id,pse__Assignment__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            for(pse__Assignment__c assignment : newList){
                if(assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS && assignment.pse__Role__c == null){
                    assignment.addError('Role: You must enter a value');
                }
            }
        }
    }
    
    public static void populateResourceLanguageSkillSet(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        String languageStr = '';
        Set<Id> resourceIdSet = new Set<Id>();
        List<Schema.PicklistEntry> languageValuesList = pse__Skill_Certification_Rating__c.Language__c.getDescribe().getPicklistValues();
        Map<String, String> picklistValueToApiNameOfLanguageMap = new Map<String, String>();
        Map<String, Set<String>> resourceIdToResourceSkillSetSetMap = new Map<String, Set<String>>();
        Map<String, Set<String>> resourceIdTolanguageSetMap = new Map<String, Set<String>>();
        List<pse__Skill_Certification_Rating__c> resourceLanguageRatingList = new List<pse__Skill_Certification_Rating__c>();
        Set<String> skillCertificationRatingFieldsSet = new Set<String>{'Id', 'pse__Resource__c', 'pse__Rating__c', 'Language__c', 'pse__Skill_Certification__r.pse__Type__c'}; 
        String conditionString = 'pse__Resource__c IN : resourceIdSet AND pse__Skill_Certification__r.pse__Type__c = \'Language\' AND Language__c != null '
            +'AND pse__Resource__c != null AND pse__Rating__c != null'; 
        
        for(Schema.PicklistEntry languagePicklistValue : languageValuesList){
            picklistValueToApiNameOfLanguageMap.put(languagePicklistValue.getValue(), languagePicklistValue.getLabel());
        }
        
        for(pse__Assignment__c assignment : newList){
            if(assignment.pse__Resource__c != null && assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS){
                resourceIdSet.add(assignment.pse__Resource__c);
            }
        }
        
        if(resourceIdSet.size() > 0){
            resourceLanguageRatingList = new SLT_Skill_Certification_Rating(false,false).getSkillCertificationRatingsByResourceIds(resourceIdSet, conditionString, skillCertificationRatingFieldsSet, true);
            for(pse__Skill_Certification_Rating__c languageRating : resourceLanguageRatingList){
                if(picklistValueToApiNameOfLanguageMap.containsKey(languageRating.Language__c)){
                    languageStr = picklistValueToApiNameOfLanguageMap.get(languageRating.Language__c);
                }
                if(resourceIdToResourceSkillSetSetMap.containsKey(languageRating.pse__Resource__c)){
                    resourceIdTolanguageSetMap.get(languageRating.pse__Resource__c).add(languageRating.Language__c);
                    resourceIdToResourceSkillSetSetMap.get(languageRating.pse__Resource__c).add(languageStr+': '+languageRating.pse__Rating__c);
                }else{
                    resourceIdToResourceSkillSetSetMap.put(languageRating.pse__Resource__c, new Set<String>{languageStr+': '+languageRating.pse__Rating__c});
                    resourceIdTolanguageSetMap.put(languageRating.pse__Resource__c, new Set<String>{languageRating.Language__c});
                }
            } 
        }
        
        if(resourceIdTolanguageSetMap.size() > 0){
            for(pse__Assignment__c assignment : newList){
                if(Trigger.isInsert 
                   && assignment.pse__Resource__c != null 
                   && resourceIdTolanguageSetMap.containsKey(assignment.pse__Resource__c))
                {
                    if(resourceIdTolanguageSetMap.get(assignment.pse__Resource__c) != null && resourceIdTolanguageSetMap.get(assignment.pse__Resource__c).Size() > 0){
                        assignment.Preferred_Language__c = String.join( new List<String>(resourceIdTolanguageSetMap.get(assignment.pse__Resource__c)), ';');
                    }  
                }
            }
        }
    }
    public static void updateActiveResourceOnProject(List<pse__Assignment__c> newList, Map<Id, pse__Assignment__c> oldMap){
        Set<Id> projectIdSet = new Set<Id>();
        if(trigger.isInsert || trigger.isUpdate){
            for(pse__Assignment__c assignment : newList){
                if(assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS
                   && (trigger.isInsert 
                       || (trigger.isUpdate 
                           && ((assignment.Active__c != oldMap.get(assignment.Id).Active__c)
                               ||(assignment.pse__Status__c != oldMap.get(assignment.Id).pse__Status__c))
                          ))
                  )
                {
                    projectIdSet.add(assignment.pse__Project__c);
                } 
            }
        }
        if(trigger.isDelete){
            for(pse__Assignment__c assignment : oldMap.values()){
                if(assignment.recordTypeId == CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS){
                    projectIdSet.add(assignment.pse__Project__c);
                }
            }
        }
        if(!projectIdSet.isEmpty()){
            updateLiteratureProjectList(projectIdSet);
        }
    }
    @future
    public static void updateLiteratureProjectList(Set<Id> projectIdSet){
        UTL_PSA.updateActiveResourceLitertureProjectList(projectIdSet);
    }
      public static void deleteNonBillableProject(Map<Id, pse__Assignment__c> oldMap){
        String profileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
        Set<String> profileNameSet = new Set<String>{'System Administrator', 'System Administrator Integration', 'System Administrator Module','System Administrator Package Support','IQVIA Salesforce Platform Support'};
        if(!profileNameSet.contains(profileName)) { 
            Set<String> nonBillableProjectIds = new Set<String>();
            
            List<PermissionSetAssignment> psaList = [
                SELECT PermissionSet.Name,Assignee.Profile.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('RDS_Resource','RDS_Project_Manager_and_Functional_Lead','RDS_Resource_and_Line_Manager')
            ];
            if(psaList.size()>0){
                PSA_RDS_Settings__c rdsSetting = PSA_RDS_Settings__c.getInstance();
                if(rdsSetting.Non_billable_ProjectId__c != null){
                    nonBillableProjectIds = new Set<String>(rdsSetting.Non_billable_ProjectId__c.split(','));
                }     
                List<Contact> contactList = new List<Contact>();
                Set<String> contactFieldSet = new Set<String>{'Id', 'Name', 'pse__Salesforce_User__c','Salesforce_User__c'};
                contactList= new SLT_Contact().selectBySalesforceUserIdsList(new Set<Id>{UserInfo.getUserId()}, contactFieldSet);
                for(pse__Assignment__c assignments : oldMap.values()){
                    if(contactList.size() == 0) {
                        assignments.addError('You do not have permission to delete this Assignment.');
                    } 
                    else if(nonBillableProjectIds.contains(assignments.pse__Project__c)){
                        if (assignments.pse__Resource__c != contactList[0].Id) {
                            assignments.addError('You do not have permission to delete this Assignment.');
                        }
                    }
                    else{
                        assignments.addError('You do not have permission to delete this Assignment.');
                    }                    
                }
            }
        }        
    }
  
}
