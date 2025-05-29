public class DAO_APTS_DocumentVersion extends fflib_SObjectDomain{
    
    /**
     * Constructor of this class
     * @params sObjectList List<Apttus__APTS_Agreement__c>
     */
    public DAO_APTS_DocumentVersion(List<Apttus__DocumentVersion__c> sObjectList) {
        super(sObjectList);
        
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_APTS_DocumentVersion(sObjectList);
        }
    }
    /**
     * This method is used for before insert of the Agreement trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_CLM_APTS_DocumentVersion.updateIQAGRRecordTypeName((List<Apttus__DocumentVersion__c>)Records);
        DAOH_CLM_APTS_DocumentVersion.setLastSharingCalculationTimestamp((List<Apttus__DocumentVersion__c>)Records, null);  
    }
    
    /**
     * This method is used for after insert of the Agreement trigger.
     * @return void
     */
    public override void onAfterInsert() {
        
        //This is the section where all the methods that needs to be run at first are included.
        DAOH_CLM_APTS_DocumentVersion.setDummyCreatorAccess((List<Apttus__DocumentVersion__c>)records);
        DAOH_CLM_APTS_DocumentVersion.setSharing((List<Apttus__DocumentVersion__c>)Records, null);
        
    }
    
    /**
     * This method is used for before update of the Agreement trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {

        DAOH_CLM_APTS_DocumentVersion.setLastManualSharingFieldUpdate((List<Apttus__DocumentVersion__c>)Records,null);
        DAOH_CLM_APTS_DocumentVersion.setLastSharingCalculationTimestamp((List<Apttus__DocumentVersion__c>)Records, (Map<Id, Apttus__DocumentVersion__c>)existingRecords);
        DAOH_CLM_APTS_DocumentVersion.unlockDocumentVersion((List<Apttus__DocumentVersion__c>)Records, (Map<Id, Apttus__DocumentVersion__c>)existingRecords);
    }
    
    /**
     * This method is used for after update of the Agreement trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        
        DAOH_CLM_APTS_DocumentVersion.setSharing((List<Apttus__DocumentVersion__c>)Records, (Map<Id, Apttus__DocumentVersion__c>)existingRecords);
        DAOH_CLM_APTS_DocumentVersion.updateAgreements((List<Apttus__DocumentVersion__c>)Records, (Map<Id, Apttus__DocumentVersion__c>)existingRecords);
    }
    
    /**
     * This method is used for before Delete of the Agreement trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        
    }
    
    public override void onAfterDelete() {
        
    }

}