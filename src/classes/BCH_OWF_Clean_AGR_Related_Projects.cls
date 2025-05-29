global class BCH_OWF_Clean_AGR_Related_Projects implements Database.Batchable<sObject>, Database.Stateful{
    
    @TestVisible 
    List<Map<Id, String>> projectIdToErrorMessageMapList;
    
    
    /**
* Constructor
*/
    public BCH_OWF_Clean_AGR_Related_Projects()
    {
        projectIdToErrorMessageMapList = new List<Map<Id, String>>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select Id,Name, IsDeleted,Object__c,Error_Message__c from Apex_Error_Log__c where Object__c = \'Project (pse__Proj__c)\' and Record_Processed__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Apex_Error_Log__c > apexErrorLogsList)
    {
        String criteria1 = 'Error in Project deletion through queuable job:';
        String criteria2 = 'caused by: fflib_SObjectDomain.DomainException: Permission to delete';
        String criteria3 = 'Error in Project deletion through Batch : ';
        Set<Id> erroredProjectIdSet = new Set<Id>();
        Id projectToBeDeletedInstanceId;
        Map<Id, Apex_Error_Log__c> projectIdToErrorLogMap = new Map<Id, Apex_Error_Log__c>();
        for(Apex_Error_Log__c errorLogInstance : apexErrorLogsList)
        {
            if((errorLogInstance.Error_Message__c.contains(criteria1) && errorLogInstance.Error_Message__c.contains(criteria2)) || errorLogInstance.Error_Message__c.contains(criteria3))
            {
                projectToBeDeletedInstanceId = processIdFromErrorMessage(errorLogInstance.Error_Message__c);
                erroredProjectIdSet.add(projectToBeDeletedInstanceId);
                errorLogInstance.Record_Processed__c = true;
                errorLogInstance.Record_Processed_Date__c = Date.today();
                projectIdToErrorLogMap.put(projectToBeDeletedInstanceId,errorLogInstance);
            }
        }
        
        
        Set<String> projectFieldSet = new Set<String>{'Id','Name'};
        String projectCondition = 'Bid_History__c = null';
        List<pse__Proj__c> projectWithNullAGRList = new SLT_Project(false,false).getProjectByIdSetandCondition(erroredProjectIdSet, projectCondition, projectFieldSet);
        if(projectWithNullAGRList.size()>0)
        {
            Map<Id, String> projectIdToErrorMessageMap;
            Database.DeleteResult[] results = Database.Delete(projectWithNullAGRList, false);
            if (results.size() > 0){
                for (Integer i=0; i< results.size(); i++){
                    if (!results[i].isSuccess()){
                        projectIdToErrorMessageMap = new Map<Id,String>();
                        projectIdToErrorMessageMap.put(projectWithNullAGRList[i].Id, 'Error in Project deletion through Batch : ' + results[i].getErrors()[0].getMessage());
                        projectIdToErrorMessageMapList.add(projectIdToErrorMessageMap);
                    }
                }
            }
            if(projectIdToErrorLogMap.size()>0)
            {
                update projectIdToErrorLogMap.values();
            }  
        }
        
        
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(projectIdToErrorMessageMapList.size()>0)
        {
            List<Apex_Error_Log__c> failedProcessRecordsList = new List<Apex_Error_Log__c>();
            for(Map<Id,String> mapInstance: projectIdToErrorMessageMapList)
            {
                failedProcessRecordsList.add(processFailedRecords(mapInstance));
            }
            if(failedProcessRecordsList.size()>0)
                insert failedProcessRecordsList;
        }
    }
    
    Id processIdFromErrorMessage(String errorMessage)
    {
        Id projectId;
        String openingString = '. ';
        String closingString = '---->';
        projectId = errorMessage.substringBetween(openingString, closingString);
        return projectId;
    }
    
    Apex_Error_Log__c processFailedRecords(Map<Id, String> incomingFailedRecordMap)
    {
        Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
        apexErrorLog.Running_User__c = UserInfo.getUserId();
        apexErrorLog.Object__c = 'Project (pse__Proj__c)';
        String errorMessage = 'Error in Project deletion through Batch: ';
        String errorList = '';
        Integer counter = 0;
        for (Id k : incomingFailedRecordMap.keySet() ) {
            errorList += ++counter+'. '+k+'----> ';
            errorList += incomingFailedRecordMap.get(k)+'\n\n  ';
        }
        
        apexErrorLog.Error_Message__c = errorMessage + '\n\n' + errorList;
        return apexErrorLog;
    }
    
    
}
