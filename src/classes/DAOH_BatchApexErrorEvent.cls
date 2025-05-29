/**
 * Helper object for BatchApexErrorEvent objects
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 24 May 2020               CLD                 		 Initial Version
 */
public with sharing class DAOH_BatchApexErrorEvent {
  public static String AUDIT_LOG_JOB_CLASS_NAME = 'SRV_PSA_AuditLog';

  @TestVisible
  private static Set<String> MONITOR_APP_LOG_JOBS = new Set<String>{
    AUDIT_LOG_JOB_CLASS_NAME
  };

  /**
   * Logs a CDC Audit Log Job Error
   *
   * Evaluates the batch apex error event for a monitored app log job
   * and writes event to the app logs
   */
  public static void logCDCAuditJobError (sObject[] batchApexErrors) {
    Set<Id> asyncApexJobIds = new Set<Id>();
    for(sObject evt: batchApexErrors){
      asyncApexJobIds.add(Id.valueOf(String.valueOf(evt.get('AsyncApexJobId'))));
    }

    // Lookup failed job details with apex class name
    Map<Id,AsyncApexJob> jobs = new SLT_AsyncApexJob().findJobs(asyncApexJobIds, new Set<String>{'Id', 'ApexClass.Name'});

    appirio_core__App_Log__c[] applogs = new appirio_core__App_Log__c[]{};
    for(sObject evt: batchApexErrors) {
      String asyncApexJobId = String.valueOf(evt.get('AsyncApexJobId'));
      AsyncApexJob apexJob = jobs.get(asyncApexJobId);

      // # Only handle jobs setup for app log monitoring
      if (MONITOR_APP_LOG_JOBS.contains(apexJob.ApexClass.Name)) {
        String ExceptionType = String.valueOf(evt.get('ExceptionType'));
        String Message = String.valueOf(evt.get('Message'));

        Map<String, Object> errDataObj = new Map<String, Object>{
            'ExceptionType' => evt.get('ExceptionType')
          , 'Phase' => evt.get('Phase')
          , 'CreatedById' => evt.get('CreatedById')
          , 'Message' => evt.get('Message')
          , 'StackTrace' => evt.get('StackTrace')
          , 'AsyncApexJobId' => evt.get('AsyncApexJobId')
          , 'DoesExceedJobScopeMaxLength' => evt.get('DoesExceedJobScopeMaxLength')
          , 'ReplayId' => evt.get('ReplayId')
          , 'RequestId' => evt.get('RequestId')
        };

        Map<String, Object> errData2Obj = new Map<String, Object>{
          'JobScope' => evt.get('JobScope')
        };

        // Build app log from monitored info
        String origin = SRV_PSA_AuditLog.APP_LOG_ORIGIN; // 'BatchApexError ' + apexJob.ApexClass.Name;
        String errMsg = ExceptionType + ' ' +  Message;
        String errData = JSON.serialize(errDataObj);
        String errData2 = JSON.serialize(errData2Obj);

        appirio_core__App_Log__c appLog = UTL_PSA_AppLog.writeLog(origin, UTL_PSA_AppLog.APP_LOG_ERROR_LEVEL, errMsg, errData, false);
        appLog.appirio_core__Data2__c = errData2; //  add JobScope to err data 2

        applogs.add(appLog);
      }
    }
    if (applogs != null && applogs.size() > 0) {
      Database.insert(applogs);
    }
  }
}
/*
Batch Apex Error Event
https://developer.salesforce.com/docs/atlas.en-us.224.0.platform_events.meta/platform_events/sforce_api_objects_batchapexerrorevent.htm

{"attributes":{"type":"BatchApexErrorEvent",
  "url":"/services/data/v48.0/sobjects/BatchApexErrorEvent/1"},
  "ExceptionType":"System.LimitException",
  "JobScope":"AuditLogWrapper:[
          field=LastModifiedDate,
          logObject=pse__Project_Task__c,
          logTime=2020-05-27 15:18:39,
          newValue=2020-05-27 15:18:39,
          operation=UPDATE,
          priorValue=null,
          reasonForDeletion=null,
          recordId=aBF8A000000QbFTWA0,
          replayId=102721,
          transactionKey=0002e75d-29a1-143a-afa9-d71d4bf92ef3,
          userId=0058A000004Dl4AQAS],
        AuditLogWrapper:[
          field=pse__Status__c,
          logObject=pse__Project_Task__c,
          logTime=2020-05-27 15:18:39,
          newValue=Planned,
          operation=UPDATE,
          priorValue=null,
          reasonForDeletion=null,
          recordId=aBF8A000000QbFTWA0,
          replayId=102721,
          transactionKey=0002e75d-29a1-143a-afa9-d71d4bf92ef3,
          userId=0058A000004Dl4AQAS]",

  "Phase":"EXECUTE",
  "CreatedById":"0056A000001FD9OQAW",
  "Message":"TESTING. This is a constructed LimitException! Catch It If You Can!",
  "RequestId":"4WAfepN7VbKA7ikCag",
  "StackTrace":"Class.SRV_PSA_AuditLog.insertAuditLogs: line 91, column 1",
  "ReplayId":"1",
  "CreatedDate":"2020-05-27T15:18:59.000+0000",
  "Id":"1QQxx0000000001GAA",
  "AsyncApexJobId":"7078A00001IFqtr",
  "DoesExceedJobScopeMaxLength":false
  }
Map<String, Object>
  "ExceptionType":"System.LimitException"
  "Phase
jobScope to data2!

32,000
32,000

 5000 msg
 5000 stack
40000 jobscope!

 */