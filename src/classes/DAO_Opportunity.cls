/**
 * This is Opportunity trigger handler class.
 * version : 1.0
 */ 
public class DAO_Opportunity extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Opportunity>
     */
    public DAO_Opportunity(List<Opportunity> sObjectList) {
        super(sObjectList);
        if(UTL_ExecutionControl.disableTriggerCRUDSecurityForOpportunity){
            Configuration.disableTriggerCRUDSecurity();
        }
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Opportunity(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the opportunity trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method
        DAOH_Opportunity.resetTriggerExecutionFlag((List<Opportunity>)Records);
        DAOH_Opportunity.updateSalesSpotCompetitor((List<Opportunity>)Records, null);
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Opportunity.validateOpportunity((List<Opportunity>)records);
        DAOH_Opportunity.setTimeStampBasedOnStage((List<Opportunity>)Records, null);
        DAOH_Opportunity.setStandardPriceBookId((List<Opportunity>)records);
        DAOH_Opportunity.setClonedOpportunitiesNumerBlank((List<Opportunity>)records);
        DAOH_Opportunity.setOppFields((List<Opportunity>)records, null);
        DAOH_Opportunity.setBidTeamSplit((List<Opportunity>)Records, null);
        DAOH_Opportunity.setParentNumber((List<Opportunity>)Records, null);
        DAOH_Opportunity.updateGPU((List<Opportunity>)Records,null);
        DAOH_Opportunity.setRareDiseaseFieldValue((List<Opportunity>)Records, null);
        //This is the section for OWF where all the methods that needs to be run in a normal sequence are included.
        //This Section is enabled to run based on the release version
        if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_OPP_Flow__c) {
          
              DAOH_OWF_Opportunity.setNoOfPotentialRegionsBasedOnPotentialRegions((List<Opportunity>)Records, null);  
          
        }
        
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will integrate the opp with the latest changes
        DAOH_Opportunity.setMuleSoftSyncMechanism((List<Opportunity>)records, null);      
        DAOH_Opportunity.updateConversionRate((List<Opportunity>)records);
        DAOH_Opportunity.updateRWSTriageLastModified((List<Opportunity>)Records,null);
        DAOH_Opportunity.updateLast_Modified_By_USER((List<Opportunity>)Records);
        DAOH_Opportunity.setLostDateToday((List<Opportunity>)Records,null);
        DAOH_Opportunity.setLastSharingCalculationTimestamp((List<Opportunity>)Records, null);
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_Opportunity.emeaIqviaQuoteError((List<Opportunity>)Records, null);
        }
        DAOH_Opportunity.isUSBUOpportunity((List<Opportunity>)Records,null);
    }
    
    /**
     * This method is used for before update of the opportunity trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method
        //DAOH_Opportunity.addLIGError((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setLastManualSharingFieldUpdate((List<Opportunity>)Records,null);
        DAOH_Opportunity.resetTriggerExecutionFlag((List<Opportunity>)Records);
        DAOH_Opportunity.updateSalesSpotCompetitor((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Opportunity.setOppFields((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setTimeStampBasedOnStage((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.validateOpportunitiesBasedOnStage(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.resetLegacyAccountId(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        if(!CON_CRM.IS_CLONE_OPPORTUNITY_FLOW && !CON_CRM.IS_CURRENCY_CHANGE_FLOW) {
            DAOH_Opportunity.validationForProxyBNFApproval(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.validationOnOppForProxyPA(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.populateProbabiltyOnOpportunity(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
            //DAOH_Opportunity.validationForProxySCMAgreement(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.processProjectAwardedAndSignedPrice((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords, true);
        }
        //DAOH_Opportunity.excludePACheck(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setBidTeamSplit((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.hasLQMaterialProducts(new Map<Id, Opportunity>((List<Opportunity>)Records));
        DAOH_Opportunity.setPathProbabilityOnClosedWonOpp((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        //This is the section for OWF where all the methods that needs to be run in a normal sequence are included.
        //This Section is enabled to run based on release version
        if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_OPP_Flow__c) {
            
            DAOH_OWF_Opportunity.setNoOfPotentialRegionsBasedOnPotentialRegions((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_OWF_Opportunity.BDLeadSubRegionRequired((List<Opportunity>)Records);
        }
        
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will integrate the opp with the latest changes
        DAOH_Opportunity.updatePricingToolRecommended((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setMuleSoftSyncMechanism((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);  
        DAOH_Opportunity.updateConversionRate((List<Opportunity>)records);
        DAOH_Opportunity.validateOpportunityForStage((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setParentNumber((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setFreezeUnfreezeOpp(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setLeadSourceFields((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setStageLastChangesDate((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.stampedSurveySentDates((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.updateRWSTriageLastModified((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.validateOppForRWS((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.updateLast_Modified_By_USER((List<Opportunity>)Records);
        DAOH_Opportunity.updateGPU((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setRareDiseaseFieldValue((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.RestoreOpportunityOwnerChange_On_AccountTerritoryUpdate((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.awardedBidMandatory((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setLostDateToday((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setBoxFolderURLonOpp(new Map<Id, Opportunity>((List<Opportunity>)Records),(Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.setLastSharingCalculationTimestamp((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.getSiteSubUpdateByOpprtunity((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_Opportunity.avacareOppValidations((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        }
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_Opportunity.emeaIqviaQuoteError((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.checkExcludeIQVIAQuoteSync((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        }
        DAOH_Opportunity.isUSBUOpportunity((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
    }

    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        //DAOH_Opportunity.createTeamMemberForPICUser(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        //DAOH_Opportunity.createLineItemGroup(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.submitUnvalidatedAccounts((List<Opportunity>)Records,(Map<Id, Opportunity>)existingRecords);
        //IQVIACBEX-1804:Added a call to process the sync logic between Salesforce and Unity.
        DAOH_Opportunity.setUnityFlagSyncMechanism(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        
         //Refactor code IQVIAPSA-2236 Start
         Set<Id> oppIdExistAgrmtSet=new Set<Id>();
         oppIdExistAgrmtSet = UTL_OWF.isOPPhasOWFAgreementReturnSet(trigger.newMap.keySet());
         //Refactor code IQVIAPSA-2236 End
        
        //This is the section for OWF where all the methods that needs to be run in a normal sequence are included.
        //This section is enabled to run based on release version
        //Refactor code IQVIAPSA-2236 (Remove  UTL_OWF.isOPPhasOWFAgreement(trigger.newMap.keySet() Add oppIdExistAgrmt.size() > 0 )
        if((!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_RR_Trigger__c) && oppIdExistAgrmtSet.size() > 0) {
            
            DAOH_OWF_Opportunity.createClinicalBidResRequestsOnOppUpdate((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            //DAOH_OWF_Opportunity.createClinicalBidResourceRequestsOnPhaseUpdate((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords); 
            DAOH_OWF_Opportunity.updateComplexityScoreTotalOnRR((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            //DAOH_OWF_Opportunity.updateBiotech((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);             
        }
        DAOH_OWF_Opportunity.UpdateOCTRFxBid((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will set the sync fields with the latest changes
        DAOH_Opportunity.setMuleSoftSyncFields((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);     
        if(!CON_CRM.IS_CLONE_OPPORTUNITY_FLOW && !CON_CRM.IS_CURRENCY_CHANGE_FLOW) {    
            //DAOH_Opportunity.processProjectAwardedAndSignedPrice((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords, false);
        }

        DAOH_Opportunity.updateLeadStatusOnClose((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);  
        DAOH_Opportunity.updateSurveyFields((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords);
        Email_Execution_Control__c emailControl = Email_Execution_Control__c.getInstance();
        if(emailControl == null || !emailControl.Stop_Send_Emails__c){     
            // Win Loss Alert
            DAOH_Opportunity.winLossAlertEmail((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.sendEmailToRemovePICUser((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.notifyUsersOnStage5((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.sendMailToClosedOppUser((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.notifyUserOnStage5And7b((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
            DAOH_Opportunity.notifyChildOppOwner((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
			DAOH_Opportunity.sendMailWhenOppOwnerIsChanged((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        }
        
        //ESPSFDCQI-7474
        if(!CON_CRM.IS_CURRENCY_CHANGE_FLOW){
            DAOH_Opportunity.creditAssessmentCheck((List<Opportunity>)records, (Map<Id, Opportunity>)existingRecords); 
        }

        //Method to update CLM's preliminary agreement records 
        DAOH_CLM_Opportunity.updateIsStudyAwaredOfAgreement((List<Opportunity>)Records, 
            (Map<Id, Opportunity>)existingRecords);
        DAOH_Opportunity.updateSalesProgram((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        if(!CON_CRM.IS_CURRENCY_CHANGE_FLOW){
            DAOH_Opportunity.setSharing((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        }
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_Opportunity.updateSalePriceAvacareProduct((List<Opportunity>)Records, (Map<Id, Opportunity>)existingRecords);
        }
    }

    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        DAOH_Opportunity.setOpportunityNumber((List<Opportunity>)Records);
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        //DAOH_Opportunity.createTeamMemberForPICUser(new Map<Id, Opportunity>((List<Opportunity>)Records), null); 
        //DAOH_Opportunity.createLineItemGroup(new Map<Id, Opportunity>((List<Opportunity>)Records), null); 
        DAOH_Opportunity.submitUnvalidatedAccounts((List<Opportunity>)Records,null);
        DAOH_Opportunity.setFreezeUnfreezeOpp(new Map<Id, Opportunity>((List<Opportunity>)Records), null);    
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will set the sync fields with the latest changes
        DAOH_Opportunity.setMuleSoftSyncFields((List<Opportunity>)records, null);
        DAOH_Opportunity.updateSalesProgram((List<Opportunity>)Records, null);
        DAOH_Opportunity.logSaveTime((List<Opportunity>)Records, null);
        DAOH_Opportunity.addDefaultDrugProductforAvacare((List<Opportunity>)Records);
        DAOH_Opportunity.setSharing((List<Opportunity>)Records, null);
        if(Mulesoft_Integration_Control__c.getInstance() != null && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c == false){
            DAOH_Opportunity.addDefaultOLIAvacare((List<Opportunity>)Records);
        }
    } 
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Opportunity.createOutboundMessageDeletionQueue((List<Opportunity>)Records);
        DAOH_Opportunity.setParentNumber((List<Opportunity>)Records, null);
        //This is the section for OWF where all the methods that needs to be run in a normal sequence are included.
        //This section is enabled to run based on release version
        if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_OWF_OPP_Flow__c){
            
                DAOH_OWF_Opportunity.deleteAgreementBasedOnOpportunity((List<Opportunity>)Records);
        }
        
        //This is the section where all the methods that needs to be run at last are included.
    } 
    	
    public Boolean isChanged(String fieldName, sObject newRecord){
        sObject oldRecord = Trigger.oldMap != null ? Trigger.oldMap.get((Id)newRecord.get('id')) : null;
        if(oldRecord == null){
            return true;
        } 
        return oldRecord.get(fieldName) != newRecord.get(fieldName);
    }
    
    public override void onAfterDelete(){
        DAOH_Opportunity.updateSalesProgram((List<Opportunity>)Records, null);
    }
    
    public override void onAfterUndelete(){
        DAOH_Opportunity.updateSalesProgram((List<Opportunity>)Records, null);
    }
}