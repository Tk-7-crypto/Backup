public class BCH_PSA_UpdateCancelledStatus implements Database.Batchable<sObject> {
    public static Set<Id> projectIdSet =  new Set<Id>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, pse__Stage__c, pse__Parent_Project__c '+
                       'FROM pse__Proj__c '+
            	       'WHERE pse__Parent_Project__r.pse__Stage__c =\'' + CON_PSA.PROJ_STAGE_CANCELED + '\' ' +
                       'AND (pse__Stage__c != \'' + CON_PSA.PROJ_STAGE_CANCELED + '\' ' +
            	       'OR (pse__Stage__c = \'' + CON_PSA.PROJ_STAGE_CANCELED + '\' ' +
            	       'AND LastModifiedDate > YESTERDAY ))' +
            	       'AND RecordType.Name = \'' + CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE + '\' ' +
                       'AND pse__Parent_Project__c != null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<pse__Proj__c> records){
        String assignmentCondition = 'pse__Project__c IN : sObjectIdset AND pse__Status__c != \'' + CON_PSA.ASSIGNMENT_STATUS_CANCELLED + '\' AND RecordType.Name =\'' + CON_PSA.ASSIGNMENT_REC_TYPE_RDS + '\'';
        String projectTaskCondition = 'pse__Project__c IN : sObjectIdset AND(RecordType.Name = \'' + CON_PSA.RDS_DELIVERABLE + '\' OR RecordType.Name = \'' + CON_PSA.RDS_DELIVERABLE_TASK + '\' OR RecordType.Name = \'' + CON_PSA.RDS_PROJECT_TASK + '\') AND pse__Status__c != \'' + CON_PSA.PROJ_TASK_STATUS_CANCELLED + '\' AND pse__Status__c != \'' + CON_PSA.PROJ_TASK_STATUS_COMPLETE + '\'';
        String mileStoneCondition = 'pse__Project__c IN : sObjectIdset AND  ( RecordType.Name =\'' + CON_PSA.MILESTONE_REC_TYPE_BILLING + '\' OR RecordType.Name = \'' + CON_PSA.MILESTONE_REC_TYPE_SERVICE + '\') AND pse__Status__c != \'' + CON_PSA.MILESTONE_STATUS_CANCELLED + '\'';
        String resourceRequestCondition = 'pse__Project__c IN : sObjectIdset AND pse__Status__c != \'' + CON_PSA.RESOURCE_REQUEST_STATUS_CANCELLED + '\' AND RecordType.Name =\'' + CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST + '\'';
        List<sObject> sObjectToUpdateList = new List<sObject>();
        List<pse__Milestone__c> getMileStoneList = new List<pse__Milestone__c>();
        List<pse__Project_Task__c> getProjectTaskList = new List<pse__Project_Task__c>();
        Map<Id, pse__Assignment__c> getAssignmentIdToAssignmentMap = new Map<Id, pse__Assignment__c>();
        List<pse__Resource_Request__c> getResourceRequestList = new List<pse__Resource_Request__c>();
        for(pse__Proj__c project : records){
            projectIdSet.add(project.Id);
            projectIdSet.add(project.pse__Parent_Project__c);
            sObjectToUpdateList.add(new pse__Proj__c(Id = project.Id, pse__Stage__c = CON_PSA.PROJ_STAGE_CANCELED));
        }
        if(projectIdSet.size() > 0){
            //Retrive MileStone 
            getMileStoneList = new SLT_Milestone().getMileStoneByIdSet(projectIdSet, mileStoneCondition, new Set<String>{'Id', 'pse__Status__c'}); 
            for(pse__Milestone__c mileStone : getMileStoneList){
                sObjectToUpdateList.add(new pse__Milestone__c(Id = mileStone.Id, pse__Status__c = CON_PSA.MILESTONE_STATUS_CANCELLED)); 
            }
            
            // Retrive Project Task 
            getProjectTaskList = new SLT_Project_Task().getProjectTaskByIdSet(projectIdSet, projectTaskCondition,new  Set<String>{'Id', 'pse__Status__c'}); 
            for(pse__Project_Task__c projectTask : getProjectTaskList){
                sObjectToUpdateList.add(new pse__Project_Task__c(Id = projectTask.Id, pse__Status__c = CON_PSA.PROJ_TASK_STATUS_CANCELLED)); 
            }
            
            // Retrive Assignment
            getAssignmentIdToAssignmentMap = new SLT_Assignment().selectAssignmentsByIdSet(projectIdSet, assignmentCondition,new Set<String>{'Id', 'pse__Status__c'}); 
            for(pse__Assignment__c assignment : getAssignmentIdToAssignmentMap.values()){
                sObjectToUpdateList.add(new pse__Assignment__c(Id = assignment.Id, pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_CANCELLED)); 
            }
            
            // Retrive Resource Request 
            getResourceRequestList = new SLT_Resource_Request().getResourceRequestByIdSet(projectIdSet, resourceRequestCondition, new Set<String>{'Id', 'pse__Status__c'}); 
            for(pse__Resource_Request__c resourceRequest : getResourceRequestList){
                sObjectToUpdateList.add(new pse__Resource_Request__c(Id = resourceRequest.Id, pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_CANCELLED)); 
            }
            
        }
        if(sObjectToUpdateList.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution_OWF = TRUE;
            UTL_ExecutionControl.stopTriggerExecution = TRUE;
            update sObjectToUpdateList;
            UTL_ExecutionControl.stopTriggerExecution = FALSE;
            UTL_ExecutionControl.stopTriggerExecution_OWF = FALSE;
        }
    }

    public void finish(Database.BatchableContext BC){
        
    }
}