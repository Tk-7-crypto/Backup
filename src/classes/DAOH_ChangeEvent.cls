/**
 * Helper object for ChangeEvent objects
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
public with sharing class DAOH_ChangeEvent {
  public static final String CHANGE_EVENT_HEADER_CLASS_NAME = 'ChangeEventHeader'; // EventBus.ChangeEventHeader.class.getName().split('.')[1];
  public static final String REPLAY_ID = 'ReplayId';
  public static final String OPERATION_INSERT = 'INSERT';
  public static final String CHANGE_TYPE_DELETE = 'DELETE';
  public static final String AUDIT_EXCLUDE_FIELDSET_NAME = 'Audit_Exclude';

  // Map of sobject to field name to use as the 'Reason_For_Deletion__c'
  static Map<String, String> sobjReasonForDeletionField = new Map<String, String>{
    'pse__Project_Task__c' => 'Reason_For_Deletion__c',
    'Project_Log__c'       => 'Reason_For_Deletion__c',
    'Aggregate_Report__c'  => 'Delete_Reason__c'
  };


  // Apex Record Type Control method to control audit logging by record type!
  public static final string METHOD_NAME_FOR_RECORDTYPE_CONTROL = SRV_PSA_AuditLog.METHOD_NAME_FOR_RECORDTYPE_CONTROL;

  /**
   * Build events to audit by optionally excluding based on Apex Record Type Control settings
   * then transforms the events into AuditLogWrappers and commit them
   *
   * @param {Schema.SObjectType} - sobject type of object to audit
   * @param {sObject[]} - list of change events
   *
   */
  public static void auditChanges (Schema.SObjectType sobjectTypeToAudit, sObject[] eventsToAudit) {
    try {
      sObject[] eventsToLog = buildEventsToLog(sobjectTypeToAudit, eventsToAudit);

      //TEMP
      System.debug('Auditing '+eventsToAudit.size()+' events of type '+sobjectTypeToAudit);
      //TEMP

      if (eventsToLog != null && eventsToLog.size() > 0) {

        //TEMP
        System.debug( 'Logging '+eventsToLog.size()+' events');
        //TEMP

        saveEvents(eventsToLog);
      }
    } catch (Exception e) {
      UTL_PSA_AppLog.writeError('DAOH_ChangeEvent.auditChanges', e);
    }
  }

  /**
   * Builds AuditLogWrappers from supplied platform sobject events and commits them
   *
   * @param {sObject[]} - list of platform sobject events to persist as audit log objects
   */
  private static void saveEvents(sObject[] changeEvents) {
    if (changeEvents.isEmpty()) {
      System.debug('Save Events? nothing to save.');
      return;
    }

    // build fields to exclude and for insert mapped by entity name
    ChangeEventFieldWrapper cefield = new ChangeEventFieldWrapper(changeEvents);
    Map<String, Set<String>> fieldsToExclude = cefield.fieldsToExclude;
    Map<String, Set<String>> fieldsForInsert = cefield.fieldsForInsert;
    Map<Id, Sobject> deletedDetails = cefield.deletedDetails;

    // when setup and configured will be field injected into delete operation
    String reasonForDeletionField = cefield.reasonForDeletionField;

    SRV_PSA_AuditLog.AuditLogWrapper[] auditLogWrappers = new SRV_PSA_AuditLog.AuditLogWrapper[]{};
    Integer counter = 1;
    sObject event;
    String lastReplayId = null;
    Integer size = changeEvents.size();
    for (Integer index = 0; index < size && index < SRV_PSA_AuditLog.EVENT_SIZE; index++)  {
      // # process!
      event = changeEvents[index];
      EventBus.ChangeEventHeader header = (EventBus.ChangeEventHeader) event.get(CHANGE_EVENT_HEADER_CLASS_NAME);

      // Map out the event for logging
      Object jsonObj = JSON.deserializeUntyped(JSON.serialize(event));
      Map<String, Object> eventObjMap = (Map<String, Object>) jsonObj;

      for (String recordId: header.recordids) {
        String operation = header.changeType;
        String[] changedFieldNames = header.changedfields;

        // determine fields to log based  on the change type
        String changeTypeDeleteReasonForDeletion =  null;

        switch on header.changeType {
          when 'CREATE' {
            operation = OPERATION_INSERT; // Map to audit log operation
            Set<String> insertFields = fieldsForInsert.get(header.entityname);
            changedFieldNames = new List<String>(insertFields != null && insertFields.size() > 0 ? insertFields : event.getPopulatedFieldsAsMap().keySet());
          }
          when 'UPDATE' {
            changedFieldNames = header.changedfields;
          }
          when 'DELETE' {
            // lookup reason for deletion when set!
            if (String.isNotEmpty(reasonForDeletionField)) {
              changedFieldNames = new String[]{reasonForDeletionField};
              if (deletedDetails.containsKey(Id.valueOf(recordId))) { // inject reason for deletion
                changeTypeDeleteReasonForDeletion = String.valueOf(deletedDetails.get(Id.valueOf(recordId)).get(reasonForDeletionField));
              }
            } else {
              changedFieldNames = new String[]{'Id'}; // default so it gets picked up in the audit log logic
            }
          }
          when 'UNDELETE' {
            // Set<String> insertFields = fieldsForInsert.get(header.entityname);
            // changedFieldNames = new List<String>(insertFields != null && insertFields.size() > 0 ? insertFields : event.getPopulatedFieldsAsMap().keySet());
            Set<String> insertFields = new Set<String>{'Id'}; //fieldsForInsert.get(header.entityname);
            changedFieldNames = new List<String>(insertFields != null && insertFields.size() > 0 ? insertFields : event.getPopulatedFieldsAsMap().keySet());
          }
        }

        // setup fields to exclude from logging
        Set<String> auditExcludeFields = fieldsToExclude.get(header.entityname);
        auditExcludeFields = auditExcludeFields != null ? auditExcludeFields : new Set<String>();

        //  when field is not excluded,  log  it!
        for (String changedFieldName: changedFieldNames) {
          //If we hit the max size for the queue, submit it and start filling a fresh one
          if(counter > QUE_SRV_PSA_AuditLog.QUEUE_LIMIT) {
            System.debug('Save Events chunk done - saving '+auditLogWrappers.size()+' events');
            SRV_PSA_AuditLog.commitAuditLogChangeEventJob(auditLogWrappers);
            auditLogWrappers = new SRV_PSA_AuditLog.AuditLogWrapper[]{};
            counter = 1;
          }
          counter++;

          Boolean excludeField = auditExcludeFields.contains(changedFieldName) ? true : false;
          if  (excludeField == false) {
            SRV_PSA_AuditLog.AuditLogWrapper auditlog = new SRV_PSA_AuditLog.AuditLogWrapper();
            auditlog.logObject = header.entityname;
            auditlog.operation = operation;
            auditlog.userId = header.commituser;
            auditlog.logTime = DateTime.newInstance(header.commitTimestamp);
            auditlog.recordId = recordId;
            auditlog.field = changedFieldName;

            // use the event object map to grab new values!
            auditlog.newValue = eventObjMap.containsKey(changedFieldName) ? String.valueOf(eventObjMap.get(changedFieldName)) : '';

            auditlog.transactionKey = header.transactionKey;
            auditlog.replayId = eventObjMap.get(REPLAY_ID) != null ? String.valueOf(eventObjMap.get(REPLAY_ID)) : '';

            lastReplayId = auditLog.replayId;

            //  inject reason for deletion when delete chagne type
            String reasonForDelField = sobjReasonForDeletionField.get(header.entityName);
            if (operation == CHANGE_TYPE_DELETE && String.isNotEmpty(reasonForDelField) && changedFieldName == reasonForDelField) {
              if (String.isEmpty(auditlog.newValue) && String.isNotEmpty(changeTypeDeleteReasonForDeletion)) {
                auditlog.newValue = changeTypeDeleteReasonForDeletion;
              }
            }

            auditLogWrappers.add(auditLog);
          }
        }
      }
    }

    if (auditLogWrappers.size() > 0) {
      System.debug('Save Events done - saving '+auditLogWrappers.size()+' events');
      SRV_PSA_AuditLog.commitAuditLogChangeEventJob(auditLogWrappers);

      // Set Replay ID after which to resume event processing
      // in new trigger execution.
      if (String.isNotEmpty(lastReplayId)) {
        System.debug('@@ DAOH_ChangeEvent.saveEvents lastReplayId ' + lastReplayId);
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(lastReplayId);
      }
    } else {
      System.debug('Save Events done - no events to save');
    }
  }

  /**
   * Change Event Field Wrapper
   * builds fields to exclude and for insert mapped by entity name
   *
   */
  class ChangeEventFieldWrapper {
    public Map<String, Set<String>> fieldsToExclude {get;set;}
    public Map<String, Set<String>> fieldsForInsert {get;set;}
    public Map<Id, Sobject> deletedDetails {get; set;}

    // Standard Reason for deletion field...when configured!
    public String reasonForDeletionField = null;

    public ChangeEventFieldWrapper (sObject[] changeEvents) {
      fieldsForInsert = new Map<String, Set<String>>();
      fieldsToExclude = new Map<String, Set<String>>();
      deletedDetails = new Map<Id, Sobject>();

      Map<String, Schema.sObjectType> entityNameSObject = new Map<String, Schema.sObjectType>();
      Map<String, Set<String>> queryAllheaderNameToRecordIds =  new Map<String, Set<String>>();

      for (sObject event: changeEvents) {
        EventBus.ChangeEventHeader header = (EventBus.ChangeEventHeader) event.get(CHANGE_EVENT_HEADER_CLASS_NAME);
        fieldsToExclude.put(header.entityname, new Set<String>());
        // initializie sobjectType for grabbing fields and fieldsets
        if (entityNameSObject.containsKey(header.entityname) == false) {
          entityNameSObject.put(header.entityname, ((SObject)(Type.forName('Schema.' + header.entityname).newInstance())).getSObjectType());
        }

        // collect header recordids for deleted operations to query for Reason_For_Deletion__c
        if (header.changeType == CHANGE_TYPE_DELETE) {
          if (sobjReasonForDeletionField.containsKey(header.entityname)) {
            this.reasonForDeletionField = sobjReasonForDeletionField.get(header.entityName);
            Set<String> recIds = queryAllheaderNameToRecordIds.get(header.entityname);
            recIds = recIds != null ? recIds : new Set<String>();
            for (String recId : header.recordids) {
              recIds.add(recId);
            }
            queryAllheaderNameToRecordIds.put(header.entityname, recIds);
          }
        }
      }
      //  query all and load the deleted record from recycling bin
      if (queryAllheaderNameToRecordIds != null && queryAllheaderNameToRecordIds.size() > 0) {
        for (String ename: queryAllheaderNameToRecordIds.keySet()) {
          Set<String> recids =  queryAllheaderNameToRecordIds.get(ename);

          Schema.sObjectType sobjType = entityNameSObject.get(ename); // from cache
          sobjType = sobjType != null ? sobjType : ((SObject)(Type.forName('Schema.' + ename).newInstance())).getSObjectType();
          try {
            deletedDetails = new SLT_SObject().selectSObjectRowsByIds(sobjType, recIds, new Set<String>{'Id', reasonForDeletionField}, TRUE);
          } catch (Exception e) {
            UTL_PSA_AppLog.writeError('ChangeEventFieldWrapper', e);
          }
        }
      }

      // Populate sobj fieldsToExclude from optional 'Audit_Exclude' fieldset
      for (String sobjName: fieldsToExclude.keySet()) {
        Schema.sObjectType sobjType = entityNameSObject.get(sobjName); // from cache
        sobjType = sobjType != null ? sobjType : ((SObject)(Type.forName('Schema.' + sobjName).newInstance())).getSObjectType();
        Schema.FieldSet fieldSetObj = sobjType.getDescribe().FieldSets.getMap().get(AUDIT_EXCLUDE_FIELDSET_NAME);
        List<Schema.FieldSetMember> fields =  fieldSetObj != null? fieldSetObj.getFields() : null;
        if (fields != null  && fields.size() > 0) {
          for(Schema.FieldSetMember field : fields) {
            Set<String> flds = fieldsToExclude.get(sobjName);
            flds =  flds != null ? flds : new Set<String>();
            flds.add(field.getFieldPath());
            fieldsToExclude.put(sobjName, flds);
          }
        }

        // Populate sobj fieldsForInsert for use on insert / undelete operations
        Map<String,Schema.SObjectField> mfields = sobjType.getDescribe().fields.getMap();
        for (Schema.SObjectField sobjField: mfields.values()) {
          Set<String> flds = fieldsForInsert.get(sobjName);
          flds = flds != null ? flds : new Set<String>();
          String fldName = sobjField.getDescribe().getName();
          flds.add(fldName);
          fieldsForInsert.put(sobjName, flds);
        }
      }
    }
  }

  /**
   * Exclude from audit changes unless the changed record types are included
   * in the Custom Metadata Apex Record Type Control object
   *
   * Call this method to only include audit log records for specific record types
   *
   * (Note, the Custom Metadata Apex Record Type Control object will control which
   * record types will be processed via the Change event triggers.)
   *
   * @param {Schema.SObjectType} - sobjectType with record types to evaluate
   * @param {sObject[]} - list of platform sobject events to check record type enabling and then store
   */
  private static sObject[] buildEventsToLog (Schema.SObjectType sobjectTypeToAudit, sObject[] eventsToAudit) {
    SObject[] eventsToLog = eventsToAudit;
    Map<String,Schema.SObjectField> sobjFieldMap = sobjectTypeToAudit.getDescribe().fields.getMap();
    Boolean  sobjHasRecordType =  sobjFieldMap.containsKey('RecordTypeId');

    // # Limit by record type when provided
    if (sobjHasRecordType) {
      System.debug('Limiting by recordtype...');
      // Loop over the events to grab the grab the changeevent record ids
      eventsToLog =new SObject[]{};
      Set<String> recordIds = new Set<String>();
      Boolean queryAll = false;
      for (sObject event: eventsToAudit) {
        EventBus.ChangeEventHeader header = (EventBus.ChangeEventHeader) event.get(DAOH_ChangeEvent.CHANGE_EVENT_HEADER_CLASS_NAME);
        if (header.recordids != null && header.recordids.size() > 0) {
          for (String recId : header.recordids) {
            recordIds.add(recId);
          }
        }
        if (header.changetype == CHANGE_TYPE_DELETE) {
          queryAll = true; // query all when change contains a delete operation (to grab records from recycling bin)
        }
      }
      if (recordIds.isEmpty() == false) {
        // query for record with record types to evaluate for auditing
        Set<String>  fieldsToQuery = new Set<String>{'Id', 'RecordTypeId', 'RecordType.DeveloperName'};
        Map<Id,SObject> idToSObject = new SLT_Sobject().selectSObjectRowsByIds(sobjectTypeToAudit, recordIds, fieldsToQuery, queryAll);

        // Grab the apex record type controls for change data capture auditing BY RECORD TYPE!
        Map<String, Set<String>> methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap(sobjectTypeToAudit.getDescribe().getName());
        Set<String> enabledRecordTypeNames = methodToRecordTypeMap.get(SRV_PSA_AuditLog.METHOD_NAME_FOR_RECORDTYPE_CONTROL);
        enabledRecordTypeNames = enabledRecordTypeNames != null ? enabledRecordTypeNames : new Set<String>();

        if (enabledRecordTypeNames.isEmpty()) {
          // no defined record types to filter by
          eventsToLog = eventsToAudit;
        } else {
          // Loop over events again collecting events to audit based on the underlying record type name and change control
          for (sObject event: eventsToAudit)  {
            Boolean includeEvent = false; // included when record type name is enabled
            EventBus.ChangeEventHeader header = (EventBus.ChangeEventHeader) event.get(DAOH_ChangeEvent.CHANGE_EVENT_HEADER_CLASS_NAME);
            if (header.recordids != null && header.recordids.size() > 0) {
              // check the record type is enabled for chagne event
              SObject sobj = idToSObject.get(Id.valueOf(header.recordids[0]));
              SObject recordType = sobj != null ? sobj.getSObject('RecordType') : null;

              if (recordType != null && recordType.get('DeveloperName') != null) {
                String recordTypeDeveloperName = String.valueOf(recordType.get('DeveloperName'));
                if (enabledRecordTypeNames.contains(recordTypeDeveloperName)) {
                  includeEvent = true;  // record type needs included
                }
              }
            }
            if (includeEvent) {
              eventsToLog.add(event);
            }
          }
        }
      }
    }
    return eventsToLog;
  }

}