/*
 * @author Shilpa Gattewar <sgattewar@cldpartners.com>
 * Apex support methods for Audit Log
 *
 * ----------------------------------------------------------------------------
 * Date Modified     Modified By        Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020       CLD                Support Change Data Capture Events,
 *                                      * Includeded new Audit Log Fields 'Transaction Key' and 'Replay ID'
 *                                      * Removed big object data
 *                                      * Include versioning to allow either using  the current or the new cdc event logging implementations
 * 14 OCT 2020       CLD                * Removed batch support
 *                                      * Changed to use Queueable 
 *
 */
public class SRV_PSA_AuditLog implements Database.RaisesPlatformEvents {
  // collection of wrappers to save
  private final AuditLogWrapper[] auditLogWrappers;

  // number of change events to process at a time
  public static final Integer EVENT_SIZE = 20000;

  // Origin for app log entries for audit logs!
  public static final String APP_LOG_ORIGIN ='PSA_AuditLog'; // hierarchy custom setting?

  // Apex Record Type Control method when included enables CDC Event Audit Logging and disables version 1 logging
  public static final string METHOD_NAME_FOR_ENABLED_CDC_AUDIT = 'isCDCAuditEnabled';

  // Apex Record Type Control method to control audit logging by record type!
  public static final string METHOD_NAME_FOR_RECORDTYPE_CONTROL = 'allAuditMethods';

  // add object names to 'ignore' list added in ESIDSSR-310, IQVIAPSA-1261
  public static final Set<String> ignoreObjs = new Set<String>{'Target__c', 'Project_Contact__c', 'Agreement_Products__c', 'iCSR_Exchange_Timeline__c', 'Responsibilities_and_Maintenance__c', 'Agreement_Notes__c', 'Reconciliation__c', 'Aggregate_Report__c', 'RA_Feedback__c', 'RA_Issue__c', 'RA_Recommendation__c', 'RA_Request__c', 'Report_Country__c','Partner_Contact__c','Drug__c',
      														  'PSSF__c','Topics_of_Interest__c','HA_Websites_Review__c','SD_Runs__c','Signal__c','Event_Journals__c','CFI_Meetings__c','Journals_Main_Catalogue__c','Search_Strategy__c','LR_Project_Overview__c'};

  public SRV_PSA_AuditLog(List<AuditLogWrapper> wrapperList) {
    this.auditLogWrappers = wrapperList;
    System.debug('@@ SRV_PSA_AuditLog constructor (wrapperList.size())' + wrapperList.size());
  }

  // --------------------------------------------------------------------------
  // version of audit logging to use....when CDC Entity Selected and Apex Control contains
  // an entry for the sobject and method name of 'isCDCAuditEnabled' then
  // uses the CDC Audit Logging, otherwise uses triggered logging
  // --------------------------------------------------------------------------

  // map of sobj name to having isCDCAuditEndabled method!
  private static Map<String, Boolean> hasCDCAuditEnabledMethods = new Map<String, Boolean>();
  private static Boolean isCDCAuditEnabled (String sobjName) {
    Boolean result = false;
    if (hasCDCAuditEnabledMethods.containsKey(sobjName))  {
      result = hasCDCAuditEnabledMethods.get(sobjName);
    } else {
      Map<String, Set<String>> methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap(sobjName);
      result = methodToRecordTypeMap.containsKey(SRV_PSA_AuditLog.METHOD_NAME_FOR_ENABLED_CDC_AUDIT);
      hasCDCAuditEnabledMethods.put(sobjName, result);
    }
    return result;
  }

  // true when version 1 audit logging to be executed per sobj
  private static Boolean isVersion1enabled (String sobjName) {
    Boolean version1Enabled = isCDCAuditEnabled(sobjName) == false || Test.isRunningTest();
    system.debug('IS VERSION 1 ENABLED? ' +  sobjName + ' ' + version1Enabled);
    return version1Enabled;
    // return isCDCAuditEnabled(sobjName) == false || Test.isRunningTest();
  }

  // true when version 2 audit logging to be executed per sobj
  private static Boolean isVersion2enabled (String sobjName) {
    return isCDCAuditEnabled(sobjName) || Test.isRunningTest();
  }

  /**
   * Batch save a list of audit log wrappers (Version 2)
   *
   * @param {AuditLogWrapper[]} - list of Audit Log Wrapper objects to batch save
   * @return batch id
   */
  public static Id commitAuditLogChangeEventJob (AuditLogWrapper[] auditLogWrappers) {
    Id jobId = null;
    System.debug('@@ SRV_PSA_AuditLog.commitAuditLogChangeEventJob (auditLogWrappers.size())' + auditLogWrappers.size());
    try {
        System.debug('@@ SRV_PSA_AuditLog.commitAuditLogChangeEventJob submitting apex job to queue.');
        jobId = System.enqueueJob(new QUE_SRV_PSA_AuditLog(auditLogWrappers));
    } catch (Exception e) {
        UTL_PSA_AppLog.writeError(SRV_PSA_AuditLog.APP_LOG_ORIGIN, null, e, JSON.serialize(auditLogWrappers));
    }
    return jobId;
  }

  /*
  * starts batch job to stores audit log information (Version 1)
  */
  private static void commitAuditLogs (AuditLogWrapper[] auditLogWrappers) {
    if (isVersion1enabled(auditLogWrappers[0].logObject) == false) {
      return; // skip cdc is enabled
    }

    QUE_SRV_PSA_AuditLog psaAuditLogService = new QUE_SRV_PSA_AuditLog(auditLogWrappers);
    psaAuditLogService.insertAuditLogs(auditLogWrappers);
  }

  // Audit Log for 'DELETE' and 'UNDELETE' operations (Version 1)
  public static void setAuditLogOnDeleteUnDelete(List<SObject> objectList,String operation) {
    if (isVersion1enabled(objectList[0].getSObjectType().getDescribe().getName()) == false) {
      return; // skip cdc is enabled
    }
    //  IS CDC ENABLED THEN SKIP!

    List<AuditLogWrapper> auditlogForInsertList = buildAuditLogWrappersOnDelete(objectList, operation);
    try {
        if(auditlogForInsertList != null && auditlogForInsertList.size() > 0) {
            SRV_PSA_AuditLog.commitAuditLogs(auditlogForInsertList);
        }
    } catch (DmlException e) {
            UTL_PSA_AppLog.writeError('SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete', e);
        }
    }
    
  // Audit Log for 'INSERT' and 'UPDATE' operations (Version 1)
  public static void setAuditOnInsertUpdate(List<SObject> newList,Map<Id,SObject> oldMap) {
    if (isVersion1enabled(newList[0].getSObjectType().getDescribe().getName()) == false) {
      return; // skip cdc is enabled
    }
    List<AuditLogWrapper> auditlogForUpdateList = buildAuditLogWrappersOnInsertUpdate(newList, oldMap);
    try {
      if(auditlogForUpdateList != null && auditlogForUpdateList.size() > 0) {
        SRV_PSA_AuditLog.commitAuditLogs(auditlogForUpdateList);
      }
    } catch (DmlException e) {
      UTL_PSA_AppLog.writeError('SRV_PSA_AuditLog.setAuditOnInsertUpdate', e);
    }
  }

  @TestVisible
  private static List<AuditLogWrapper> buildAuditLogWrappersOnDelete(List<SObject> objectList, String operation) {
    List<AuditLogWrapper> auditlogForInsertList = new List<AuditLogWrapper>();
    if(objectList.size()>0) {
      AuditLogWrapper auditlog = new AuditLogWrapper();
      for(SObject a : objectList) {
        auditlog.logObject = a.getSObjectType().getDescribe().getName();
        auditlog.operation = operation;
        auditlog.recordId = a.id;
        auditlog.field = 'Id';
        auditlog.userId = UserInfo.getUserId();
        auditlog.logTime = System.now();
        if(operation == 'DELETE' && !ignoreObjs.contains(auditlog.logObject)) { //if op is delete and obj is not one added in ESIDSSR-310
          auditlog.reasonForDeletion = String.valueOf(a.get('Reason_for_Deletion__c'));
        }
      }
      auditlogForInsertList.add(auditlog);
    }
    return auditlogForInsertList;
  }

  @TestVisible
  private static List<AuditLogWrapper> buildAuditLogWrappersOnInsertUpdate(List<SObject> newList,Map<Id,SObject> oldMap) {
    List<AuditLogWrapper> auditlogForUpdateList = new List<AuditLogWrapper>();
    for(SObject newrecord : newList) {
      Map<String, Schema.SObjectField> schemaFieldMap = newrecord.getSObjectType().getDescribe().fields.getMap();
      if(oldMap != null) {
        SObject oldrecord =  oldMap.get(newrecord.id);
        //check if field on SObject has changed/updated.
        if(oldMap != null && oldMap.get(newrecord.id) != null) {
          for(String fieldName : schemaFieldMap.keySet()) {
            if(newrecord.get(fieldName)!= oldrecord.get(fieldName)) {
              AuditLogWrapper auditlog = new AuditLogWrapper();
              auditlog.logObject = newrecord.getSObjectType().getDescribe().getName();
              auditlog.operation = 'UPDATE';
              auditlog.recordId = newrecord.id;
              auditlog.userId = UserInfo.getUserId();
              auditlog.logTime = System.now();
              auditlog.field = fieldName;
              auditlog.priorValue = String.valueOf(oldrecord.get(fieldName));
              auditlog.newValue = String.valueOf(newrecord.get(fieldName));

              auditlogForUpdateList.add(auditlog);
            }
          }
        }
      }

      //check if field on SObject has been inserted.
      if(oldMap == null ) {
        for(String fieldName : schemaFieldMap.keySet()) {
          if(newrecord.get(fieldName)!= null) {
            AuditLogWrapper auditlog = new AuditLogWrapper();
            auditlog.logObject = newrecord.getSObjectType().getDescribe().getName();
            auditlog.operation = 'INSERT';
            auditlog.recordId = newrecord.id;
            auditlog.userId = UserInfo.getUserId();
            auditlog.logTime = System.now();
            auditlog.field = fieldName;
            auditlog.priorValue = null;
            auditlog.newValue = String.valueOf(newrecord.get(fieldName));

            auditlogForUpdateList.add(auditlog);
          }
        }
      }
    }
    return auditlogForUpdateList;
  }

  /*
   * wrapper for audit logs
   */
  public class AuditLogWrapper {
    public String logObject {get; set;}
    public String operation {get; set;}
    public String recordId {get; set;}
    public String userId {get; set;}
    public DateTime logTime {get; set;}
    public String reasonForDeletion {get; set;}
    public String field {get; set;}
    public String newValue {get; set;}
    public String transactionKey {get;set;}
    public String replayId {get;set;}

    public String priorValue {get; set;}

  }
} 
