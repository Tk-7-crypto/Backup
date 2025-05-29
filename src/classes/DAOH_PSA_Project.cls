/**
* This is Project trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Project {
    private static Integer RESOURCE_REQUEST_BATCH_SIZE = 50;
    private static Set<Id> projectIdsForUpdatingWorkflowCondition = new Set<Id>();
    
    public static void fieldValidationsRDS(List<pse__Proj__c> newList, Map<Id, pse__Proj__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c && !CON_PSA.isSkipValidationFieldValidationsRDS && trigger.isUpdate){
            //get custom setting 
            PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
            for(pse__Proj__c projRec : newList){
                String recordTypeName = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(projRec.RecordTypeId).getName();
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.CT_Database_Location__c == null){
                    projRec.addError('CT Database Location is required.');
                }
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.Safety_Database_Location__c == null){
                    projRec.addError('Safety Database Location is required.');
                }
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.Setting__c == null){
                    projRec.addError('Setting is required.');
                }
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.Scope__c != null && projRec.Scope__c.contains('Other') && String.isBlank(projRec.Provide_Reason__c)){
                    projRec.addError(' You have selected '+ '\'' + 'Other' + '\''+ ' in scope, please provide reason to ' + '\'' +'If Other (Specify)' + '\'' + '.');
                }
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.Scope__c != null && !projRec.Scope__c.contains('PSSF') && String.isBlank(projRec.Provide_Reason_PSSF_not_in_Scope__c)){
                    projRec.addError(' You have not selected '+ '\''+ 'PSSF' + '\'' + ' in scope, please provide reason PSSF not in scope.');
                }
                if(recordTypeName == CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE && projRec.Service_Line__c == rdsSettings.Signal_Management_Service_Line_Id__c && projRec.Scope__c != null && !projRec.Scope__c.contains('SMT Charter') && String.isBlank(projRec.Provide_Reason_SMT_Charter_not_in_Scope__c)){
                    projRec.addError(' You have not selected ' +'\''+'SMT Charter'+'\''+' in scope, please provide reason SMT Charter not in scope.');
                }
                break;
            }
        }
    }
    
    /**
* This method is used to Set Project Manager on Resource Request when PM is set or changed on the project.
* @params  newList List<pse__Proj__c>
* @return  void
*/
    public static void updatePMFieldOnRR (List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap,Map<String, Set<String>> methodToRecordTypeMap) {
        
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();

        Set<Id> projectIdSet = new Set<Id>();
        
        for (pse__Proj__c updatedproject : newList) {
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('updatePMFieldOnRR') == null || !methodToRecordTypeMap.get('updatePMFieldOnRR').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedproject.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            //check if Service Line Lead field on Project has changed/updatesd.
            if (oldMap != null && oldMap.get(updatedproject.id) != null) {
                Id oldServiceLineManagerId = oldMap.get(updatedproject.id).Service_Line_Lead__c;
                if( updatedproject.Service_Line_Lead__c != oldServiceLineManagerId){
                    inScopeProjectList.add(updatedproject);
                    projectIdSet.add(updatedproject.id);
                }
            }
        }
        
        if (inScopeProjectList.size() > 0) {
            Database.executeBatch(new BCH_PSA_UpdateRRFields(projectIdSet), RESOURCE_REQUEST_BATCH_SIZE);
        }
            
    }
    
    /**
* This method is used roll up SL Project values to the RDS Projects
*/
    public static void rollUpActuals(List<pse__Proj__c> newList, Map<Id, pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        Set<Id> projectIdSet = new Set<Id>();
        
        for(pse__Proj__c proj : newList) {
            
            pse__Proj__c oldms = oldMap != null ? oldMap.get(proj.id) : null;
            
            if ( methodToRecordTypeMap.get('rollUpActuals') == null || !methodToRecordTypeMap.get('rollUpActuals').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(proj.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }
            
            if ((proj.pse__Parent_Project__c != null && oldMap == null)
                || ( oldMap != null && proj.Budget_Hours__c != oldms.Budget_Hours__c && proj.pse__Parent_Project__c !=  null)
                || ( oldMap != null && proj.pse__Total_Assigned_Hours__c != oldms.pse__Total_Assigned_Hours__c && proj.pse__Parent_Project__c !=  null))
            {
                projectIdSet.add(proj.pse__Parent_Project__c);
            }
        }
        
        if (projectIdSet.size() > 0) {
            if (system.isFuture() || system.isBatch() || system.isScheduled()) {
                UTL_PSA_RollupActuals.refreshRDSProjectActuals(projectIdSet);
            } else {
                UTL_PSA_RollupActuals.refreshRDSProjectActuals_Future(projectIdSet);
            }
        }
    }
    
    /**
* This method is used to Set Project Manager and Service Line Lead on Milestones when PM is set or changed on the project.
*/
    public static void updatePMFieldOnMilestones (List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();
        List<pse__Milestone__c> milestoneUpdateList = new List<pse__Milestone__c>();
        Set<Id> projectIdSet = new Set<Id>();
        
        for (pse__Proj__c updatedproject : newList) {
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('updatePMFieldOnMilestones') == null || !methodToRecordTypeMap.get('updatePMFieldOnMilestones').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedproject.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            //check if Service Line Lead field on Project has changed/updatesd.
            if (oldMap != null && oldMap.get(updatedproject.id) != null) {
                Id oldServiceLineManagerId = oldMap.get(updatedproject.id).Service_Line_Lead__c;
                if( updatedproject.Service_Line_Lead__c != oldServiceLineManagerId){
                    inScopeProjectList.add(updatedproject);
                    projectIdSet.add(updatedproject.id);
                }
            }
        }
        
        if (inScopeProjectList.size() > 0) {
            
            Map<Id, List<pse__Milestone__c>> projectMilestoneListMap = new SLT_Milestone().selectMilestoneListByProjectId(projectIdSet,new Set<String> {'Id','Name','pse__Project__c','Project_Manager__c', 'Service_Line_Lead__c'});
            
            for (pse__Proj__c updatedproject : inScopeProjectList) {
                
                List<pse__Milestone__c> milestoneTempList = projectMilestoneListMap.get(updatedproject.id);
                
                if(milestoneTempList != null ){
                    for(pse__Milestone__c  ms : milestoneTempList){
                        ms.Project_Manager__c = updatedproject.pse__Project_Manager__c;
                        ms.Service_Line_Lead__c = updatedproject.Service_Line_Lead__c;
                        milestoneUpdateList.add(ms);
                    }
                }
            }
            
            if(milestoneUpdateList.size() > 0){
                update milestoneUpdateList;
            }
        }
    }
    
    /**
* This method is used to set field updates on RDS Projects
*/
    public static void setRDSProjectFields(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        
        for(pse__Proj__c project : newList) {
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('setRDSProjectFields') == null || !methodToRecordTypeMap.get('setRDSProjectFields').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(project.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            if (project.pse__Stage__c == 'Completed') {
                project.pse__Closed_for_Time_Entry__c = true;
                project.Closed_for_Unit_Entry__c = true;
                if( (oldMap == null || (oldMap != null && oldMap.get(project.id).pse__Stage__c != project.pse__Stage__c)) 
                   && project.Date_Completed__c == null) {
                   		project.Date_Completed__c = Date.today();
                }
                if(oldMap == null || (oldMap != null && oldMap.get(project.id).Date_Completed__c != project.Date_Completed__c)) {
                    if(project.Date_Completed__c == null){
                    	project.addError('The \'Date Completed\' is required field, please update to save the record');
                    }
                    else {
                        DateTime dT = project.Date_Completed__c;
                        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                        if(myDate > Date.today()){
                            project.addError('The \'Date Completed\' field cannot be in future.');
                        }
                    }    
                }
            }
        }
    }
    
    /**
* This method is used to set field updates on child Service Line Projects
*/
    public static void updateServiceLineProjectFields(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        
        for(pse__Proj__c project : newList) {
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('updateServiceLineProjectFields') == null || !methodToRecordTypeMap.get('updateServiceLineProjectFields').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(project.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            if (project.pse__Stage__c == 'Completed') {
                project.pse__Is_Active__c = false;
                project.pse__Closed_for_Time_Entry__c = true;
                project.Closed_for_Unit_Entry__c = true;
                if( (oldMap == null || (oldMap != null && oldMap.get(project.id).pse__Stage__c != project.pse__Stage__c)) 
                   && project.Date_Completed__c == null) {
                   		project.Date_Completed__c = Date.today();
                }
                if(oldMap == null || (oldMap != null && oldMap.get(project.id).Date_Completed__c != project.Date_Completed__c)) {
                    if(project.Date_Completed__c == null){
                    	project.addError('The \'Date Completed\' is required field, please update to save the record');
                    }
                    else {
                        DateTime dT = project.Date_Completed__c;
                        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                        if(myDate > Date.today()){
                            project.addError('The \'Date Completed\' field cannot be in future.');
                        }
                    } 
                }
            }
            
            // on insert
            if (project.Service_Line_Lead__c != null && oldMap == null) {
                project.pse__Project_Manager__c = project.Service_Line_Lead__c;
            }
            
            // on update
            if (oldMap != null && project.pse__Project_Manager__c != project.Service_Line_Lead__c) {
                project.pse__Project_Manager__c = project.Service_Line_Lead__c;
            }
        }
    }
 
    /* This method is used to delete project tasks from CEVA service line project when a Service Line Scope Vlue is deselected.
     * IQVIAPSA-5980
	*/
    public static void deleteDeselectedSlScopeProjectTasks(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        String serviceLineScopeNewValues;
        String serviceLineScopeOldValues;
        List<String> serviceLineScopeOldValuesList= new List<String>();
        List<String> serviceLineScopeNewValuesList= new List<String>();
        List<String> serviceLineScopeDeselectedValuesList= new List<String>();
        Set<String> projectTaskFieldsSet = new Set<string>{'Id','Service_Line_Scope__c','pse__Project__c','pse__Status__c'};
	    List<pse__Proj__c> projectList = new List<pse__Proj__c>();
        List<pse__Project_Task__c> taskToDeleteIdList = new List<pse__Project_Task__c>();
        Set<Id> projectIdSet = new Set<Id>();
        List< pse__Project_Task__c > currentProjectTaskList;
        Map<String, List<pse__Project_Task__c>> currentProjectIdToProjectTaskListMap = new Map<String, List<pse__Project_Task__c>>();
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        
        // adding ceva service ine projects to a list if SL scope value is updated.
        for(pse__Proj__c projectRecord : newList){
            if(mulesoftSetting != null && mulesoftSetting.Ignore_Validation_Rules__c == FALSE 
               && projectRecord.RecordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE
               && oldMap != null 
               && oldMap.get(projectRecord.id) != null 
               && projectRecord.Service_Line_Scope__c != oldMap.get(projectRecord.id).Service_Line_Scope__c){
                   projectList.add(projectRecord);
                   projectIdSet.add(projectRecord.Id);
               }
        }
        if(projectIdSet.size() > 0){
            // adding project-id wise tasks to currentProjectIdToProjectTaskListMap map.
            currentProjectTaskList = new SLT_Project_Task().getProjectTasksByServiceLineProject( projectIdSet, projectTaskFieldsSet );
            for (pse__Project_Task__c pt : currentProjectTaskList){
                if(currentProjectIdToProjectTaskListMap.containsKey(pt.pse__Project__c)){
                    currentProjectIdToProjectTaskListMap.get(pt.pse__Project__c).add(pt);                    
                }else{
                    currentProjectIdToProjectTaskListMap.put(pt.pse__Project__c, new List<pse__Project_Task__c>{pt});
                }
            }
            for(pse__Proj__c currentProject : projectList){
                // adding deselected picklist values to serviceLineScopeDeselectedValuesList list.
                serviceLineScopeNewValues = string.valueOf(currentProject.Service_Line_Scope__c) != null ? string.valueOf(currentProject.Service_Line_Scope__c) : '';
                serviceLineScopeOldValues = string.valueOf(oldMap.get(currentProject.id).Service_Line_Scope__c) != null ? string.valueOf(oldMap.get(currentProject.id).Service_Line_Scope__c) : '';
                if(serviceLineScopeNewValues != ''){
                    serviceLineScopeNewValuesList = serviceLineScopeNewValues.split(';');
                }
                if(serviceLineScopeOldValues != ''){
                    serviceLineScopeOldValuesList = serviceLineScopeOldValues.split(';');
                }
                for(String plValue: serviceLineScopeOldValuesList){
                    if(!serviceLineScopeNewValuesList.contains(plValue)){
                        serviceLineScopeDeselectedValuesList.add(plValue);
                    }
                }
                if(currentProjectIdToProjectTaskListMap.containsKey(currentProject.Id) 
                   && currentProjectIdToProjectTaskListMap.get(currentProject.Id) != null){
                       for(pse__Project_Task__c pt : currentProjectIdToProjectTaskListMap.get(currentProject.Id)){
                           if(pt.Service_Line_Scope__c != null && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE && serviceLineScopeDeselectedValuesList.contains(pt.Service_Line_Scope__c)){
                               taskToDeleteIdList.add(new pse__Project_Task__c(Id = pt.Id));
                           }
                       }
                   }
                serviceLineScopeDeselectedValuesList.clear();
            }
        }
        //delete taskToDeleteIdList;
        if(taskToDeleteIdList.size() > 0){
            CON_PSA.PROJ_TASK_FLAG = false;
            Database.DeleteResult[] deletedTasksList = Database.delete(taskToDeleteIdList);  
            CON_PSA.PROJ_TASK_FLAG = true;
        }
    }
    

    /**
* This method is used to apply checklist tasks when an update is needed outside of project creation scenario
*/
    public static void applyTemplateChecklistTasks(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();
        Set<Id> projectIdSet = new Set<Id>();
        Map<id, pse__Proj__c> projectMap = new Map<id,pse__Proj__c>();
        for(pse__Proj__c projectRecord : newList){
            if(projectRecord.RecordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE){
                projectIdSet.add(projectRecord.id);
            }     
        }
        if(projectIdSet.size() > 0){
            List<pse__Proj__c> updatedProjectList  = new SLT_Project().selectByProjectRecordId(projectIdSet, new Set<String>{'Service_Line_Lead__c', 'Service_Line__r.Name', 'RecordTypeId', 'CT_Database_Location__c', 'Setting__c', 'pse__Parent_Project__c', 'pse__Group__c', 'Safety_Database_Location__c', 'Service_Line_Scope__c', 'Project_Category__c', 'Project_Scope__c', 'Program__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'Go_Live_Date__c', 'Close_Out_Date__c', 'pse__Account__r.Name', 'pse__Stage__c'});
            for (pse__Proj__c updatedprojectRecord : updatedProjectList) {
                projectMap.put(updatedprojectRecord.id,updatedprojectRecord);
            }
            for (pse__Proj__c updatedproject : newList) {
                
                //skip record if code not configured for recordtype
                if ( methodToRecordTypeMap.get('QUE_PSA_ApplyRDSProjectTaskTemplates') == null || !methodToRecordTypeMap.get('QUE_PSA_ApplyRDSProjectTaskTemplates').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedproject.RecordTypeId).getDeveloperName()) ) {
                    continue;
                }
                if (oldMap != null && oldMap.get(updatedproject.id) != null) {
                    boolean oldActionApplyTasks = oldMap.get(updatedproject.id).Action_Apply_Template_Tasks__c;
                    if((updatedproject.Project_Scope__c != oldMap.get(updatedproject.Id).Project_Scope__c
                        || updatedproject.pse__Group__c != oldMap.get(updatedproject.Id).pse__Group__c
                        || updatedproject.Project_Category__c != oldMap.get(updatedproject.Id).Project_Category__c 
                        || updatedproject.Service_Line__c != oldMap.get(updatedproject.Id).Service_Line__c
                        || updatedproject.Service_Line_Scope__c != oldMap.get(updatedproject.Id).Service_Line_Scope__c
                        || updatedproject.CT_Database_Location__c != oldMap.get(updatedproject.Id).CT_Database_Location__c
                        || updatedproject.Setting__c != oldMap.get(updatedproject.Id).Setting__c
                        || updatedproject.Safety_Database_Location__c != oldMap.get(updatedproject.Id).Safety_Database_Location__c) 
                       && ((projectMap.get(updatedproject.id).Service_Line__r.Name == CON_PSA.PROJ_SERVICELINE_CEVA 
                            && updatedproject.Service_Line_Scope__c != null)
                           || (projectMap.get(updatedproject.id).Service_Line__r.Name == CON_PSA.PROJ_SERVICELINE_SIGNAL_MANAGEMENT
                               && updatedproject.CT_Database_Location__c != null
                               && updatedproject.Setting__c != null 
                               && updatedproject.Safety_Database_Location__c != null))
                       || (updatedproject.Action_Apply_Template_Tasks__c && !oldActionApplyTasks))
                    {
                        inScopeProjectList.add(updatedproject);
                        updatedproject.Action_Apply_Template_Tasks__c = false;
                    }
                }
            }
        }
        
        if (inScopeProjectList.size() > 0) {
            //Id jobId = BCH_PSA_ApplyRDSProjectTaskTemplates.batchRun(inScopeProjectList);
            BCH_PSA_InsertTaskTemplates.batchRun(inScopeProjectList);
        }        
    }
    
    /**
* This method is used to cascade status and other fields (future?) to the sub-projects
*/
    /*public static void cascadeToServiceLineProjects(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();
        List<pse__Proj__c> supProjectUpdateList = new List<pse__Proj__c>();
        Set<Id> projectIdSet = new Set<Id>();
        
        for (pse__Proj__c updatedproject : newList) {
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('cascadeToServiceLineProjects') == null || !methodToRecordTypeMap.get('cascadeToServiceLineProjects').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedproject.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            //check if stage had been updated
            if (oldMap != null && oldMap.get(updatedproject.id) != null) {
                string oldStage = oldMap.get(updatedproject.id).pse__Stage__c;
                boolean oldActive = oldMap.get(updatedproject.id).pse__Is_Active__c;
                boolean oldClosedForUnitEntry = oldMap.get(updatedproject.id).Closed_for_Unit_Entry__c;
                
                if ((updatedproject.pse__Stage__c == 'Completed' && updatedproject.pse__Stage__c != oldStage)
                    || (updatedproject.Closed_for_Unit_Entry__c && !oldClosedForUnitEntry)
                    || (!updatedproject.pse__Is_Active__c && oldActive))
                {
                    inScopeProjectList.add(updatedproject);
                    projectIdSet.add(updatedproject.id);
                }
            }
        }
        
        if (inScopeProjectList.size() > 0) {
            
            Map<Id, List<pse__Proj__c>> subProjectMap = new SLT_Project(false,false).selectMapByParentProjectId(projectIdSet,new Set<String> {'Id', 'Name', 'pse__Parent_Project__c', 'pse__Stage__c'});
            
            for (pse__Proj__c updatedproject : inScopeProjectList) {
                List<pse__Proj__c> subProjectList = subProjectMap.get(updatedproject.id);
                
                if(subProjectList != null ){
                    for(pse__Proj__c subProj : subProjectList){
                        subProj.pse__Stage__c = updatedproject.pse__Stage__c == 'Completed' ? 'Not Active' : subProj.pse__Stage__c;
                        subProj.Closed_for_Unit_Entry__c = updatedproject.Closed_for_Unit_Entry__c;
                        subProj.pse__Is_Active__c = updatedproject.pse__Is_Active__c;
                        
                        supProjectUpdateList.add(subProj);
                    }
                }
            }
            
            if(supProjectUpdateList.size() > 0){
                update supProjectUpdateList;
            }
        }
    }*/
    
    /**
* This method is used to close related child project assignments
*/
    public static void closeRelatedAssignments(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        List<pse__Proj__c> inScopeProjectList = new List<pse__Proj__c>();
        List<pse__Assignment__c> relatedAssignmentsCloseList = new List<pse__Assignment__c>();
        List<pse__Schedule__c> relatedSchedulesCloseList = new List<pse__Schedule__c>();
        Set<Id> projectIdSet = new Set<Id>();
        
        for (pse__Proj__c updatedproject : newList) {
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('closeRelatedAssignments') == null || !methodToRecordTypeMap.get('closeRelatedAssignments').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedproject.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            
            //check if stage had been updated
            if (oldMap != null && oldMap.get(updatedproject.id) != null) {
                string oldStage = oldMap.get(updatedproject.id).pse__Stage__c;
                
                if (updatedproject.pse__Stage__c == 'Completed' && updatedproject.pse__Stage__c != oldStage){
                    inScopeProjectList.add(updatedproject);
                    projectIdSet.add(updatedproject.id);
                }
            }
        }
        
        if (inScopeProjectList.size() > 0) {
            
            List<pse__Assignment__c> relatedAssignmentList = new SLT_Assignment(false,false).getAssignmentsByProject
                (projectIdSet, new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Status__c', 'Active__c','Closed_for_Unit_Entry__c','pse__Closed_for_Time_Entry__c', 'pse__Schedule__c', 'pse__Schedule__r.pse__End_Date__c'});
            
            Map<Id, List<pse__Assignment__c>> projectToAssignmentsMap = new Map<Id, List<pse__Assignment__c>>();
            
            for (pse__Assignment__c assign : relatedAssignmentList) {
                List<pse__Assignment__c> relatedAssignments = projectToAssignmentsMap.get(assign.pse__Project__c);
                
                if (relatedAssignments != null ) {
                    relatedAssignments.add(assign);
                    projectToAssignmentsMap.put(assign.pse__Project__c, relatedAssignments);
                } else {
                    projectToAssignmentsMap.put(assign.pse__Project__c, new List<pse__Assignment__c>{assign});
                }
            }
            
            for (pse__Proj__c updatedproject : inScopeProjectList) {
                
                List<pse__Assignment__c> relatedAssignments = projectToAssignmentsMap.get(updatedproject.id);
                
                if(relatedAssignments != null ){
                    for(pse__Assignment__c assignment : relatedAssignments){
                        assignment.pse__Status__c = 'Closed';
                        assignment.Closed_for_Unit_Entry__c = true;
                        assignment.pse__Closed_for_Time_Entry__c = true;
                        assignment.Active__c = false;
                        
                        relatedAssignmentsCloseList.add(assignment);
                        
                        pse__Schedule__c tempSchedule = new pse__Schedule__c(id=assignment.pse__Schedule__c);
                        
                        if (updatedproject.pse__End_Date__c < assignment.pse__Schedule__r.pse__End_Date__c) {
                            tempSchedule.pse__End_Date__c = updatedproject.pse__End_Date__c;
                            relatedSchedulesCloseList.add(tempSchedule);
                        }
                    }
                }
            }
            
            if(relatedAssignmentsCloseList.size() > 0){
                update relatedAssignmentsCloseList;
            }
            
            if(relatedSchedulesCloseList.size() > 0){
                update relatedSchedulesCloseList;
            }
        }
    }
    
    //This method is to sync up the project scope fields of RDS and its service line projects
    public static void syncProjectScopeFields(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        List<pse__Proj__c> supProjectUpdateList = new List<pse__Proj__c>();
        Set<Id> projectIdSet = new Set<Id>();
        List<pse__Proj__c> subProjectList;
        
        for(pse__Proj__c updatedProject : newList){
            
            //skip record if code not configured for recordtype
            if ( methodToRecordTypeMap.get('syncProjectScopeFields') == null || !methodToRecordTypeMap.get('syncProjectScopeFields').contains(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosById().get(updatedProject.RecordTypeId).getDeveloperName()) ) {
                continue;
            }
            if(updatedproject.RecordTypeId == CON_PSA.PROJ_REC_TYPE_ID_RDS_PROJECT && updatedProject.Project_Scope__c != oldMap.get(updatedProject.Id).Project_Scope__c){
                projectIdSet.add(updatedproject.id);
            }
        }
        if(projectIdSet.size() > 0){
            Map<Id, List<pse__Proj__c>> subProjectMap = new SLT_Project(false,false).selectMapByParentProjectId(projectIdSet,new Set<String> {'Id', 'Name', 'pse__Parent_Project__c'});
            
            for (pse__Proj__c parentProject : newList) {
                if(subProjectMap != null && subProjectMap.values().size()>0 && subProjectMap.containsKey(parentProject.id) && subProjectMap.get(parentProject.id) != null){
                    subProjectList = subProjectMap.get(parentProject.id);
                    if(subProjectList != null ){
                        for(pse__Proj__c subProj : subProjectList){
                            subProj.Project_Scope__c = parentProject.Project_Scope__c;                    
                            supProjectUpdateList.add(subProj);
                        }
                    }
                }
            }
        }
        
        if(supProjectUpdateList.size() > 0  && CON_PSA.runSubProjectUpdate){
            CON_PSA.runSubProjectUpdate = false;
            update supProjectUpdateList;
        }
    }
    
     /**
     * Method to check if the running user is allowed to delete the given Project record.
     */
    public static void validateDeletion(List<pse__Proj__c> deletedList){
        Id profileId=userinfo.getProfileId();
        User userRec = [select Id,Name, username from User where Id = :UserInfo.getUserId()];
        Set<String> profileNameSet = new Set<String>{'System Administrator', 'System Administrator Integration', 'System Administrator Module','System Administrator Package Support','IQVIA Salesforce Platform Support'};
         
        Set<Id> recordTypeSet = new Set<Id>();
        recordTypeSet.add(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Internal').getRecordTypeId());
        recordTypeSet.add(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Project').getRecordTypeId());
        recordTypeSet.add(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId());
        recordTypeSet.add(Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Template').getRecordTypeId());
        
        // get user profile
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        // get user permissoin set
        List<PermissionSetAssignment> permissionSetList = [SELECT Id, PermissionSet.Name,Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'RDS_Admin'];
        
        Set<String> rds_AdminUser = new Set<string>();
        for(PermissionSetAssignment perRec : permissionSetList){
            rds_AdminUser.add(perRec.Assignee.Name);
        }
        
        
        
        for(pse__Proj__c projRec : deletedList){
            if(profileNameSet.contains(profileName) || (rds_AdminUser.contains(userRec.Name) && recordTypeSet.contains(projRec.RecordTypeId))){
                // user have permission to delete project.;
            }
            else{
                projRec.addError('You are not authorised to delete this Project.');
            }
        }
    }
    static PSA_RDS_Settings__c psaRdsSeting = PSA_RDS_Settings__c.getOrgDefaults();
    static Id RDSProjectRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Project').getRecordTypeId();  
    public static void updateAssignmentCheckListTaskOnChangeOrder( List<pse__Proj__c> projectList, Map<Id,pse__Proj__c> oldMap ){
        Set<Id> ProjectIds=new Set<Id>();
        for(pse__Proj__c pro:projectList){
            if( pro.RecordTypeId == RDSProjectRecordTypeId && ( pro.pse__Stage__c=='Conduct' || pro.pse__Stage__c=='Start-Up' )){
                if(pro.pse__End_Date__c!=oldMap.get(pro.id).pse__End_Date__c){
                    ProjectIds.add(pro.Id);
                }
            }
        }
        if(!ProjectIds.isEmpty()){
            if(psaRdsSeting.IsFuture__c){
                updateAssignmentCheckListTaskOnChangeOrderinFuture(ProjectIds);
            }else{
                updateAssignmentCheckListTaskOnChangeOrderinQueue(ProjectIds);
            }
        } 
    }
    @future
    public static void updateAssignmentCheckListTaskOnChangeOrderinFuture(Set<Id> projectIds)
    {   
        updateAssignmentCheckListTaskOnChangeOrderinQueue(projectIds);
    }
    /**
	* This method is  used to update Assignment and RDS Project Task of RDSProject if End Date of RDSProject is Updated
	*/
    public static void updateAssignmentCheckListTaskOnChangeOrderinQueue(Set<Id> sObjectIdset){
        Map<Id,List<pse__Project_Task__c>> projectCheckListRDSProjectMap= new Map<Id,List<pse__Project_Task__c>>(); 
        
        Set<String> ProjectFieldSet=new Set<String>{'Id','pse__End_Date__c','Go_Live_Date__c','pse__Stage__c'};
        Set<String> assignmentFieldSet=new Set<String>{'Id','pse__Project__r.pse__Parent_Project__c','pse__Project__r.pse__Parent_Project__r.pse__End_Date__c','Active__c', 'pse__Status__c', 'pse__End_Date__c','pse__Schedule__c'};
        Set<String> CheckListTaskFieldSet=new Set<String>{'Id','Parent_Project__c','Type__c','pse__End_Date_Time__c','pse__Status__c'};
               
        String assignmentCondition='pse__Project__r.pse__Parent_Project__c in :sObjectIdset AND Active__c=true AND (pse__Status__c=\'Scheduled\' OR pse__Status__c=\'Tentative\')';
        
        List<pse__Proj__c> projectList=new SLT_Project().selectServiceLineByProject(sObjectIdset,ProjectFieldSet);        
        List<pse__Assignment__c> AssignmentList=new SLT_Assignment().getAssignmentByResource(sObjectIdset, assignmentCondition, assignmentFieldSet);
        List<pse__Project_Task__c> checkListTask=new SLT_Project_Task().getRDSRecordTypeProjectTasksByRDSProject(sObjectIdset,CheckListTaskFieldSet);
        
        List<Log_History__c> lstLogForError = new List<Log_History__c>();
        List<String> lstException = new List<String>();
        Set<Id> scheduleIds=new Set<Id>();
        if(!AssignmentList.isEmpty()){
            for(pse__Assignment__c ass:AssignmentList){
                scheduleIds.add(ass.pse__Schedule__c);
            }
        }
        List<pse__Schedule__c> scheduleList=[select id,pse__End_Date__c from pse__Schedule__c where id in:scheduleIds];
        if(!scheduleList.isEmpty()){
            for(pse__Assignment__c ass:AssignmentList){
                for(pse__Schedule__c schedule:scheduleList){
                    if(schedule.id==ass.pse__Schedule__c){
                        schedule.pse__End_Date__c=ass.pse__Project__r.pse__Parent_Project__r.pse__End_Date__c;
                    }
                }
            }
        }
        
        for(pse__Proj__c projects:projectList){
            List<pse__Project_Task__c> projectCheckListTask=new List<pse__Project_Task__c>();
            for(pse__Project_Task__c p:checkListTask){
                if(p.Parent_Project__c==projects.id){
                    projectCheckListTask.add(p); 
                }
            }
            projectCheckListRDSProjectMap.put(projects.id,projectCheckListTask);
        }
        List<pse__Project_Task__c> projectTaskToBeUpdated = new List<pse__Project_Task__c>();
        for(pse__Proj__c proj:projectList){
            List<pse__Project_Task__c> checkListTaskRelatedToRDSProject=projectCheckListRDSProjectMap.get(proj.Id);
            if(!checkListTaskRelatedToRDSProject.isEmpty()){
                if(proj.pse__Stage__c== CON_PSA.PROJ_STAGE_CONDUCT ){
                    for(pse__Project_Task__c checkList:checkListTaskRelatedToRDSProject){
                        
                        if( checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE 
                           && checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_COMPLETE 
                           && checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_CANCELLED ){
                               
                               if(checkList.Type__c== CON_PSA.PROJ_TYPE_CLOSE_OUT ){
                                   checkList.pse__End_Date_Time__c = proj.pse__End_Date__c;
                                   projectTaskToBeUpdated.add(checkList); 
                               }
                           }
                    }
                }
                if(proj.pse__Stage__c== CON_PSA.PROJ_STAGE_STARTUP){
                    for(pse__Project_Task__c checkList:checkListTaskRelatedToRDSProject){
                        if( checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE 
                            && checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_COMPLETE 
                            && checkList.pse__Status__c!= CON_PSA.PROJ_TASK_STATUS_CANCELLED ){ 
                                
                            if(checkList.Type__c== CON_PSA.PROJ_TYPE_START_UP ){
                                checkList.pse__End_Date_Time__c = proj.Go_Live_Date__c;
                                projectTaskToBeUpdated.add(checkList);   
                            }
                            if(checkList.Type__c== CON_PSA.PROJ_TYPE_CLOSE_OUT ){
                                checkList.pse__End_Date_Time__c = proj.pse__End_Date__c; 
                                projectTaskToBeUpdated.add(checkList);
                            }
                        }
                    }
                }
            }  
        }
        try{
            update(projectTaskToBeUpdated);
            update(scheduleList);
        }
        catch(Exception e){
            lstException.add(UTL_GLOBAL.concatenateException(e));
            
        }finally{
            if(system.isFuture()){
                if(!lstException.isEmpty()) {
                    for(SObject destinationRecord : projectTaskToBeUpdated) {
                        lstLogForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, lstException[0], 'PSA', 'Custom', 
                                                                               'ERROR', lstException[0].substring(0, lstException[0].indexOf(':')), destinationRecord.Id));  
                    }
                }
                try {
                    UTL_LogFactory.saveLogs(lstLogForError, false);
                }
                catch(Exception e) {
                    e.getMessage();
                }               
            }
        }   
    }
    
    /*
    * Story IQVIAPSA-4676
    */
    static Id RDSProjectTaskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByName().get('RDS Project Task').getRecordTypeId();
    public static void updateProjectTask( List<pse__Proj__c> projectList, Map<Id,pse__Proj__c> oldMap ){
        Set<Id> ProjectIds=new Set<Id>();
        String changesIn = '';
        Integer numYears = 0;
        List<pse__Project_Task__c> lstToUpdate = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> lstToInsert = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> lstToDelete = new List<pse__Project_Task__c>();
        Map<String,List< pse__Project_Task__c> > mapOfMaintanceList = new Map<String,List< pse__Project_Task__c >>();
        for(pse__Proj__c pro:projectList){
            if(  pro.Go_Live_Date__c!=oldMap.get(pro.id).Go_Live_Date__c ){
                changesIn = 'Go_Live_Date';
                ProjectIds.add(pro.Id);
            }else if( pro.Actual_Go_Live_Date__c!=oldMap.get(pro.id).Actual_Go_Live_Date__c ) {
                changesIn = 'Actual_Go_Live_Date';
                ProjectIds.add(pro.Id);
            }
        }
        If( ProjectIds.size() > 0  ){
            for( pse__Project_Task__c pt : [ SELECT Id, Parent_Project__r.pse__End_Date__c, Parent_Project__r.Go_Live_Date__c, 
                                                        Parent_Project__r.pse__Stage__c, Parent_Project__r.Actual_Go_Live_Date__c,
                                                        Parent_Project__r.pse__Start_Date__c, Type__c, pse__Status__c, RecordTypeId,
                                                        pse__Project__c, Parent_Project__r.Program__c,pse__Project__r.Service_Line__c,
                                                        pse__Project__r.Service_Line_Lead__c, Parent_Project__r.Close_Out_Date__c,
                                                        pse__Project_Task__c.Frequency__c, pse__Project_Task__c.pse__End_Date_Time__c,
                                                        pse__Project__r.pse__Account__r.Name, Name, Role__c, Trigger_Email_Notification__c,
                                                        pse__Start_Date__c, pse__Start_Date_Time__c,Parent_Project__r.pse__Account__r.Name
                                            FROM pse__Project_Task__c
                                            WHERE Parent_Project__c IN : projectIds
                                            AND ( Type__c = 'Start-up' OR Type__c = 'Maintenance' ) 
                                            AND RecordTypeId =: RDSProjectTaskRecordTypeId
                                           ] )
            {
                numYears = (pt.Parent_Project__r.pse__Start_Date__c.monthsBetween(pt.Parent_Project__r.pse__End_Date__c) / 12)+1;
                if( pt.pse__End_Date_Time__c != pt.Parent_Project__r.Go_Live_Date__c && changesIn == 'Go_Live_Date' )
                {
                    if( pt.Type__c == CON_PSA.PROJ_TYPE_START_UP && ( pt.pse__Status__c == CON_PSA.PROJ_TASK_STATUS_NOT_STARTED || pt.pse__Status__c == CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS )){
                        pt.pse__End_Date_Time__c = pt.Parent_Project__r.Go_Live_Date__c;
                        if( pt.pse__Start_Date_Time__c < pt.pse__End_Date_Time__c ){
                            lstToUpdate.add(pt);
                        }
                    }
                    
                    if( pt.Type__c == CON_PSA.PROJ_TYPE_MAINTENANCE &&  pt.Frequency__c == CON_PSA.PROJ_Frequency_YEARLY ){
                        pt.pse__End_Date_Time__c = pt.Parent_Project__r.Go_Live_Date__c;
                        if( mapOfMaintanceList.containsKey( pt.Name ) ){
                            mapOfMaintanceList.get( pt.Name ).add( pt );
                        }else{
                            mapOfMaintanceList.put( pt.Name, new List< pse__Project_Task__c > {pt} );
                        }
                    }
                }else if( pt.pse__End_Date_Time__c != pt.Parent_Project__r.Actual_Go_Live_Date__c 
                         && pt.Parent_Project__r.Actual_Go_Live_Date__c != null
                         && pt.Type__c == CON_PSA.PROJ_TYPE_MAINTENANCE
                         && changesIn == 'Actual_Go_Live_Date'
                        )
                {
                    if( pt.Frequency__c == CON_PSA.PROJ_Frequency_YEARLY ){
                        pt.pse__End_Date_Time__c = pt.Parent_Project__r.Actual_Go_Live_Date__c;
                        if( mapOfMaintanceList.containsKey( pt.Name ) ){
                            mapOfMaintanceList.get( pt.Name ).add( pt );
                        }else{
                            mapOfMaintanceList.put( pt.Name, new List< pse__Project_Task__c > {pt} );
                        }
                        
                    }
                }
                else if( pt.Parent_Project__r.Actual_Go_Live_Date__c == null 
                        && pt.Type__c == CON_PSA.PROJ_TYPE_MAINTENANCE 
                        && pt.Frequency__c == CON_PSA.PROJ_Frequency_YEARLY
                        && changesIn == 'Actual_Go_Live_Date'
                       )
                {
                    pt.pse__End_Date_Time__c = pt.Parent_Project__r.Go_Live_Date__c;
                    if( mapOfMaintanceList.containsKey( pt.Name ) ){
                        mapOfMaintanceList.get( pt.Name ).add( pt );
                    }else{
                        mapOfMaintanceList.put( pt.Name, new List< pse__Project_Task__c > {pt} );
                    }
                }
            }
            if( mapOfMaintanceList.size() > 0 ){
                for( String projectTaskName  : mapOfMaintanceList.keySet() ){
                    if( mapOfMaintanceList.get( projectTaskName ) != null ){
                        Integer maintanceProjectTaskSize = mapOfMaintanceList.get( projectTaskName ).size();
                        List< pse__Project_Task__c > maintanceProjectTask = mapOfMaintanceList.get( projectTaskName );
                        
                        if( maintanceProjectTask.size() > 0 ){
                            if( numYears == maintanceProjectTask.size() ){
                                for( Integer i = 0 ; i< maintanceProjectTaskSize ;i++ ){
                                    maintanceProjectTask[i].pse__Start_Date_Time__c = maintanceProjectTask[0].pse__Start_Date_Time__c.addYears(i);
                                    maintanceProjectTask[i].pse__End_Date_Time__c = maintanceProjectTask[i].pse__End_Date_Time__c.addYears(i+1);
                                    if( maintanceProjectTask[i].pse__Start_Date_Time__c < maintanceProjectTask[i].pse__End_Date_Time__c 
                                       && ( maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_NOT_STARTED || maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS ) ){
                                        lstToUpdate.add(maintanceProjectTask[i]); 
                                       }
                                } 
                            }else if( numYears > maintanceProjectTask.size() ){
                                
                                for( Integer i = 0 ; i< maintanceProjectTaskSize ;i++ ){
                                    maintanceProjectTask[i].pse__Start_Date_Time__c = maintanceProjectTask[0].pse__Start_Date_Time__c.addYears(i);
                                    maintanceProjectTask[i].pse__End_Date_Time__c = maintanceProjectTask[i].pse__End_Date_Time__c.addYears(i+1);
                                    if( maintanceProjectTask[i].pse__Start_Date_Time__c < maintanceProjectTask[i].pse__End_Date_Time__c 
                                       && ( maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_NOT_STARTED || maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS ) ){
                                        lstToUpdate.add(maintanceProjectTask[i]);  
                                       }
                                } 
                                for (integer i = 0; i < numYears - maintanceProjectTask.size(); i++ ) {
                                    pse__Project_Task__c newMaintenanceTask = new pse__Project_Task__c();
                                    newMaintenanceTask = cloneTask(maintanceProjectTask[maintanceProjectTask.size()-1]);
                                    newMaintenanceTask.pse__Start_Date_Time__c = maintanceProjectTask[maintanceProjectTask.size()-1].pse__Start_Date_Time__c.addYears(i);
                                    newMaintenanceTask.pse__End_Date_Time__c = maintanceProjectTask[maintanceProjectTask.size()-1].pse__End_Date_Time__c.addYears(i+1);
                                    if( newMaintenanceTask.pse__Start_Date_Time__c < newMaintenanceTask.pse__End_Date_Time__c ){
                                        lstToInsert.add( newMaintenanceTask ); 
                                    }
                                }
                            }else{
                               
                                for( Integer i = 0 ; i< maintanceProjectTaskSize ;i++ ){
                                    maintanceProjectTask[i].pse__Start_Date_Time__c = maintanceProjectTask[0].pse__Start_Date_Time__c.addYears(i);
                                    maintanceProjectTask[i].pse__End_Date_Time__c = maintanceProjectTask[i].pse__End_Date_Time__c.addYears(i+1);
                                    if( maintanceProjectTask[i].pse__Start_Date_Time__c < maintanceProjectTask[i].pse__End_Date_Time__c 
                                       && ( maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_NOT_STARTED || maintanceProjectTask[i].pse__Status__c == CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS ) ){
                                        lstToUpdate.add(maintanceProjectTask[i]);  
                                       }
                                } 
                                for (integer i = maintanceProjectTask.size()-1; i >= numYears  ; i-- ) {
                                    lstToDelete.add( maintanceProjectTask[i] ); 
                                }
                            }
                        }
                    }
                }
            }
            if( lstToUpdate.size() > 0 ){
                try{
                    update lstToUpdate; 
                    
                }catch( Exception e ){
                    e.getMessage();
                }
                
            }
            if( lstToInsert.size() > 0 ){
                try{
                    insert lstToInsert; 
                    
                }catch( Exception e ){
                    e.getMessage();
                }
            }
            if( lstToDelete.size() > 0 ){
                try{
                    Delete lstToDelete; 
                    
                }catch( Exception e ){
                    e.getMessage();
                }
            }
            
        }
    }
    private Static pse__Project_Task__c cloneTask( pse__Project_Task__c origTask ) {
        pse__Project_Task__c newTask = new pse__Project_Task__c();
        newTask.name = origTask.name;
        newTask.pse__Project__c = origTask.pse__Project__c;
        newTask.Parent_Project__c =  origTask.Parent_Project__c;
        newTask.Program__c = origTask.Parent_Project__r.Program__c;
        newTask.RecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Project_Task').getRecordTypeId();
        newTask.Role__c = origTask.Role__c;
        newTask.Frequency__c = origTask.Frequency__c;
        newTask.Type__c = origTask.Type__c;
        newTask.Template_Task_ID__c = origTask.Id;
        newTask.Trigger_Email_Notification__c = origTask.Trigger_Email_Notification__c;
        newTask.Service_Line_Lead__c = origTask.pse__Project__r.Service_Line_Lead__c;
        newTask.Service_Line__c = origTask.pse__Project__r.Service_Line__c;
        newTask.Account_Name__c = origTask.Parent_Project__r.pse__Account__r.Name;
        newTask.pse__Status__c = 'Not Started';
        return newTask;
    }
    
    /*
     * This method is used to update Project Task's checkbox Activate_Workflow_Rule_Conditionally__c for workflow updation
     * based on RDS Project's or RDS Service Line Project's pse__Stage__c field
	*/
    public static void updateProjectTaskWorkFlowCondition(List<pse__Proj__c> newList, Map<Id, pse__Proj__c> oldMap) {
        if(!(projectIdsForUpdatingWorkflowCondition.size()>0)){
            Id RDS_Project_Id = Id.valueOf(CON_PSA.PROJ_REC_TYPE_ID_RDS_PROJECT);
            Id RDS_Service_Line_Id = Id.valueOf(CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE);
            Set<Id> rdsProjectIdsForFetchingProjectTasks = new Set<Id>();
            Set<Id> rdsServiceLineProjectIdsForFetchingProjectTasks = new Set<Id>();
            List<pse__Project_Task__c> projectTaskOfRDSProject = new List<pse__Project_Task__c>();
            List<pse__Project_Task__c> projectTaskOfRDSServiceLineProject = new List<pse__Project_Task__c>();
            List<pse__Project_Task__c> projectTaskToUpdate = new List<pse__Project_Task__c>();
            
            if(trigger.isUpdate){
                for( pse__Proj__c proj : newList ){
                    if(proj.pse__Stage__c != oldMap.get(proj.Id).pse__Stage__c || proj.Service_Line_Lead__c != oldMap.get(proj.Id).Service_Line_Lead__c){
                        projectIdsForUpdatingWorkflowCondition.add(proj.Id);
                        if(proj.RecordTypeId == RDS_Project_Id){
                            rdsProjectIdsForFetchingProjectTasks.add(proj.Id);
                        }else if (proj.RecordTypeId == RDS_Service_Line_Id){
                            rdsServiceLineProjectIdsForFetchingProjectTasks.add(proj.Id);
                        }
                    }
                }
                
                //getting project tasks of RDS Project and RDS Service Line Projects
                if(rdsProjectIdsForFetchingProjectTasks.size()>0){
                    projectTaskOfRDSProject = new SLT_Project_Task().getRDSRecordTypeProjectTasksByRDSProject(rdsProjectIdsForFetchingProjectTasks, new Set<String>{'Id', 'pse__Actual_End_Date_Time__c', 'RecordTypeId', 'pse__End_Date__c', 'Trigger_Email_Notification__c',
                        'Parent_Project__r.RecordTypeId', 'pse__Project__r.RecordTypeId', 'Parent_Project__r.pse__Stage__c',
                        'pse__Status__c', 'pse__End_Date_Time__c', 'pse__Actual_End_Date__c', 'pse__Project__r.pse__Stage__c','Activate_Workflow_Rule_Conditionally__c'});
                    for( pse__Project_Task__c pt : projectTaskOfRDSProject ){
                        if(pt.Trigger_Email_Notification__c == TRUE && pt.pse__End_Date_Time__c > Date.today() && pt.pse__Actual_End_Date__c == null
                           && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_CANCELLED &&  pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE
                           && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_CANCELED && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_COMPLETED && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_ON_HOLD
                           && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_CANCELED && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_COMPLETED && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_ON_HOLD){
                               if(pt.Activate_Workflow_Rule_Conditionally__c == FALSE){
                                   pt.Activate_Workflow_Rule_Conditionally__c = TRUE;
                                   projectTaskToUpdate.add(pt);
                               }
                           }else{
                               if(pt.Activate_Workflow_Rule_Conditionally__c == TRUE){
                                   pt.Activate_Workflow_Rule_Conditionally__c = FALSE;
                                   projectTaskToUpdate.add(pt);
                               }
                           }
                    }
                }
                if(rdsServiceLineProjectIdsForFetchingProjectTasks.size()>0){
                    projectTaskOfRDSServiceLineProject = new SLT_Project_Task().getRDSRecordTypeProjectTasksByServiceLineProject(rdsServiceLineProjectIdsForFetchingProjectTasks, new Set<String>{'Id', 'pse__Actual_End_Date_Time__c', 'RecordTypeId', 'pse__End_Date__c', 'Trigger_Email_Notification__c',
                        'Parent_Project__r.RecordTypeId', 'pse__Project__r.RecordTypeId', 'Parent_Project__r.pse__Stage__c',
                        'pse__Status__c', 'pse__End_Date_Time__c', 'pse__Actual_End_Date__c', 'pse__Project__r.pse__Stage__c','Activate_Workflow_Rule_Conditionally__c'});
                    for( pse__Project_Task__c pt : projectTaskOfRDSServiceLineProject ){
                        if(pt.Trigger_Email_Notification__c == TRUE && pt.pse__End_Date_Time__c > Date.today() && pt.pse__Actual_End_Date__c == null
                           && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_CANCELLED &&  pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_COMPLETE && pt.pse__Status__c != CON_PSA.PROJ_TASK_STATUS_NOT_APPLICABLE
                           && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_CANCELED && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_COMPLETED && pt.Parent_Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_ON_HOLD
                           && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_CANCELED && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_COMPLETED && pt.pse__Project__r.pse__Stage__c != CON_PSA.PROJ_STAGE_ON_HOLD){
                               if(pt.Activate_Workflow_Rule_Conditionally__c == FALSE){
                                   pt.Activate_Workflow_Rule_Conditionally__c = TRUE;
                                   projectTaskToUpdate.add(pt);
                               }
                           }else{
                               if(pt.Activate_Workflow_Rule_Conditionally__c == TRUE){
                                   pt.Activate_Workflow_Rule_Conditionally__c = FALSE;
                                   projectTaskToUpdate.add(pt);
                               }
                           }
                    }
                }
                if(projectTaskToUpdate.size()>0){
                    update projectTaskToUpdate;
                }
            }
        }
    }
    
     
    public static void enableAccountChkboxForBatchProcessing( List<pse__Proj__c> newList, Map<Id, pse__Proj__c> oldMap ){  
        Id RDS_Service_Line_Id = Id.valueOf(CON_PSA.PROJ_REC_TYPE_ID_RDS_SERVICELINE);
        if (trigger.isUpdate){            
            for( pse__Proj__c proj : newList ){
                if(proj.RecordTypeId == RDS_Service_Line_Id){
                    pse__Proj__c oldProj = (pse__Proj__c) oldmap.get(proj.Id);                  
                    if (proj.pse__Account__c != oldProj.pse__Account__c){
                        if(proj.Has_Account_Changed__c != true){
                            proj.Has_Account_Changed__c = true;   
                        }
                    }
                }
            }
        }
    }    
} 
