public class DAO_LR_Project_Overview extends fflib_SObjectDomain {
    public static Boolean isSupportCRUD = true;
    /**
     * Constructor of this class
     * @params sObjectList List<LR_Project_Overview__c>
     */
    public DAO_LR_Project_Overview(List<LR_Project_Overview__c> sObjectList) {
        super(sObjectList);
        if( !isSupportCRUD ){
           Configuration.disableTriggerCRUDSecurity(); 
        }else{
           Configuration.enforceTriggerCRUDSecurity();
        }
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_LR_Project_Overview(sObjectList);
        }
    }
    
     /**
     * This method is used for before insert of the LR Project Overview (LR_Project_Overview__c) trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_PSA_LR_Project_Overview.setLRFieldValues((List<LR_Project_Overview__c>) records, null);         
        DAOH_PSA_LR_Project_Overview.populateAccountFromProject((List<LR_Project_Overview__c>) records, null );
        DAOH_PSA_LR_Project_Overview.validedFieldOnCompletion((List<LR_Project_Overview__c>) records, null );
        DAOH_PSA_LR_Project_Overview.validationOnLocalAndCompletedStatus((List<LR_Project_Overview__c>) records, null );
    }
    
    /**
    * This method is used for before update of the LR Project Overview trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_LR_Project_Overview.setLRFieldValues((List<LR_Project_Overview__c>) records, (Map<Id,LR_Project_Overview__c>) existingRecords);            
        DAOH_PSA_LR_Project_Overview.populateAccountFromProject((List<LR_Project_Overview__c>) records, (Map<Id,LR_Project_Overview__c>) existingRecords);         
        DAOH_PSA_LR_Project_Overview.cfiMeetingUpdateFromLR((List<LR_Project_Overview__c>) records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.validedFieldOnCompletion((List<LR_Project_Overview__c>) records, (Map<Id,LR_Project_Overview__c>) existingRecords); 
        DAOH_PSA_LR_Project_Overview.enableChkboxForBatchProcessing((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
    }
    /**
     * This method is used for after insert of the LR Project Overview  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_LR_Project_Overview.synchronizeProjectEvents((List<LR_Project_Overview__c>)Records, null);
        DAOH_PSA_LR_Project_Overview.synchRecordSS((List<LR_Project_Overview__c>)Records, null);
        DAOH_PSA_LR_Project_Overview.synchRecordEJ((List<LR_Project_Overview__c>)Records, null);
        DAOH_PSA_LR_Project_Overview.insertAuditLogOnUpdate((List<LR_Project_Overview__c>)Records, null);
    }
    
    /**
    * This method is used for after update of the LR Project Overview trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_LR_Project_Overview.copyInArchiveWhenLRStatusCompleteAndCancelled((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.cloneLrRecordsWhenStatusCompleted((List<LR_Project_Overview__c>) records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.synchronizeProjectEvents((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.synchRecordSS((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.synchRecordEJ((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
        DAOH_PSA_LR_Project_Overview.insertAuditLogOnUpdate((List<LR_Project_Overview__c>)Records, (Map<Id,LR_Project_Overview__c>) existingRecords);
    }
    
    /**
     * This method is used for after Delete of the LR Project Overview trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_LR_Project_Overview.insertAuditLog((List<LR_Project_Overview__c>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the LR Project Overview trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_LR_Project_Overview.insertAuditLog((List<LR_Project_Overview__c>)Records,'UNDELETE');
    }
}
