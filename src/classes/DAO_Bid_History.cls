public class DAO_Bid_History extends fflib_SObjectDomain{
 /**
     * Constructor of this class
     * @params sObjectList List<Bid_History__c>
     */
    public DAO_Bid_History(List<Bid_History__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Bid_History(sObjectList);
        }
    }
    
    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            Outbound_Message_Deletion_queue__c.SobjectType
        }
    );
    
    public override void onApplyDefaults() {
    }
    
    /**
     * This method is used for before insert of the Agreement trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                DAOH_OWF_Bid_History.changeRecordType((List<Bid_History__c>)records);
                DAOH_OWF_Bid_History.setBidNoBasedOnRecordType((List<Bid_History__c>)records);
                DAOH_OWF_Bid_History.setNoOfRequestedServicesBasedOnRequestedServices((List<Bid_History__c>)Records, null);
                DAOH_OWF_Bid_History.populateAgrNameWithOppName((List<Bid_History__c>)records);
                DAOH_OWF_Bid_History.setMulesoftSyncfields((List<Bid_History__c>)records,null);
                DAOH_OWF_Bid_History.updateBiotech((List<Bid_History__c>)Records);
                DAOH_OWF_Bid_History.validateEarlyEngagementBid((List<Bid_History__c>)Records);	
                DAOH_OWF_Bid_History.updateBidComplexity((List<Bid_History__c>)Records);
                DAOH_OWF_Bid_History.updateSuggestedDueDate((List<Bid_History__c>)Records, null);
                DAOH_OWF_Bid_History.setQueueAsOwneronQ2RecordType((List<Bid_History__c>)Records, null);																										
                DAOH_OWF_Bid_History.q2LabBidHistoryAssignProposalRankingFieldUpdate((List<Bid_History__c>) records);
                DAOH_OWF_Bid_History.q2BioFortisQuoteNeededFieldUpdate((List<Bid_History__c>) records,(Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.populateRelatedQuoteStatusForAwardeded((List<Bid_History__c>)records, null);
                DAOH_OWF_Bid_History.populateFieldsForGCCBidHistory((List<Bid_History__c>)records, null);
                DAOH_OWF_Bid_History.populateFieldsForContractPostAwardBid((List<Bid_History__c>)records, null);
                DAOH_OWF_Bid_History.processQ2SolutionsBid((List<Bid_History__c>)records, null);
                DAOH_OWF_Bid_History.populateChangeOrderAmount((List<Bid_History__c>)records, null);
                DAOH_OWF_Bid_History.populateStandardSubmissionDate((List<Bid_History__c>)records, null);
            }
        }
        DAOH_OWF_Bid_History.setAccountCountry((List<Bid_History__c>)Records, null);
    }
    
    /**
     * This method is used for after insert of the Agreement trigger.
     * @return void
     */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Trigger__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                DAOH_OWF_Bid_History.createProjectBasedOnAgreement((List<Bid_History__c>)records);
                DAOH_OWF_Bid_History.sendEmailToRequestedProductsEmailsOnCSSBid((List<Bid_History__c>) records);
                if(!Mulesoft_Integration_Control__c.getInstance().By_Pass_Flow_Process__c || Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c) {
                    DAOH_OWF_Bid_History.sendEmailbyWorkflowEmailRecord((List<Bid_History__c>) records, null);             
                }
                UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
            }
            DAOH_CRM_Bid_History.updateRfpReceivedDate((List<Bid_History__c>)Records, null);
            UTL_OWF.getGovernorLimits(String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
            // CBEx IQVIACBEX-1201 move from Agreement to Bid-History
            DAOH_CBEx_Bid_History.reParentFilesToAgreement((List<Bid_History__c>)Records);
            DAOH_CBEx_Bid_History.createUnityLink((List<Bid_History__c>)Records);
            // CBEx End            
            //This has to be the last function call. Any method calling should be above this.
        }
        
    }
    
    /**
     * This method is used for before update of the Agreement trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                DAOH_OWF_Bid_History.setNoOfRequestedServicesBasedOnRequestedServices((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.setMulesoftSyncfields((List<Bid_History__c>)records,(Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.validateEarlyEngagementBid((List<Bid_History__c>)Records);
                DAOH_OWF_Bid_History.validateBidUpdate((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.updateBidComplexity((List<Bid_History__c>)Records);
                DAOH_OWF_Bid_History.updateSuggestedDueDate((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.q2LabBidHistoryAssignProposalRankingFieldUpdate((List<Bid_History__c>) records);
                DAOH_OWF_Bid_History.setQueueAsOwneronQ2RecordType((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);																																			
                DAOH_OWF_Bid_History.q2BioFortisQuoteNeededFieldUpdate((List<Bid_History__c>) records,(Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.populateRFPAssignedDate((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.populateRelatedQuoteStatusForAwardeded((List<Bid_History__c>)records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.populateFieldsForGCCBidHistory((List<Bid_History__c>)records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.processQ2SolutionsBid((List<Bid_History__c>)records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.populateChangeOrderAmount((List<Bid_History__c>)records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.checkStandardSubmissionDateOnAfterUpdate((List<Bid_History__c>)records);
            }
        DAOH_OWF_Bid_History.setAccountCountry((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);   
    }
    }
    /**
     * This method is used for after update of the Agreement trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            //This is the section where all the methods that needs to be run in a normal sequence are included.
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_RR_Trigger__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                
                DAOH_OWF_Bid_History.createClinicalBidResRequestsOnAgreementUpdate((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                
                DAOH_OWF_Bid_History.setEndDateAndStatusOnProjectResReqsAndAssignments((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.updateComplexityScoreTotalOnRR((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.updateDataBasedOnOasSetting((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                if(!Mulesoft_Integration_Control__c.getInstance().By_Pass_Flow_Process__c || Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c){
                    DAOH_OWF_Bid_History.sendEmailbyWorkflowEmailRecord((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);                    
                }
                //DAOH_OWF_Bid_History.updatepopulateBoxLinktoQuotesFolder((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
                DAOH_OWF_Bid_History.updateResourcesNeededFromAgreement((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
            }
            DAOH_CRM_Bid_History.updateRfpReceivedDate((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
            //IQVIACBEX-1804:Added a call to process the sync logic between Salesforce and Unity.
            DAOH_CBEx_Bid_History.setUnityFlagSyncMechanism(new Map<Id, Bid_History__c>((List<Bid_History__c>)Records), (Map<Id, Bid_History__c>)existingRecords);
            DAOH_OWF_Bid_History.createResourceRequestsOnContractPostAwardBid((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
            DAOH_OWF_Bid_History.createResourceRequestsOnCSSBid((List<Bid_History__c>)Records, (Map<Id, Bid_History__c>)existingRecords);
        }
    }
    /**
     * This method is used for before Delete of the Agreement trigger.
     * @return void
     */
    public override void onBeforeDelete() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_Agreement_Flow__c && !UTL_ExecutionControl.stopTriggerExecution_OWF) {
                DAOH_OWF_Bid_History.deleteProjectBasedOnAgreement((List<Bid_History__c>)records);             
            }
        }
    }
    
    public override void onAfterDelete() {
        if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Bid_History_Trigger__c){
            if (!UTL_ExecutionControl.stopTriggerExecution_OWF) {
                DAOH_OWF_Bid_History.createOutboundMessageDeletionQueue((List<Bid_History__c>)Records);
            }
        }
    }
}
