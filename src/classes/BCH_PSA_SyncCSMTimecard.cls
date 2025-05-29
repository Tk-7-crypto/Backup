/****************************************************************************************
Name            : BCH_PSA_SyncCSMTimecard
Created by      : 
Story No        : 
Use             : 
****************************************************************************************/

global class BCH_PSA_SyncCSMTimecard implements Database.Batchable<sObject>,Database.AllowsCallouts {
    //Here 20 sync count will be managed by custom setting
   CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
   boolean stopTimecradSync = csmCustomsetting.StopCSMTimesheetSync__c;
   boolean enablePartialTimecardSync = csmCustomsetting.EnableTimesheetPartialDataSync__c;
   Integer numberOfSyncAttempts = (Integer)csmCustomsetting.SyncNumberOfAttempts__c;
   DateTime dateFromSyncCSMTimesheet = (DateTime)csmCustomsetting.DateFromSyncCSMTimesheetData__c;
   String query = 'SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c ,Comment__c, MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById FROM TimeSheet__c WHERE Status__c = \'Stop\' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND PSA_Sync_Status__c!= \'Success\' AND PSA_Sync_Status__c!= \'Sync in progress\'  AND (PSA_Sync_Count__c =null OR PSA_Sync_Count__c <:numberOfSyncAttempts)';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(stopTimecradSync){
            return Database.getQueryLocator('Select ID from TimeSheet__c WHERE PSA_Sync_Count__c < -1');//This query is only for bypass batch execution
        }
        // This case is to handle if any issue occurs then after fix we will pick records after particular date
        if(dateFromSyncCSMTimesheet != null){
            query = query + ' AND CreatedDate >=:dateFromSyncCSMTimesheet' ;
        } 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<TimeSheet__c> timesheetList) 
    {        
        System.debug('CPU Time taken1:'+System.Limits.getCpuTime());
        System.debug('CPU Time:'+Limits.getCpuTime());
        system.debug('timesheetsize-'+timesheetList?.size());
        if(timesheetList?.size() > 0 && !csmCustomsetting.StopCSMTimesheetSync__c){
            try{
                if(enablePartialTimecardSync){
                   timesheetList = SRV_PSA_SyncCSMTimecard.getPartialSyncTimecardsList(timesheetList);//For partial syncing of timecards
                   system.debug('timesheetsize2-'+timesheetList?.size());
                }
                if(timesheetList?.size()>0){
                    string requestString = SRV_PSA_SyncCSMTimecard.getTimecardApiRequest(timesheetList);
                    string responseString = SRV_PSA_SyncCSMTimecard.saveTimecardApiRequest(requestString, timesheetList);
                    system.debug('responseString:'+responseString);
                    if(!responseString.startsWith('Failed-')){
                        SRV_PSA_SyncCSMTimecard.processTimecardAPIResponse(responseString, timesheetList);
                    }
                    else{
                        SRV_PSA_SyncCSMTimecard.processFailedRecords(timesheetList, responseString);
                    }
                }
            }
            catch(Exception Ex){
                SRV_PSA_SyncCSMTimecard.processFailedRecords(timesheetList, 'Failed-' + ex.getStackTraceString() + ' ' + ex.getMessage());
            }
            System.debug('CPU Time taken5:'+System.Limits.getCpuTime());
            System.debug('CPU Time:'+Limits.getLimitCpuTime());
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
         System.debug('CPU Time taken:'+System.Limits.getCpuTime());
         System.debug('CPU Time limit:'+System.Limits.getLimitCpuTime());
    }
}