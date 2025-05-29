/**
 * This is Quote/Proposal trigger handler class.
 * version : 1.0 
 */
public class DAO_Proposal extends fflib_SObjectDomain
{    
    /**
     * Constructor of this class
     * @params sObjectList List<Apttus_Proposal__Proposal__c>
     */
    public DAO_Proposal(List<Apttus_Proposal__Proposal__c> sObjectList)
    {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new DAO_Proposal(sObjectList);
        }
    }

    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork
    (
        new Schema.SObjectType[] 
        {
            Outbound_Message_Deletion_queue__c.SobjectType
        }
    );
    
    public override void onApplyDefaults() {}

    /**
     * This method is used for before insert of the Quote/Proposal trigger.
     * @return void
     */
    public override void onBeforeInsert() 
    {
        List<Apttus_Proposal__Proposal__c> sfProposalRecords = DAOH_Proposal.getRDSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> nonSFProposalRecords = DAOH_Proposal.getRDSNonSFProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> techSolutionProposalRecords = DAOH_Proposal.getTSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        DAOH_Proposal.setAccountCountry((List<Apttus_Proposal__Proposal__c>)Records, null);
        DAOH_Proposal.setLastSharingCalculationTimestamp((List<Apttus_Proposal__Proposal__c>)Records, null); 
        if (sfProposalRecords.size() > 0) {
            DAOH_Proposal.setBudgetFields(sfProposalRecords, null);
            DAOH_Proposal.setNumberFormatForBudget(sfProposalRecords, null);
        }
        if (nonSFProposalRecords.size() > 0 || sfProposalRecords.size() > 0) {
            List<Apttus_Proposal__Proposal__c> allSFNonSFProposalRecords = new List<Apttus_Proposal__Proposal__c>();
            allSFNonSFProposalRecords.addAll(nonSFProposalRecords);
            allSFNonSFProposalRecords.addAll(sfProposalRecords);
            DAOH_Proposal.setBudgetName(allSFNonSFProposalRecords);   
            DAOH_Proposal.updateRelatedAgreement(allSFNonSFProposalRecords, null);
            DAOH_Proposal.setBudgetLink(allSFNonSFProposalRecords, null);
            DAOH_Proposal.handleCNFLinking(allSFNonSFProposalRecords, null);
        }
        if (techSolutionProposalRecords.size() > 0) {
            DAOH_Proposal.setProposalAddress(techSolutionProposalRecords, null);
        }
    }
    
    /**
     * This method is used for after insert of the Quote/Proposal trigger.
     * @return void
     */
    public override void onAfterInsert() 
    {
        List<Apttus_Proposal__Proposal__c> sfProposalRecords = DAOH_Proposal.getRDSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> nonSFProposalRecords = DAOH_Proposal.getRDSNonSFProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> techSolutionProposalRecords = DAOH_Proposal.getTSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        //This is the section where all the methods that needs to be run at first are included.
        DAOH_Proposal.setDummyCreatorAccess((List<Apttus_Proposal__Proposal__c>)records);
        if (sfProposalRecords.size() > 0) {
            DAOH_Proposal.cloneBudgetAttachment(sfProposalRecords);
            DAOH_Proposal.removeInitialOrRebidRelatedAgreement(sfProposalRecords);
            DAOH_Proposal.createTeamMemberForPL(sfProposalRecords, null);
            
            //CLM Methods Calling for RDS_Budget Records
            DAOH_CLM_Proposal.createCOAGRForCOQuote(sfProposalRecords);
        }
        
        if (nonSFProposalRecords.size() > 0) {
            //CLM Methods Calling for RDS_Non_SF Records
            DAOH_CLM_Proposal.createCOAGRForCOQuote(nonSFProposalRecords);
        }
        
        if (nonSFProposalRecords.size() > 0 || sfProposalRecords.size() > 0) {
            List<Apttus_Proposal__Proposal__c> allSFNonSFProposalRecords = new List<Apttus_Proposal__Proposal__c>();
            allSFNonSFProposalRecords.addAll(nonSFProposalRecords);
            allSFNonSFProposalRecords.addAll(sfProposalRecords);
            DAOH_Proposal.updateGenericContract(allSFNonSFProposalRecords);
            DAOH_Proposal.handleCNFLinking(allSFNonSFProposalRecords, null);
            for (Apttus_Proposal__Proposal__c budget : allSFNonSFProposalRecords) {

                if (budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || budget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK) 
                {
                    ID jobID = System.enqueueJob(new QUE_CPQ_BudgetBoxFoldersJob(records));
                }
            }
        }
        
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will implement the sharing
        DAOH_Proposal.setSharing((List<Apttus_Proposal__Proposal__c>)Records, null);
    }
    
    /**
     * This method is used for before update of the Quote/Proposal trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) 
    {
        List<Apttus_Proposal__Proposal__c> sfProposalRecords = DAOH_Proposal.getRDSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> nonSFProposalRecords = DAOH_Proposal.getRDSNonSFProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> TSProposalRecords = DAOH_Proposal.getTSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        DAOH_Proposal.setLastManualSharingFieldUpdate((List<Apttus_Proposal__Proposal__c>)Records,null);
        DAOH_Proposal.setAccountCountry((List<Apttus_Proposal__Proposal__c>)Records, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        DAOH_Proposal.setLastSharingCalculationTimestamp((List<Apttus_Proposal__Proposal__c>)Records, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        if (sfProposalRecords.size() > 0) {
            DAOH_Proposal.setXAELockTimeStamp(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.validateLineItemCount(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.moveToPresentedStage(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);	 
            DAOH_Proposal.setNumberFormatForBudget(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            /* Commented under LC-11450
            DAOH_Proposal.setBudgetStatus(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            */
            DAOH_Proposal.setBudgetAmountFields(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        }
        if (nonSFProposalRecords.size() > 0 || sfProposalRecords.size() > 0) {
            List<Apttus_Proposal__Proposal__c> allSFNonSFProposalRecords = new List<Apttus_Proposal__Proposal__c>();
            allSFNonSFProposalRecords.addAll(nonSFProposalRecords);
            allSFNonSFProposalRecords.addAll(sfProposalRecords);
            DAOH_Proposal.validationOnInactiveBudgets(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.resetCNFBudgetStatus(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.setBudgetLink(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.resetCOLinkingFromRejectedCNF(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.handleCNFLinking(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        }
        if (TSProposalRecords.size() > 0 ) {
            DAOH_Proposal.setAmount(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.setStageGeneratedToApproved(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.setPriceList(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.setProposalAddress(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        }
        DAOH_Proposal.setAcceptedDate((List<Apttus_Proposal__Proposal__c>)Records, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
    }
    
    /**
     * This method is used for after update of the Quote/Proposal trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) 
    {
        List<Apttus_Proposal__Proposal__c> sfProposalRecords = DAOH_Proposal.getRDSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> nonSFProposalRecords = DAOH_Proposal.getRDSNonSFProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        List<Apttus_Proposal__Proposal__c> TSProposalRecords = DAOH_Proposal.getTSProposalRecords((List<Apttus_Proposal__Proposal__c>)Records);
        
        if (sfProposalRecords.size() >0) {
            DAOH_Proposal.createAdminTimeEntryData(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.updateBidHistoryAndOLI(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            
            //CLM Methods Calling for RDS_Budget Records
            DAOH_CLM_Proposal.updatePSAAGRForPSBudgetType(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_CLM_Proposal.updateAgreementCurrencyFromQuote(sfProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        }
        
        if (nonSFProposalRecords.size() > 0) {
            //CLM Methods Calling for RDS_Non_SF Records
            DAOH_CLM_Proposal.updatePSAAGRForPSBudgetType(nonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_CLM_Proposal.updateAgreementCurrencyFromQuote(nonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);  
        }
        if (TSProposalRecords.size() > 0 ) {
            DAOH_Proposal.setUSDAmount(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
            DAOH_Proposal.setPriceListOnCartAndLineItems(TSProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        }
        if (sfProposalRecords.size() > 0 || nonSFProposalRecords.size() > 0) {
            List<Apttus_Proposal__Proposal__c> allSFNonSFProposalRecords = new List<Apttus_Proposal__Proposal__c>();
            allSFNonSFProposalRecords.addAll(nonSFProposalRecords);
            allSFNonSFProposalRecords.addAll(sfProposalRecords);
            DAOH_Proposal.handleCNFLinking(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords); 
            DAOH_Proposal.updateContractPostAwardBidDate(allSFNonSFProposalRecords, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords); 																																 
        }
        DAOH_Proposal.setSharing((List<Apttus_Proposal__Proposal__c>)Records, (Map<Id, Apttus_Proposal__Proposal__c>)existingRecords);
        
    }
	
    /**
     * This method is used for before Delete of the Quote/Proposal trigger.
     * @return void
     */
    public override void onBeforeDelete() {}
	
    /**
     * This method is used for after Delete of the Quote/Proposal trigger.
     * @return void
     */
    public override void onAfterDelete() {}
}
