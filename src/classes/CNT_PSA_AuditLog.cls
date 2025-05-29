/*
 * @author Ryan Kapil (CLD)
 * Apex support methods for Audit Log Lightning Web Component
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 18 May 2020               CLD                 		 Initial Version
 */
public with sharing class CNT_PSA_AuditLog {

  /** Fieldset name for Audit_UI */
    public static final String AUDIT_UI_FIELDSET_NAME = 'Audit_UI';
    public static final String AVAILABLE_FIELDS = 'AVAILABLE_FIELDS';
    public static final String AUDIT_RECORD_LABEL = 'AUDIT_RECORD_LABEL';
    public static final String AUDIT_RECORD_NAME = 'AUDIT_RECORD_NAME';
    public static final String AUDIT_RECORD_IS_CDC_ENABLED = 'AUDIT_RECORD_IS_CDC_ENABLED';
    public static final String SHOW_AUDIT_RECORD_DETAILS = 'SHOW_AUDIT_RECORD_DETAILS';
    public static final String AUDIT_RECORD_DETAILS_NAME = 'AUDIT_RECORD_DETAILS_NAME';
    
    public CNT_PSA_AuditLog() {
    }

  /**
   * Returns sobject details for the specific record to audit
   *
   * @param {String} recordId - record id to view audit log results
   */
    @AuraEnabled(cacheable=true)
    public static AuraResult getSobjectDetails (String recordId) {
        AuraResult auraResult  = new AuraResult();
        
        // initialize audit log sobject details
        Schema.SObjectType sobjType = getRecordSobjectType(recordId);
        if (sobjType != null) {
            auraResult.items.put(AUDIT_UI_FIELDSET_NAME, getAuditUIFields(sobjType));
            auraResult.items.put(AVAILABLE_FIELDS, getAvailableFields(sobjType));
            auraResult.items.put(AUDIT_RECORD_LABEL, sobjType.getDescribe().getLabel());
            auraResult.items.put(AUDIT_RECORD_NAME, sobjType.getDescribe().getName());
            auraResult.items.put(AUDIT_RECORD_IS_CDC_ENABLED, isCDCAuditEnabled(sobjType));
        }
        //adding audit record details for showing in UI conditionally
        if(sobjType != null && sobjType.getDescribe().getName() == CON_PSA.PSSF_OBJECT_API_NAME){
            List <PSSF__c> pssfRecordData = new SLT_PSSF().getPSSFById(new Set<Id> {recordId}, new Set<String> {'Name'});
            if(pssfRecordData != null && pssfRecordData.size() > 0){
                auraResult.items.put(SHOW_AUDIT_RECORD_DETAILS, true);
                auraResult.items.put(AUDIT_RECORD_DETAILS_NAME, pssfRecordData[0].Name);
            }
        }else{
            auraResult.items.put(SHOW_AUDIT_RECORD_DETAILS, false);
        }
        return auraResult;
    }

  /**
   * Returns true when the underlying record is enabled for Change Data Capture
   */
  private static Boolean isCDCAuditEnabled (Schema.SObjectType sobjType) {
    String sobjName = sobjType.getDescribe().getName();
    Map<String, Set<String>> methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap(sobjName);
    return methodToRecordTypeMap.containsKey(SRV_PSA_AuditLog.METHOD_NAME_FOR_ENABLED_CDC_AUDIT);
  }

  /**
   * Audit Log Fields to select
   */
  private static Set<String> AUDIT_LOG_FIELDS = new Set<String>{
      'Id',
      'Object__c',
      'User__c',
      'User__r.Name',
      'Time__c',
      'Field__c',
      'New_Value__c',
      'Operation__c',
      'Prior_Value__c',
      'Record_ID__c',
      'Replay_ID__c',
      'Transaction_Key__c'
  };

  /**
   * Returns audit logs for the specific record
   * @param {String} recordId - record id to view audit log results
   */
  @AuraEnabled(cacheable=true)
  public static AuraResult getAuditLogsByRecordId (String recordId) {
    AuraResult auraResult  = new AuraResult();

    List<Audit_Log__c> alList = new SLT_Audit_Log().selectAuditLogsByRecordId(new Set<Id>{recordId}, AUDIT_LOG_FIELDS);
    for (Audit_Log__c log : alList) {
      auraResult.records.add(new AuditLogWrapper(log));
    }

    return auraResult;
  }

  /**
   * Retrieves audit log  records by replay id
   * @param {String} replayId - replay id to view audit log results
   */
  @AuraEnabled
  public static AuraResult getAuditLogsByReplayId (String replayId) {
    AuraResult  auraResult = new  AuraResult();
    Map<String, Audit_Log__c[]> replayLogs = replayId != null ? new SLT_Audit_Log().selectAuditLogsByReplayId(new Set<String>{replayId}, AUDIT_LOG_FIELDS) : null;

    if (replayLogs != null && replayLogs.containsKey(replayId)) {
      Audit_Log__c[] auditLogs = replayLogs.get(replayId);
      for (Audit_Log__c alog: auditLogs) {
        auraResult.records.add(new AuditLogWrapper(alog));
      }
    }
    return auraResult;
  }

  /**
   * saveReplayedEvents
   * @paream auditLogWrapperJSON - json string of audit log wrappers  to save!
   */
  @AuraEnabled
  public static AuraResult saveReplayedEvents (String auditLogWrapperJSON) {
    // Transaform JSON serialized list of AuditLogWrappers
    List<AuditLogWrapper> auditLogWrappers = (List<AuditLogWrapper>)JSON.deserialize(auditLogWrapperJSON, List<AuditLogWrapper>.class);

    AuraResult auraResult = new AuraResult();
    try {
      // Check for dupes  by  replay  id?
      Set<String> replayIds = new Set<String>();
      for (AuditLogWrapper a: auditLogWrappers) {
        replayIds.add(a.replayId);
      }
      Map<String, Audit_Log__c[]> replayLogs = new Map<String, Audit_Log__c[]>();
      if (replayIds.size() > 0) {
        replayLogs = new SLT_Audit_Log().selectAuditLogsByReplayId(replayIds, new Set<String>{'Id', 'Replay_Id__c'});
      }

      // collect duplicates
      Set<String> duplicateReplayIds = new Set<String>();

      //  transform to service audit logs
      SRV_PSA_AuditLog.AuditLogWrapper[] wrappersToSave = new SRV_PSA_AuditLog.AuditLogWrapper[]{};
      for (AuditLogWrapper alwrap: auditLogWrappers) {
        if (replayLogs.containsKey(alwrap.replayId)) {
          // DUPLICATE RECORD EXISTS!
          duplicateReplayIds.add(alwrap.replayId);
        } else {
          SRV_PSA_AuditLog.AuditLogWrapper srvLog = new SRV_PSA_AuditLog.AuditLogWrapper();
          srvLog.logObject = alwrap.objectType;
          srvLog.operation  = alwrap.operation;
          srvLog.recordId = alwrap.recordId;
          srvLog.userId = alwrap.userId;

          if (String.isNotEmpty(alwrap.logTimestamp)) {
            srvLog.logTime = DateTime.newInstance(Long.valueOf(alwrap.logTimestamp));
          }

          srvLog.field = alwrap.field;
          srvLog.newValue = alwrap.newValue;
          srvLog.transactionKey = alwrap.transactionKey;
          srvLog.replayId = alwrap.replayId;
          wrappersToSave.add(srvLog);
        }
      }
      // system.debug('wrappersToSave? ' + wrappersToSave);
      if (wrappersToSave != null && wrappersToSave.size() > 0) {
        String jobId =  SRV_PSA_AuditLog.commitAuditLogChangeEventJob(wrappersToSave);
        auraResult.items.put('jobId', jobId);
      }
      auraResult.isSuccess = true;
    } catch (Exception e) {
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }

    return auraResult;
  }

  /**
   * Returns sobject type  from record id string
   */
  private static Schema.SObjectType getRecordSobjectType (String recordId)  {
    return Id.valueOf(recordId).getsobjecttype();
  }
  /**
   * returns Audit_UI fieldset fieldds for sobject type
   */
  private static String[] getAuditUIFields (Schema.SObjectType sobjType) {
    // Schema.SObjectType sobjType = Id.valueOf(recordId).getsobjecttype();
    List<String> fieldNames = new List<String>();
    if (sobjType != null) {
        Schema.FieldSet fieldSetObj = sobjType.getDescribe().FieldSets.getMap().get(AUDIT_UI_FIELDSET_NAME);
        List<Schema.FieldSetMember> fields =  fieldSetObj != null? fieldSetObj.getFields() : null;
        if (fields != null  && fields.size() > 0) {
          for(Schema.FieldSetMember field : fields) {
            fieldNames.add(field.getFieldPath());
          }
        }
      }
      return fieldNames;
  }

  /**
   * returns audit field for sobject type
   */
  private static FieldWrapper[] getAvailableFields (Schema.SObjectType sobjType) {
    FieldWrapper[] fieldWrappers = new FieldWrapper[]{};

    Map<String,Schema.SObjectField> mfields = sobjType.getDescribe().fields.getMap();
    for (Schema.SObjectField sobjField: mfields.values()) {
      String fldName = sobjField.getDescribe().getName();
      String fldLabel = sobjField.getDescribe().getLabel();
      if (fldName != 'Id') {
        fieldWrappers.add(new FieldWrapper(fldLabel, fldName));
      }
    }
    return fieldWrappers;
  }


  /**
   * Wrapper for Audit_Log__c
   */
  public class AuditLogWrapper {
    @AuraEnabled public String id { get; set; }
    @AuraEnabled public String objectType { get; set; }
    @AuraEnabled public String userId { get; set; }
    @AuraEnabled public String userName { get; set; }
    @AuraEnabled public Datetime logTime { get; set; }
    @AuraEnabled public String logTimestamp { get; set; }
    @AuraEnabled public String operation { get; set; }
    @AuraEnabled public String recordId { get; set; }
    @AuraEnabled public String replayId { get; set; }
    @AuraEnabled public String transactionKey { get; set; }
    @AuraEnabled public String field { get; set; }
    @AuraEnabled public String newValue { get; set; }

    public AuditLogWrapper () { }

    public AuditLogWrapper (Audit_Log__c sobj) {
      this.id = sobj.Id;
      this.objectType = sobj.Object__c;
      this.userId = sobj.User__c;
      this.userName = sobj.User__r != null ? sobj.User__r.Name : sobj.User__c;
      this.logTime = sobj.Time__c;
      this.operation = sobj.Operation__c;
      this.recordId = sobj.Record_Id__c;
      this.replayId = sobj.Replay_Id__c;
      this.transactionKey = sobj.Transaction_Key__c;
      this.field  = sobj.Field__c;
      this.newValue = sobj.New_Value__c;
      //  to support older implementation use user + operation + logTime when transaction key not defined
      if (String.isEmpty(this.transactionKey)) {
        this.transactionKey = this.userId + this.operation + this.logTime;
        this.newValue = String.isNotEmpty(newValue) ? newValue.replaceAll('&quot;', '') : '';
      }
    }
  }

  /**
   * Wrapper for field labels and api names
   */
  public class FieldWrapper {
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public String apiName {get; set;}
    public FieldWrapper (String label, String apiName) {
      this.label = label;
      this.apiName = apiName;
    }
  }


	/*
	 * Class returned from @AuraEnabled methods
	 */
	public class AuraResult {
		@AuraEnabled public Object[] records {get;set;}
		@AuraEnabled public Map<String, Object> items {get;set;}
		@AuraEnabled public Boolean isSuccess {get;set;}
		public AuraResult () {
			this.records = new Object[]{};
			this.items = new Map<String, Object>();
		}
	}
}