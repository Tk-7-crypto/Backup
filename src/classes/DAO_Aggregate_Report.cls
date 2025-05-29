/**
 * This is Aggregate Report (Aggregate_Report__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Aggregate_Report extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Aggregate_Report__c>
     */
    public DAO_Aggregate_Report(List<Aggregate_Report__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Aggregate_Report(sObjectList);
        } 
    }
    
    /**
     * This method is used for before insert of the Aggregate_Report__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Aggregate_Report.applyDateOffsets(Records);
        DAOH_Aggregate_Report.synchronizeFields(Records, null);
        DAOH_Aggregate_Report.setMuleSoftSyncMechanism((List<Aggregate_Report__c>)Records, null);
        if (methodToRecordTypeMap.get('validateFields') != null) {
            DAOH_Aggregate_Report.validateFields((List<Aggregate_Report__c>)Records,null,methodToRecordTypeMap);
        }
        DAOH_Aggregate_Report.setProductNameOnRAResponseReport((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.fieldValidations((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.checkQCTOnReportCompletion((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.checkQCTOnReportCompletionForSandoz((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.setDefaultValueFromReportType((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.sandozRecordTypeFieldValidations((List<Aggregate_Report__c>)Records,null);
        DAOH_Aggregate_Report.completeStatusValidationForSandoz((List<Aggregate_Report__c>)Records, null);
    }

    /**
     * This method is used for after insert of the Aggregate_Report__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Aggregate_Report.synchronizeProjectEvents((List<Aggregate_Report__c>)Records, null);
        DAOH_Aggregate_Report.insertAuditLogOnUpdate((List<Aggregate_Report__c>)Records, null);
        if (methodToRecordTypeMap.get('synchronizeDeliverables') != null) {
            DAOH_Aggregate_Report.synchronizeDeliverables((List<Aggregate_Report__c>)Records, null, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('populateSanofiDrugs') != null){
            DAOH_Aggregate_Report.populateSanofiDrugs((List<Aggregate_Report__c>)Records, null, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('validateReportDrugs') != null){
            DAOH_Aggregate_Report.validateReportDrugs((List<Aggregate_Report__c>)Records, null, methodToRecordTypeMap);
        }
    }

    /**
     * This method is used for before update of the Aggregate_Report__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Aggregate_Report.applyDateOffsets(Records);
        DAOH_Aggregate_Report.synchronizeFields((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.setProductNameOnRAResponseReport((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.setMuleSoftSyncMechanism((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
        if (methodToRecordTypeMap.get('validateFields') != null) {
            DAOH_Aggregate_Report.validateFields((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords,methodToRecordTypeMap);   
        }
        DAOH_Aggregate_Report.fieldValidations((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.checkQCTOnReportCompletion((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.checkQCTOnReportCompletionForSandoz((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.updateFieldsforEmailAlerts((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.setDefaultValueFromReportType((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.sandozRecordTypeFieldValidations((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.completeStatusValidationForSandoz((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
    }

    /**
     * This method is used for after update of the Aggregate_Report__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        DAOH_Aggregate_Report.synchronizeProjectEvents((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.insertAuditLogOnUpdate((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.setProductNameOnRAResponseReport((List<Aggregate_Report__c>)Records,(Map<Id,Aggregate_Report__c>) existingRecords);
        if (methodToRecordTypeMap.get('synchronizeDeliverables') != null) {
            DAOH_Aggregate_Report.synchronizeDeliverables((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('populateSanofiDrugs') != null){
            DAOH_Aggregate_Report.populateSanofiDrugs((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords, methodToRecordTypeMap);
        }
        if (methodToRecordTypeMap.get('validateReportDrugs') != null){
            DAOH_Aggregate_Report.validateReportDrugs((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords, methodToRecordTypeMap);
        }
        
        DAOH_Aggregate_Report.updtRltdPJEToUpdtReciepients((List<Aggregate_Report__c>)Records, (Map<Id,Aggregate_Report__c>) existingRecords);
        DAOH_Aggregate_Report.sendMailToPrimaryResource((List<Aggregate_Report__c>)records, (Map<Id,Aggregate_Report__c>) existingRecords);
        if(Mulesoft_Integration_Control__c.getInstance() != null 
           && (Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c 
               || !Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c))
        {
            DAOH_Aggregate_Report.sendMailForMedicalReviewDateChange((List<Aggregate_Report__c>)records, (Map<Id,Aggregate_Report__c>) existingRecords);
        }
    }

    /**
     * This method is used for before delete of the Aggregate_Report__c trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        DAOH_Aggregate_Report.validateDeletion((List<Aggregate_Report__c>)Records);
        DAOH_Aggregate_Report.deleteProjectEvents((List<Aggregate_Report__c>)Records);
    }

    /**
     * This method is used for after insert of the Aggregate_Report__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Aggregate_Report.insertAuditLog((List<Aggregate_Report__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Aggregate_Report__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Aggregate_Report.synchronizeProjectEvents((List<Aggregate_Report__c>)Records, null);
        DAOH_Aggregate_Report.insertAuditLog((List<Aggregate_Report__c>)Records,'UNDELETE');
    }
} 
