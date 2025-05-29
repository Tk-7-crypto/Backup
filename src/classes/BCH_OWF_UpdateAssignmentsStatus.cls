/**
 * This is Batch class to udpate status on Assignments based on related Agreement's Bid_Due_Date field
 * version : 1.0
 */
global class BCH_OWF_UpdateAssignmentsStatus implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible Map<Id, String> assignmentIdToErrorMessageMap;
    @TestVisible List<Id> successfullUpdatedAssignmentList;
    @TestVisible  Map<String,List<String>> eligibleTimeZones;
    @TestVisible  String currentDate;
    @TestVisible List<Timezone__c> timeZoneList;
    
    /**
     * Constructor
     */
    public BCH_OWF_UpdateAssignmentsStatus( Map<String,List<String>> eligibleTimeZones,List<Timezone__c>timeZoneList) {
        this.eligibleTimeZones = eligibleTimeZones;
        this.timeZoneList = timeZoneList;
        assignmentIdToErrorMessageMap = new Map<Id, String>();
        successfullUpdatedAssignmentList = new List<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
         for(String dt : eligibleTimeZones.keySet()){
            currentDate = dt;
         }
         String timezones = String.join(eligibleTimeZones.get(currentDate), '\',\'') +'\'';
         String query = 'Select Id, pse__Status__c ' +
                        ',pse__Resource_Request__r.pse__Opportunity__r.Bid_Defense_Date__c'+
                        ',pse__Resource_Request__r.Is_Bid_Defense__c'+
                        ',Bid_History__r.Bid_Due_Date__c'+
                        ',pse__End_Date__c'+
                        ' From pse__Assignment__c ' + 
                        ' Where pse__Resource_Request__c != NULL And pse__Resource_Request__r.pse__Project__c != NULL And Bid_History__c != NULL ' +
                        ' And RecordType.DeveloperName = \''+ CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_NAME + '\'' +
                        'AND pse__Resource__r.pse__Salesforce_User__r.TimeZoneSidKey in ( \'' + timezones  +
                        //' And Bid_History__c.Bid_Due_Date__c = TODAY And pse__Status__c != \''+ CON_OWF.OWF_STATUS_COMPLETED + '\'';
             	        ') AND pse__End_Date__c <=' + currentDate + ' And pse__Status__c = \''+ CON_OWF.OWF_STATUS_ACCEPTED + '\'';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<pse__Assignment__c> assignments) {
        List<pse__Assignment__c> assignmentUpdateList = new List<pse__Assignment__c>();
        
        for(pse__Assignment__c assignment : assignments){
           //IQVIAPSA-6608
                assignment.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
                
            assignmentUpdateList.add(assignment);
        }
        
        if (assignmentUpdateList.size() > 0){
            Database.SaveResult[] results = Database.Update(assignmentUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        assignmentIdToErrorMessageMap.put(assignmentUpdateList[i].Id, 'Error in updating assignment status : ' + results[i].getErrors()[0].getMessage());
                    }
                    else if (results[i].isSuccess() && assignmentUpdateList[i].pse__Status__c == 'Completed')
                    {
                        system.debug(assignmentUpdateList[i].Id);
                        successfullUpdatedAssignmentList.add(assignmentUpdateList[i].Id);
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (assignmentIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
            apexErrorLog.Running_User__c = UserInfo.getUserId();
            apexErrorLog.Object__c = 'OWF Assignment (pse__Assignment__c): BCH_OWF_UpdateAssignmentsStatus';
            String errorMessage = 'Error in Assignment updation';
            String errorList = '';
            Integer counter = 0;
            for (Id assignmentId : assignmentIdToErrorMessageMap.keySet() ) {
                errorList += ++counter+'. '+assignmentId+'----> ';
                errorList += assignmentIdToErrorMessageMap.get(assignmentId)+'\n\n  ';
            }
            apexErrorLog.Error_Message__c = errorMessage + '\n\n' + errorList;
            insert apexErrorLog;
            
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_UPDATEASSIGNMENTSSTATUS, assignmentIdToErrorMessageMap, 'Errors occurred during BCH_OWF_UpdateAssignmentsStatus batch process.');
        }
        for(Timezone__c timezone : timeZoneList){
            timezone.CutOffUTCTime__c = timezone.CutOffUTCTime__c.addDays(Integer.valueof(1));
        }
        update timezoneList;
        if(successfullUpdatedAssignmentList.size()>0)
        {
 			Database.executeBatch(new BCH_OWF_AsyncBidDefenseRRCreation(successfullUpdatedAssignmentList,CON_OWF.BCH_COMPLETING_MODE), successfullUpdatedAssignmentList.size());
        }
        

    }
}