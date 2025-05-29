public with sharing class CNT_CPQ_QuoteWorkflow {
    private static final String EMEA_BUSINESS_UNIT = 'EMEA Region All';

    @AuraEnabled(cacheable=true)
    public static IQVIA_CPQ_QuoteDetails getQuoteDetails(Id recordId) {
        List<String> assignedPermissionsetNameList = new List<String>();
        Map<String, String> flowNameByPricingToolMap = new Map<String, String>();
        Map<String, String> congaQuoteIdByPricingToolMap = new Map<String, String>();
        List<String> availableOutsideToolList = new List<String>();
        List<String> availableCongaToolList = new List<String>();
        Map<Id, String> idToStageMap = new Map<Id, String>();
        Set<String> completeConsentfieldSet = new Set<String>{'Document_Type__c', 'License_Type__c'};
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Related_Bid__c', 'Primary__c', 'Pricing_Tools__c', 'Approval_Stage__c', 'GBU__c', 'Related_Opportunity__c', 'OwnerId', 'Approver_1__c', 'Approver_2__c', 'Approver_3__c', 'Approver_4__c', 'Approver_5__c', 'Selected_Languages__c', 'CurrencyIsoCode', 'Related_Quote__c', 'Scenario__c', 'Aggregate_Discount_Percent__c', 'Discount_Reason__c', 'Quote_Type__c', 'Is_Cloned__c', 'Conversion_Rate__c','priority__c', 'Related_Opportunity__r.CreatedDate'};
        Map<String, String> toolToPathway = new Map<String, String>();
        for (PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()]) {
            assignedPermissionsetNameList.add(psa.PermissionSet.Name);
            if (psa.PermissionSet.name == CON_CPQ.DPS_Permission_Set) {
                fieldSet.addAll(completeConsentfieldSet);
            }
        }
        Quote__c quote = new SLT_IQVIA_Quote().getQuoteId(recordId, fieldSet);
        List<Quote__c> childQuotes = new SLT_IQVIA_Quote().getQuotesByCondition(new Set<String>{CON_CPQ.ID}, 'Related_Quote__c IN: relatedOpportunityIdSet', new Set<Id>{recordId});

        for (CPQ_Proposal_Create_Settings__c customSetting : [SELECT GBU__c, Available_Pricing_Tools__c, Permission_Set_Name__c, Conga_Setup__c, Flow_Name__c, Pathway__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN: quote.Pricing_Tools__c.split(';')]) {
            if (customSetting.Available_Pricing_Tools__c != null) {
                if (customSetting.Conga_Setup__c) {
                    if (assignedPermissionsetNameList.contains(customSetting.Permission_Set_Name__c)) {
                        flowNameByPricingToolMap.put(customSetting.Available_Pricing_Tools__c, customSetting.Flow_Name__c);
                    }
                    availableCongaToolList.add(customSetting.Available_Pricing_Tools__c);
                } else {
                    availableOutsideToolList.add(customSetting.Available_Pricing_Tools__c);
                }
                toolToPathway.put(customSetting.Available_Pricing_Tools__c, customSetting.Pathway__c);
            }
        }
        String checkCongaAccess = CPQ_QuoteUtility.checkPathway(availableCongaToolList);
        if (checkCongaAccess == CON_CPQ.HASCONGAACCESS)  {
            String condition = 'Select_Pricing_Tool__c IN :pricingToolIds AND IQVIA_Quote__c = \'' + recordId + '\'';        
            for (Apttus_Proposal__Proposal__c proposal: new SLT_Proposal().getProposalByPricingToolIds(flowNameByPricingToolMap.keySet(), condition, new Set<String>{CON_CPQ.ID, CON_CPQ.APPROVAL_STAGE, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL})) {
                congaQuoteIdByPricingToolMap.put(proposal.Select_Pricing_Tool__c, proposal.Id);
                idToStageMap.put(proposal.Id, proposal.Apttus_Proposal__Approval_Stage__c);
            }
        }
        IQVIA_CPQ_QuoteDetails quoteObj = new IQVIA_CPQ_QuoteDetails();
        
        try {
            if (quote != null) {
                if (childQuotes.size() >0) {
                    quoteObj.quoteHasChildQuote = true;
                }
                quoteObj.hasPermissionForSalesWithPSA = assignedPermissionsetNameList.contains('Sales_with_PSA') ? true : false;
                CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
                if (quote.related_Opportunity__r.CreatedDate < cpqSetting.EMEA_Phase_2_Go_Live__c) {
                    quoteObj.hasPermissionForSalesWithPSA = false; 
                }
                quoteObj.haveCongaPermission = CPQ_QuoteUtility.checkCongaPermission();
                quoteObj.checkPathway = checkCongaAccess;
                quoteObj.haveCongaCLMPermission = CPQ_QuoteUtility.checkCongaCLMPermission();
                quoteObj.Name = quote.Name;
                quoteObj.bidHistoryId = quote.Related_Bid__c;
                quoteObj.approvalStage = quote.Approval_Stage__c;
                quoteObj.gbu = quote.GBU__c;
                quoteObj.quoteType = quote.Quote_Type__c;
                quoteObj.selectedPricingTools = quote.Pricing_Tools__c;
                quoteObj.opportunityId = quote.Related_Opportunity__c;
                quoteObj.idToStageMap = idToStageMap;
                quoteObj.conversionRate = quote.Conversion_Rate__c;
                quoteObj.priority = quote.priority__c;						  
                if (quote.Selected_Languages__c != null) {
                    List<String> selectedLanguages = quote.Selected_Languages__c.split(';');
                    selectedLanguages.sort();
                    quoteObj.selectedLanguages = String.join(selectedLanguages, ';');
                }
                quoteObj.currencyIsoCode = quote.CurrencyIsoCode;
                quoteObj.isPrimary = quote.Primary__c;
                quoteObj.isSpecial = ((quote.GBU__c == CON_CPQ.GBU_RDS_SF || quote.GBU__c == CON_CPQ.GBU_RDS_NON_SF) && ([SELECT id FROM GroupMember WHERE Group.DeveloperName = 'CPQ_Admin_Users_for_Inactive_Quotes' AND UserOrGroupId =: UserInfo.getUserId() LIMIT 1].size() == 0 || quote.Primary__c)) ? false : true;
                quoteObj.relatedQuote = quote.Related_Quote__c;
                quoteObj.Scenario = quote.Scenario__c;
                quoteObj.aggregateDiscount = quote.Aggregate_Discount_Percent__c;
                quoteObj.discountReason = quote.Discount_Reason__c;
                if (quote.Pricing_Tools__c.contains(CON_CPQ.COMPLETE_CONSENT)) {
                    quoteObj.LicenseType = quote.License_Type__c;
                    quoteObj.DocumentType = quote.Document_Type__c;
                }
                if (congaQuoteIdByPricingToolMap.size() > 0) {
                    for (String pricingTool: flowNameByPricingToolMap.keySet()) {
                        if (quote.Pricing_Tools__c.contains(pricingTool)) {
                            quoteObj.pricingTools = quoteObj.pricingTools != null ? quoteObj.pricingTools + '&&' + pricingTool : pricingTool;
                        }
                    }
                    quoteObj.flowNameByPricingToolMap = flowNameByPricingToolMap;
                    quoteObj.congaQuoteIdByPricingToolMap = congaQuoteIdByPricingToolMap;
                }
                quoteObj.toolToPathway = toolToPathway;
                quoteObj.availableOutsideToolList = availableOutsideToolList;
                quoteObj.availableCongaToolList = availableCongaToolList;
                if (quote.Approval_Stage__c == CON_CPQ.PENDING_APPROVAL) {
                    quoteObj.isOwner = UserInfo.getUserId() == quote.OwnerId ? true : false;
                    ProcessInstance[] processInstance = [
                        SELECT Id, TargetObjectId, (
                            SELECT Id, StepStatus, ActorId, Comments, Actor.name
                            FROM StepsAndWorkitems 
                            WHERE StepStatus = 'Pending' and TargetObjectId = :quote.Id
                        ) FROM ProcessInstance
                        WHERE TargetObjectId = :quote.Id AND Status = 'Pending'
                    ];
                    Set<String> actorIds = new Set<String>();
                    for (ProcessInstance instance : processInstance) {
                        for (ProcessInstanceHistory history :instance.StepsAndWorkitems ) {
                            actorIds.add(history.actorId);
                        }
                    }
                    List<ProcessInstanceWorkitem> piwList1 = getProcessInstanceWorkItems(quote, actorIds);
                    if (piwList1.size() > 0) {
                        quoteObj.haveApprovalItems = true;
                        quoteObj.approverDetails = JSON.serialize(getApproverDetails(recordId, quote, piwList1));
                        if (FeatureManagement.checkPermission('Access_To_Approve_Quote')) {
                            quoteObj.hasReassignAccess = true;
                        }
                    }				 
                    List<ProcessInstanceWorkitem> piwList = getProcessInstanceWorkItems(quote, new Set<String>{UserInfo.getUserId()});
                    if (piwList.size() > 0) {
                        quoteObj.haveApprovalItems = true;
                        quoteObj.isApprover = true;
                        quoteObj.approverDetails = JSON.serialize(getApproverDetails(recordId, quote, piwList));
                    }
                    List<ProcessInstanceStep> pisList = [SELECT Id FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =: recordId AND StepStatus =: CON_CPQ.APPROVED];
                    if (pisList.size() > 0) {
                        quoteObj.isStep1 = false;
                    }
                }
                if (checkCongaAccess == CON_CPQ.HASCONGAACCESS && Schema.sObjectType.Apttus_Config2__ProductConfiguration__c.isAccessible()) {
                    if (quote.Is_Cloned__c == true) {
                        String condition = 'Apttus_QPConfig__Proposald__r.IQVIA_Quote__c IN :quoteIds AND Apttus_QPConfig__Proposald__r.Apttus_Proposal__Approval_Stage__c = \'Draft\' AND Apttus_Config2__Status__c != \'Finalized\'';
                        List<Apttus_Config2__ProductConfiguration__c> productConfigurations = new SLT_ProductConfiguration().getProductConfigByQuoteId(new Set<Id>{quote.Id}, new Set<String>{CON_CPQ.ID}, condition);
                        if (!productConfigurations.isEmpty()) {
                            quoteObj.hasProductConfiguration = true;
                        }
                    }
                }
                List<Quote_Line_Item__c> quoteLineItems = new SLT_QuoteLineItem().getQuoteLineItemByQuoteId(new Set<Id>{recordId}, new Set<String>{CON_CPQ.ID});
                if (!quoteLineItems.isEmpty()) {
                    quoteObj.quoteLineItems = quoteLineItems;
                }
            }
        } catch (Exception e) {									  
            quoteObj.error = e.getMessage();
            return quoteObj;
        }
        return quoteObj;
    }

    @AuraEnabled
    public static String finalizeQuote(Integer numberOfCongaQuoteIds, Integer numberOfExcelTool, Id recordId, List<String> congaTools, String currencyIsoCode) {
        Integer pricingToolCount = new SLT_QuoteLineItem().getPricingToolByQuoteLineItemRecords(recordId,congaTools);
        Integer finalizedProposalsCount = new SLT_Proposal().getFinalizedProposals(recordId).size();
        if (finalizedProposalsCount == numberOfCongaQuoteIds) {
            if (pricingToolCount == numberOfExcelTool) {
                return finalizeAndSetAmountOnQuote(recordId, currencyIsoCode, 1);
            }
        }
        return 'Fail';
    }
    @AuraEnabled
    public static String finalizeQuoteForSingleTool(Id recordId) {
        Set<String> proposalFieldSet = new Set<String> {CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.APPROVAL_STAGE, CON_CPQ.FIELD_FINALIZE_DATE};
        if (Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.IQVIA_Quote__c.isAccessible()) {    
            proposalFieldSet.add(CON_CPQ.IQVIA_QUOTE);
            proposalFieldSet.add(CON_CPQ.RELATED_IQVIA_QUOTE_PRICING_TOOLS);
            proposalFieldSet.add(CON_CPQ.RELATED_IQVIA_QUOTE_APPROVAL_STAGE);
        }
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(recordId, proposalFieldSet);
        if (proposalFieldSet.contains(CON_CPQ.IQVIA_QUOTE) && proposal.IQVIA_Quote__c != null) {
            if (proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && proposal.IQVIA_Quote__r.Approval_Stage__c == CON_CPQ.IN_PROGRESS_STATUS) {
                Double conversionRate = 1;
                if (proposal.CurrencyIsoCode != CON_CPQ.USD) {
                    conversionRate = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{proposal.CurrencyIsoCode}, System.today()).values()[0].Conversion_rate__c;
                }
                Datetime finalizedDate = proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c;
                Datetime thirtyMinuteAgo = Datetime.now().addMinutes(-30);
                if (finalizedDate >= thirtyMinuteAgo) {
                    CPQ_QuoteUtilityWO.deletePreviewDocuments(proposal.IQVIA_Quote__c);
                    CPQ_QuoteUtility.createQuoteLineItemsUsingProposalLineItem(proposal.IQVIA_Quote__c, recordId, proposal.Select_Pricing_Tool__c, CON_CPQ.CONGA_PATHWAY);
                    if (proposal.IQVIA_Quote__r.Pricing_Tools__c.split(';')?.size() == 1) {
                        finalizeAndSetAmountOnQuote(proposal.IQVIA_Quote__c, proposal.CurrencyIsoCode, conversionRate);
                    }
                }
            } else if (proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c == null && proposal.Apttus_Proposal__Approval_Stage__c == CON_CPQ.IN_PROGRESS_STATUS) {
                CPQ_QuoteUtility.createQuoteLineItemsUsingConfigLineItem(proposal.IQVIA_Quote__c, recordId, proposal.Select_Pricing_Tool__c, CON_CPQ.CONGA_PATHWAY);
            }
            return proposal.IQVIA_Quote__c;
        }
        return 'Fail';
    }

    public static String finalizeAndSetAmountOnQuote(Id recordId, String currencyIsoCode, Double conversionRate) {
        try {
            Quote__c quote = new Quote__c(Id = recordId);
            quote.Approval_Stage__c = CON_CPQ.FINALIZED;

            return updateIQVIAQuote(quote);
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    public static String updateIQVIAQuote(Quote__c quote) {
        try {
            fflib_SObjectUnitOfWork uowQuote = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote__c.SobjectType
                }
            );
            uowQuote.registerDirty(quote);
            uowQuote.commitWork();
            return CON_CPQ.SUCCESS;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    public static List<ApproverDetails> getApproverDetails(Id recordId, Quote__c quote, List<ProcessInstanceWorkitem> piwList) {
        List<ApproverDetails> approverDetailsList = new List<ApproverDetails>();
        for (Integer i=1 ; i<=piwList.size(); i++) {
            ApproverDetails approverDetailsWrap = new ApproverDetails();
            approverDetailsWrap.piwId = piwList[i-1].Id;
            approverDetailsWrap.approverField = 'Approver_' + i + '__c';
            approverDetailsWrap.userName = piwList[i-1].actor.name;
            approverDetailsWrap.label = 'Approver' +' '+ i;									   									   
            approverDetailsWrap.currentAppprover = piwList[i-1].ActorId;
            approverDetailsWrap.newApprover = null;
            approverDetailsList.add(approverDetailsWrap);
        }
        return approverDetailsList;
    }

    @AuraEnabled
    public static String updateApprovers(String jsonData, Id quoteId) {
        try {
            List<ApproverDetails> approverDetailsList = (List<ApproverDetails>)JSON.deserialize(jsonData, List<ApproverDetails>.class);
            List<ProcessInstanceWorkitem> piwList = new List<ProcessInstanceWorkitem>();
            for (ApproverDetails approverDetail: approverDetailsList) {
                if (approverDetail.newApprover != null && approverDetail.newApprover != approverDetail.currentAppprover) {
                    ProcessInstanceWorkitem piw = new ProcessInstanceWorkitem(Id = approverDetail.piwId, ActorId = approverDetail.newApprover);
                    piwList.add(piw);
                }
            }
            if (piwList.size() > 0) {
                update piwList;
            }
            return CON_CPQ.SUCCESS;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Quote__c quote, Set<String> actorIds) {
        List<ProcessInstanceWorkitem> ProcessInstanceWorkitemList;
        Id quoteId = quote.Id;
        if (actorIds == null || actorIds.size()==0) {
            ProcessInstanceWorkitemList = [SELECT Id, ActorId, ProcessInstance.Status, ProcessInstanceId, Actor.Name FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: quoteId ORDER BY CreatedDate];
        } else {
            ProcessInstanceWorkitemList = [SELECT Id, ActorId, ProcessInstance.Status, ProcessInstanceId, Actor.Name FROM ProcessInstanceWorkitem WHERE ActorId IN :actorIds AND ProcessInstance.TargetObjectId =: quoteId ORDER BY CreatedDate];
        }
        return ProcessInstanceWorkitemList;
    }
	
    @AuraEnabled
    public static String syncQLIWithOpportunity(Id recordId, String pricingTool, String stageName) {
        Quote__c existingQuoteRecord = [SELECT Id, Execution_Status__c FROM Quote__c WHERE Id = :recordId];     
        if (existingQuoteRecord.Execution_Status__c == CON_CPQ.IN_PROGRESS_STATUS) {
            return CON_CPQ.IN_PROGRESS_STATUS;
        }
        try {
            Id jobId;
            fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote__c.SobjectType
                        }
            );
            Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
            Map<String, CurrencyType> isoCodeToYearlyCurrencyTypeMap;
            Map<String, String> pricingToolFXRateTypeMap = new Map<String, String>();
            for (CPQ_Proposal_Create_Settings__c cPCS : CPQ_Proposal_Create_Settings__c.getAll().values()) {
                if (cPCS.FX_Rate_Type__c != null) {
                    pricingToolFXRateTypeMap.put(cPCS.Available_Pricing_Tools__c, cPCS.FX_Rate_Type__c);
                }
            }
            QUE_CPQ_SyncBudgetWithOpportunity syncBudgetWithOpportunityJob;
            List<Quote__c> quotes = new SLT_IQVIA_Quote().getQuoteIdslist(new Set<Id>{recordId}, new Set<String>{CON_CPQ.CURRENCYISOCODE, CON_CPQ.QUOTE_OPPORTUNITY_CURRENCYISOCODE, CON_CPQ.CONVERSION_DATE, CON_CPQ.CONVERSION_RATE});
            if (!quotes.isEmpty()) {
                UTL_ExecutionControl.stopTriggerExecutionCPQ = true;
                uowProposal.registerDirty(new Quote__c(Id = recordId, Execution_Status__c = (CON_CPQ.IN_PROGRESS_STATUS)));
                uowProposal.commitWork();
                UTL_ExecutionControl.stopTriggerExecutionCPQ = false;
                if (!pricingToolFXRateTypeMap.isEmpty() && !pricingToolFXRateTypeMap.isEmpty() && pricingToolFXRateTypeMap.get(pricingTool) == CON_CPQ.YEARLY) {
                    isoCodeToYearlyCurrencyTypeMap = quotes[0].CurrencyIsoCode != quotes[0].Related_Opportunity__r.CurrencyIsoCode ? new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{quotes[0].CurrencyIsoCode, quotes[0].Related_Opportunity__r.CurrencyIsoCode}) : null;
                    syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(recordId, true, pricingTool, stageName, quotes[0].CurrencyIsoCode, quotes[0].Related_Opportunity__r.CurrencyIsoCode, isoCodeToYearlyCurrencyTypeMap != null ? isoCodeToYearlyCurrencyTypeMap.get(quotes[0].Related_Opportunity__r.CurrencyIsoCode).ConversionRate : null, isoCodeToYearlyCurrencyTypeMap != null ? isoCodeToYearlyCurrencyTypeMap.get(quotes[0].CurrencyIsoCode).ConversionRate : null);
                } else if (!pricingToolFXRateTypeMap.isEmpty() && !pricingToolFXRateTypeMap.isEmpty() && pricingToolFXRateTypeMap.get(pricingTool) == CON_CPQ.MONTHLY) {
                    isoCodeTocurrencyTypeMap = quotes[0].CurrencyIsoCode != quotes[0].Related_Opportunity__r.CurrencyIsoCode ? new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{quotes[0].CurrencyIsoCode, quotes[0].Related_Opportunity__r.CurrencyIsoCode}, quotes[0].Conversion_Date__c) : null;
                    if (pricingTool == CON_CPQ.Q2_Solutions) {
                        syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(recordId, true, pricingTool, stageName, quotes[0].CurrencyIsoCode, quotes[0].Related_Opportunity__r.CurrencyIsoCode, isoCodeTocurrencyTypeMap != null ? isoCodeTocurrencyTypeMap.get(quotes[0].Related_Opportunity__r.CurrencyIsoCode).Conversion_rate__c : null, quotes[0].Conversion_Rate__c != null ? quotes[0].Conversion_Rate__c : null);
                    } else {
                        syncBudgetWithOpportunityJob = new QUE_CPQ_SyncBudgetWithOpportunity(recordId, true, pricingTool, stageName, quotes[0].CurrencyIsoCode, quotes[0].Related_Opportunity__r.CurrencyIsoCode, isoCodeTocurrencyTypeMap != null ? isoCodeTocurrencyTypeMap.get(quotes[0].Related_Opportunity__r.CurrencyIsoCode).Conversion_rate__c : null, isoCodeTocurrencyTypeMap != null ? isoCodeTocurrencyTypeMap.get(quotes[0].CurrencyIsoCode).Conversion_rate__c : null);
                    }
                    
                }
                jobId = System.enqueueJob(syncBudgetWithOpportunityJob);
            } else {
                jobId = null;
            }
            return jobId;
        } catch(Exception ex) {
            return ex.getMessage();
        }            
    }

    @AuraEnabled
    public static Boolean markQuoteAsPrimary(Id recordId, Id relatedOpportunity) {
        try {
            if (recordId != null && relatedOpportunity != null) {
                List<Quote__c> listOfQuoteToBeUpdate = new List<Quote__c>{new Quote__c(Id = recordId, Primary__c = true)};
                String condition = 'Related_Opportunity__c IN: relatedOpportunityIdSet AND Primary__c = true AND Id != \'' + recordId + '\'';
                Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.IQ_QUOTE_PRIMARY};
                List<Quote__c> relatedQuotes = new SLT_IQVIA_Quote().getQuotesByCondition(fieldSet, condition, new Set<Id>{relatedOpportunity});
                if (!relatedQuotes.isEmpty()) {
                    for (Quote__c relatedQuote: relatedQuotes) {
                        relatedQuote.Primary__c = false;
                        listOfQuoteToBeUpdate.add(relatedQuote);
                    }
                }
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote__c.SobjectType
                    }
                );
                uowProposal.registerDirty(listOfQuoteToBeUpdate);
                uowProposal.commitWork();
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateQuoteStage(Id recordId, String stageName) {
        if (recordId != null && String.isNotBlank(stageName)) {
            Quote__c quote = new Quote__c(Id = recordId, Approval_Stage__c = stageName);
            try {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote__c.SobjectType
                    }
                );
                uowProposal.registerDirty(quote);
                uowProposal.commitWork();
                return CON_CPQ.SUCCESS;
            } catch (Exception e) {
                return e.getMessage();
            } 
        }
        return 'Fail';
    }

    @AuraEnabled
    public static List<String> getLanguagesByCountry(Id recordId) {
        Set<String> countryList = new Set<String>();
        Set<String> languageList = new Set<String>();
        Set<String> countryMasterDataFieldSet = new Set<String>{'Id', 'Language__c'};
        Set<Id> quoteIdSet = new Set<Id>{recordId};
        String condition = 'Quote__c IN: quoteIdSet';
        for (Quote_Requisites__c countryInput: new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteIdSet, new Set<String>{'Id', 'Country__c'}, condition)) {
            if (countryInput.Country__c != null) {
                countryList.add(countryInput.Country__c);
            }
        }
        for (CPQ_Country_Master_Data__c countryMtd: new SLT_CPQCountryMasterData().getCountryMasterDataByNames(countryList, countryMasterDataFieldSet)) {
            if (countryMtd.Language__c != null) {
                languageList.addAll(countryMtd.Language__c.split(';'));
            }
        }
        return new List<String>(languageList);
    }

    @AuraEnabled
    public static String updateLanguages(Id recordId, List<String> languageList) {
        languageList.sort();
        String selectedLanguages = String.join(languageList, ';');
        Set<String> uniqueLanguagesSet = new Set<String>(languageList);
        Integer uniqueLanguageCount = uniqueLanguagesSet.size();
        try {
            fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote__c.SobjectType, Quote_Requisites__c.SobjectType
                }
            );
            Set<Id> quoteIdSet = new Set<Id>{recordId};
            Set<String> quoteReqFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.SELECTED_LANGUAGES, CON_CPQ.COUNTRY};
            String condition = 'Quote__c IN : quoteIdSet AND Type__c = \'' + CON_CPQ.COUNTRY_INPUT + '\'';
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteIdSet, quoteReqFieldSet, condition);
            Set<String> countryNamesSet = new Set<String>();
            for (Quote_Requisites__c quoteReq : quoteReqList) {
                countryNamesSet.add(quoteReq.Country__c);
            }

            Map<String, String> countryLanguageMap = new Map<String, String>();
            for (CPQ_Country_Master_Data__c countryData : new SLT_CPQCountryMasterData().getCountryMasterDataByNames(countryNamesSet, new Set<String>{CON_CPQ.COUNTRY, CON_CPQ.LANGUAGE})) {
                countryLanguageMap.put(countryData.Country__c.toLowercase(), countryData.Language__c);
            }

            for (Quote_Requisites__c req : quoteReqList) {
                String countryLanguage = countryLanguageMap.get(req.Country__c.toLowerCase());
                String selectedLanguagesString = '';
                if (String.isNotBlank(countryLanguage)) {
                    for (String language : uniqueLanguagesSet) {
                        if (countryLanguage.contains(language) ) {
                            selectedLanguagesString += language + ', ';
                        }
                    }
                    req.Selected_Languages__c = String.isEmpty(selectedLanguagesString) ? null : selectedLanguagesString.removeEnd(',');
                }
            }

            Quote__c quote = new Quote__c(Id = recordId);
            quote.Selected_Languages__c = selectedLanguages;
            quote.Adjusted_Languages__c = selectedLanguages.contains('English(US)') ? uniqueLanguageCount - 1 : uniqueLanguageCount;
            
            uowProposal.registerDirty(quoteReqList);
            uowProposal.registerDirty(quote);
            uowProposal.commitWork();
        } catch (Exception e) {
            return e.getMessage();
        }
        return CON_CPQ.SUCCESS;
    }

    @AuraEnabled
    public static List<Quote_Requisites__c> getStudyInformation(String studyNumber, Id quoteId) {
        try {
            if (!String.isEmpty(studyNumber)) {
                Set<String> quoteReqFieldSet = new Set<String>{CON_CPQ.ID};
                String condition = 'Study_Number__c =: studyNumber AND Quote__c =: quoteId';
                return new SLT_QuoteRequisites().getQuoteRequisitesByStudyNumber(studyNumber, quoteId, quoteReqFieldSet, condition);
            } else {
                return null;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }            
    }

    public class IQVIA_CPQ_QuoteDetails {
        @AuraEnabled
        public Decimal priority{get; set;}
        @AuraEnabled
        public Boolean haveApprovalItems {get; set;}
        @AuraEnabled
        public Boolean isApprover {get; set;}
        @AuraEnabled
        public Boolean isOwner {get; set;}
        @AuraEnabled
        public String opportunityId {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public String approverDetails {get; set;}
        @AuraEnabled
        public String gbu {get; set;}
        @AuraEnabled
        public String pricingTools {get; set;}
        @AuraEnabled
        public List<String> availableCongaToolList {get; set;}
        @AuraEnabled
        public List<String> availableOutsideToolList {get; set;}
        @AuraEnabled
        public String error {get; set;}
        @AuraEnabled
        public Boolean isPrimary {get; set;}
        @AuraEnabled
        public String selectedPricingTools {get;set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public Map<Id, String> idToStageMap {get; set;}
        @AuraEnabled
        public String selectedLanguages {get;set;}
        @AuraEnabled
        public Map<String, String> flowNameByPricingToolMap {get; set;}
        @AuraEnabled
        public Map<String, String> congaQuoteIdByPricingToolMap {get; set;}
        @AuraEnabled
        public String currencyIsoCode {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String DocumentType {get;set;}
        @AuraEnabled
        public String LicenseType {get;set;}
        @AuraEnabled
        public ID bidHistoryId {get;set;}
        @AuraEnabled
        public String relatedQuote {get;set;}
        @AuraEnabled
        public Double Scenario {get;set;}
        @AuraEnabled
        public Boolean haveCongaPermission {get; set;}
        @AuraEnabled
        public Boolean haveCongaCLMPermission {get; set;}
        @AuraEnabled
        public String checkPathway {get; set;}
        @AuraEnabled
        public Boolean hasProductConfiguration {get; set;}
        @AuraEnabled
        public String discountReason {get;set;}
        @AuraEnabled
        public Double aggregateDiscount {get;set;}
        @AuraEnabled
        public boolean quoteHasChildQuote {get;set;}
        @AuraEnabled
        public String quoteType {get;set;}
        @AuraEnabled
        public Map<String, String> toolToPathway {get;set;}
        @AuraEnabled
        public boolean isStep1 {get;set;}
        @AuraEnabled
        public List<Quote_Line_Item__c> quoteLineItems {get;set;}
        @AuraEnabled
        public Double conversionRate {get;set;}
        @AuraEnabled 
        public boolean hasReassignAccess{get;set;}
	    @AuraEnabled
        public Boolean hasPermissionForSalesWithPSA {get;set;}
        @AuraEnabled
        public Boolean isSpecial {get; set;}

        public IQVIA_CPQ_QuoteDetails() {
            this.haveApprovalItems = false;
            this.Name = '';
            this.LicenseType = '';
            this.DocumentType = '';
            this.haveCongaPermission = false;
            this.quoteHasChildQuote = false;
            this.isStep1 = true;
            this.hasProductConfiguration = false;
            this.quoteLineItems = null;
            this.hasReassignAccess = false;
            this.isApprover = false;
            this.hasPermissionForSalesWithPSA = false;
            this.isSpecial = true;
        }
    }
   
    public class ApproverDetails {
        @AuraEnabled
        public String approverField {get; set;}
        @AuraEnabled
        public Id piwId {get; set;}
        @AuraEnabled
        public String currentAppprover {get; set;}
        @AuraEnabled
        public String newApprover {get; set;}
        @AuraEnabled
        public String userName {get;set;}
        @AuraEnabled 
        public String label {get;set;}		
    }
    @AuraEnabled
    public static String getGuidanceFileURL() {
        String returnString;
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.TITLE};
        String condition = 'Title = \'' + CON_CPQ.DPS_GUIDANCE_FILE + '\'';
        List<ContentVersion> contentFileList = new SLT_ContentVersion().getContentVersionByCondition(fieldSet, condition);
        if (contentFileList.size() > 0) {
            returnString = URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentFileList[0].id;
        }
        return returnString;
    }
    
    @AuraEnabled
    public static String addBundleProductInCart(Id recordId, Id congaQuoteId, Id relatedQuote) {
        String status = 'Failed';
        List<Apttus_Config2__ProductConfiguration__c> carts = new List<Apttus_Config2__ProductConfiguration__c>();
        List<Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        List<Id> productIdSet = new List<Id>();
        String condition = 'Quote__c IN: quoteIdSet';
        List<Quote_Requisites__c> quoteRequisitesList = new SLT_QuoteRequisites().getQuoteRequisitesRecord(new Set<Id>{recordId}, new Set<String>{CON_CPQ.ID, CON_CPQ.SERVICE_LINE, CON_CPQ.BID_HISTORY_STUDY_NUMBER, CON_CPQ.CLINICAL_TYPE, CON_CPQ.NUMBER_OF_ANALYTE, CON_CPQ.SPECIMEN_TYPE, CON_CPQ.QUOTE_REQUISITES_SPECIES, CON_CPQ.QUOTE_REQUISITES_ANALYTE_ID, CON_CPQ.QUOTE_REQUISITES_MATRIX, CON_CPQ.QUOTE_REQUISITES_STUDY_TYPE, CON_CPQ.QUOTE_REQUISITES_SERVICE_LINE_NAME, CON_CPQ.QUOTE_CONVERSION_RATE, CON_CPQ.QR_QUOTE_TYPE}, condition);
        quoteRequisitesList = sortListByStudyNumber(quoteRequisitesList);
        if (String.isBlank(relatedQuote)) {
            try { 
                String cartId; 
                if (quoteRequisitesList.size() > 0) {
                    Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
                    request.QuoteId = congaQuoteId;
                    Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
                    cartId = response.CartId;
                }
                if (cartId != null) {
                    for (Quote_Requisites__c qR : quoteRequisitesList) {
                        if (qR.Service_Line_Product__c != null) {
                            Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
                            selProdDO.ProductID = qR.Service_Line_Product__c;
                            selProdDO.Quantity = 1;
                            selectedProdDOList.add(selProdDO);
                        }
                    }
                    if (selectedProdDOList.size() > 0) {
                        Apttus_CPQApi.CPQ.AddMultiProductRequestDO multiProductRequest = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
                        multiProductRequest.CartId = cartId;
                        multiProductRequest.SelectedProducts = selectedProdDOList;
                        Apttus_CPQApi.CPQWebService.addMultiProducts(multiProductRequest);
                    }
                    fflib_SObjectUnitOfWork productConfig = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] { Apttus_Config2__ProductConfiguration__c.SobjectType }
                    );
                    productConfig.registerDirty(new List<Apttus_Config2__ProductConfiguration__c>{new Apttus_Config2__ProductConfiguration__c(Id = cartId, Apttus_Config2__Status__c = CON_CPQ.PRODUCT_CONFIG_STATUS_SAVED)});
                    productConfig.commitWork();
                    return adjustLineNumberOnLineItems(quoteRequisitesList, new SLT_LineItem().selectByProductConfigId(new Set<Id>{cartId}, new Set<String> {CON_CPQ.ID, CON_CPQ.LINE_ITEM_PRODUCT, CON_CPQ.LINE_ITEM_PRO_ATTR_VALUE, CON_CPQ.LINE_NUMBER, CON_CPQ.LINE_ITEM_BASE_PRICE_OVERRIDE, CON_CPQ.LINE_ITEM_BASE_PRICE_CALLBACK, CON_CPQ.RELATED_PROPOSAL_CURRENCYISOCODE, CON_CPQ.LINE_ITEM_DESCRIPTION, CON_CPQ.QUOTETYPE, CON_CPQ.CLI_NET_PRICE, CON_CPQ.CLI_QUANTITY, CON_CPQ.CLI_PREVIOUS_NET_PRICE, CON_CPQ.CLI_PREVIOUS_QUANTITY, CON_CPQ.LINE_ITEM_ADJUSTMENT_TYPE, CON_CPQ.LINE_ITEM_ADJUSTMENT_AMOUNT}), null);
                }
            } catch (Exception e) {
                return e.getMessage();
            }
            return status;
        } else {
            try {
                Map<String, List<Apttus_Config2__LineItem__c>> serviceLineStudyNumberMap = new Map<String, List<Apttus_Config2__LineItem__c>>();
                carts =  new SLT_ProductConfiguration().getProductConfigByProposalIdAndStatus( new Set<Id>{congaQuoteId}, CON_CPQ.PRODUCT_CONFIG_STATUS_SAVED, new Set<String> {CON_CPQ.ID, CON_CPQ.PRODUCT_CONFIG_STATUS});
                List<Apttus_Config2__LineItem__c> lineItemList = new SLT_LineItem().selectByProductConfigId(new Set<Id>{carts[0].Id}, new Set<String> {CON_CPQ.ID, CON_CPQ.BID_HISTORY_STUDY_NUMBER, CON_CPQ.LINE_ITEM_PRODUCT});
                List<Apttus_Config2__LineItem__c> lineItemToBeDeletedList = new List<Apttus_Config2__LineItem__c>();
                if (lineItemList.size() > 0) {
                    for (Apttus_Config2__LineItem__c lineItem : lineItemList) {
                        if (!serviceLineStudyNumberMap.containsKey(lineItem.Apttus_Config2__ProductId__c + lineItem.Study_Number__c)) {
                            serviceLineStudyNumberMap.put(lineItem.Apttus_Config2__ProductId__c + lineItem.Study_Number__c, new List<Apttus_Config2__LineItem__c>());
                        }
                        List<Apttus_Config2__LineItem__c> cliList = serviceLineStudyNumberMap.get(lineItem.Apttus_Config2__ProductId__c + lineItem.Study_Number__c);
                        cliList.add(lineItem);
                        serviceLineStudyNumberMap.put(lineItem.Apttus_Config2__ProductId__c + lineItem.Study_Number__c, cliList);
                    }
                    for (Quote_Requisites__c quoteRequisite : quoteRequisitesList) {
                        if (!(serviceLineStudyNumberMap.containsKey(quoteRequisite.Service_Line_Product__c + quoteRequisite.Study_Number__c))) {
                            productIdSet.add(quoteRequisite.Service_Line_Product__c);
                        } else { 
                            serviceLineStudyNumberMap.remove(quoteRequisite.Service_Line_Product__c + quoteRequisite.Study_Number__c);
                        }
                    }
                    if (serviceLineStudyNumberMap.size() > 0) {
                        for (String lineItem : serviceLineStudyNumberMap.keySet()) {
                            lineItemToBeDeletedList.addAll(serviceLineStudyNumberMap.get(lineItem));
                        }
                    }
                    if (lineItemToBeDeletedList.size() > 0) {
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Apttus_Config2__LineItem__c.SObjectType});
                        uow.registerDeleted(lineItemToBeDeletedList);
                        uow.commitWork();
                    }
                }
                if (productIdSet.size() > 0) {
                    for (Id productId : productIdSet) {
                        Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
                        selProdDO.ProductID = productId;
                        selProdDO.Quantity = 1;
                        selectedProdDOList.add(selProdDO);
                    }
                }
                if (selectedProdDOList.size() > 0) {
                    Apttus_CPQApi.CPQ.AddMultiProductRequestDO multiProductRequest = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
                    multiProductRequest.CartId = carts[0].Id;
                    multiProductRequest.SelectedProducts = selectedProdDOList;
                    Apttus_CPQApi.CPQWebService.addMultiProducts(multiProductRequest);
                }
                return adjustLineNumberOnLineItems(quoteRequisitesList, new SLT_LineItem().selectByProductConfigId(new Set<Id>{carts[0].Id}, new Set<String> {CON_CPQ.ID, CON_CPQ.LINE_ITEM_PRODUCT, CON_CPQ.LINE_ITEM_PRO_ATTR_VALUE, CON_CPQ.LINE_NUMBER, CON_CPQ.LINE_ITEM_BASE_PRICE_OVERRIDE, CON_CPQ.LINE_ITEM_BASE_PRICE_CALLBACK, CON_CPQ.RELATED_PROPOSAL_CURRENCYISOCODE, CON_CPQ.LINE_ITEM_DESCRIPTION, CON_CPQ.QUOTETYPE, CON_CPQ.CLI_NET_PRICE, CON_CPQ.CLI_QUANTITY, CON_CPQ.CLI_PREVIOUS_NET_PRICE, CON_CPQ.CLI_PREVIOUS_QUANTITY, CON_CPQ.LINE_ITEM_ADJUSTMENT_TYPE, CON_CPQ.LINE_ITEM_ADJUSTMENT_AMOUNT}), relatedQuote);
            } catch(Exception e) {
                return e.getMessage();
            }
        }
    }
    
    public static String adjustLineNumberOnLineItems(List<Quote_Requisites__c> quoteRequisitesList, List<Apttus_Config2__LineItem__c> cliList, Id relatedQuote) {
        try {
            String relatedQuoteCurrencyIsoCode = null;
            String currentQuoteCurrencyIsoCode = null;
            String relatedQuoteStageName = null;
            String currentQuoteType = null;
            Decimal relatedQuoteConversionRate = null;
            Quote__c relatedQuoteData;
            Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
            if (relatedQuote != null) {
                relatedQuoteData = new SLT_IQVIA_Quote().getQuoteDetails(relatedQuote);
                relatedQuoteCurrencyIsoCode = relatedQuoteData.CurrencyIsoCode;
                relatedQuoteConversionRate = relatedQuoteData.Conversion_Rate__c;
                currentQuoteCurrencyIsoCode = cliList[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.CurrencyIsoCode;
                relatedQuoteStageName = relatedQuoteData.Approval_Stage__c;
                currentQuoteType = cliList[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.IQVIA_Quote__r.Quote_Type__c;
                isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{relatedQuoteCurrencyIsoCode, currentQuoteCurrencyIsoCode}, System.today());
            }
            quoteRequisitesList = sortListByStudyNumber(quoteRequisitesList);
            Decimal quoteConversionRate = (quoteRequisitesList.size() > 0 && (quoteRequisitesList[0].Quote__r.Conversion_Rate__c != 0 && quoteRequisitesList[0].Quote__r.Conversion_Rate__c != null)) ? quoteRequisitesList[0].Quote__r.Conversion_Rate__c : null;
            Map<Id, Set<Integer>> studyNumberSetByProductId = new Map<Id, Set<Integer>>();
            String quoteType = quoteRequisitesList.size() > 0 ? quoteRequisitesList[0].Quote__r.Quote_Type__c : '';
            for (Quote_Requisites__c qr: quoteRequisitesList) {
                if (!studyNumberSetByProductId.containsKey(qr.Service_Line_Product__c)) {
                    studyNumberSetByProductId.put(qr.Service_Line_Product__c, new Set<Integer>());
                }
                Set<Integer> studyNumberSet = studyNumberSetByProductId.get(qr.Service_Line_Product__c);
                studyNumberSet.add(Integer.valueOf(qr.Study_Number__c));
                studyNumberSetByProductId.put(qr.Service_Line_Product__c, studyNumberSet);
            }
            Map<Integer, Map<Id, List<Apttus_Config2__LineItem__c>>> cliListByIdByLineNumberMap = new Map<Integer, Map<Id, List<Apttus_Config2__LineItem__c>>>();
            for (Apttus_Config2__LineItem__c cli: cliList) {
                if (!cliListByIdByLineNumberMap.containsKey((Integer)cli.Apttus_Config2__LineNumber__c)) {
                    cliListByIdByLineNumberMap.put((Integer)cli.Apttus_Config2__LineNumber__c, new Map<Id, List<Apttus_Config2__LineItem__c>>());
                }
                Map<Id, List<Apttus_Config2__LineItem__c>> cliListByIdMap = cliListByIdByLineNumberMap.get((Integer)cli.Apttus_Config2__LineNumber__c);
                if (!cliListByIdMap.containsKey(cli.Apttus_Config2__ProductId__c)) {
                    cliListByIdMap.put(cli.Apttus_Config2__ProductId__c, new List<Apttus_Config2__LineItem__c>());
                }
                List<Apttus_Config2__LineItem__c> lineItemList = cliListByIdMap.get(cli.Apttus_Config2__ProductId__c);
                lineItemList.add(cli);
                cliListByIdMap.put(cli.Apttus_Config2__ProductId__c, lineItemList);
                cliListByIdByLineNumberMap.put((Integer)cli.Apttus_Config2__LineNumber__c, cliListByIdMap);
            }
            List<Apttus_Config2__LineItem__c> cliListToUpdate = new List<Apttus_Config2__LineItem__c>();
            List<Apttus_Config2__ProductAttributeValue__c > proAttrListToUpdate = new List<Apttus_Config2__ProductAttributeValue__c >();
            Id productId;
            for (Integer inte: cliListByIdByLineNumberMap.keySet()) {
                for (String key: cliListByIdByLineNumberMap.get(inte).KeySet()) {
                    for (Apttus_Config2__LineItem__c cli: cliListByIdByLineNumberMap.get(inte).get(key)) {
                        cli.Apttus_Config2__LineNumber__c = new List<Integer>(studyNumberSetByProductId.get(cli.Apttus_Config2__ProductId__c)).get(0);
                        cli.Apttus_Config2__LineSequence__c = cli.Apttus_Config2__LineNumber__c;
                        cli.Quote_Requisites__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Id;
                        cli.Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING;
                        if (cli.Apttus_Config2__OptionId__c == null) {
                            cli.Apttus_Config2__Description__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Study_Type__c + ' for ' + quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Analyte_ID__c + ' in ' + quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Species_Global__c + ' ' +quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Matrix__c + ', ' + quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Service_Line_Product__r.Name;
                        }
                        if (quoteType != CON_CPQ.CHNAGE_ORDER && cli.Apttus_Config2__BasePriceOverride__c != 0.0 && cli.Apttus_Config2__BasePriceOverride__c != cli.Base_Price_Callback__c && relatedQuoteCurrencyIsoCode != null && (relatedQuoteCurrencyIsoCode != currentQuoteCurrencyIsoCode || relatedQuoteConversionRate != quoteConversionRate)) {
                            if (relatedQuoteCurrencyIsoCode == CON_CPQ.USD) {
                                if (quoteConversionRate != null) {
                                    cli.Apttus_Config2__BasePriceOverride__c *= quoteConversionRate;
                                } else if (isoCodeTocurrencyTypeMap.containsKey(currentQuoteCurrencyIsoCode)) {
                                    cli.Apttus_Config2__BasePriceOverride__c *= (Decimal)(isoCodeTocurrencyTypeMap.get(currentQuoteCurrencyIsoCode).Conversion_rate__c);
                                }
                            } else if (currentQuoteCurrencyIsoCode == CON_CPQ.USD) {
                                if (relatedQuoteConversionRate != null && relatedQuoteConversionRate != 0) {
                                    cli.Apttus_Config2__BasePriceOverride__c /= relatedQuoteConversionRate;
                                } else if (isoCodeTocurrencyTypeMap.containsKey(relatedQuoteCurrencyIsoCode)) {
                                    cli.Apttus_Config2__BasePriceOverride__c /= (Decimal)(isoCodeTocurrencyTypeMap.get(relatedQuoteCurrencyIsoCode).Conversion_rate__c);
                                }
                            } else {
                                if (quoteConversionRate != null && quoteConversionRate != 0 && relatedQuoteConversionRate != null && relatedQuoteConversionRate != 0) {
                                    cli.Apttus_Config2__BasePriceOverride__c *= (Decimal)(quoteConversionRate / relatedQuoteConversionRate);
                                } else if (isoCodeTocurrencyTypeMap.containsKey(currentQuoteCurrencyIsoCode) && isoCodeTocurrencyTypeMap.containsKey(relatedQuoteCurrencyIsoCode)) {
                                    cli.Apttus_Config2__BasePriceOverride__c *= (Decimal)(isoCodeTocurrencyTypeMap.get(currentQuoteCurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(relatedQuoteCurrencyIsoCode).Conversion_rate__c);
                                }
                            }
                        }
                        if (cli.Apttus_Config2__AdjustmentType__c != null && cli.Apttus_Config2__AdjustmentAmount__c != 0.0 && cli.Apttus_Config2__AdjustmentAmount__c != null && (cli.Apttus_Config2__AdjustmentType__c == 'Discount Amount' || cli.Apttus_Config2__AdjustmentType__c == 'Markup Amount') 
                            && relatedQuoteCurrencyIsoCode != null && (relatedQuoteCurrencyIsoCode != currentQuoteCurrencyIsoCode || relatedQuoteConversionRate != quoteConversionRate) ) {
                                if (relatedQuoteCurrencyIsoCode == CON_CPQ.USD) {
                                    system.debug('quoteConversionRate => '+quoteConversionRate);
                                    if (quoteConversionRate != null) {
                                        cli.Apttus_Config2__AdjustmentAmount__c *= quoteConversionRate;
                                    } else if (isoCodeTocurrencyTypeMap.containsKey(currentQuoteCurrencyIsoCode)) {
                                        cli.Apttus_Config2__AdjustmentAmount__c  *= (Decimal)(isoCodeTocurrencyTypeMap.get(currentQuoteCurrencyIsoCode).Conversion_rate__c);
                                    }
                                } else if (currentQuoteCurrencyIsoCode == CON_CPQ.USD) {
                                    if (relatedQuoteConversionRate != null && relatedQuoteConversionRate != 0) {
                                        cli.Apttus_Config2__AdjustmentAmount__c  /= relatedQuoteConversionRate;
                                    } else if (isoCodeTocurrencyTypeMap.containsKey(relatedQuoteCurrencyIsoCode)) {
                                        cli.Apttus_Config2__AdjustmentAmount__c  /= (Decimal)(isoCodeTocurrencyTypeMap.get(relatedQuoteCurrencyIsoCode).Conversion_rate__c);
                                    }
                                } else {
                                    if (quoteConversionRate != null && quoteConversionRate != 0 && relatedQuoteConversionRate != null && relatedQuoteConversionRate != 0) {
                                        cli.Apttus_Config2__AdjustmentAmount__c  *= (Decimal)(quoteConversionRate / relatedQuoteConversionRate);
                                    } else if (isoCodeTocurrencyTypeMap.containsKey(currentQuoteCurrencyIsoCode) && isoCodeTocurrencyTypeMap.containsKey(relatedQuoteCurrencyIsoCode)) {
                                        cli.Apttus_Config2__AdjustmentAmount__c  *= (Decimal)(isoCodeTocurrencyTypeMap.get(currentQuoteCurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(relatedQuoteCurrencyIsoCode).Conversion_rate__c);
                                    }
                                }
                        }
                        if (currentQuoteType != null && currentQuoteType == CON_CPQ.CHANGE_ORDER && relatedQuoteStageName != null && relatedQuoteStageName == CON_CPQ.ACCEPTED) {
                            cli.Previous_Net_Price__c = cli.Apttus_Config2__NetPrice__c;
                            cli.Previous_Quantity__c = cli.Apttus_Config2__Quantity__c;
                        }
                        cliListToUpdate.add(cli);
                        
                        Apttus_Config2__ProductAttributeValue__c prodAttribute = new Apttus_Config2__ProductAttributeValue__c(Id = cli.Apttus_Config2__AttributeValueId__c);
                        prodAttribute.Study_Number__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Study_Number__c;
                        prodAttribute.Clinical_Type__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Clinical_Type__c;
                        prodAttribute.Specimen_Type__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Specimen_Type__c;
                        prodAttribute.Number_of_Analyte__c = quoteRequisitesList[(Integer)cli.Apttus_Config2__LineNumber__c - 1].Number_of_Analyte_Global__c;
                        proAttrListToUpdate.add(prodAttribute);

                        productId = cli.Apttus_Config2__ProductId__c;
                    }
                    if (studyNumberSetByProductId.get(productId).size() > 0) {
                        Integer studyNumber = new List<Integer>(studyNumberSetByProductId.get(productId)).get(0);
                        studyNumberSetByProductId.get(productId).remove(studyNumber);
                    }
                    if (studyNumberSetByProductId.get(productId).size() == 0) {
                        studyNumberSetByProductId.remove(productId);
                    }
                }
            }
            if (cliListToUpdate.size() > 0 && proAttrListToUpdate.size() > 0) {
                fflib_SObjectUnitOfWork uowLineItemAndProAttribute = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus_Config2__LineItem__c.SobjectType, Apttus_Config2__ProductAttributeValue__c.SobjectType
                    }
                );
                List<SObject> sObjectList = new List<SObject>();
                sObjectList.addAll(cliListToUpdate);
                sObjectList.addAll(proAttrListToUpdate);

                uowLineItemAndProAttribute.registerDirty(sObjectList);
                uowLineItemAndProAttribute.commitWork();
            }
            return CON_CPQ.SUCCESS;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public static List<Quote_Requisites__c> sortListByStudyNumber(List<Quote_Requisites__c> quoteRequisitesList) {
        Map<Integer, Quote_Requisites__c> qrByStudyNumberMap = new Map<Integer, Quote_Requisites__c>();
        for (Quote_Requisites__c qr: quoteRequisitesList) {
            if (!String.isBlank(qr.Study_Number__c)) {
                qrByStudyNumberMap.put(Integer.valueOf(qr.Study_Number__c), qr);
            }
        }
        List<Integer> studyNumberList = new List<Integer>();
        studyNumberList.addAll(qrByStudyNumberMap.keySet());
        studyNumberList.sort();
        List<Quote_Requisites__c> newSortedList = new List<Quote_Requisites__c>();
        for (Integer key: studyNumberList) {
            newSortedList.add(qrByStudyNumberMap.get(key));
        }
        return newSortedList;
    }

    @AuraEnabled
    public static String rejectRestQuotes(Id relatedOpportunity, Id recordId, String gbu) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Quote__c.SObjectType});
            String approvalStage =  gbu == CON_CPQ.RECORD_TYPE_TECH_SOLUTION ? CON_CPQ.CANCELLED_STATUS : CON_CPQ.REJECTED;
            String condition = 'Related_Opportunity__c IN: relatedOpportunityIdSet AND Approval_Stage__c != \'' + CON_CPQ.REJECTED + '\' AND Id != \'' + recordId + '\'';
            if (gbu != CON_CPQ.RECORD_TYPE_TECH_SOLUTION) {
                condition +=  ' AND Approval_Stage__c != \'' + CON_CPQ.ACCEPTED + '\'' ;
            }
            Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.QUOTE_APPROVAL_STAGE};
            for (Quote__c quote: new SLT_IQVIA_Quote().getQuotesByCondition(fieldSet, condition, new Set<Id>{relatedOpportunity})) {
                quote.Approval_Stage__c = approvalStage;
                uow.registerDirty(quote);
            }
            uow.commitWork();
            return CON_CPQ.SUCCESS;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<ProcessInstance> getProcessInstance(Id targetObjectId) {
        return [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId =: targetObjectId];
    }

    @AuraEnabled
    public static String recallApprovalProcess(Id recordId) {
        List<ProcessInstanceWorkitem> piList = getProcessInstanceWorkItems(new Quote__c(Id = recordId), null);
        Set<Id> approverIdSet = new Set<Id>();
        for (ProcessInstanceWorkitem pi: piList) {
            approverIdSet.add(pi.ActorId);
        }
        if (piList.size() > 0) {
            try {
                Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
                result.setComments('Recalled');
                result.setAction(CON_CPQ.REMOVED);
                result.setWorkitemId(piList[0].Id);
                Approval.Process(result);
                List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuoteIdslist(new Set<Id>{recordId}, CON_CPQ.QUOTE_FIELDSET_FOR_RECALL);
                String emailBody = '<html><body><br>Quote (' + quoteList[0].Name + ') has been recalled from your approval queue.  No action is needed from you at this time.';
                emailBody += '<br><br>The individual submitting the quote for approval has decided to not move forward with that version of the quote but may submit a new version as a replacement.  Any notification within Salesforce CRM related to this approval request will automatically be removed from your notification list.';
                emailBody += '<br><br>Quote Summary:';
                emailBody += '<ul><li>Account Name: ' + quoteList[0].Related_Account__r.Name + '</li>';
                emailBody += '<li>Opportunity Name: ' + quoteList[0].Related_Opportunity__r.Name + '</li>';
                emailBody += '<li>Opportunity Number: ' + quoteList[0].Opportunity_Number__c + '</li>';
                emailBody += '<li>Opportunity Owner: ' + quoteList[0].Opportunity_Owner__c + '</li>';
                emailBody += '<li>Pricing Tool: ' + quoteList[0].Pricing_Tools__c + '</li>';
                emailBody += '<li>Quote Includes Account-specific Rate Card Pricing: ' + (quoteList[0].Special_Pricing__c ? 'Yes' : 'No') + '</li></ul>';
                emailBody += '<br><br>Thank you.</body></html>';
                Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
                objWorkFlowEmail.Related_To_Object_Id__c = recordId;
                objWorkFlowEmail.Related_To_Object_Api__c = CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME;
                objWorkFlowEmail.Module_Name__c = CON_CPQ.CPQ;
                objWorkFlowEmail.Email_Action__c = CON_CPQ.CPQ_04_SEND_EMAIL;
                objWorkFlowEmail.Email_Subject__c = 'Quote Recall: ' + quoteList[0].Related_Account__r.Name;
                objWorkFlowEmail.content_1__c = emailBody;
                List<Id> notifiersList = new List<Id>();
                notifiersList.addAll(approverIdSet);
                for (integer i = 1; i <= notifiersList.size(); i++) {
                    if (notifiersList.size() >= i && notifiersList.get(i-1) != null) {                                     
                        objWorkFlowEmail.put('To_User_' + i + '__c', notifiersList.get(i-1));
                    }  
                }
                insert objWorkFlowEmail;
                return updateQuoteStage(recordId, CON_CPQ.IN_PROGRESS_STATUS);
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        return 'Success';
    }

    @AuraEnabled
    public static boolean checkAlreadyAccepted(Id relatedOpportunity) {
            String condition = 'Related_Opportunity__c IN:relatedOpportunityIdSet AND Approval_Stage__c = \'' + CON_CPQ.ACCEPTED + '\'';
            Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.QUOTE_APPROVAL_STAGE};
            List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuotesByCondition(fieldSet, condition, new Set<Id>{relatedOpportunity});
        	return !quoteList.isEmpty();
    }

    @AuraEnabled
    public static boolean checkCurrentQuoteApproved(Id recordId) {
        Boolean isQuoteApproved = false;
        for (Quote__history stageHistoy: [SELECT Id, OldValue FROM Quote__history WHERE parentId =: recordId AND Field =: CON_CPQ.QUOTE_APPROVAL_STAGE ORDER BY CreatedDate DESC]) {
            if (stageHistoy.OldValue == CON_CPQ.APPROVED_STATUS) {
                isQuoteApproved = true;
                break;
            }
        }
        return isQuoteApproved;
    }
    @AuraEnabled
    public static void updateProposal(Id recordId) {
        if (recordId != null) {
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Id = recordId, Apttus_Proposal__Approval_Stage__c = 'In-Progress', Apttus_QPConfig__ConfigurationFinalizedDate__c = null);
            try {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus_Proposal__Proposal__c.SobjectType
                    }
                );
                uowProposal.registerDirty(proposal);
                uowProposal.commitWork();
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }
    }

    @AuraEnabled
    public static Boolean checkNonZPubProducts(Id quoteId) {
        Boolean haveNonZPubProducts = false;
        String condition = 'Quote__c = \'' + quoteId +  '\' AND Quote__r.GBU__c =\''+ CON_CPQ.RECORD_TYPE_TECH_SOLUTION + '\' AND Bundle_Product__r.Material_Type__c != \'' + CON_CPQ.ZPUB + '\''; 
        List<Quote_Line_Item__c> nonZPubProductsList = new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new Set<String>{CON_CPQ.ID});
        if (nonZPubProductsList.size() > 0) {
            haveNonZPubProducts = true;
        }
        return haveNonZPubProducts;
    }
	
    @AuraEnabled
    public static Boolean checkZrepProducts(Id quoteId) {
        Boolean paEligible = false;
        String condition = 'Quote__c = \'' + quoteId +  '\'' + ' AND (Bundle_Product__r.Material_Type__c = \'ZREP\')';
        List<Quote_Line_Item__c> zrepProductList = new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new Set<String>{CON_CPQ.ID, 'Bundle_Product__r.Excluded_From_Pricing_Assistant__c', 'Bundle_Product__r.productCode', 'Quote__r.Related_Opportunity__c', 'Quote__r.Related_Opportunity__r.Exclude_from_Pricing_Assistant__c', 'Quote__r.Related_Opportunity__r.Business_Unit__c', 'Quote__r.Related_Opportunity__r.LI_Opportunity_Id__c', 'Quote__r.Related_Opportunity__r.CreatedDate'});
        CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
        if (zrepProductList[0].Quote__r.Related_Opportunity__r.CreatedDate >= cpqSetting.EMEA_Phase_2_Go_Live__c) {
            if (zrepProductList.size() > 0) {
                List<PC_Global_Setting_c__x> pcSettings = [SELECT Id,Cegedim_BUs_c__c,Name__c FROM PC_Global_Setting_c__x ];
                Map<String,PC_Global_Setting_c__x> pcGlobalSettingMap =  CNT_CPQ_QuoteWorkflow.prepareProductCodeWithSettingRecordMap(pcSettings);
                List<PC_Pricing_Calculator__x> pricingAssistantRecords = SLT_PricingAssistant.getPricingAssistantRecord(zrepProductList[0].quote__r.Related_Opportunity__r.LI_Opportunity_Id__c);
                for (Quote_Line_Item__c lineItem : zrepProductList) { 
                    if (!lineItem.quote__r.Related_Opportunity__r.Exclude_from_Pricing_Assistant__c) {
                        if (pricingAssistantRecords.size() == 0) {
                            if (!lineItem.Bundle_Product__r.Excluded_From_Pricing_Assistant__c) {
                                return paEligible = true;
                            }
                            else {
                                String businessUnit = EMEA_BUSINESS_UNIT;
                                if (CNT_CPQ_QuoteWorkflow.checkPAProduct(pcGlobalSettingMap, businessUnit, lineItem.Bundle_Product__r.productCode)) {
                                    return paEligible = true;
                                }
                            }
                        }  
                    }
                }
            }
        }
        return paEligible;
    }
    
    public static Map<String, PC_Global_Setting_c__x> prepareProductCodeWithSettingRecordMap(List<PC_Global_Setting_c__x> pcSettings) {
        Map<String, PC_Global_Setting_c__x> productCodeWithSettingRecordMap= new Map<String, PC_Global_Setting_c__x>();
        for(PC_Global_Setting_c__x settingRecord :pcSettings ){
            productCodeWithSettingRecordMap.put(settingRecord.name__c, settingRecord);
        }
        return productCodeWithSettingRecordMap;
    }
    
    public static Boolean checkPAProduct(Map<String, PC_Global_Setting_c__x> pcGlobalSettingMap, String OppBusinessUnit,String productCode) {
        Boolean isPaProduct = false;
        List<String> cegedimBuList = new List<String>();
        PC_Global_Setting_c__x pcGlobalSetting = pcGlobalSettingMap.get(productCode);
        if(pcGlobalSetting != null) {
            if(pcGlobalSetting.Cegedim_BUs_c__c != null){
                cegedimBuList.addAll(pcGlobalSetting.Cegedim_BUs_c__c.split('#'));
                System.debug(cegedimBuList);
            } else {
                cegedimBuList.addAll(pcGlobalSettingMap.get('PC GlobalSetting').Cegedim_BUs_c__c.split('#'));
            }
            System.debug(cegedimBuList.contains(OppBusinessUnit));
            if(cegedimBuList.size() > 0 && cegedimBuList.contains(OppBusinessUnit)) {
                isPaProduct = true;
            }
        }
        return isPaProduct;
    }
    
    @AuraEnabled
    public static String checkTechSolutionProducts(Id quoteId) {
        Boolean haveNonZPubProducts = false;
        String condition = 'Quote__c = \'' + quoteId +  '\'' + ' AND (Bundle_Product__r.Material_Type__c != \'' + CON_CPQ.ZPUB + '\'';
        condition += 'OR ((BasePrice__c = 0 OR BasePrice__c = null) AND Net_Price__c = 0))';
        List<Quote_Line_Item__c> qliList = new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new Set<String>{CON_CPQ.ID, CON_CPQ.PRODUCT_MATERIAL_TYPE});
        
        if (qliList.size() > 0) {
            for (Quote_Line_Item__c qli: qliList) {
                if (qli.Bundle_Product__r.Material_Type__c != CON_CPQ.ZPUB) {
                    return 'ERROR_1: The current pricing process for EMEA only supports approvals for quotes that have only ZPUB products. Please either remove the non-ZPUB products from the Quote or cancel the Quote and proceed with Pricing Assistant.';
                }
            }
            return 'ERROR_2: There is one or more products from the cart without any pricing information provided, do you still want to proceed with finalizing the Quote? You will not be able to edit once the Quote is finalized.';
        }
        return 'Success';
    }
		
	public class UserWrapper {
        @auraEnabled public String userNameWithTier;
        @auraEnabled public String Id;   
    }  
    
    @AuraEnabled
    public static List<UserWrapper> getPriorityUserDetails(String priorityWithApproverIdsJson) {
        List<UserWrapper> userWrappers = new List<UserWrapper>();
        Set<Id> userIdSet = new Set<Id>();
        Map<String, List<String>> priorityWithUsersMap = new Map<String, List<String>>();
        Map<String, Object>mapString = (map<String,Object>) JSON.deserializeUntyped(priorityWithApproverIdsJson);
        for (String key : mapString.keySet()) {
            Object value = mapString.get(key);
            if (value instanceof List<Object>) {
                List<Object> objectList = (List<Object>) value;
                List<Id> userList = new List<Id>();
                for (Object item : objectList) {
                    userList.add((Id) item);
                }
                priorityWithUsersMap.put(key, userList);
                userIdSet.addAll(userList);            
            }
        }
        List<Id> userIds = new List<Id>();
        userIds.addAll(userIdSet);
        List<user> users = SLT_User.getUsersByUserIds(userIds);
        for (user user : users) {
            UserWrapper wrapper = new UserWrapper();
            for (String key :mapString.keySet()) {
                if (priorityWithUsersMap.get(key).contains(user.Id)) {
                    wrapper.id = user.Id;
                    wrapper.userNameWithTier = user.name + '' + '' + ' (Tier' + ' ' + key + ')';
                    break;
                }
                
            }
            userWrappers.add(wrapper);
        }
        return userWrappers;      
    }
    
    @AuraEnabled
    public static Id attachDocumentToFiles (String Name, Id parentRecord) {
		Id createContentLinkId;
		try {
			List<Document> document = new SLT_Document().selectUserByName(Name);
			if (document.isEmpty()) {
				AuraHandledException e = new AuraHandledException('Document not found with this name ');
				e.setMessage('Document not found with this name '+Name);
				throw e;
			}
			createContentLinkId = UTL_CPQ_FileServices.createContentLink(UTL_CPQ_FileServices.createContentVersion(document[0].Body, CON_CPQ.UPT_TEMPLATE_PREFIX + parentRecord + CON_CPQ.UPT_TEMPLATE_EXTENSION), parentRecord);
            if (createContentLinkId != null) {
                Quote__c quote = new Quote__c();
                quote.Id = parentRecord;
                quote.Tool_Launched_Already__c = true;  
                update quote;      
            }
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
        return createContentLinkId; 
    }

    @AuraEnabled
    public static Boolean isLaunchFiles (Id parentRecord) {
        String name = CON_CPQ.UPT_TEMPLATE_PREFIX + parentRecord + CON_CPQ.UPT_TEMPLATE_EXTENSION;
        Quote__c parentRec = [SELECT Related_Quote__c,Tool_Launched_Already__c FROM Quote__c WHERE Id =:parentRecord LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: parentRecord];
		if (contentDocumentLinks.size() == 0 && parentRec.Related_Quote__c == NULL && parentRec.Tool_Launched_Already__c == false) {
            return true;
        } else {
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
                if (contentDocumentLink.ContentDocument.Title == name) {
                    return false;
                }
            }
            return false;
        }          
    }
    @AuraEnabled
    public static  QuoteLineItemWrapper getQuoteLineItems(Id quoteId) {
        Integer pricingAssistantSize; 
        List<Quote_Line_Item__c> quoteLineItemsList = new List<Quote_Line_Item__c>();
     
        String condition = 'Quote__c = \'' + quoteId + '\' ';
        for (Quote_Line_Item__c qli : new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new Set<String>{CON_CPQ.ID, CON_CPQ.COUNTRY,'Bundle_Product__r.ProductCode', 'Bundle_Product__r.Material_Type__c', 'Bundle_Product__r.Excluded_From_Pricing_Assistant__c', 'Quote__r.Related_Opportunity__r.Exclude_from_Pricing_Assistant__c', 'Quote__r.Related_Opportunity__r.StageName','Quote__r.Pricing_Tools__c'})) {
            if (qli.Quote__r.Pricing_Tools__c == CON_CPQ.EMEA) {
                quoteLineItemsList.add(qli);
            }
        }
        Set<Id> oppIdSet = new Set<Id>{quoteLineItemsList[0].Quote__r.Related_Opportunity__c};
        List<Opportunity> oppList = new SLT_Opportunity().selectByIdWithPricingAssistant(oppIdSet);
        List<PC_Global_Setting_c__x> pcSettings = [select id,Cegedim_BUs_c__c,Name__c from PC_Global_Setting_c__x ];
        Map<String,PC_Global_Setting_c__x> pcGlobalSettingMap=  CNT_CPQ_QuoteWorkflow.prepareProductCodeWithSettingRecordMap(pcSettings);
        
        QuoteLineItemWrapper quoteLineItemWrapper = new QuoteLineItemWrapper();
        
        if (quoteLineItemsList.size() == 0) {
            quoteLineItemWrapper.showError = true;
            quoteLineItemWrapper.message = 'Opportunity does not fulfill Pricing Assistant creation criteria';
            return quoteLineItemWrapper;
        }
        
        for (Quote_Line_Item__c qli : quoteLineItemsList) {  
            if (qli.Quote__r.Related_Opportunity__r.Exclude_from_Pricing_Assistant__c && oppList[0].Pricing_Assistants__r.size() == 0) {
                quoteLineItemWrapper.message = 'Can not create Pricing Assistant as this opportunity is excluded from Pricing Assistant.';
                quoteLineItemWrapper.showError = true;
                return quoteLineItemWrapper;
            }

            String currentOppStage = quoteLineItemsList[0].Quote__r.Related_Opportunity__r.StageName.substring(0,1);
            if ((oppList[0].Pricing_Assistants__r.size() == 0) && (currentOppStage == '5' || currentOppStage == '6' || quoteLineItemsList[0].Quote__r.Related_Opportunity__r.StageName == 'In Hand')) {
                quoteLineItemWrapper.showError = true;
                quoteLineItemWrapper.message = 'Opportunities with Non excluded MC or CES Products must have a Pricing Assistant prior to being in Stage 5. Please update your Opportunity to include a Pricing Assistant.  If you are in Stage 4 you will not be allowed to move to Stage 5 until you have an Approved Pricing Assistant. If you attempt to modify the Opportunity after the Pricing Assistant has been approved, you will need to move the Opportunity into Stage 4 and then un-approve the Pricing Assistant to make adjustments to the Opportunity.';   
                return quoteLineItemWrapper;
            }
        
            if (oppList[0].LI_Opportunity_Id__c == null || oppList[0].LI_Opportunity_Id__c == '') {
                quoteLineItemWrapper.showError = true;
                quoteLineItemWrapper.message = 'Opportunity does not exist on Lagacy IMS Side.';
                return quoteLineItemWrapper;
            }
            if ((qli.Bundle_Product__r.Material_Type__c == 'ZREP') && (qli.Bundle_Product__r.Excluded_From_Pricing_Assistant__c == false || checkPAProduct(pcGlobalSettingMap, EMEA_BUSINESS_UNIT, qli.Bundle_Product__r.ProductCode))) {
                quoteLineItemWrapper.url =  CPQ_Settings__c.getOrgDefaults().LI_PA_URL__c + oppList[0].LI_Opportunity_Id__c + '&type=IQVIAQuote&subtype=EMEA';
                quoteLineItemWrapper.showError = false;
                return quoteLineItemWrapper;
            }      
          
        }

        quoteLineItemWrapper.showError = true;
        quoteLineItemWrapper.message = 'Opportunity does not fulfill Pricing Assistant creation criteria';
        return quoteLineItemWrapper;
    }
    
    public class QuoteLineItemWrapper {
        @AuraEnabled 
        public String message;
        @AuraEnabled 
        public Boolean showError; 
        @AuraEnabled 
        public String url;
    }
}
