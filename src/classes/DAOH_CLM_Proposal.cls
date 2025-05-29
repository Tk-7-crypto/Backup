/*
* This class is used by CLM to update Proposal/Quote Object 
*/
public class DAOH_CLM_Proposal {

    /*
    * This method is used for updating related Agreement to be updated when budget type changes to Project Specific
    * @param List<Apttus_Proposal__Proposal__c> newProposalList
    * @param Map<Id, Apttus_Proposal__Proposal__c> oldMap
    * @param Boolean isRDSBudgetProposals
    */
    public static void updatePSAAGRForPSBudgetType(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        try {
            Map<Id, Apttus_Proposal__Proposal__c> mapOfAgrIdQuote = new Map<Id, Apttus_Proposal__Proposal__c>();
            List <Apttus__APTS_Agreement__c> listOfAgreementsToUpdate = new List <Apttus__APTS_Agreement__c>();
            Set<String> agreementFields = new Set<String>{'Id', 'Name', 'Apttus_QPComply__RelatedProposalId__c'};
            for(Apttus_Proposal__Proposal__c proposalObj : newProposalList) {
                if((proposalObj.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_PROJECT_SPECIFIC 
                    || proposalObj.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_CHANGE_ORDER)
                    && proposalObj.Apttus_QPComply__MasterAgreementId__c != null
                    && (oldMap.get(proposalObj.Id).Apttus_QPComply__MasterAgreementId__c != proposalObj.Apttus_QPComply__MasterAgreementId__c
                    || proposalObj.Select_Pricing_Tool__c != oldMap.get(proposalObj.Id).Select_Pricing_Tool__c
                    || proposalObj.Project_Expense__c != oldMap.get(proposalObj.Id).Project_Expense__c
                    || proposalObj.Actual_Quote_Amount__c != oldMap.get(proposalObj.Id).Actual_Quote_Amount__c)) {
                        mapOfAgrIdQuote.put(proposalObj.Apttus_QPComply__MasterAgreementId__c, proposalObj);
                    }
            }
           
            String conditionForAgreement = 'Id IN : agreementIds AND RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID 
                + '\' AND Apttus__Subtype__c IN (\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_WO+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA_SMALL_PROJECTS+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA_SMALL_PROJECTS+'\')'
                + ' AND Apttus__Status_Category__c IN (\'' + CON_CLM.REQUEST + '\', \'' + CON_CLM.IN_BUDGETING + '\', \'' + CON_CLM.IN_AUTHORING + '\', \'' + CON_CLM.IN_APPROVAL + '\' ,\'' + CON_CLM.IN_SIGNATURES + '\')';
            if (!mapOfAgrIdQuote.isEmpty()) {  
                List <Apttus__APTS_Agreement__c> listOfAgreements = new SLT_Agreement()
                    .getAgreementListByCondition(agreementFields, conditionForAgreement, mapOfAgrIdQuote.keySet());
                for(Apttus__APTS_Agreement__c agreement : listOfAgreements) {
                    if (mapOfAgrIdQuote.containsKey(agreement.Id)) {
                        setAGRFieldsFromProposal(agreement, mapOfAgrIdQuote.get(agreement.Id), 
                            mapOfAgrIdQuote.get(agreement.Id).Apttus_Proposal__Proposal_Category__c);
                        listOfAgreementsToUpdate.add(agreement);
                    }  
            	}
                updateAgreement(listOfAgreementsToUpdate);
            }
		}
        catch(Exception e) {
            UTL_CLM.logExceptionAndRaiseCommonError(newProposalList, e);
        }
    }      

    @testVisible
    private static void createRelatedAGRRecordsToReplicateAmend(Map<Id, Apttus__APTS_Agreement__c> mapOfIdAgreement) {
        List<Apttus__APTS_Related_Agreement__c> relatedAgreementList = new List<Apttus__APTS_Related_Agreement__c>();
        for(Id agreementId : mapOfIdAgreement.keySet()) {
            Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
            relatedAgreement.Apttus__APTS_Contract_From__c = agreementId;
            relatedAgreement.Apttus__APTS_Contract_To__c = mapOfIdAgreement.get(agreementId).Id;
            relatedAgreement.Apttus__Relationship_From_Type__c = CON_CLM.IS_AMENDED_BY;
            relatedAgreement.Apttus__Relationship_To_Type__c = CON_CLM.IS_AMENDMENT_FOR;
            relatedAgreement.Name = CON_CLM.CURRENT_AGREEMENT;
            relatedAgreementList.add(relatedAgreement);
        }

        if(!relatedAgreementList.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                Apttus__APTS_Related_Agreement__c.SObjectType
            });
            uow.registerNew(relatedAgreementList);
            uow.commitWork();            
        }
    }


    /*
    * This method is to set agreement fields from quote based on budget type and record type
    * @param Apttus__APTS_Agreement__c agreement
    * @param Apttus_Proposal__Proposal__c proposal
    * @param Boolean isRDSBudgetProposals
    * @param String budgetType
    * @param isUpdateForPrimary
    */
    @testVisible
    private static void setAGRFieldsFromProposal(Apttus__APTS_Agreement__c agreement, Apttus_Proposal__Proposal__c proposal, 
        String budgetType) {
        agreement.Apttus_QPComply__RelatedProposalId__c = proposal.Id;
        agreement.Select_Pricing_Tool__c = proposal.Select_Pricing_Tool__c;
        agreement.Project_Expenses__c = proposal.Project_Expense__c;
        agreement.Actual_Agreement_Value__c = proposal.Actual_Quote_Amount__c;
        if(budgetType == CON_CLM.PROPOSAL_CHANGE_ORDER) {
            agreement.CurrencyIsoCode = proposal.CurrencyIsoCode;
        }
    }

    /**
     * This method updates related agreement from null to value if agreement(Change Order) on opportunity is activated, 
     * then it should clone the agreement and creates amended agreement record(another change order)
     * @param newProposalList contains the list of proposal with latest values
     * @param oldMap contains the proposals with old values
     */
    public static void createCOAGRForCOQuote(List<Apttus_Proposal__Proposal__c> newProposalList) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal__c> mapOfOppIdAndProposal = new Map<Id, Apttus_Proposal__Proposal__c>();
        Set<Id> proposalIds = new Set<Id>();
        for(Apttus_Proposal__Proposal__c proposal : newProposalList) {
            if(proposal.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_CHANGE_ORDER) {
                opportunityIds.add(proposal.Apttus_Proposal__Opportunity__c);
                mapOfOppIdAndProposal.put(proposal.Apttus_Proposal__Opportunity__c, proposal);
                proposalIds.add(proposal.Id);
            }
        }
        if(!opportunityIds.isEmpty()) {
            Set<String> agreementFields = UTL_CLM.getSObjectTypeFields(Apttus__APTS_Agreement__c.SObjectType, false);
            Set<String> exclAgreementFields = UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.AGREEMENT_OBJECT_API_NAME);
            agreementFields.removeAll(exclAgreementFields);
            String conditionForAgreement = 'Apttus__Related_Opportunity__c IN : agreementIds AND RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID 
                + '\' AND Apttus__Status_Category__c=\'' + CON_CLM.IN_EFFECT 
                + '\' AND Apttus__Status__c IN (\'' + CON_CLM.ACTIVATED + '\',\''+ CON_CLM.BEING_AMENDED + '\')'; 
            List<Apttus__APTS_Agreement__c> listOfAgreements = new SLT_Agreement()
                .getAgreementListByCondition(agreementFields, conditionForAgreement, opportunityIds);
            if(!listOfAgreements.isEmpty()) {
                if(listOfAgreements.size() > 1){
                    if(!UTL_ExecutionControl.coEmailSent) {
                        sendEmailToQuoteOwner(proposalIds);
                    }
                }else {
                    updateFieldsWithRelatedAgreementForCOProposal(listOfAgreements, mapOfOppIdAndProposal, null, true);
                }
            }
        }
    }

    /**
     * This method is cloning the activated agreement and created a change order agreement along with this it sets the field
     * values to agreement from proposal
     * @param listOfAgreements contains the agreements which are going to be cloned into change order agreements.
     * @param proposalMap it is used in the case when related agreement field is blank for change order proposal otherwise it will be null.
     * @param mapOfAgrIdQuote is used when related agreement field is filled already in change order proposal.
     * @param isRDSBudgetProposals is true if proposal record type is RDS Budget otherwise false.
     */
    public static void updateFieldsWithRelatedAgreementForCOProposal(List<Apttus__APTS_Agreement__c> listOfAgreements, 
        Map<Id, Apttus_Proposal__Proposal__c> proposalsMap, Map<Id, Apttus_Proposal__Proposal__c> mapOfAgrIdQuote, Boolean isRDSBudgetProposals) {
        try {
            Map<Id, Apttus__APTS_Agreement__c> mapOfIdAgreement = new Map<Id, Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> listOfAgreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
            Set<String> fieldSet = new Set<String>{'Id', 'IQVIA_Business_Account_Manager__c',
            'Contract_Ranking__c', 'IQVIA_Project_Manager_Contact__c', 'Triage_Comments__c', 'Date_Tracking_started__c',
            'IQVIA_Supporting_Contract_Manager__c', 'OwnerId', 'IQVIA_Business_Account_Manager__r.Email','IQVIA_Business_Account_Manager__r.EmployeeNumber'};
            Set<String> bidFieldSet = new Set<String>{'Id', 'Contract_Ranking__c', 'Date_Tracking_started__c','OwnerId', 'Triage_Notes__c', 'Bid_History_Related_Opportunity__c'};
            Map<Id, Id> proposalToBidHistoryMap = new Map<Id, Id>();
            Map<Id, Bid_History__c> mapOfBidHistory = new Map<Id, Bid_History__c>();
            Set<String> agreementNumbers = new Set<String>();
            Map<String, Decimal> agreementNumberToAgreementsMap = 
                new Map<String, Decimal>();
            for(Apttus_Proposal__Proposal__c proposal : 
                (mapOfAgrIdQuote != null ? mapOfAgrIdQuote.values() : proposalsMap.values())) {
                if(proposal.Clinical_Bid__c != null) {
                    proposalToBidHistoryMap.put(proposal.Id, proposal.Clinical_Bid__c);
                }
            }
            if(!(proposalToBidHistoryMap.isEmpty())) {
                mapOfBidHistory = new SLT_Bid_History().getBidHistoriesById(new Set<Id>(proposalToBidHistoryMap.values()), bidFieldSet);
            }
            for(Apttus__APTS_Agreement__c agreement : listOfAgreements) {
                agreementNumbers.add(agreement.Apttus__Agreement_Number__c);
            }
            List<Apttus__APTS_Agreement__c> listOfRelatedAgreements = new SLT_Agreement().
                getAgreementListByAgreementNumbers(new Set<String>{'Id', 'Apttus__Agreement_Number__c', 'Apttus__Version_Number__c'}, agreementNumbers);
            for(Apttus__APTS_Agreement__c agreement : listOfRelatedAgreements) {
                String agreementNumber = agreement.Apttus__Agreement_Number__c;
                if(!agreementNumberToAgreementsMap.containsKey(agreementNumber)){
                    agreementNumberToAgreementsMap.put(agreementNumber,agreement.Apttus__Version_Number__c);
                }
            }
            for(Apttus__APTS_Agreement__c agreement : listOfAgreements) {
                Apttus__APTS_Agreement__c clonedAgreement = agreement.clone(false, true, false, false); 
                clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
                clonedAgreement.Agreement_Cloned_From__c = agreement.Id;
                if(agreementNumberToAgreementsMap.containsKey(agreement.Apttus__Agreement_Number__c)) {
                    clonedAgreement.Apttus__Version_Number__c = agreementNumberToAgreementsMap.get(agreement.Apttus__Agreement_Number__c) + 1;
                }
                clonedAgreement.Apttus__Status__c = CON_CLM.ASSIGNED;
                clonedAgreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
                clonedAgreement.Special_Terms_Included__c = '';
                clonedAgreement.Date_Tracking_Started__c = System.today();
                if(mapOfAgrIdQuote != null && mapOfAgrIdQuote.containsKey(agreement.Id)) {
                    setAGRFieldsFromProposal(clonedAgreement, mapOfAgrIdQuote.get(agreement.Id), CON_CLM.PROPOSAL_CHANGE_ORDER); 
                    if(!(mapOfBidHistory.isEmpty())) {
                        setAgreementFieldsFromProposalBidHistory(clonedAgreement, mapOfBidHistory.get
                            (proposalToBidHistoryMap.get(mapOfAgrIdQuote.get(agreement.Id).Id)));
                    }
                } else {
                    setAGRFieldsFromProposal(clonedAgreement, proposalsMap.get(agreement.Apttus__Related_Opportunity__c), 
                        CON_CLM.PROPOSAL_CHANGE_ORDER); 
                    if(!mapOfBidHistory.isEmpty()) {
                        setAgreementFieldsFromProposalBidHistory(clonedAgreement, mapOfBidHistory.get
                            (proposalToBidHistoryMap.get(proposalsMap.get(agreement.Apttus__Related_Opportunity__c).Id)));
                    }
                }
                if(agreement.Apttus__Version_Number__c == 0) {
                    clonedAgreement.Original_Agreement__c = agreement.Id;
                }
                clonedAgreement.Confidence_In_Approval_Of_Budget_Draft__c = 'Low';
                mapOfIdAgreement.put(agreement.Id, clonedAgreement);
                agreement.Apttus__Status__c = CON_CLM.BEING_AMENDED;
                agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
                listOfAgreementsToBeUpdated.add(agreement);
                if(proposalsMap != null) {
                    break;
                }
            }
            UTL_ExecutionControl.stopTriggerExecution = true;
            UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed = true;
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__APTS_Agreement__c.SObjectType
                }
            );

            if(!mapOfIdAgreement.isEmpty()) {
                uow.registerNew(mapOfIdAgreement.values());
            }
            if(!listOfAgreementsToBeUpdated.isEmpty()) {
                uow.registerDirty(listOfAgreementsToBeUpdated);
            }
            if(!mapOfIdAgreement.isEmpty() || !listOfAgreementsToBeUpdated.isEmpty()) {
                uow.commitWork();
            }
            if(!mapOfIdAgreement.isEmpty()) {
                createRelatedAGRRecordsToReplicateAmend(mapOfIdAgreement);
                UTL_CLM.createActivityOnAmend(mapOfIdAgreement.values());
            }
            UTL_ExecutionControl.stopTriggerExecution = false;
            UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed = false;
        }
        catch(Exception e) {
            UTL_CLM.logExceptionAndRaiseCommonError(mapOfAgrIdQuote != null ? mapOfAgrIdQuote.values() : 
                proposalsMap.values(), e);
        }
    }

    /*
    * This method is to perform DML on agreement list
    * @param Apttus__APTS_Agreement__c agreement
    */
    @testVisible
    private static void updateAgreement(List<Apttus__APTS_Agreement__c> listOfAgreementsToUpdate) {
        if(listOfAgreementsToUpdate!= null && !listOfAgreementsToUpdate.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__APTS_Agreement__c.SObjectType
                }
            );
            uow.registerDirty(listOfAgreementsToUpdate);
            uow.commitWork();
        }
    }

    
    /**
     * This method is to set agreement fields from Related Bid History of Quote
     * @param newAgreementRecord is new agreement extension for cloned Change Order Agreement
     * @param bidHistory is related Bid History of quote
     */
    @testVisible
    private static void setAgreementFieldsFromProposalBidHistory(Apttus__APTS_Agreement__c clonedAgreement, 
        Bid_History__c bidHistory) {
        if(bidHistory != null) {
            clonedAgreement.Bid_History__c = bidHistory.Id;
            clonedAgreement.Contract_Ranking__c = bidHistory.Contract_Ranking__c;
            clonedAgreement.Triage_Notes__c = bidHistory.Triage_Notes__c;
            clonedAgreement.Date_Tracking_started__c = bidHistory.Date_Tracking_started__c;
            clonedAgreement.OwnerId = bidHistory.OwnerId;
            clonedAgreement.Apttus__Requestor__c = bidHistory.OwnerId;
        }
    }

    /**
     * This method is to set related agreement currency field from quote
     * @param List<Apttus_Proposal__Proposal__c> newProposalList
     * @param Map<Id, Apttus_Proposal__Proposal__c> oldMap
     */
    public static void updateAgreementCurrencyFromQuote(List<Apttus_Proposal__Proposal__c> newProposalList, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        try {
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> agreementListToUpdate = new List<Apttus__APTS_Agreement__c>();
            Set<String> agreementFieldsSet = new Set<String>{'Id', 'CurrencyIsoCode', 'Record_Type_Developer_Name__c', 'Apttus_QPComply__RelatedProposalId__c', 'Apttus__Subtype__c'};
            String agreementCondition = 'Apttus_QPComply__RelatedProposalId__c IN : quoteIds';
            Set<Id> rdsProposalIdSet = new Set<Id>();
            Map<Id, Apttus_Proposal__Proposal__c> rdsProposalMap = new Map<Id, Apttus_Proposal__Proposal__c>(newProposalList);

            for(Apttus_Proposal__Proposal__c proposalRecord : newProposalList) {
                if(oldMap.get(proposalRecord.Id) != null && oldMap.get(proposalRecord.Id).CurrencyIsoCode != proposalRecord.CurrencyIsoCode){
                    rdsProposalIdSet.add(proposalRecord.Id);
                }
            }
            if(!rdsProposalIdSet.isEmpty()) {
                agreementList = new SLT_Agreement().getAgreementListByQuoteId(rdsProposalIdSet, agreementFieldsSet, agreementCondition);
            }  
            for(Apttus__APTS_Agreement__c agreementRecord : agreementList) {
                Apttus_Proposal__Proposal__c relatedQuote = rdsProposalMap.get(agreementRecord.Apttus_QPComply__RelatedProposalId__c);
                if((relatedQuote.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_PROJECT_SPECIFIC && agreementRecord.Record_Type_Developer_Name__c == CON_CLM.PSA_RECORD_TYPE_NAME) 
                    || (relatedQuote.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_PRELIMINARY && agreementRecord.Record_Type_Developer_Name__c == CON_CLM.PA_RECORD_TYPE_NAME) 
                    || (relatedQuote.Apttus_Proposal__Proposal_Category__c == CON_CLM.PROPOSAL_CHANGE_ORDER && agreementRecord.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER)
                    && relatedQuote.CurrencyIsoCode != agreementRecord.CurrencyIsoCode) {
                    agreementRecord.CurrencyIsoCode = relatedQuote.CurrencyIsoCode;
                    agreementListToUpdate.add(agreementRecord);
                }
            }
            UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed = true;
            if(!agreementListToUpdate.isEmpty()) {
                updateAgreement(agreementListToUpdate);
            }
            UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed = false;
        }
        catch(Exception e) {
            UTL_CLM.logExceptionAndRaiseCommonError(newProposalList, e);
        }
    }

    /**
     * sendEmailToQuoteOwner method notifies the Quote Owner That Change Order can not be created.
     */
    @testVisible
    private static void sendEmailToQuoteOwner(Set<Id> proposalIds){
        Set<String> proposalFields = new Set<String>{'Id', 'OwnerId', 'Owner.Email'};
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        if(!proposalIds.isEmpty()) {
            List<Apttus_Proposal__Proposal__c> quoteList = new SLT_Proposal().getProposalFieldsById(proposalIds, proposalFields);
            List<EmailTemplate> lstEmailTemplate = new SLT_EmailTemplate()
                .selectEmailTemplatesByDeveloperNames(new Set<String>{CON_CLM.No_CHANGE_ORDER_CREATE_EMAIL_TEMPLATE});
            for(Apttus_Proposal__Proposal__c quote : quoteList) {
                Messaging.SingleEmailMessage objSingleEmailMessage = Messaging.renderStoredEmailTemplate(lstEmailTemplate[0].Id, NULL,quote.Id);    
                mailList.add(UTL_CLM.createSingleEmailMessage(new List<String>{quote.Owner.Email}, objSingleEmailMessage.getSubject(), objSingleEmailMessage.getHTMLBody(), null, null, null));
            }
        }
        if(!mailList.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);            
        }
    }

    /**
    * This method is unit of work
    * @params  lstWorkflowEmailRecs
    * @return  void
    */
    @testVisible
    private static void insertWorkflowEmailRecordList(List<Workflow_Email_Record__c> lstWorkflowEmailRecs) {
        try {  
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Workflow_Email_Record__c.SObjectType
                }
            );
            uow.registerNew(lstWorkflowEmailRecs);
            uow.commitWork();
        } catch(DMLException dmlExp) {
            System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
        }
    }
}