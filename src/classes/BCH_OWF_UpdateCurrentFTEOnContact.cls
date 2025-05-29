/**
 * This is Batch class to Current FTE on OWF Contact when their assignments start date is arrived 
 * version : 1.0
 */
global class BCH_OWF_UpdateCurrentFTEOnContact implements Database.Batchable<sObject>, Database.Stateful {
    
    @TestVisible Map<Id, String> contactIdToErrorMessageMap;
    
    /**
     * Constructor
     */
    public BCH_OWF_UpdateCurrentFTEOnContact() {
        contactIdToErrorMessageMap = new Map<Id, String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id, Current_FTE_Sum__c from Contact where COUNT_Assignemnts_Accepted__c > 0';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactList) {
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactUpdateList = new List<Contact>();
        Map<Id,List<pse__Assignment__c>> resourceIdToRelatedAssignmentListMap = new Map<Id,List<pse__Assignment__c>>();
        
        for(Contact con : contactList){
            contactIdSet.add(con.id);
        }
        
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        Date currentDate = Date.Today();
        String assignmentCondition = 'pse__Resource__c in: sObjectIdset and pse__Status__c =\'Accepted\' and pse__Start_Date__c <= :currentDate';
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Resource__c','pse__Status__c','Suggested_FTE__c','pse__Start_Date__c','Estimation_Effort__c'};
        assignmentList = new SLT_Assignment(false,false).getAssignmentByResourceAndCondition(contactIdSet,currentDate,assignmentCondition,assignmentFieldSet);
        
        for(pse__Assignment__c assignment : assignmentList) {
            if(!resourceIdToRelatedAssignmentListMap.containsKey(assignment.pse__Resource__c)){
                resourceIdToRelatedAssignmentListMap.put(assignment.pse__Resource__c, new List<pse__Assignment__c>());
            }
            resourceIdToRelatedAssignmentListMap.get(assignment.pse__Resource__c).add(assignment);
        }        
        List<Contact> updatedResourceList = new List<Contact>();
        Decimal currentFTECount = 0;
        for(Id resourceId : resourceIdToRelatedAssignmentListMap.keySet()){
            currentFTECount = 0;
            if(resourceIdToRelatedAssignmentListMap.get(resourceId).size() > 0){
                for(pse__Assignment__c assignment : resourceIdToRelatedAssignmentListMap.get(resourceId)){
                    if(assignment.pse__Status__c == 'Accepted' && assignment.pse__Start_Date__c <= Date.Today()){
                        if(assignment.Estimation_Effort__c != NULL){
                            currentFTECount += assignment.Estimation_Effort__c;
                        }else{
                            currentFTECount += assignment.Suggested_FTE__c;
                        }
                    }
                }  
            }
            Contact contactRecord = new Contact(Id = resourceId);
            contactRecord.Current_FTE_Sum__c = currentFTECount ;
            
            updatedResourceList.add(contactRecord);
        }
        
        if(!updatedResourceList.isEmpty()){
            Database.SaveResult[] results = Database.Update(updatedResourceList, false);
        
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        contactIdToErrorMessageMap.put(updatedResourceList[i].Id, 'Error in updating Contact\'s Current FTE : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (contactIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            UTL_OWF.sendMailOnException('BCH_OWF_UpdateCurrentFTEOnContact', contactIdToErrorMessageMap, 'Errors occurred during BCH_OWF_UpdateCurrentFTEOnContact batch process.');
        }
    }
}