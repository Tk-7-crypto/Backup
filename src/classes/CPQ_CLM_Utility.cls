public class CPQ_CLM_Utility {
    
    /* Written Under LC-8263 CLM-CPQ Alignment
    * This Method is used to Update Quote Stage as Accepted when Related Agreement is moved to Activated/In-Effect Status
    * param Id proposalId contains the proposal record Id which need to be update.
    * Will retrun error message during Quote Accepted Process if any else return blank value as string.
    * @param Map<Id, Date> proposalIdMap 
    * @param Boolean isActivated
    * @return Map<Id, List<String>> 
    */
    public static Map<Id, List<String>> acceptQuoteOnAgreementActivation(Map<Id, Apttus__APTS_Agreement__c> proposalIdMap, Boolean isActivated) {
        Set<Id> setOfProposalId = new Set<Id>();
        String status = CON_CPQ.BLANK; 
        Map<Id, List<String>> statusOnQuoteAcceptance = new Map<Id, List<String>>();
        List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalsById(proposalIdMap.keySet(), new Set<String> {CON_CPQ.ID, 
            CON_CPQ.APPROVAL_STAGE, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.FIELD_FINALIZE_DATE, CON_CPQ.APTTUS_PROPOSAL_PRIMARY,
            CON_CPQ.EXECUTED_DATE, CON_CPQ.RECORDTYPE_DEVELOPER_NAME, CON_CPQ.APPROVAL_STATUS, CON_CPQ.RELATED_OPPORTUNITY_STAGENAME,
            CON_CPQ.RELATED_AGREEMENT_STATUS_CATEGORY, CON_CPQ.RELATED_AGREEMENT_STATUS});
        if(!proposalList.isEmpty()) {
            for(Apttus_Proposal__Proposal__c proposal : proposalList) {
                status = '';
                Apttus__APTS_Agreement__c agreement = proposalIdMap.get(proposal.Id);
                Boolean oppStage = !CON_CPQ.OPPORTUNITY_STAGES.contains(proposal.Apttus_Proposal__Opportunity__r.StageName) && proposal.Apttus_Proposal__Opportunity__r.StageName != CON_CPQ.OPPORTUNITY_STAGE_7B_CLOSED_LOST;
                if(!statusOnQuoteAcceptance.containsKey(proposal.Id)) {
                    statusOnQuoteAcceptance.put(proposal.Id, new List<String>());
                }
                if(agreement != null && proposal.Apttus_QPComply__MasterAgreementId__c != agreement.Id) {
                    status = 'Agreement and Quote linkage is not correct, Agreement "Proposal/Quote" and Proposal "Related Agreement" field should be in sync';
                    statusOnQuoteAcceptance.get(proposal.Id).add(status);
                }
                if((proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                    || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER 
                    || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY)
                    && proposal.Apttus_Proposal__Approval_Stage__c != CON_CPQ.ACCEPTED) {
                    if (!oppStage) {
                        status = 'The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.';
                        statusOnQuoteAcceptance.get(proposal.Id).add(status);
                    }
                    if(isActivated && proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER &&
                        proposal.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.AGREEMENT_STATUS_CATEGORY_IN_EFFECT &&
                        proposal.Apttus_QPComply__MasterAgreementId__r.Apttus__Status__c != CON_CPQ.AGREEMENT_STATUS_ACTIVATED) {
                        status = 'There is no activated Change Order Agreement associated with this Quote so it could not be marked as Accepted. Please ensure the related Change Order Agreement is Activated before Accepting the Quote.';
                        statusOnQuoteAcceptance.get(proposal.Id).add(status);
                    }
                    if (proposal.RecordType.DeveloperName == CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET) {
                        if (proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c == null) {
                            status = 'Please Finalize the Budget.';
                            statusOnQuoteAcceptance.get(proposal.Id).add(status);
                        }
                    }
                    if (isActivated && agreement != null && agreement.Apttus__Other_Party_Signed_Date__c != null) {
                        proposal.Executed_Date__c = agreement.Apttus__Other_Party_Signed_Date__c;
                    }
                    if (isActivated && proposal.RecordType.DeveloperName == CON_CPQ.RDS_NON_SF) {                       
                        if (proposal.Executed_Date__c == null) {
                            status = 'Please enter the “Executed Date” to move to Accepted Stage.';
                            statusOnQuoteAcceptance.get(proposal.Id).add(status);
                        }
                    }
                    if (isActivated && String.isBlank(status)) { 
                        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
                        proposal.Approval_Status__c = CON_CPQ.DOCUMENT_PRESENTED;
                        updateProposalList.add(proposal);
                        if (proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER) {
                            setOfProposalId.add(proposal.Id);
                        }
                    }
                }
            }
        }
        if(!updateProposalList.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                Apttus_Proposal__Proposal__c.SObjectType
            });
            uow.registerDirty(updateProposalList);
            uow.commitWork();
            if (setOfProposalId.size() > 0) {
                CPQ_Utility.syncProtocolNumberOnOpp(setOfProposalId);
            }          
        }
        return statusOnQuoteAcceptance;
    }
    
    /* Written Under LC-7070 CLM-CPQ Alignment
     * This Method is used to Update Quote Stage as Cancelled when Related Agreement is Cancelled.
     * param Id proposalId contains the proposal record Id which need to be update.
     * Will retrun error message during Quote Cancelled Process if any else return blank value as string.
     * Update latest Quote of the previous Agreement & set it to primary Quote if any.
     */
    
    public static void cancelQuoteOnAgreementCancellation(Set<Id> proposalIdSet) {
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalsById(proposalIdSet, new Set<String> {CON_CPQ.ID, 
            CON_CPQ.APPROVAL_STAGE, CON_CPQ.APPROVAL_STATUS, CON_CPQ.PROPOSAL_CATEGORY});
        if(proposalList.size()>0) {
            for(Apttus_Proposal__Proposal__c proposal:proposalList) {
                if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC
                    || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER 
                    || proposal.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PRELIMINARY) {
                    proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.CANCELLED;
                    proposal.Approval_Status__c = CON_CPQ.CANCELLED;
                }  
            } 
            update proposalList; 
        }  
    }
    public static Map<Id, List<String>> acceptIqviaQuoteOnAgreementActivation(Map<Id, SObject> quoteIdMap, Boolean isActivated) {
        Set<Id> setOfQuoteId = new Set<Id>();
        String status = CON_CPQ.BLANK; 
        Map<Id, List<String>> statusOnQuoteAcceptance = new Map<Id, List<String>>();
        List<Quote__c> updateQuoteList = new List<Quote__c>();
        List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuoteIdslist(quoteIdMap.keySet(), new Set<String> {CON_CPQ.ID, 
            CON_CPQ.QUOTE_APPROVAL_STAGE, CON_CPQ.QUOTE_TYPE, CON_CPQ.FINALIZED_DATE,
            CON_CPQ.EXECUTED_DATE, CON_CPQ.GBU, CON_CPQ.RELATED_OPPORTUNITY_STAGE_NAME});
        if (!quoteList.isEmpty()) {
            for (Quote__c quote : quoteList) {
                status = '';
                SObject agreement = quoteIdMap.get(quote.Id);
                Boolean oppStage = !CON_CPQ.OPPORTUNITY_STAGES.contains(quote.Related_Opportunity__r.StageName) && quote.Related_Opportunity__r.StageName != CON_CPQ.OPPORTUNITY_STAGE_7B_CLOSED_LOST;
                if (!statusOnQuoteAcceptance.containsKey(quote.Id)) {
                    statusOnQuoteAcceptance.put(quote.Id, new List<String>());
                }
                if ((quote.Quote_Type__c == CON_CPQ.PROJECT_SPECIFIC || quote.Quote_Type__c == CON_CPQ.CHNAGE_ORDER ) && quote.Approval_Stage__c != CON_CPQ.ACCEPTED) {
                    if (!oppStage) {
                        status = 'The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.';
                        statusOnQuoteAcceptance.get(quote.Id).add(status);
                    }
                    if (quote.GBU__c == CON_CPQ.GBU_RDS_SF && quote.Finalized_Date__c == null) {
                        status = 'Please Finalize the Budget.';
                        statusOnQuoteAcceptance.get(quote.Id).add(status);
                    }
                    if (isActivated && agreement != null && (Date)agreement.get('Apttus__Other_Party_Signed_Date__c') != null) {
                        quote.Executed_Date__c = (Date)agreement.get('Apttus__Other_Party_Signed_Date__c');
                    }
                    if (isActivated && quote.GBU__c == CON_CPQ.GBU_RDS_NON_SF && quote.Executed_Date__c == null) {
                        status = 'Please enter the “Executed Date” to move to Accepted Stage.';
                        statusOnQuoteAcceptance.get(quote.Id).add(status);
                    }
                    if (isActivated && String.isBlank(status)) { 
                        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
                        updateQuoteList.add(quote);
                        setOfQuoteId.add(quote.Id);
                        
                    }
                }
            }
        }
        if (!updateQuoteList.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                Quote__c.SObjectType
            });
            uow.registerDirty(updateQuoteList);
            uow.commitWork();
            if (setOfQuoteId.size() > 0) {
                CPQ_Utility.syncProtocolNumberOnOpp(setOfQuoteId);
            }          
        }
        return statusOnQuoteAcceptance;
    }
    
    public static void cancelIqviaQuoteOnAgreementCancellation(Set<Id> quoteIdSet) {
        List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuoteIdslist(quoteIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.QUOTE_APPROVAL_STAGE, CON_CPQ.QUOTE_TYPE});
        if (quoteList.size()>0) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                Quote__c.SObjectType
            });
            for (Quote__c quote:quoteList) {
                if (quote.Quote_Type__c == CON_CPQ.PROJECT_SPECIFIC || quote.Quote_Type__c == CON_CPQ.CHNAGE_ORDER ) {
                    quote.Approval_Stage__c = CON_CPQ.CANCELLED;
                }  
            }
            uow.registerDirty(quoteList);
            uow.commitWork();
        }  
    }
}