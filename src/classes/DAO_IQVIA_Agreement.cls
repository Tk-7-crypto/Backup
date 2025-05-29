public class DAO_IQVIA_Agreement extends fflib_SObjectDomain{
    /**
     * Constructor of this class
     * @params sObjectList List<IQVIA_Agreement__c>
     */
    public DAO_IQVIA_Agreement(List<IQVIA_Agreement__c> sObjectList) {
        super(sObjectList);
        if(UTL_ExecutionControl.disableTriggerCRUDAGR) {
            Configuration.disableTriggerCRUDSecurity();       
        }
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_IQVIA_Agreement(sObjectList);
        }
    }
    
    public override void onBeforeInsert() { 
        List<IQVIA_Agreement__c> clmIQVIAAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmAvacareAgreementRecords = new List<IQVIA_Agreement__c>();
        for(IQVIA_Agreement__c agreement : (List<IQVIA_Agreement__c>)Records) {
            if(agreement.recordTypeId != CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                clmIQVIAAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId == CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                clmAvacareAgreementRecords.add(agreement);
            }
        }
        //sharing methods should be called first, don't make changes in the ordering
        if(!clmIQVIAAgreementRecords.isEmpty()) {
            DAOH_IQVIA_Agreement.setAccountCountry(clmIQVIAAgreementRecords,  null);
            DAOH_IQVIA_Agreement.setLastSharingCalculationTimestamp(clmIQVIAAgreementRecords,  null);
        }
        if(!clmAvacareAgreementRecords.isEmpty()) {
            DAOH_CLM_IQVIA_Agreement.setDefaultAccount(clmAvacareAgreementRecords);
        }
    }
    
    public override void onAfterInsert() {
        List<IQVIA_Agreement__c> clmUSBUAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmMSAAgreementRecords = new List<IQVIA_Agreement__c>(); 
        List<IQVIA_Agreement__c> clmIQVIAAgreementRecords = new List<IQVIA_Agreement__c>();    
        Set<Id> clmAgreementRecordsIDs = new Set<Id>();
        for(IQVIA_Agreement__c agreement : (List<IQVIA_Agreement__c>)Records) {
            clmAgreementRecordsIDs.add(agreement.Id);
            if(agreement.recordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID) {
                clmUSBUAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId != CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                clmIQVIAAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID) {
                clmMSAAgreementRecords.add(agreement);
            }
        }
        //sharing methods should be called first, don't make changes in the ordering
        if(!clmIQVIAAgreementRecords.isEmpty()) {
            DAOH_IQVIA_Agreement.setDummyCreatorAccess(clmIQVIAAgreementRecords);
            DAOH_IQVIA_Agreement.setSharing(clmIQVIAAgreementRecords,  null);
        }
        DAOH_CLM_IQVIA_Agreement.setIQVIAAgreementNumber(clmAgreementRecordsIDs);
        if(clmUSBUAgreementRecords.size() > 0) {
            DAOH_CLM_IQVIA_Agreement.createCongaAgreementFromIqvAgreement((List<IQVIA_Agreement__c>)clmUSBUAgreementRecords, null);
        }  
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        List<IQVIA_Agreement__c> clmUSBUAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmMSAAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmIQVIAAgreementRecords = new List<IQVIA_Agreement__c>();
        for(IQVIA_Agreement__c agreement : (List<IQVIA_Agreement__c>)Records) {
            if(agreement.recordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID) {
                clmUSBUAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID) {
                clmMSAAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId != CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                clmIQVIAAgreementRecords.add(agreement);
            }
        }
        //sharing methods should be called first, don't make changes in the ordering
        if(!clmIQVIAAgreementRecords.isEmpty()) {
            DAOH_IQVIA_Agreement.setLastManualSharingFieldUpdate(clmIQVIAAgreementRecords, null);
            DAOH_IQVIA_Agreement.setAccountCountry(clmIQVIAAgreementRecords,  (Map<Id, IQVIA_Agreement__c>)existingRecords);
            DAOH_IQVIA_Agreement.setLastSharingCalculationTimestamp(clmIQVIAAgreementRecords,  (Map<Id, IQVIA_Agreement__c>)existingRecords);
        }  
        if(!clmUSBUAgreementRecords.isEmpty()) {
            DAOH_CLM_IQVIA_Agreement.updateRequestDate(clmUSBUAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
            DAOH_CLM_IQVIA_Agreement.updateParallelChangeOrderAmendments(clmUSBUAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
            DAOH_CLM_IQVIA_Agreement.updateAGROnFullySigned(clmUSBUAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
        }
        if(!clmMSAAgreementRecords.isEmpty()) {
            DAOH_CLM_IQVIA_Agreement.updateRequestDate(clmMSAAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
            DAOH_CLM_IQVIA_Agreement.updateParallelChangeOrderAmendments(clmMSAAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
        }
        DAOH_CLM_IQVIA_Agreement.updateSearchField((List<IQVIA_Agreement__c>)Records, (Map<Id, IQVIA_Agreement__c>)existingRecords); 
        DAOH_CLM_IQVIA_Agreement.updateActivationFields((List<IQVIA_Agreement__c>)Records, (Map<Id, IQVIA_Agreement__c>)existingRecords); 
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        
        Map<Id, IQVIA_Agreement__c> oldMap = (Map<Id, IQVIA_Agreement__c>)existingRecords;
        List<IQVIA_Agreement__c> clmUSBUAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmMSAAgreementRecords = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> clmIQVIAAgreementRecords = new List<IQVIA_Agreement__c>();
        for(IQVIA_Agreement__c agreement : (List<IQVIA_Agreement__c>)Records) {
            if(agreement.recordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID) {
                clmUSBUAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID) {
                clmMSAAgreementRecords.add(agreement);
            }
            if(agreement.recordTypeId != CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                clmIQVIAAgreementRecords.add(agreement);
            }
        }
        //sharing methods should be called first, don't make changes in the ordering
        if(!clmIQVIAAgreementRecords.isEmpty()) {
            DAOH_IQVIA_Agreement.setSharing(clmIQVIAAgreementRecords, (Map<Id, IQVIA_Agreement__c>)existingRecords);
        }
        if(clmUSBUAgreementRecords.size()>0){
            DAOH_CLM_IQVIA_Agreement.createCongaAgreementFromIqvAgreement((List<IQVIA_Agreement__c>)clmUSBUAgreementRecords, oldMap);
            DAOH_CLM_IQVIA_Agreement.activateFullySignedAgreements((List<IQVIA_Agreement__c>)clmUSBUAgreementRecords, oldMap);
            DAOH_CLM_IQVIA_Agreement.createAROnActivation((List<IQVIA_Agreement__c>)clmUSBUAgreementRecords, oldMap);
        }
        if(!clmMSAAgreementRecords.isEmpty()) {
            DAOH_CLM_IQVIA_Agreement.createCongaAgreementFromIqvAgreement((List<IQVIA_Agreement__c>)clmMSAAgreementRecords, oldMap);
            DAOH_CLM_IQVIA_Agreement.activateFullySignedAgreements((List<IQVIA_Agreement__c>)clmMSAAgreementRecords, oldMap);
            DAOH_CLM_IQVIA_Agreement.createAROnActivation((List<IQVIA_Agreement__c>)clmMSAAgreementRecords, oldMap);
        } 
        DAOH_CLM_IQVIA_Agreement.updateCongaAgreementName((List<IQVIA_Agreement__c>)Records, (Map<Id, IQVIA_Agreement__c>)existingRecords);
    }
}