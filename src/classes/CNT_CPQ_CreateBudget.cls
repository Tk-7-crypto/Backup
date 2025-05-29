public class CNT_CPQ_CreateBudget {
    @AuraEnabled
    public static Boolean isFieldAccessible(String pricingTool) {
        
        if (Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Select_Pricing_Tool__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.RecordTypeId.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Opportunity_Number__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.RFP_Scenario__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Scenario_Description__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Scenario_Number__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Budget_Iteration__c.isUpdateable() &&
            Schema.sObjectType.Apttus_Proposal__Proposal__c.fields.Apttus_Proposal__Primary__c.isUpdateable())
            return true;
        else
            return false;
    }
    
    @AuraEnabled
    public static WPR_CPQ_Status checkPostAward(Id recordId) {
        WPR_CPQ_Status status = new WPR_CPQ_Status();
        status.isSuccess = false;
        Bid_History__c clinicalBid = new SLT_Bid_History().getClinicalBidDetails(recordId, new Set<String>{CON_CPQ.BID_TO_ACCOUNT_STATUS, 'Bid_History_Related_Opportunity__r.StageName', CON_CPQ.BID_HISTORY_OPPORTUNITY, CON_CPQ.RECORD_TYPE_DEV_NAME, CON_CPQ.BUDGET_TOOLS});
        if (clinicalBid.Bid_History_Account__r.AccountStatus__c == CON_CPQ.INACTIVE) {
            status.isSuccess = false;
            status.errorMsg = 'Due to inactive status of the Account selected on the Opportunity, the Proposal cannot be created.';
            return status;
        }
        if (!status.isSuccess) {
            status.isSuccess = false;
            status.isSuccess = restrictSecondQuoteCreation(recordId);
            if (!status.isSuccess) {
                status.errorMsg = 'Only 1 Quote is allowed on 1 Bid History.';
                return status;
            }
        }
        if (clinicalBid.Budget_Tools__c == null) {
            status.isSuccess = false;
            status.errorMsg = 'Please select the Budget Tool.';
            return status;
        }
        if (clinicalBid.Record_Type_Developer_Name__c == CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID && (clinicalBid.Budget_Tools__c != 'LCS UPT' && clinicalBid.Budget_Tools__c != 'GRA UPT' && clinicalBid.Budget_Tools__c != 'Unit Pricing Tool')) {
            status.isSuccess = false;
            status.errorMsg = 'You cannot create a Quote record with the selected Budget tool.';
            return status;
        }
        if (clinicalBid.Bid_History_Related_Opportunity__r.StageName == CON_CPQ.OPPORTUNITY_STAGE_FINALIZING_DEAL && clinicalBid.Record_Type_Developer_Name__c == CON_CPQ.CONTRACT_POST_AWARD && (clinicalBid.Budget_Tools__c == 'LCS UPT' || clinicalBid.Budget_Tools__c == 'GRA UPT' || clinicalBid.Budget_Tools__c == 'Unit Pricing Tool')) {
            String condition = 'Apttus_Proposal__Opportunity__c in : oppoSet AND Apttus_Proposal__Approval_Stage__c = \'' + CON_CPQ.ACCEPTED + '\' AND RFP_Scenario__c != \'' + CON_CPQ.INACTIVE + '\' AND Apttus_Proposal__Proposal_Category__c IN (\'' + CON_CPQ.INITIAL + '\',\'' + CON_CPQ.REBID + '\')';
            if ((new SLT_Proposal().getRelatedProposalByRelatedOppIds(new Set<String>{CON_CPQ.ID}, condition, new Set<Id>{clinicalBid.Bid_History_Related_Opportunity__c})).size() == 0) {
                status.isSuccess = false;
                status.errorMsg = 'Please accept the pre-award Quote.';
                return status;
            }
        }
        status.isSuccess = true;
        return status;
    }

    @AuraEnabled
    public static AllDetails getAllRelatedBudgets(Id opportunityId, String pricingTool) {
        AllDetails allDetailsObj = new AllDetails();
        List<BudgetWrapper> budgetWrapperList = new List<BudgetWrapper>();
        Set<ID> opportunityIdSet = new Set<Id> { opportunityId };        
            Set<String> fieldSet = new Set<String> {
                CON_CPQ.ID,
                CON_CPQ.Name,
                CON_CPQ.RFP_SCENARIO,
                CON_CPQ.SCENARIO_DESCRIPTION,
                CON_CPQ.SCENARIO_NUMBER,
                CON_CPQ.BUDGET_ITERATION,
                CON_CPQ.PROPOSAL_NAME,
                CON_CPQ.APTTUS_PROPOSAL_PRIMARY,
                CON_CPQ.RECORDTYPE_NAME,
                CON_CPQ.BID_SENT_VALUE,
                CON_CPQ.TOTAL_BID_VALUE,
                CON_CPQ.TOTAL_QUOTE_VALUE,
                CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL,
                CON_CPQ.APTTUS_PROPOSAL_PARENT_BID,
                CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY,
                CON_CPQ.PROPOSAL_OPPORTUNITY_NAME,
                CON_CPQ.PROPOSAL_CATEGORY,
                CON_CPQ.APPROVAL_STAGE,
                CON_CPQ.BID_RECORD_TYPE_NAME,
                CON_CPQ.APTTUS_PROPOSAL_PARENT_BID,
                CON_CPQ.REQ_AGMT_TYPE
            };
                        
        Id recordTypeId;
        if(pricingTool == CON_CPQ.UNIT_PRICING_TOOL || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT_LABEL || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT_LABEL) {
            recordTypeId = CPQ_Utility.proposalBudgetRecordTypeId;
        } else {
            recordTypeId = CPQ_Utility.proposalRDSNonSFRecordTypeId;
        }
        String condition = 'RecordTypeId = \'' + recordTypeId + '\' and Apttus_Proposal__Opportunity__c in :opportunityIdSet and RFP_Scenario__c != \''+CON_CPQ.INACTIVE+'\'';
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getQuoteByParentRelatedOpportunity(opportunityIdSet, fieldSet, condition);
        for (Apttus_Proposal__Proposal__c proposal : proposalList) {
            budgetWrapperList.add(new BudgetWrapper(proposal));
        } 
        
        allDetailsObj.budgetWrapperList = budgetWrapperList;
        return allDetailsObj;
    }
    
    @AuraEnabled
    public static WPR_CPQ_PicklistValues getPicklistvalues(String objectName, String field_apiname, String developerName, Id opportunityId) {
        WPR_CPQ_PicklistValues picklistValuesObj = new WPR_CPQ_PicklistValues();
        List<String> picklistValues = new List<String>();
        List<CPQ_Available_Budget_Type_for_Quote__mdt> mappings = [SELECT Budget_Types__c FROM CPQ_Available_Budget_Type_for_Quote__mdt WHERE DeveloperName =:developerName];        
        if (mappings.size() > 0 && mappings[0].Budget_Types__c != null) {
            picklistValues = mappings[0].Budget_Types__c.split(CON_CPQ.SEMICOLON);  
        }
        List<String> picklistValue = new List<String>();
        String stageName = '';
        List<Opportunity> opp = [SELECT Id, StageName FROM Opportunity WHERE Id =: opportunityId];
        if (opp.size() > 0 && opp != null) {
            stageName = opp[0].StageName;
        }
        if (stageName == CON_CPQ.OPP_STAGE_3 || stageName == CON_CPQ.OPP_STAGE_4) {
            if (developerName == 'Create_Budget_SF'){
                picklistValue.add('Initial');
                picklistValue.add('Rebid');
                picklistValuesObj.budgetTypes = picklistValue;
            } else {
                picklistValuesObj.budgetTypes = picklistValues;
            }  
        } else {
            picklistValuesObj.budgetTypes = picklistValues;
        }
        picklistValuesObj.scenarioByBudgetTypeMap = getScenariosByBudgetType(objectName, field_apiname);
        
        return picklistValuesObj;
    }
    
    public static Map<String, List<String>> getScenariosByBudgetType(String objectName, String dependentField) {
        return CPQ_Utility.getDependentValuesByControllingValue(objectName, dependentField);
    }
    
    @AuraEnabled
    public static WPR_CPQ_PicklistValues getBudgetTypesValues(String objectName, String field_apiname, String bidRecordType, String quoteCreatedFrom, Id opportunityId, String reqAgmtType) {  
        String agmtType = reqAgmtType == null ? 'None' : '%'+reqAgmtType+'%';
        WPR_CPQ_PicklistValues picklistValuesObj = new WPR_CPQ_PicklistValues();
        List<String> picklistValues = new List<String>();
        List<CPQ_Available_Budget_Type_for_Quote__mdt> mappings = [SELECT Budget_Types__c FROM CPQ_Available_Budget_Type_for_Quote__mdt WHERE Quote_Created_From__c =: quoteCreatedFrom AND Record_Type__c =: bidRecordType AND Requested_Agreement_Type__c like :agmtType];
        if (mappings.size() > 0 && mappings[0].Budget_Types__c != null) {
            picklistValues = mappings[0].Budget_Types__c.split(CON_CPQ.SEMICOLON);  
        }
        picklistValuesObj.budgetTypes = picklistValues;
        picklistValuesObj.scenarioByBudgetTypeMap = getScenariosByBudgetType(objectName, field_apiname);
        return picklistValuesObj;
    }
	
    @AuraEnabled
    public static WPR_CPQ_Status createAnySobject(Id recordId, Id contractId, Id budgetId, String name, String pricingTool, String scenario, String scenarioDescription,
        Integer scenarioNumber, Integer budgetIteration, Boolean markAsPrimary, Id oppId, Id accId, String budgetType, String parentScenario, String parentBudgetType) {
            WPR_CPQ_Status status = new WPR_CPQ_Status();
            status.isSuccess = true;
            Apttus_Proposal__Proposal__c newBudget = new Apttus_Proposal__Proposal__c();
            fflib_SObjectUnitOfWork uowBudget = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus_Proposal__Proposal__c.SobjectType
                }
            );
            fflib_SObjectUnitOfWork uowBidHistory = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Bid_History__c.SobjectType
                }
            );
            if (recordId == null) {
                Map<Id, Bid_History__c> clinicalBidMap = new SLT_Bid_History().getLatestClinicalBidOnOpportunity(new Set<Id> {oppId}, new Set<String> {CON_CPQ.RECORDTYPE, CON_CPQ.BID_HISTORY_OPPORTUNITY, CON_CPQ.RECORD_TYPE_DEV_NAME}, 'Bid_History_Related_Opportunity__c in :opportunityIdSet AND (Record_Type__c = \'Clinical Bid\' OR Record_Type__c = \'Contract Post Award\')');
                List<Bid_History__c> clinicalBidList = clinicalBidMap.values();
                if (clinicalBidList.size() > 0) {
                    recordId = clinicalBidList[0].Id;
                }
                if (accId != null) {
                    newBudget.Apttus_Proposal__Account__c = accId;
                }
            }
            if (budgetId != null) {
                newBudget = CPQ_Utility.cloneBudget(recordId, budgetId, pricingTool, scenario, budgetType, parentScenario, parentBudgetType);
            } else if (recordId != null) {
                newBudget = CPQ_Utility.cloneClinical(recordId, pricingTool);
            }
            if (pricingTool == CON_CPQ.UNIT_PRICING_TOOL || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT_LABEL || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT_LABEL ||
                pricingTool== CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT) {
                newBudget.RecordTypeId = CPQ_Utility.proposalBudgetRecordTypeId;
                /* Commented under LC-11450
                newBudget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
                */
                newBudget.Approval_Status__c = CON_CPQ.NONE;
            } else {
                newBudget.currencyISOCode = null;
                newBudget.RecordTypeId = CPQ_Utility.proposalRDSNonSFRecordTypeId;
                newBudget.Approval_Status__c = CON_CPQ.NONE;
            }
            newBudget.Contract__c = contractId;  
            newBudget.Apttus_Proposal__Proposal_Name__c = name;
            newBudget.Scenario_Description__c = scenarioDescription;
            newBudget.Scenario_Number__c = scenarioNumber;
            newBudget.RFP_Scenario__c = scenario;
            newBudget.Budget_Iteration__c = 1;
            newBudget.Apttus_Proposal__Primary__c = markAsPrimary;
            newBudget.Apttus_Proposal__Opportunity__c = oppId;
            newBudget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
            newBudget.Apttus_Proposal__Proposal_Category__c = budgetType;
            newBudget.Select_Pricing_Tool__c = pricingTool;

            CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
            if (cpqSetting != null && cpqSetting.Bid_Grid_Mapping_Email__c != null) {
                newBudget.Requester_email__c = cpqSetting.Bid_Grid_Mapping_Email__c;
            }
            
            if (pricingTool == CON_CPQ.UNIT_PRICING_TOOL) 
                newBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
            else if (pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT_LABEL)
                newBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
            else if (pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT_LABEL)
                newBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT;
            else if (pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_IQB_UPT_LABEL)
                newBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_IQB_UPT;
            
            if (newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC || newBudget.Apttus_Proposal__Proposal_Category__c == 
                CON_CPQ.PRELIMINARY || newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CNF || newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER
                || newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.BALLPARK) {
                    newBudget.OwnerId = UserInfo.getUserId();
                }
            
            if(newBudget.currencyISOCode == null && oppId != null)
            {
                Map<Id, Opportunity> opportunityMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{oppId},new Set<String>{CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE});
                if(opportunityMap != null && opportunityMap.containsKey(oppId))
                {
                    newBudget.currencyISOCode = opportunityMap.get(oppId).CurrencyIsoCode;
                }
            }
            if (newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.CHNAGE_ORDER) {
                List<Apttus_Proposal__Proposal__c> changeOrderProposals = new List<Apttus_Proposal__Proposal__c>();
                changeOrderProposals.add(newBudget);
                if (status.isSuccess) {
                    String result = validateChangeOrderQuoteWRTAgreement(changeOrderProposals);
                    if(result != 'success') {
                        status.isSuccess = false;
                        status.errorMsg = result;
                        return status;
                    }
                }
            }
            else if (newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.PROJECT_SPECIFIC) {
                status.isSuccess = restrictSecondPSQuoteCreation(newBudget.Apttus_Proposal__Opportunity__c);
                if (!status.isSuccess) {
                    status.errorMsg = 'A Project Specific Quote already exists. Creation of another Quote can not be performed.';
                }
            }
            
            if (status.isSuccess) {
                try {
                    uowBudget.registerNew(newBudget);
                    uowBudget.commitWork();
                    CPQ_Utility.createProposalTeamMemberRecord(new List<Apttus_Proposal__Proposal__c>{newBudget}, null);	
                    
                    if (newBudget.Apttus_Proposal__Primary__c) {
                        CPQ_Utility.markAsPrimary(true, oppId, newBudget.Id);
                    }
                    if (newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.INITIAL || newBudget.Apttus_Proposal__Proposal_Category__c == CON_CPQ.REBID) {
                        uowBidHistory.registerDirty(new Bid_History__c(Id = newBudget.Clinical_Bid__c, Related_Quote_Status__c = CON_CPQ.NOT_READY_TO_AWARD, Related_Quote_Id__c = newBudget.Id));
                        uowBidHistory.commitWork();
                    }
                    status.budgetId = newBudget.id;
                    return status;
                }
                catch (DmlException ex) {
                    String errorMessage = ex.getDmlMessage(0) + '\n' + ex.getStackTraceString();
                    CPQ_Utility.createApexErrorLogRecord(ex.getDmlId(0), errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
                    throw new AuraHandledException(ex.getDmlMessage(0));
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            else {
                return status;
            } 
    }
	
    @AuraEnabled
    public static BudgetWrapper setWrapper(Apttus_Proposal__Proposal__c proposal) {
        BudgetWrapper budgetWrapper =  new BudgetWrapper(proposal);
        return budgetWrapper;
    }
    public class AllDetails {
        @AuraEnabled
        public List<BudgetWrapper> budgetWrapperList {get; set;}
    }
    public static String validateChangeOrderQuoteWRTAgreement(List<Apttus_Proposal__Proposal__c> proposals) {
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<String> nonPSAgreementSubTypes = new Set<String>{CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA, CON_CLM.REQUESTED_AGREEMENT_TYPE_WO, CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA, CON_CPQ.GCA_SMALL_PROJECTS, CON_CPQ.GSA_SMALL_PROJECTS};
        Set<String> flightAgreementStatus = new Set<String>{CON_CLM.TERMINATED, CON_CLM.CANCELLED, CON_CPQ.AMENDED, CON_CLM.IN_EFFECT, CON_CLM.EXPIRED};
        for (Apttus_Proposal__Proposal__c budget : proposals) {
            opportunityIdSet.add(budget.Apttus_Proposal__Opportunity__c);
        }
        String conditionForAgreement = 'Apttus__Related_Opportunity__c IN : opportunityIDSet AND RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID + '\'';
        Set<String> agreementFieldSet = new Set<String>{'Apttus__Related_Opportunity__c','Apttus__Status__c','Apttus__Status_Category__c','Id', 'Apttus__Subtype__c'};
        Map<Id,Apttus__APTS_Agreement__c> agreementMap = new SLT_APTS_Agreement().getBudgetsRelatedToOpportunity(opportunityIdSet, agreementFieldSet, conditionForAgreement);
        Map<Id, Integer> oppToFlightAgreementCount = new Map<Id, Integer>();
        Boolean isPSAgreementActive = false;
        Boolean isChangeOrderAgreementActivated = false;

        for (Apttus__APTS_Agreement__c agreement : agreementMap.values()) {
            if (nonPSAgreementSubTypes.contains(agreement.Apttus__Subtype__c) && (agreement.Apttus__Status_Category__c == CON_CPQ.AMENDED || agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT)) {
                isPSAgreementActive = true;
            }
            if (!flightAgreementStatus.contains(agreement.Apttus__Status_Category__c) && agreement.Apttus__Subtype__c == CON_CPQ.CHNAGE_ORDER) {
                if (oppToFlightAgreementCount.containsKey(agreement.Apttus__Related_Opportunity__c)) {
                    oppToFlightAgreementCount.put(agreement.Apttus__Related_Opportunity__c, (oppToFlightAgreementCount.get(agreement.Apttus__Related_Opportunity__c) + 1));
                } else {
                    oppToFlightAgreementCount.put(agreement.Apttus__Related_Opportunity__c, 1);
                }
            }
            if ((agreement.Apttus__Status_Category__c == CON_CPQ.AMENDED || agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT) && agreement.Apttus__Subtype__c == CON_CPQ.CHNAGE_ORDER) {
                isChangeOrderAgreementActivated = true;
            }
        }
        
        for (Apttus_Proposal__Proposal__c budget: proposals) {
            Integer changeOrderCount = oppToFlightAgreementCount.containsKey(budget.Apttus_Proposal__Opportunity__c) ? oppToFlightAgreementCount.get(budget.Apttus_Proposal__Opportunity__c) : 0;
            if (changeOrderCount > 1) { 
                return 'You cannot create a CO Quote record as the existing CO Agreement(s) is yet not In Effect/Activated. Please update the Agreement record status.';
            } else if (changeOrderCount == 0 && !isPSAgreementActive && !isChangeOrderAgreementActivated) {
                return 'You cannot create a Quote record as the existing Project Specific Agreement is yet not In Effect/Activated. Please update the Agreement record status.';
            }
        }
        return 'success';
    }
    
    public static Boolean restrictSecondPSQuoteCreation (Id OppId) {
        Boolean isFirstPSQuote = true;
        Set<ID> opportunityIdSet = new Set<Id> { oppId };
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        String condition = 'Apttus_Proposal__Proposal_Category__c = \'' + CON_CPQ.PROJECT_SPECIFIC + '\' and Apttus_Proposal__Opportunity__c in :opportunityIdSet and RFP_Scenario__c != \''+CON_CPQ.INACTIVE+ '\' AND Apttus_Proposal__Approval_Stage__c != \'' + CON_CPQ.CANCELLED_STATUS + '\'';
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getQuoteByParentRelatedOpportunity(opportunityIdSet, fieldSet, condition);
        if (proposalList.size() > 0) {
            isFirstPSQuote = false;
        }
        return isFirstPSQuote;
    }
	
	public static Boolean restrictSecondQuoteCreation (Id clinicalBidIds) {
        Boolean isFirstQuote = true;
        String conditon = 'Clinical_Bid__c IN : clinicalBidIds AND Clinical_Bid__c != NULL AND RFP_Scenario__c != \''+CON_CPQ.INACTIVE +  '\'';
        List<Apttus_Proposal__Proposal__c> existingProposalList = new SLT_Proposal().getQuoteByParentClinicalBid(new Set<Id>{clinicalBidIds}, new Set<String> {CON_CPQ.ID, CON_CPQ.PROPOSAL_CATEGORY}, conditon);
        if (existingProposalList.size() > 0) {
            isFirstQuote = false;
        }
        return isFirstQuote;
    }
    /*
     * Version       : 1.0
     * Description   : Budget Wrapper Class
     */
    public class BudgetWrapper {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String agId {get; set;}
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String clinicalBidId {get; set;}
        @AuraEnabled
        public String oppId {get; set;}
        @AuraEnabled
        public String pricingTool {get; set;}
        @AuraEnabled
        public String quoteName {get; set;}
        @AuraEnabled
        public String recordType {get; set;}
        @AuraEnabled
        public Boolean isPrimary {get; set;}
        @AuraEnabled
        public decimal bidNumber {get; set;}
        @AuraEnabled
        public Date bidDueDate {get; set;}
        @AuraEnabled
        public String scenario {get; set;}
        @AuraEnabled
        public String scenarioDes {get; set;}
        @AuraEnabled
        public decimal scenarioNumber {get; set;}
        @AuraEnabled
        public decimal budgetIteration {get; set;}
        @AuraEnabled
        public Date bidSentDate {get; set;}
        @AuraEnabled
        public decimal totalBidValue {get; set;}
        @AuraEnabled
        public decimal totalQuoteValue {get; set;}
        @AuraEnabled
        public String budgetType {get; set;}
        @AuraEnabled
        public String approvalStage {get; set;}
        @AuraEnabled
        public String budgetName {get; set;}
        @AuraEnabled
        public String isAgreementActivated {get; set;}
        @AuraEnabled
        public String bidRecordType {get; set;}
        @AuraEnabled
        public String reqAgreementType {get; set;}
        
        //Constructor 
        public BudgetWrapper(Apttus_Proposal__Proposal__c quote) {
            this.Id = quote.Id;
            this.agId = '/' + quote.Id;
            this.name = quote.Apttus_Proposal__Proposal_Name__c;
            this.recordType = quote.RecordType.Name;
            this.bidDueDate = null;
            this.isPrimary = quote.Apttus_Proposal__Primary__c;
            this.bidNumber = null;
            this.budgetIteration = quote.Budget_Iteration__c;
            this.scenario = quote.RFP_Scenario__c;
            this.scenarioDes = quote.Scenario_Description__c;
            this.scenarioNumber = quote.Scenario_Number__c;
            this.bidSentDate = quote.Bid_Sent_Date__c;
            this.totalBidValue = quote.Total_Bid_Value_Labor_Direct_Discount__c;
            this.totalQuoteValue = quote.Total_Quote_Amount__c;
            this.oppId = quote.Apttus_Proposal__Opportunity__c;
            this.pricingTool = quote.Select_Pricing_Tool__c;
            this.quoteName = quote.Apttus_Proposal__Opportunity__r.Name;
            this.budgetType = quote.Apttus_Proposal__Proposal_Category__c;
            this.approvalStage = quote.Apttus_Proposal__Approval_Stage__c;
            this.budgetName = quote.Name;
            this.bidRecordType = quote.Clinical_Bid__r.Record_Type_Developer_Name__c;
            this.reqAgreementType = quote.Clinical_Bid__r.Requested_Agreement_Type__c;
        }
    }
    
    public class WPR_CPQ_PicklistValues {
        @AuraEnabled
        public List<String> scenarios {get; set;}
        @AuraEnabled
        public List<String> budgetTypes {get; set;}
        @AuraEnabled
        public Map<String, List<String>> scenarioByBudgetTypeMap {get; set;}
    }
    
    public class WPR_CPQ_Status {
        @AuraEnabled
        public Boolean isSuccess {get; set;}
        @AuraEnabled
        public String errorMsg {get; set;}
        @AuraEnabled
        public Id budgetId {get; set;}
    }
}
