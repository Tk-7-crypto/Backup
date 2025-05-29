global class CPQ_ProposalLifecycle extends Apttus_Proposal.AbstractQuoteLifecycleCallback {

    global override void afterClone(Apttus_Proposal__Proposal__c originalSO, Apttus_Proposal__Proposal__c cloneSO) {
        cloneSO.Apttus_Proposal__RelatedProposalId__c = originalSO.Id;
    }
	
     /**
     * Callback invoked after an agreement is created from a quote/proposal
     * @param quoteSO the quote sobject 
     * @param agreementSO the new agreement sobject 
     */
    
    global override void afterCreateAgreement(Apttus_Proposal__Proposal__c quoteSO, Apttus__APTS_Agreement__c agreementSO) {
        if(agreementSO.RecordTypeId == CON_CLM.AMESA_RECORDTYPEID) {
            UTL_CLM.setAgreementFields(quoteSO,agreementSO);
        }
    }
}