/**
 * This is Agreement trigger handler class.
 * version : 1.0 
 */
public class DAO_APTS_Agreement extends fflib_SObjectDomain{
    
    /**
     * Constructor of this class
     * @params sObjectList List<Apttus__APTS_Agreement__c>
     */
    public DAO_APTS_Agreement(List<Apttus__APTS_Agreement__c> sObjectList) {
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
            return new DAO_APTS_Agreement(sObjectList);
        }
    }
    /**
     * This method is used for before insert of the Agreement trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                //FEATURE-2947
                //DAOH_OWF_APTS_Agreement.populateReBidFields((List<Apttus__APTS_Agreement__c>)records);
                //Added by sanjeev sharma 
                //DAOH_OWF_APTS_Agreement.checkAgreementRecordTypeMapping((List<Apttus__APTS_Agreement__c>)records);
                //added by sanjeev sharma 
                //DAOH_OWF_APTS_Agreement.changeRecordType((List<Apttus__APTS_Agreement__c>)records);
                //DAOH_OWF_APTS_Agreement.setBidNoBasedOnRecordType((List<Apttus__APTS_Agreement__c>)records);
                //DAOH_OWF_APTS_Agreement.setNoOfRequestedServicesBasedOnRequestedServices((List<Apttus__APTS_Agreement__c>)Records, null);
                //DAOH_OWF_APTS_Agreement.populateAgrNameWithOppName((List<Apttus__APTS_Agreement__c>)records);
                //DAOH_OWF_APTS_Agreement.setMulesoftSyncfields((List<Apttus__APTS_Agreement__c>)records,null);
               // DAOH_OWF_APTS_Agreement.updateBiotech((List<Apttus__APTS_Agreement__c>)Records);
               // DAOH_OWF_APTS_Agreement.validateEarlyEngagementBid((List<Apttus__APTS_Agreement__c>)Records);	
                // Set Agreement defaults
                //DAOH_OWF_APTS_Agreement.updateBidComplexity((List<Apttus__APTS_Agreement__c>)Records);
            }
            
            List<Apttus__APTS_Agreement__c> clmAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmMSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmPSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSAEAOrCPRAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmPreliminaryAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmAmesaAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmAMAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWSSOWAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmCommercialAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWLPAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmEMEAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmVendorAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmGenericRecords = new List<Apttus__APTS_Agreement__c>();
            for(Apttus__APTS_Agreement__c agreement : (List<Apttus__APTS_Agreement__c>)Records) {
                
                if(agreement.recordTypeId == CON_CLM.PSA_RECORDTYPEID
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment) {
                    clmPSAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.OSA_RECORDTYPEID) {
                    if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_EA || 
                        agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_RA) {
                        clmOSAEAOrCPRAAgreementRecords.add(agreement);
                    } else {
                        clmOSAAgreementRecords.add(agreement);
                    }
                } else if(agreement.recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                    clmPreliminaryAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.MSA_RECORDTYPEID) {
                    clmMSAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.AMESA_RECORDTYPEID) {
                    clmAmesaAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.AMA_RECORDTYPEID) {
                    clmAMAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.RWS_RECORDTYPEID) {
                    clmRWSSOWAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.COMMERCIAL_RECORDTYPEID) {
                    clmCommercialAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.RWLP_RECORDTYPEID) {
                    clmRWLPAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.EMEA_RECORDTYPEID) {
                    clmEMEAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.VENDOR_RECORDTYPEID) {
                    clmVendorAgreementRecords.add(agreement);
                }
                else if(agreement.recordTypeId == CON_CLM.GENERIC_RECORDTYPEID) {
                    clmGenericRecords.add(agreement);
                }
            }
            DAOH_CLM_APTS_Agreement.setStatusCategoryAndStatus((List<Apttus__APTS_Agreement__c>)Records, CON_CLM.REQUEST, CON_CLM.REQUEST);
            DAOH_CLM_APTS_Agreement.updateParentAgreement((List<Apttus__APTS_Agreement__c>)Records, null);
            DAOH_CLM_APTS_Agreement.updateAGRFromOpportunity((List<Apttus__APTS_Agreement__c>)Records, null);
            
            if(clmPSAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.updateTermYears(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmPSAAgreementRecords, null);
                
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateAgreementFromQuote(clmPSAAgreementRecords, null, CON_CLM.PSA_RECORD_TYPE_NAME);
                DAOH_CLM_APTS_Agreement.preventUserFromCreatingCOFromOpp(clmPSAAgreementRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updatePaymentTerm(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setProvisionsTabForPSA(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.populateProbToMoveToHighConfidenceInQtr(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmPSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setAnalystStartDateFromBidRR(clmPSAAgreementRecords, null); 
            }
            if(clmOSAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmOSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmOSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.populateProbToMoveToHighConfidenceInQtr(clmOSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmOSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setAnalystStartDateFromBidRR(clmOSAAgreementRecords, null);
            }
            if(clmOSAEAOrCPRAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmOSAEAOrCPRAAgreementRecords, null);
            }
            if(!clmMSAAgreementRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.updateTermYears(clmMSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(clmMSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setAutoRenewField(clmMSAAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmMSAAgreementRecords, null);
            }
            if(!clmPreliminaryAgreementRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmPreliminaryAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateAgreementforIsStudyAwarded(clmPreliminaryAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateAgreementFromQuote(clmPreliminaryAgreementRecords, null, CON_CLM.PA_RECORD_TYPE_NAME);
                DAOH_CLM_APTS_Agreement.updatePaymentTerm(clmPreliminaryAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmPreliminaryAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmPreliminaryAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setAnalystStartDateFromBidRR(clmPreliminaryAgreementRecords, null);
            }
            if(!clmAmesaAgreementRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.setPickListLabelToField(clmAmesaAgreementRecords, null, 
                    CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME, CON_CLM.TO_ACCOUNT_COUNTRY_FIELD_API_NAME);
                DAOH_CLM_APTS_Agreement.setPickListLabelToField(clmAmesaAgreementRecords, null, 
                    CON_CLM.FROM_CONTRACTING_COUNTRY_FIELD_API_NAME, CON_CLM.TO_CONTRACTING_COUNTRY_FIELD_API_NAME);
            }
            if(!clmRWSSOWAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmRWSSOWAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateTermMonthValue(clmRWSSOWAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.preventUserFromCreatingCOFromOpp(clmRWSSOWAgreementRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmRWSSOWAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmRWSSOWAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmRWSSOWAgreementRecords, null);
            }
            if(!clmCommercialAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTermYears(clmCommercialAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmCommercialAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmCommercialAgreementRecords, null);
            }
            if(!clmRWLPAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmRWLPAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmRWLPAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmRWLPAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmRWLPAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.setAnalystStartDateFromBidRR(clmRWLPAgreementRecords, null);
            }
            if(!clmEMEAAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmEMEAAgreementRecords, null);
            }
            if(!clmVendorAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmVendorAgreementRecords, null);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmVendorAgreementRecords, null);
            }
            if(!clmGenericRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateIQAGRRecordTypeName(clmGenericRecords);
            }
        }
        DAOH_APTS_Agreement.setAccountCountry((List<Apttus__APTS_Agreement__c>)Records, null);
        DAOH_APTS_Agreement.setLastSharingCalculationTimestamp((List<Apttus__APTS_Agreement__c>)Records, null);  
    }
    
    /**
     * This method is used for after insert of the Agreement trigger.
     * @return void
     */
    public override void onAfterInsert() {
        
        //This is the section where all the methods that needs to be run at first are included.
        DAOH_APTS_Agreement.setDummyCreatorAccess((List<Apttus__APTS_Agreement__c>)records);
        DAOH_APTS_Agreement.setSharing((List<Apttus__APTS_Agreement__c>)Records, null);
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Trigger__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                //DAOH_OWF_APTS_Agreement.createProjectBasedOnAgreement((List<Apttus__APTS_Agreement__c>)records);
                UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
            }
            List<Apttus__APTS_Agreement__c> clmPSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmAMESARecords = new List<Apttus__APTS_Agreement__c>();
            for(Apttus__APTS_Agreement__c agreement : (List<Apttus__APTS_Agreement__c>)Records) {
                if(agreement.recordTypeId == CON_CLM.PSA_RECORDTYPEID
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment) {
                    clmPSAAgreementRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.OSA_RECORDTYPEID) {
                    clmOSAAgreementRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.AMESA_RECORDTYPEID) {
                    clmAMESARecords.add(agreement);
                }
            }
            if(clmPSAAgreementRecords.size() > 0){
                DAOH_CLM_APTS_Agreement.updateRelatedAgreementOnQuote(clmPSAAgreementRecords, null);
            }
            if(clmAMESARecords.size() > 0){
                DAOH_CLM_APTS_Agreement.updateRelatedAgreementOnQuote(clmAMESARecords, null);
            }
            UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
            //This has to be the last function call. Any method calling should be above this.
        }
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will implement the sharing
        
        DAOH_CRM_APTS_Agreement.updateRfpReceivedDate((List<Apttus__APTS_Agreement__c>)Records, null);
        DAOH_CRM_APTS_Agreement.updateSurveyPIC((List<Apttus__APTS_Agreement__c>)Records, null);
    }
    
    /**
     * This method is used for before update of the Agreement trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_APTS_Agreement.setLastManualSharingFieldUpdate((List<Apttus__APTS_Agreement__c>)Records,null);
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                
                //DAOH_OWF_APTS_Agreement.setNoOfRequestedServicesBasedOnRequestedServices((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_OWF_APTS_Agreement.setMulesoftSyncfields((List<Apttus__APTS_Agreement__c>)records,(Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_OWF_APTS_Agreement.validateEarlyEngagementBid((List<Apttus__APTS_Agreement__c>)Records);
                //DAOH_OWF_APTS_Agreement.updateBidComplexity((List<Apttus__APTS_Agreement__c>)Records);
                
            }
			
            List<Apttus__APTS_Agreement__c> clmAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmPSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmMSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmPreliminaryAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmAmesaAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmAMAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSAEAOrCPRAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWSAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmCommercialAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWLPAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmEMEAAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmNonSCCAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmVendorAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            
            for(Apttus__APTS_Agreement__c agreement : (List<Apttus__APTS_Agreement__c>)Records) {
                
                if(agreement.recordTypeId == CON_CLM.PSA_RECORDTYPEID
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment){
                    clmPSAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                    clmPreliminaryAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.MSA_RECORDTYPEID) {
                    clmMSAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.AMESA_RECORDTYPEID) {
                    clmAmesaAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.AMA_RECORDTYPEID) {
                    clmAMAAgreementRecords.add(agreement);
                } else if(agreement.recordTypeId == CON_CLM.COMMERCIAL_RECORDTYPEID) {
                    clmCommercialAgreementRecords.add(agreement);
                }
                else if(agreement.recordTypeId == CON_CLM.OSA_RECORDTYPEID) {
                    if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_EA ||
                        agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_RA) {
                        clmOSAEAOrCPRAAgreementRecords.add(agreement);
                    } else {
                        clmOSAAgreementRecords.add(agreement);
                    }
                } else if(agreement.recordTypeId == CON_CLM.RWS_RECORDTYPEID) {
                    clmRWSAgreementRecords.add(agreement);
                }
                else if(agreement.recordTypeId == CON_CLM.RWLP_RECORDTYPEID) {
                    clmRWLPAgreementRecords.add(agreement);
                }
                else if(agreement.recordTypeId == CON_CLM.EMEA_RECORDTYPEID) {
                    clmEMEAAgreementRecords.add(agreement);
                }
                else if(agreement.recordTypeId == CON_CLM.VENDOR_RECORDTYPEID) {
                    clmVendorAgreementRecords.add(agreement);
                }

                if(agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment) {
                    clmNonSCCAgreementRecords.add(agreement);
                }
            }
            DAOH_CLM_APTS_Agreement.updateGenerateStatuses((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            DAOH_CLM_APTS_Agreement.validateSignedDateBeforeFullySigned(clmNonSCCAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            DAOH_CLM_APTS_Agreement.validateSignerInfo(clmNonSCCAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            DAOH_CLM_APTS_Agreement.updateParentAgreement((List<Apttus__APTS_Agreement__c>)Records,  (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            DAOH_CLM_APTS_Agreement.updateAGRFromOpportunity((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            if(clmAMAAgreementRecords.size() > 0) {
                DAOH_CLM_APTS_Agreement.updateCompanySignedByAndDate(clmAMAAgreementRecords,  (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_CLM_APTS_Agreement.preventAMAUpdatesOnAmend(clmAMAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
            if(clmPSAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.updateTermYears(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updatePaymentTerm(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.setProvisionsTabForPSA(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.populateProbToMoveToHighConfidenceInQtr(clmPSAAgreementRecords, null);
                if(!UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed) {
                    DAOH_CLM_APTS_Agreement.preventUserFromUpdatingCurrencyFromAgreement(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                }
                DAOH_CLM_APTS_Agreement.updateAgreementFromQuote(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords, CON_CLM.PSA_RECORD_TYPE_NAME);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateConcessionFields(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateDateFirstSentToCustomer(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);            
                DAOH_CLM_APTS_Agreement.updateParallelChangeOrderAmendments(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);  
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);  
                DAOH_CLM_APTS_Agreement.validateStatusChangeToIR(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords); 
                DAOH_CLM_APTS_Agreement.setPerpetualOnFullySigned(clmPSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords); 
            }
            if(clmOSAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateProbToMoveToHighConfidenceInQtr(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateDateFirstSentToCustomer(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.validateStatusChangeToIR(clmOSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords); 
            }
            if(clmOSAEAOrCPRAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmOSAEAOrCPRAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
            if(!clmMSAAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTermYears(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updatePaymentTerm(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.setNotifyCustomerIfMissingINVCont(clmMSAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
            if(!clmPreliminaryAgreementRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateAgreementforIsStudyAwarded(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updatePaymentTerm(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                if(!UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed) {
                    DAOH_CLM_APTS_Agreement.preventUserFromUpdatingCurrencyFromAgreement(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                }
                DAOH_CLM_APTS_Agreement.updateAgreementFromQuote(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords, CON_CLM.PSA_RECORD_TYPE_NAME);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateDateFirstSentToCustomer(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.validateStatusChangeToIR(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords); 
                DAOH_CLM_APTS_Agreement.setPerpetualOnFullySigned(clmPreliminaryAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmAmesaAgreementRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.setPickListLabelToField(clmAmesaAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords, 
                    CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME, CON_CLM.TO_ACCOUNT_COUNTRY_FIELD_API_NAME);
                DAOH_CLM_APTS_Agreement.setPickListLabelToField(clmAmesaAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords, 
                    CON_CLM.FROM_CONTRACTING_COUNTRY_FIELD_API_NAME, CON_CLM.TO_CONTRACTING_COUNTRY_FIELD_API_NAME);         
            }
            if(!clmRWSAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmRWSAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateTermMonthValue(clmRWSAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmRWSAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmRWSAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmRWSAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmCommercialAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTermYears(clmCommercialAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmCommercialAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmCommercialAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
            if(!clmRWLPAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateConcessionFields(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateParallelChangeOrderAmendments(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateDateFirstSentToCustomer(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);  
                DAOH_CLM_APTS_Agreement.validateStatusChangeToIR(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.setPerpetualOnFullySigned(clmRWLPAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords); 
            }
            if(clmEMEAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmEMEAAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
            if(!clmVendorAgreementRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                DAOH_CLM_APTS_Agreement.populateAgreementStartDate(clmVendorAgreementRecords, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
            }
        }
        DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
        DAOH_CLM_APTS_Agreement.validateReviewCycleBeforeStatusCategoryChanged((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
        DAOH_APTS_Agreement.setAccountCountry((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
        DAOH_APTS_Agreement.setLastSharingCalculationTimestamp((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
    }
    
    /**
     * This method is used for after update of the Agreement trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_RR_Trigger__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                
                //DAOH_OWF_APTS_Agreement.createClinicalBidResRequestsOnAgreementUpdate((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                
                //DAOH_OWF_APTS_Agreement.setEndDateAndStatusOnProjectResReqsAndAssignments((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_OWF_APTS_Agreement.updateComplexityScoreTotalOnRR((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_OWF_APTS_Agreement.updateDataBasedOnOasSetting((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                //DAOH_OWF_APTS_Agreement.updateResourcesNeededFromAgreement((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
                
            }
            
            List<Apttus__APTS_Agreement__c> clmPSAAgreementRecords = new List<Apttus__APTS_Agreement__c>();          
            List<Apttus__APTS_Agreement__c> clmPreliminaryAgreementRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmEMEARecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWLPRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmOSARecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmMSARecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmGenericRecords = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> clmRWSSOWRecords = new List<Apttus__APTS_Agreement__c>();
            for(Apttus__APTS_Agreement__c agreement : (List<Apttus__APTS_Agreement__c>)Records) {
                if(agreement.recordTypeId == CON_CLM.PSA_RECORDTYPEID 
                    && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment) {
                    clmPSAAgreementRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                    clmPreliminaryAgreementRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.EMEA_RECORDTYPEID) {
                    clmEMEARecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.RWLP_RECORDTYPEID) {
                    clmRWLPRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.OSA_RECORDTYPEID) {
                    clmOSARecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.MSA_RECORDTYPEID) {
                    clmMSARecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.GENERIC_RECORDTYPEID) {
                    clmGenericRecords.add(agreement);
                }
                if(agreement.recordTypeId == CON_CLM.RWS_RECORDTYPEID) {
                    clmRWSSOWRecords.add(agreement);
                }
            }
            if(clmPSAAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.updateRelatedQuoteStageOnAgrActivation(clmPSAAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateRelatedQuoteOnAgreementCancellation(clmPSAAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmPSAAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTaskonContractManagerUpdate(clmPSAAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateBidonAgreementUpdate(clmPSAAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(clmPreliminaryAgreementRecords.size()>0){
                DAOH_CLM_APTS_Agreement.updateRelatedQuoteStageOnAgrActivation(clmPreliminaryAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateRelatedQuoteOnAgreementCancellation(clmPreliminaryAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmPreliminaryAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTaskonContractManagerUpdate(clmPreliminaryAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateBidonAgreementUpdate(clmPreliminaryAgreementRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmRWLPRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmRWLPRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTaskonContractManagerUpdate(clmRWLPRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateBidonAgreementUpdate(clmRWLPRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmOSARecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmOSARecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.createTaskonContractManagerUpdate(clmOSARecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
                DAOH_CLM_APTS_Agreement.updateBidonAgreementUpdate(clmOSARecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmMSARecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmMSARecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmGenericRecords.isEmpty()){
                DAOH_CLM_APTS_Agreement.updateIQAGRToInAuthoring(clmGenericRecords,
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            if(!clmRWSSOWRecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(clmRWSSOWRecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }
            /*
            if(!clmEMEARecords.isEmpty()) {
                DAOH_CLM_APTS_Agreement.shareActivatedAGRDocOnOpp(clmEMEARecords, 
                    (Map<Id, Apttus__APTS_Agreement__c>) existingRecords);
            }*/
            //This has to be the last function call. Any method calling should be above this.
        }
        DAOH_APTS_Agreement.setSharing((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
        DAOH_CRM_APTS_Agreement.updateRfpReceivedDate((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
        DAOH_CRM_APTS_Agreement.updateSurveyPIC((List<Apttus__APTS_Agreement__c>)Records, (Map<Id, Apttus__APTS_Agreement__c>)existingRecords);
    }
    
    /**
     * This method is used for before Delete of the Agreement trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                
                //DAOH_OWF_APTS_Agreement.deleteProjectBasedOnAgreement((List<Apttus__APTS_Agreement__c>)records);             
            }
        }
    }
    
    public override void onAfterDelete() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c){
            if (!UTL_ExecutionControl.stopTriggerExecution_OWF) {
               // DAOH_OWF_APTS_Agreement.createOutboundMessageDeletionQueue((List<Apttus__APTS_Agreement__c>)Records);
            }
        }
    }
}