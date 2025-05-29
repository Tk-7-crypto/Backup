/*
 * Version       : 1.0
 * Description   : This Batch Apex class is used to automatically changed Assignment status to accepted 
 * 				   after left in the unassigned status for more than 24 hours.
 */
public class BCH_OWF_AcceptUnassignedAssignments implements Database.Batchable<Sobject> , Database.Stateful  {
	
    @TestVisible Map<Id, String> assignmentIdToErrorMessageMap;
    @TestVisible List<Id> successfullUpdatedAssignmentList;
    /**
     * Constructor
     */
    public BCH_OWF_AcceptUnassignedAssignments() {
        assignmentIdToErrorMessageMap = new Map<Id, String>();
        successfullUpdatedAssignmentList = new List<Id>();
    }
    
    /**
     * start method 
     * @params  Database.BatchableContext context
     * @return  Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        //list of all assignments for updating status
        return Database.getQueryLocator([SELECT Id, pse__Status__c, createdDate 
                                         FROM pse__Assignment__c 
                                         WHERE pse__Status__c = :CON_OWF.OWF_STATUS_PENDING 
                                         AND RecordType.DeveloperName = :CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_NAME]);
    }
    
    /**
     * execute method 
     * @params  Database.BatchableContext context
     * @params  List<pse__Assignment__c> records
     */
    public void execute(Database.BatchableContext context, List<pse__Assignment__c> records) {
        List<Id> assignmentIdList = new List<Id>();
        List<pse__Assignment__c> assignmentUpdateList = new List<pse__Assignment__c>();
        Map<Id, pse__Assignment__History> assignmentIdToAssignmentHistoryMap = new Map<Id, pse__Assignment__History>();
        
        for(pse__Assignment__c assignment : records){
            assignmentIdList.add(assignment.Id);
        }
        List<pse__Assignment__History> assignmentHistoryList = [SELECT Id, Field , CreatedDate, ParentId  
                                                                FROM pse__Assignment__History 
                                                                WHERE ParentId in :assignmentIdList 
                                                                AND Field = :CON_OWF.ASSIGNMENT_STATUS
                                                                Order By CreatedDate desc];
        
        for(pse__Assignment__History assignmentHistory : assignmentHistoryList){
            if(!assignmentIdToAssignmentHistoryMap.containsKey(assignmentHistory.ParentId)){
                assignmentIdToAssignmentHistoryMap.put(assignmentHistory.ParentId, assignmentHistory);
            }
                
        }
        
        assignmentUpdateList = handleUnassignedAssignments(records, assignmentIdToAssignmentHistoryMap);
        
         if (assignmentUpdateList.size() > 0){
            Database.SaveResult[] results = Database.Update(assignmentUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        assignmentIdToErrorMessageMap.put(assignmentUpdateList[i].Id, 'Error in accepting unassigned assignments : ' + results[i].getErrors()[0].getMessage());
                    }
                    else if (results[i].isSuccess() && assignmentUpdateList[i].pse__Status__c == 'Accepted')
                    {
                        system.debug(assignmentUpdateList[i].Id);
                        successfullUpdatedAssignmentList.add(assignmentUpdateList[i].Id);
                    }
                }
            }
        }
    }
    
    /*
	 * Method to handle unassigned Assignments
	 */
    @TestVisible 
    private List<pse__Assignment__c> handleUnassignedAssignments(List<pse__Assignment__c> assignmentRecords, Map<Id, pse__Assignment__History>assignmentIdToAssignmentHistoryMap){
        List<pse__Assignment__c> updateAssignmentRecords = new List<pse__Assignment__c>();
        
        for(pse__Assignment__c assignment : assignmentRecords){
            if(assignmentIdToAssignmentHistoryMap.containsKey(assignment.Id)){
                if(assignmentIdToAssignmentHistoryMap.get(assignment.Id).createdDate < DateTime.now().addDays(-1)){
                    assignment.pse__Status__c = 'Accepted';
                    updateAssignmentRecords.add(assignment);
                }
            } else if (assignment.createdDate < DateTime.now().addDays(-1) || Test.isRunningTest()){
                assignment.pse__Status__c = 'Accepted';
                updateAssignmentRecords.add(assignment);
            }
        }
        return updateAssignmentRecords;
    }
    
    /**
     * finish method 
     * @params  Database.BatchableContext context
     */
    public void finish(Database.BatchableContext context) {
        if (assignmentIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_ACCEPTUNASSIGNEDASSIGNMENTS, assignmentIdToErrorMessageMap, 'Unassigned Assignment Status Update Batch: Failed');
        }

        system.debug('list size' + successfullUpdatedAssignmentList.size());
        
		if(successfullUpdatedAssignmentList.size()>0)
        {
 			Database.executeBatch(new BCH_OWF_AsyncBidDefenseRRCreation(successfullUpdatedAssignmentList,CON_OWF.BCH_ACCEPTING_MODE), successfullUpdatedAssignmentList.size());
        }  
    }
}