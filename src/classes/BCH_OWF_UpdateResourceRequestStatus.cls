/**
 * This is Batch class to udpate status on Resource_Requests based on related Agreement's Bid_Due_Date field
 * version : 1.0
 */
global class BCH_OWF_UpdateResourceRequestStatus implements Database.Batchable<sObject>, Database.Stateful{
    @TestVisible Map<Id, String> resRequestIdToErrorMessageMap;
    @TestVisible Map<String,List<String>> eligibleTimeZones = new Map<String,List<String>>();
    @TestVisible List<Timezone__c> timeZoneList = new List<Timezone__c>();
    
    
    /**
     * Constructor
     */
    public BCH_OWF_UpdateResourceRequestStatus() {
        resRequestIdToErrorMessageMap = new Map<Id, String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        timeZoneList = UTL_OWF.fetchTimezone('OWF','BCH_OWF_UpdateResourceRequestStatus');
        if(timeZoneList.size()>0){
            eligibleTimeZones = UTL_OWF.createTimezoneMap(timeZoneList);
            String currentDate;
            for(String CurrentDateFromTheMap : eligibleTimeZones.keySet()){
                currentDate = CurrentDateFromTheMap;
                break;
            }
            String timezones = String.join(eligibleTimeZones.get(currentDate), '\',\'') +'\'';
            String query = 'Select Id, pse__Status__c ' +
             	        ',pse__Opportunity__r.Bid_Defense_Date__c'+
                        ',pse__End_Date__c'+
             	        ',Is_Bid_Defense__c'+
             	        ',Bid_History__r.Bid_Due_Date__c'+ 
                        ' From pse__Resource_Request__c ' + 
                        ' Where pse__Project__c != NULL And Bid_History__c != NULL And RecordType.DeveloperName = \''+ CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\'' +
                        ' AND pse__Assignment__r.pse__Resource__r.pse__Salesforce_User__r.TimeZoneSidKey in ( \'' + timezones +
                        //' And Bid_History__r.Bid_Due_Date__c = TODAY And pse__Status__c != \''+ CON_OWF.OWF_STATUS_COMPLETED + '\'';
             	        ') AND pse__End_Date__c <= ' + currentDate  + ' And pse__Status__c = \''+ CON_OWF.OWF_STATUS_ASSIGNED + '\'';
            return Database.getQueryLocator(query);
        }
        else{
            return Database.getQueryLocator('SELECT Id FROM pse__Resource_Request__c limit 0');
        }
    }
    
    global void execute(Database.BatchableContext BC, List<pse__Resource_Request__c> resourceRequests) {
        List<pse__Resource_Request__c> resourceRequestsUpdateList = new List<pse__Resource_Request__c>();
        
        for(pse__Resource_Request__c resRequest : resourceRequests){
           if(resRequest.pse__End_Date__c <= system.today())
                resRequest.pse__Status__c = CON_OWF.OWF_STATUS_COMPLETED;
            
            
            resourceRequestsUpdateList.add(resRequest);
        }
        if(!resourceRequestsUpdateList.isEmpty()) {
            Database.SaveResult[] results = Database.Update(resourceRequestsUpdateList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()) {
                        resRequestIdToErrorMessageMap.put(resourceRequestsUpdateList[i].Id, 'Error in updating status of Resource Request : ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (resRequestIdToErrorMessageMap.size() > 0 || Test.isRunningTest()){
            Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
            apexErrorLog.Running_User__c = UserInfo.getUserId();
            apexErrorLog.Object__c = 'OWF Resource Request (pse__Resource_Request__c): BCH_OWF_UpdateResourceRequestStatus';
            String errorMessage = 'Error in Resource Request updation';
            String errorList = '';
            Integer counter = 0;
            for (Id resourcerequest : resRequestIdToErrorMessageMap.keySet() ) {
                errorList += ++counter+'. '+resourcerequest+'----> ';
                errorList += resRequestIdToErrorMessageMap.get(resourcerequest)+'\n\n  ';
            }
            apexErrorLog.Error_Message__c = errorMessage + '\n\n' + errorList;
            insert apexErrorLog;
            UTL_OWF.sendMailOnException(CON_OWF.BCH_OWF_UPDATERESOURCEREQUESTSTATUS, resRequestIdToErrorMessageMap, 'Completed Status Update on Resource Request Batch: Failed');
        }
        
        //Run batch after completing Resource_Request batch to update status on Assignments
        OWF_Batch_Config__c batchConfig = OWF_Batch_Config__c.getInstance(CON_OWF.BCH_OWF_UPDATEASSIGNMENTSSTATUS);
        Integer batchSize;
        if(batchConfig != null && batchConfig.Batch_Size__c != null)
            batchSize = (Integer)batchConfig.Batch_Size__c;
        else
            batchSize = CON_OWF.DEFAULT_BATCH_SIZE;
        if(timeZoneList.size()>0){
            BCH_OWF_UpdateAssignmentsStatus batch = new BCH_OWF_UpdateAssignmentsStatus(eligibleTimeZones,timeZoneList);
            database.executeBatch(batch, batchSize);
        }
    }
}