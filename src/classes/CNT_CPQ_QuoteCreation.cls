public class CNT_CPQ_QuoteCreation {

    @AuraEnabled
    public static String getDetails(Id recordId) {
        try {
            Bid_History__c bidHistory;
            Opportunity opp;
            List<CPQ_Proposal_Create_Settings__c> customSettings;
            List<String> assignedPermissionsetNameList = new List<String>();
            List<Iqvia_Cpq_QuoteDetails> wrapperList = new List<Iqvia_Cpq_QuoteDetails>();
            if (String.valueOf(recordId.getsobjecttype()) == CON_CPQ.BID_HISTORY) {
                bidHistory = new SLT_Bid_History().getClinicalBidDetails(recordId, new Set<String>{CON_CPQ.RELATED_BID_OPPORTUNITY_ACCOUNT_STATUS, CON_CPQ.RECORD_TYPE_DEV_NAME});
                if (bidHistory.Bid_History_Related_Opportunity__r.Account.AccountStatus__c == CON_CPQ.INACTIVE) {
                    throw new CPQ_CustomException(CON_CPQ.INACTIVE_ACCOUNT_VALIDATION);
                }
                customSettings = [SELECT GBU__c, Available_Pricing_Tools__c, Conga_Setup__c, Pathway__c, Permission_Set_Name__c, Bid_History_Record_Type_Name__c FROM CPQ_Proposal_Create_Settings__c WHERE GBU__C != null AND Bid_History_Record_Type_Name__c =: bidHistory.Record_Type_Developer_Name__c Order by GBU__c desc];
            } else if (String.valueOf(recordId.getsobjecttype()) == CON_CPQ.OPPORTUNITY) {
                opp = new SLT_Opportunity().getOpportunityDetails(recordId, new Set<String>{CON_CPQ.NAME, CON_CPQ.OPPORTUNITY_RELATED_ACCOUNT_STATUS});
                if (opp.getSObject(CON_CPQ.ACCOUNT).get(CON_CPQ.ACCOUNT_STATUS) == CON_CPQ.INACTIVE) {
                    throw new CPQ_CustomException(CON_CPQ.INACTIVE_ACCOUNT_VALIDATION);
                }
                customSettings = [SELECT GBU__c, Available_Pricing_Tools__c, Conga_Setup__c, Pathway__c, Permission_Set_Name__c, Bid_History_Record_Type_Name__c FROM CPQ_Proposal_Create_Settings__c WHERE GBU__C != null Order by GBU__c desc];
            }
            for (PermissionSetAssignment psa : [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()]) {
                assignedPermissionsetNameList.add(psa.PermissionSet.Name);
            }
            for (CPQ_Proposal_Create_Settings__c customSetting : customSettings) {
                Iqvia_Cpq_QuoteDetails wrapper = new Iqvia_Cpq_QuoteDetails();
                wrapper.GBU = customSetting.GBU__C != null ? customSetting.GBU__C : null;
                wrapper.pricingTool = customSetting.Available_Pricing_Tools__c != null ? customSetting.Available_Pricing_Tools__c : null;
                wrapper.pathway = customSetting.Pathway__c != null ? customSetting.Pathway__c : null;
                wrapper.congaSetup = customSetting.Conga_Setup__c != null ? customSetting.Conga_Setup__c : null;
                wrapper.bidHistoryRecordType = customSetting.Bid_History_Record_Type_Name__c != null ? customSetting.Bid_History_Record_Type_Name__c : null;
                if (assignedPermissionsetNameList.contains(customSetting.Permission_Set_Name__c)) {
                    wrapper.hasAccess = CON_CPQ.YES_TITLE_CASE;
                } else {
                    wrapper.hasAccess = CON_CPQ.NO_TITLE_CASE;
                }
                wrapper.oppName = opp != null ? opp.Name : null;
                if (customSetting.GBU__C == CON_CPQ.GBU_RDS_NON_SF_WRF) {
                    wrapper.NonSFTools = CON_CPQ.BUDGET_TOOL_VALUES;
                    wrapper.NonSFBudgetTypes = [SELECT Budget_Types__c FROM CPQ_Available_Budget_Type_for_Quote__mdt where DeveloperName = 'Clone_Quote_from_Opportunity'].Budget_Types__c.split(';');
                    wrapper.NonSFScenario = CPQ_Utility.getDependentValuesByControllingValue(CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.REQUESTED_TYPE);
                    wrapper.isRocheUser = assignedPermissionsetNameList.contains(CON_CPQ.CNF_ROCHE_PERMISSION);
                }
                wrapperList.add(wrapper);
            }
            return JSON.serialize(wrapperList, true);
        } catch (Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }
    
    public static String createQuote(String pricingTools, String gbu, Id recordId, String objectApiName, String bidScenarios) {
        List<String> pricingToolList = pricingTools.split(';');
        List<CPQ_Proposal_Create_Settings__c> customSettingList = new List<CPQ_Proposal_Create_Settings__c>();
        try {
            Set<String> opportunityFieldSet = new Set<String>();
            Id opportunityId;
            String identifiedBusiness;
            Quote__c newBudget = new Quote__c();
            if (objectApiName == CON_CPQ.BID_HISTORY) {
                newBudget.Related_Bid__c = recordId;
                opportunityId = new SLT_Bid_History().getRecordById(recordId).Bid_History_Related_Opportunity__c;
                newBudget.Quote_Type__c = CPQ_Utility.getQuoteType(recordId, pricingTools);
            } else {
                opportunityId = recordId;
            }
            if (newBudget.Quote_Type__c == CON_CPQ.CHANGE_ORDER) {
                if (pricingTools.contains(CON_CPQ.Q2_Solutions)) {
                    String condition = 'Related_Opportunity__c =: relatedOpportunityIdSet AND (Quote_Type__c = \'' + CON_CPQ.INITIAL + '\' OR Quote_Type__c = \'' + CON_CPQ.BID_TYPE_REBID + '\' OR  Quote_Type__c = \'' + CON_CPQ.CHNAGE_ORDER + '\')';
                    List<Quote__c> lastAcceptedQuotes = new SLT_IQVIA_Quote().getQuotesByCondition(new Set<String>{CON_CPQ.ID, CON_CPQ.QUOTE_APPROVAL_STAGE, 'Quote_Type__c'}, condition, new Set<Id>{opportunityId});
                    Boolean flag = false;
                    for (Quote__c quote : lastAcceptedQuotes) {
                        if ((quote.Approval_Stage__c == CON_CPQ.ACCEPTED && quote.Quote_Type__c == CON_CPQ.CHNAGE_ORDER) || quote.Quote_Type__c == CON_CPQ.INITIAL || quote.Quote_Type__c == CON_CPQ.BID_TYPE_REBID) {
                            flag = true;
                            break;
                        }
                    }
                    if (!lastAcceptedQuotes.isEmpty() && flag) {
                        throw new CPQ_CustomException('For Change Orders, you can only clone a quote from the last accepted quote.');
                    }
                } else {
                    throw new CPQ_CustomException('For Change Orders, you can only clone a quote from the last accepted quote.');
                }
            } else {
                newBudget.Change_Order_Number__c = 0;
            }
            if (opportunityId != null) {
                String condition = 'Related_Opportunity__c IN: relatedOpportunityIdSet';
                List<Quote__c> existingQuotesOnOpportunity = new SLT_IQVIA_Quote().getQuotesByCondition(new Set<String>{CON_CPQ.ID}, condition, new Set<Id>{opportunityId});
                if (existingQuotesOnOpportunity.isEmpty()) {
                    newBudget.Primary__c = true;
                }
            }
            List<Schema.PicklistEntry> gbuPicklistEntryList = Quote__c.GBU__c.getDescribe().getPicklistValues();
            Map<String,String> gbuLabelToApiMap = new Map<String,String>();
            for (Schema.PicklistEntry picklistValue : gbuPicklistEntryList) {
                gbuLabelToApiMap.put(picklistValue.getLabel(), picklistValue.getValue());
            }
            newBudget.GBU__c = gbuLabelToApiMap.get(gbu);
            newBudget.Pricing_Tools__c = pricingTools;
            List<CPQ_Mapping_Field_Set__mdt> mappingsPricingToolList = new List<CPQ_Mapping_Field_Set__mdt>();
            for (CPQ_Mapping_Field_Set__mdt mapFields : [SELECT Opportunity_Field__c, Quote_Field__c, Pricing_Tool__c FROM CPQ_Mapping_Field_Set__mdt WHERE Sobject_Name__c = 'Quote__c' AND Feature_Selection__c = 'Quote Creation']) {
                for (String pricingTool: pricingToolList) {
                    if (mapFields.Pricing_Tool__c.contains(pricingTool)) {
                        mappingsPricingToolList.add(mapFields);
                        opportunityFieldSet.add(mapFields.Opportunity_Field__c);
                    }
                }
            }
            opportunityFieldSet.add(CON_CPQ.LINE_OF_BUSINESS);
            opportunityFieldSet.add(CON_CPQ.IDENTIFIED_BUSINESS);
            opportunityFieldSet.add(CON_CPQ.OPPORTUNITY_STAGENAME);
            sobject opportunityRecord = new SLT_Opportunity().getOpportunityDetails(opportunityId, opportunityFieldSet);
            if (opportunityRecord.get(CON_CPQ.OPPORTUNITY_STAGENAME) == CON_CPQ.OPPORTUNITY_7B_CLOSED_LOST_STAGE) {
                throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + 'You cannot create/clone quote at "7-b Closed lost" stage of opportunity.');
            }
            List<CPQ_Proposal_Create_Settings__c> cpqProposalCreateSetting = [SELECT GBU__c, Available_Pricing_Tools__c, Price_List__c, CurrencyIsoCode__c, Conga_Setup__c, Line_of_Business__c, Identified_Business__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN: pricingToolList];           
            if (pricingTools.contains(CON_CPQ.Q2_Solutions)) {
                Boolean isBusinessInfoSet = false;
                String lineOfBusiness;
                for (CPQ_Proposal_Create_Settings__c customSetting : cpqProposalCreateSetting) {
                    if (!isBusinessInfoSet && customSetting.Available_Pricing_Tools__c == CON_CPQ.Q2_Solutions && customSetting.Line_of_Business__c != null && customSetting.Identified_Business__c != null) {
                        lineOfBusiness = customSetting.Line_of_Business__c;
                        identifiedBusiness = customSetting.Identified_Business__c;
                        isBusinessInfoSet = true;
                    }
                }
                List<String> allowedBusinessesList = identifiedBusiness != null ? identifiedBusiness.split(';') : new List<String>();
                if (opportunityRecord.get(CON_CPQ.LINE_OF_BUSINESS) != lineOfBusiness || !allowedBusinessesList.contains((String)opportunityRecord.get(CON_CPQ.IDENTIFIED_BUSINESS))){
                    throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + 'Please select correct \'Line of Business\' and \'Identified Business\' on opportunity.');
                }
                String condition = identifiedBusiness != null ? 'AND Type__c IN (\'' + String.join(allowedBusinessesList, '\',\'') + '\')' : '';
                Set<String> collectionToolFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.RELATED_BID_HISTORY_STUDY_NUMBER};
                List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolsByCondition(recordId, collectionToolFieldSet, condition);
                if (collectionToolList.size() > 0 ) {
                    String collectionToolCount = collectionToolList[0].Bid_History__r.Study_Number__c;
                    if (integer.valueof(collectionToolCount) != collectionToolList.size()) {
                        throw new CPQ_CustomException(CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
                    }
                } else if (collectionToolList.size() == 0 ) {
                    throw new CPQ_CustomException(CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
                }
            }
            sobject sb = opportunityRecord;
            for (CPQ_Mapping_Field_Set__mdt mapFields : mappingsPricingToolList) {
                if (mapFields.Opportunity_Field__c.contains('.')) {
                    List<string> splitedFields = mapFields.Opportunity_Field__c.split('\\.');
                    for (integer i = 0; i < splitedFields.size() - 1; i++) {
                        sb = opportunityRecord.getSobject(splitedFields[i]);   
                    }
                    newBudget.put(mapFields.Quote_Field__c, string.valueof(sb.get(splitedFields[splitedFields.size()-1])));
                } else if (opportunityRecord.get(mapFields.Opportunity_Field__c) != null) {
                    newBudget.put(mapFields.Quote_Field__c, opportunityRecord.get(mapFields.Opportunity_Field__c));
                }
            }
            for (CPQ_Proposal_Create_Settings__c customSetting : cpqProposalCreateSetting) {
                newBudget.CurrencyIsoCode = customSetting.CurrencyIsoCode__c != null ? customSetting.CurrencyIsoCode__c : newBudget.CurrencyIsoCode;
                if (customSetting.Conga_Setup__c == true) {
                    customSettingList.add(customSetting);
                }
            }
            fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote__C.SobjectType, Quote_Requisites__c.SobjectType
                }
            );
            if (pricingTools.contains(CON_CPQ.EMEA) || pricingTools.contains(CON_CPQ.Q2_Solutions)) {
                newBudget.Scenario__c = 1;
            }
            String result = '';
            if (objectApiName == CON_CPQ.BID_HISTORY && pricingTools.contains(CON_CPQ.Complete_Consent)) {
                result = processCollectionTool(recordId, newBudget, uowProposal, double.valueof(bidScenarios), false);
            } else if (objectApiName == CON_CPQ.BID_HISTORY && pricingTools.contains(CON_CPQ.Q2_Solutions)) {
                result = collectionToolToQuoteRequisites(recordId, newBudget, uowProposal, false, identifiedBusiness);
            } else {
                uowProposal.registerNew(newBudget);
            }

            if (!(CON_CPQ.SUCCESS == result || String.isBlank(result))) {
                throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + 'The selected Country ' + result + ' on Collection Tool, doesn not exist in the CPQ Workflow, Please Contact Support.');
            }
            uowProposal.commitWork();
            if (pricingToolList.size() > 0 && customSettingList.size() > 0) {
                List<RecordType> recordTypeList = new SLT_RecordType().getRecordType(CON_CPQ.TECH_SOLUTION);
                createCongaQuotes(pricingToolList, recordTypeList[0].Id, opportunityId, newBudget.Id, customSettingList);
            }
            if (pricingTools.contains(CON_CPQ.EMEA) || pricingTools.contains(CON_CPQ.Q2_Solutions)) {
                CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(newBudget.Id, opportunityId);
            }
            return newBudget.id;
        } catch (Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }

    public static String createCongaQuotes(List<String> pricingTools, String recordTypeId, Id  opportunityId, Id iqviaQuoteId, List<CPQ_Proposal_Create_Settings__c> customSettingList) {
        Map<String, String> priceListByPricingToolMap = new Map<String, String>();
        Map<String, String> currencyIsoCodeByPricingToolMap = new Map<String, String>();
        Set<String> opportunityFieldSet = new Set<String>();
        Map<String, Set<CPQ_Mapping_Field_Set__mdt>> FieldSetByPricingToolMap = new Map<String, Set<CPQ_Mapping_Field_Set__mdt>>();
        Set<String> pricingToolSet = new Set<String>();
        for (CPQ_Proposal_Create_Settings__c customSetting : customSettingList) {
            if (customSetting.Available_Pricing_Tools__c != null) {
                pricingToolSet.add(customSetting.Available_Pricing_Tools__c);
                if (customSetting.Price_List__c != null) {
                    priceListByPricingToolMap.put(customSetting.Available_Pricing_Tools__c, customSetting.Price_List__c);
                }
                if (customSetting.CurrencyIsoCode__c  != null) {
                    currencyIsoCodeByPricingToolMap.put(customSetting.Available_Pricing_Tools__c, customSetting.CurrencyIsoCode__c );
                }
            }
        }
        if (pricingToolSet.size() > 0) {
            List<CPQ_Mapping_Field_Set__mdt> mappingsList = [SELECT Opportunity_Field__c, Quote_Field__c, Pricing_Tool__c FROM CPQ_Mapping_Field_Set__mdt WHERE Sobject_Name__c = 'Apttus_Proposal__Proposal__c'];
            for (String pricingTool: pricingToolSet) {
                Set<CPQ_Mapping_Field_Set__mdt> oppFieldSet = new Set<CPQ_Mapping_Field_Set__mdt>();
                if (!FieldSetByPricingToolMap.containsKey(pricingTool)) {
                    FieldSetByPricingToolMap.put(pricingTool, oppFieldSet);
                }
                oppFieldSet = FieldSetByPricingToolMap.get(pricingTool);
                for (CPQ_Mapping_Field_Set__mdt mapFields : mappingsList) {
                    if(mapFields.Pricing_Tool__c.contains(pricingTool)) {
                        opportunityFieldSet.add(mapFields.Opportunity_Field__c);
                        oppFieldSet.add(mapFields);
                    }
                }
                FieldSetByPricingToolMap.put(pricingTool, oppFieldSet);
            }
            sobject opportunityRecord = new SLT_Opportunity().getOpportunityDetails(opportunityId, opportunityFieldSet);
            Set<String> currencyIsoCodeSet = new Set<String>();
            currencyIsoCodeSet.addAll(currencyIsoCodeByPricingToolMap.values());
            currencyIsoCodeSet.add((String)opportunityRecord.get(CON_CPQ.CURRENCYISOCODE));
            sobject sb = opportunityRecord; 
            Map<String, String> priceListNameByCurrencyAndPricingToolMap = new Map<String, String>();
            Set<String> priceListSet = new Set<String>();
            priceListSet.addAll(priceListByPricingToolMap.values());
            for (CPQ_Currency_PriceList_Mapping__mdt priceList: [SELECT CurrencyIsoCode__c, Price_List_Name__c, Pricing_Tool__c FROM CPQ_Currency_PriceList_Mapping__mdt WHERE CurrencyIsoCode__c IN: currencyIsoCodeSet AND Pricing_Tool__c  IN:pricingToolSet]) {
                String key = priceList.CurrencyIsoCode__c + '-' + priceList.Pricing_Tool__c;
                priceListNameByCurrencyAndPricingToolMap.put(key, priceList.Price_List_Name__c);
                priceListSet.add(priceList.Price_List_Name__c);
            }
            Map<String, Id> priceListIdbyNameMap = new Map<String, Id>();
            for (Apttus_Config2__PriceList__c pricingList : new SLT_PriceList().selectByNames(priceListSet, new Set<String> {CON_CPQ.Name, CON_CPQ.ID})) {
                priceListIdbyNameMap.put(pricingList.Name, pricingList.Id);
            }
            List<Apttus_Proposal__Proposal__c> proposalListToInsertList = new List<Apttus_Proposal__Proposal__c>();
            for (String pricingTool: pricingToolSet) {
                Apttus_Proposal__Proposal__c newBudget = new Apttus_Proposal__Proposal__c();
                newBudget.RecordTypeId = recordTypeId;
                newBudget.Select_Pricing_Tool__c = pricingTool;
                newBudget.Conversion_Date__c = Date.today();
                for (CPQ_Mapping_Field_Set__mdt mapFields : FieldSetByPricingToolMap.get(pricingTool)) {
                    if (mapFields.Opportunity_Field__c.contains('.')) {
                        List<string> splitedFieldsList = mapFields.Opportunity_Field__c.split('\\.');
                        for (integer i = 0; i < splitedFieldsList.size() - 1; i++) {
                            sb = opportunityRecord.getSobject(splitedFieldsList[i]);   
                        }
                        newBudget.put(mapFields.Quote_Field__c, string.valueof(sb.get(splitedFieldsList[splitedFieldsList.size()-1])));
                    } else if (opportunityRecord.get(mapFields.Opportunity_Field__c) != null) {
                        newBudget.put(mapFields.Quote_Field__c, opportunityRecord.get(mapFields.Opportunity_Field__c));
                    }
                }
                String priceListName;
                if (newBudget.CurrencyIsoCode != null) {
                    String key = newBudget.CurrencyIsoCode + '-' + pricingTool;
                    if (priceListNameByCurrencyAndPricingToolMap.containsKey(key)) {
                        priceListName = priceListNameByCurrencyAndPricingToolMap.get(key);
                    }
                } else {
                    priceListName = priceListByPricingToolMap.get(pricingTool);
                }
                if (priceListIdbyNameMap.containsKey(priceListName)) {
                    newBudget.Apttus_QPConfig__PriceListId__c = priceListIdbyNameMap.get(priceListName);
                }
                if (newBudget.CurrencyIsoCode == null && currencyIsoCodeByPricingToolMap.containsKey(pricingTool)) {
                    newBudget.CurrencyIsoCode = currencyIsoCodeByPricingToolMap.get(pricingTool);
                }
                newBudget.IQVIA_Quote__c = iqviaQuoteId;
                proposalListToInsertList.add(newBudget);
            }
            if (proposalListToInsertList.size() > 0) {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus_Proposal__Proposal__c.SobjectType
                    }
                );
                uowProposal.registerNew(proposalListToInsertList);
                uowProposal.commitWork();
            }
            return CON_CPQ.SUCCESS;
        }
        return 'No pricing tool found';
    }
    @AuraEnabled
    public static String createRDSQuote(String recordId, String gbu, String name, String tool, String quoteType, String requestedType, Integer scenario, String description) {
        try {
            Set<String> opportunityFieldSet = new Set<String>();
            Set<String> eligibleLOB = CON_CPQ.NON_SF_LOB;
            Quote__c newQuote = new Quote__c();

            fflib_SObjectUnitOfWork uowQuote = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Quote__C.SobjectType
            });

            List<CPQ_Mapping_Field_Set__mdt> mappingsPricingToolList = new List<CPQ_Mapping_Field_Set__mdt>();
            for (CPQ_Mapping_Field_Set__mdt mapFields : [SELECT Opportunity_Field__c, Quote_Field__c, Pricing_Tool__c FROM CPQ_Mapping_Field_Set__mdt WHERE Sobject_Name__c = 'Quote__c' AND Feature_Selection__c = 'Quote Creation']) {
                if (mapFields.Pricing_Tool__c.contains(gbu)) {
                    mappingsPricingToolList.add(mapFields);
                    opportunityFieldSet.add(mapFields.Opportunity_Field__c);
                }
            }

            opportunityFieldSet.add(CON_CPQ.LINE_OF_BUSINESS);
            SObject opp = new SLT_Opportunity().getOpportunityDetails(recordId, opportunityFieldSet);
            
            if (!eligibleLOB.contains(String.valueOf(opp.get(CON_CPQ.LINE_OF_BUSINESS)))) {
                throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + 'Please select correct \'Line of Business\' on opportunity.');
            }

            sobject sb = opp;
            for (CPQ_Mapping_Field_Set__mdt mapFields : mappingsPricingToolList) {
                if (mapFields.Opportunity_Field__c.contains('.')) {
                    List<string> splitedFields = mapFields.Opportunity_Field__c.split('\\.');
                    for (integer i = 0; i < splitedFields.size() - 1; i++) {
                        sb = opp.getSobject(splitedFields[i]);   
                    }
                    newQuote.put(mapFields.Quote_Field__c, string.valueof(sb.get(splitedFields[splitedFields.size()-1])));
                } else if (opp.get(mapFields.Opportunity_Field__c) != null) {
                    newQuote.put(mapFields.Quote_Field__c, opp.get(mapFields.Opportunity_Field__c));
                }
            }
            
            newQuote.Quote_Name__c = name;
            newQuote.GBU__c = gbu;
            newQuote.Pricing_Tools__c = tool;
            newQuote.Quote_Type__c = quoteType;
            newQuote.Request_Type__c = requestedType;
            newQuote.Scenario__c = scenario;
            newQuote.Scenario_Description__c = description;
            newQuote.Status__c = CON_CPQ.STATUS_IN_PROGRESS;
            
            uowQuote.registerNew(newQuote);
            uowQuote.commitWork();

            return newQuote.Id;

        } catch (Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }
    public class Iqvia_Cpq_QuoteDetails {
        @AuraEnabled
        public String pricingTool {get; set;}
        @AuraEnabled
        public String pathway {get; set;}
        @AuraEnabled
        public String hasAccess {get; set;}
        @AuraEnabled
        public String GBU {get; set;}
        @AuraEnabled
        public Boolean congaSetup {get; set;}
        @AuraEnabled
        public String bidHistoryRecordType {get; set;}
        @AuraEnabled
        public String oppName {get; set;}
        @AuraEnabled
        public List<String> NonSFTools {get; set;}
        @AuraEnabled
        public List<String> NonSFBudgetTypes {get; set;}
        @AuraEnabled
        public Map<String, List<String>> NonSFScenario {get; set;} 
        @AuraEnabled 
        public Boolean isRocheUser {get; set;}
        public Iqvia_Cpq_QuoteDetails() {
            congaSetup = false;
        }
    }

    @AuraEnabled
    public static Double getNumberOfScenario(Id recordId) {
        Double numberOfScenarios;
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.SCENARIO_NUMBER};  
        String condition = 'Bid_History__c = \'' + recordId + '\'' + ' AND RecordType.DeveloperName = \'' + CON_CPQ.IQVIA_TECHNOLOGIES_API + '\'' + ' AND Type__c = \'' + CON_CPQ.OTHER + '\'';
        List<CollectionTool__c> collectionTool = new SLT_CollectionTool(false, false).getCollectionToolRecords(condition, fieldSet);
        if (collectionTool.size() > 0) {
            numberOfScenarios = collectionTool[0].Scenario_Number__c;
        }
        return numberOfScenarios;
    }

    public static String processCollectionTool(Id recordId, Quote__c newBudget, fflib_SObjectUnitOfWork uowProposal, Double bidScenarios, boolean isFromClone) {
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.LPI_DATE, CON_CPQ.LPO_DATE, CON_CPQ.FPI_DATE, CON_CPQ.DBL_DATE, CON_CPQ.SCENARIO_NUMBER, CON_CPQ.COUNTRIES, CON_CPQ.NUMBER_OF_SITES, CON_CPQ.BID_HISTORY};
        String condition = 'AND Scenario_Number__c = ' + bidScenarios;
        List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolsByCondition(recordId, fieldSet, condition);
        Set<String> setOfUniqueCountries = new Set<String>();
        for (CollectionTool__c collectionTool : collectionToolList) {
            setOfUniqueCountries.add(collectionTool.Countries__c);
        }
        Bid_History__c bid  = new SLT_Bid_History().getClinicalBidDetails(recordId, CON_CPQ.BID_HISTORY_FIELDSET);
        newBudget.License_Type__c = bid.Deployment_Mode__c == CON_CPQ.SAAS_MODEL ? CON_CPQ.ENTERPRISE : CON_CPQ.PER_STUDY;
        if (!collectionToolList.isEmpty()) {
            Date databaseLockDate = collectionToolList[0].DBL_Date__c;
            Date firstPatientInDate = collectionToolList[0].FPI_Date__c;
            Date lastPatientFirstVisit = collectionToolList[0].LPI_Date__c ; 
            Integer studyDuration = (Integer) Math.round((firstPatientInDate.daysBetween(databaseLockDate) / 30.0)) + 3;
            Integer enrollmentPeriod = (Integer) Math.round((firstPatientInDate.daysBetween(lastPatientFirstVisit) / 30.0));
            if (studyDuration <= 3) {
                studyDuration = 4;
            }
            if (enrollmentPeriod <= 1) {
                enrollmentPeriod = 1;
            }
            if (bid.Preferred_Training_Method__c == CON_CPQ.TRAINING_METHOD_SITE) {
                newBudget.On_Site_Training_Days__c = 2;
            }
            if (bid.Preferred_Training_Method__c == CON_CPQ.TRAINING_METHOD_VIRTUAL) { 
                newBudget.Webinars__c = 1;
            }
            if (bid.Translations_Required__c == CON_CPQ.YES_TITLE_CASE) {
                newBudget.Patient_Videos__c = 1;
                newBudget.Patient_Education_Glossary_Definitions__c = 10;
                if (bid.Bid_History_Account__r.AccountCountry__c == CON_CPQ.JP) {
                    newBudget.Participant_Comprehension_Quizzes__c = 1;
                } else {
                    newBudget.Participant_Comprehension_Quizzes__c = 0;
                }
            } else {
                newBudget.Patient_Videos__c = 0;
                newBudget.Patient_Education_Glossary_Definitions__c = 0;
                newBudget.Participant_Comprehension_Quizzes__c = 0;
            }
            newBudget.Study_Duration__c = studyDuration;
            newBudget.Enrollment_Period__c = enrollmentPeriod;
            newBudget.Site_Tablets__c = bid.How_Many_Tablets_Site__c;
            newBudget.Amendments_to_ICF_Documents__c = bid.Institutional_Review_Board_allocation__c;
            newBudget.ICFs__c = bid.Number_of_ICF_Documents_Main_and_Short__c;
            if (setOfUniqueCountries.size() > 0) {
                newBudget.No_of_Countries__c = setOfUniqueCountries.size();
            }
        }
        if (!isFromClone) {
            uowProposal.registerNew(newBudget); 
        } else {
            uowProposal.registerDirty(newBudget); 
        }
        Set<String> timelineDataSet = new Set<String>();
        String result;
        Set<String> countriesNotPresentSet = new Set<String>();
        if (!collectionToolList.isEmpty()) {
            Set<String> countriesToCheckSet = new Set<String>();
            for (CollectionTool__c collectionTool : collectionToolList) {
                countriesToCheckSet.add(collectionTool.Countries__c);
            }    
            Schema.DescribeFieldResult fieldDescribe = Quote_Requisites__c.Country__c.getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> picklistValuesList = fieldDescribe.getPicklistValues();
                Set<String> picklistValuesSet = new Set<String>();
                for (Schema.PicklistEntry picklistEntry : picklistValuesList) {
                    picklistValuesSet.add(picklistEntry.getValue());
                }
          
                for (String country : countriesToCheckSet) {
                    if (!picklistValuesSet.contains(country) && country != CON_CPQ.UNITED_STATES_OF_AMERICA && country != CON_CPQ.UNITED_KINGDOM) {
                        countriesNotPresentSet.add(country);
                    }
                }
            }
            
            if (!countriesNotPresentSet.isEmpty()) {
                result = String.join(countriesNotPresentSet,', ');
            } else {
                Set<String> countriesSet = new Set<String>();
                Map<String, String> fieldToTimelineMap = new Map<String, String> {
                    CON_CPQ.FPI_DATE => CON_CPQ.FIRST_PATIENT_IN,
                    CON_CPQ.LPO_DATE => CON_CPQ.LAST_PATIENT_OUT,
                    CON_CPQ.LPI_DATE => CON_CPQ.LAST_PATIENT_FIRST_VISIT,
                    CON_CPQ.DBL_DATE => CON_CPQ.DATABASE_LOCK
                    };  
                for (CollectionTool__c collectionTool : collectionToolList) {
                    if (collectionTool.Countries__c != null) {
                        countriesSet.add(collectionTool.Countries__c == CON_CPQ.UNITED_STATES_OF_AMERICA ? CON_CPQ.USA : collectionTool.Countries__c == CON_CPQ.UNITED_KINGDOM ? CON_CPQ.UK : collectionTool.Countries__c);
                    }
                }
                List<CPQ_Country_Master_Data__c> countryDataList = new SLT_CPQCountryMasterData().getCountryMasterDataByNames(countriesSet, new Set<String>{CON_CPQ.COUNTRY, CON_CPQ.LANGUAGE});
                Map<String, String> countryLanguageMap = new Map<String, String>();
                for (CPQ_Country_Master_Data__c countryData : countryDataList) {
                    countryLanguageMap.put(countryData.Country__c.toLowercase(), countryData.Language__c);
                } 
                for (CollectionTool__c collectionTool : collectionToolList) {
                    for (String field : fieldToTimelineMap.keySet()) {
                        if (collectionTool.get(field) != null) {
                            Date fieldValue = (Date)collectionTool.get(field);
                            String uniqueKey = field + '_' + fieldValue;
                            if (timelineDataSet.contains(uniqueKey)) {
                                continue; 
                            }
                            timelineDataSet.add(uniqueKey);
                            Quote_Requisites__c quoteRequestTimeline = new Quote_Requisites__c(
                                Timeline_Name__c = fieldToTimelineMap.get(field),
                                Start_Date__c = fieldValue,
                                End_Date__c = fieldValue,
                                Type__c = CON_CPQ.TIMELINE
                            );
                            uowProposal.registerNew(quoteRequestTimeline, Quote_Requisites__c.Quote__c, newBudget);
                        }
                    }
                    if (collectionTool.Countries__c != null) {
                        String countries = collectionTool.Countries__c == CON_CPQ.UNITED_STATES_OF_AMERICA ? CON_CPQ.USA : collectionTool.Countries__c == CON_CPQ.UNITED_KINGDOM ? CON_CPQ.UK : collectionTool.Countries__c;
                        String countryLanguage = countryLanguageMap.get(countries.toLowerCase());
                        if (countryLanguage != null) {
                            List<String> countryLanguageList = countryLanguage.split(';');
                            countryLanguageList.sort();
                            countryLanguage = String.join(countryLanguageList, ', ');
                        }
                        Quote_Requisites__c quoteRequestCountryInput = new Quote_Requisites__c(
                            Country__c = countries,
                            Site_Count__c = collectionTool.Number_of_Sites__c,
                            Type__c = CON_CPQ.COUNTRY_INPUT,
                            Selected_Languages__c = String.isEmpty(countryLanguage) ? null : countryLanguage
                        );
                        uowProposal.registerNew(quoteRequestCountryInput, Quote_Requisites__c.Quote__c, newBudget);
                    }
                }
                result = CON_CPQ.SUCCESS;
            }
        }
        return result;
    }
    @AuraEnabled
    public static String collectionToolRecordsErrorMessage(Id recordId, Double bidScenarios) {
        String errorMessage = '';
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.LPI_DATE, CON_CPQ.LPO_DATE, CON_CPQ.FPI_DATE, CON_CPQ.DBL_DATE, CON_CPQ.SCENARIO_NUMBER, CON_CPQ.COUNTRIES, CON_CPQ.BID_HISTORY};
        String condition = 'Bid_History__c = \'' + recordId + '\'' + ' AND RecordType.DeveloperName = \'' + CON_CPQ.IQVIA_TECHNOLOGIES_API + '\'' + ' AND Type__c = \'' + CON_CPQ.OTHER + '\'' + ' AND Scenario_Number__c = ' + bidScenarios;
        List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolRecords(condition, fieldSet);
        
        if (collectionToolList.size() > 0) {
            for (CollectionTool__c collectionToolRecord : collectionToolList) {
                 if (collectionToolRecord.DBL_Date__c == null && !errorMessage.contains(CON_CPQ.DATABASE_LOCK)) {
                     errorMessage = errorMessage + '\n' + CON_CPQ.DATABASE_LOCK;
                 }
                 if (collectionToolRecord.FPI_Date__c == null && !errorMessage.contains(CON_CPQ.FIRST_PATIENT_IN)) {
                     errorMessage = errorMessage + '\n' + CON_CPQ.FIRST_PATIENT_IN;
                 }
                 if (collectionToolRecord.LPI_Date__c == null && !errorMessage.contains(CON_CPQ.LAST_PATIENT_FIRST_VISIT)) {
                      errorMessage = errorMessage + '\n' + CON_CPQ.LAST_PATIENT_FIRST_VISIT;
                 }
                 if (collectionToolRecord.LPO_Date__c == null && !errorMessage.contains(CON_CPQ.LAST_PATIENT_OUT)) {
                      errorMessage = errorMessage + '\n' + CON_CPQ.LAST_PATIENT_OUT;
                 }
                 if (collectionToolRecord.Countries__c == null && !errorMessage.contains(CON_CPQ.COUNTRY_INPUT_Record)) {
                     errorMessage = errorMessage + '\n' + CON_CPQ.COUNTRY_INPUT_Record;
                 }
                 if (collectionToolRecord.LPO_Date__c != null && collectionToolRecord.FPI_Date__c != null && collectionToolRecord.DBL_Date__c != null && collectionToolRecord.LPI_Date__c != null && collectionToolRecord.Countries__c != null) {
                     errorMessage = CON_CPQ.SUCCESS;
                 }
            } 
        }
        return errorMessage;
    }
    public static String collectionToolToQuoteRequisites(Id recordId, Quote__c newBudget, fflib_SObjectUnitOfWork uowProposal, boolean isFromClone,  String collectionToolcondition) {
        String condition = collectionToolcondition != null ? 'AND Type__c IN (\'' + String.join(collectionToolcondition.split(';'), '\',\'') + '\')' : '';
        List<CollectionTool__c> collectionToolList = new SLT_CollectionTool(false, false).getCollectionToolsByConditionOrderByStudyNumber(recordId, CON_CPQ.COLLECTION_TOOL_FIELDSET, condition);
        if (!isFromClone) {
            uowProposal.registerNew(newBudget); 
        }
        for (CollectionTool__c collectionTool : collectionToolList) {
            Quote_Requisites__c quoteRequestStudyType = new Quote_Requisites__c(
                Service_Line_Product__c = collectionTool.ServiceLine__c,
                Site__c = collectionTool.Site_Global__c,
                Study_Type__c = collectionTool.Study_Type_Global__c,
                Species_Global__c = collectionTool.Species_Global__c,
                Matrix__c = collectionTool.Biological_Matrix_Global__c,
                Analyte_ID__c = collectionTool.Compound_Molecules__c,
                Study_Number__c = String.valueOf(collectionTool.Study_Number__c),
                Type__c = CON_CPQ.STUDY_TYPE,
                Specimen_Type__c = collectionTool.Specimen_Type__c,
                Number_of_Analyte_Global__c = collectionTool.Number_of_Analyte_Global__c,
                Clinical_Type__c = collectionTool.Clinical_Type_Global__c
            );
            if (String.isBlank(collectionTool.ServiceLine__c) || String.isBlank(collectionTool.Site_Global__c) || String.isBlank(collectionTool.Study_Type_Global__c) || 
                String.isBlank(collectionTool.Species_Global__c) || String.isBlank(collectionTool.Biological_Matrix_Global__c) || String.isBlank(collectionTool.Compound_Molecules__c) || 
                String.isBlank(String.valueOf(collectionTool.Study_Number__c)) || String.isBlank(collectionTool.Specimen_Type__c) || String.isBlank(collectionTool.Number_of_Analyte_Global__c) || 
                String.isBlank(collectionTool.Clinical_Type_Global__c)) {
                    throw new CPQ_CustomException(CON_CPQ.REQUIRED_QUOTE_SECTIONS_ERORR);
            } else {
                uowProposal.registerNew(quoteRequestStudyType, Quote_Requisites__c.Quote__c, newBudget);
            }
        }
        return CON_CPQ.SUCCESS;
    }

    @AuraEnabled
    public static String createQuoteAccToLicense(String pricingTools, String gbu, Id recordId, String objectApiName, String bidScenarios, String pathway) {
        try {
            if (String.isNotEmpty(pathway) && pathway.contains(CON_CPQ.CONGA_PATHWAY)) {
                if (CPQ_QuoteUtility.checkCongaPermission() && Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()) {
                    return createQuote(pricingTools, gbu, recordId, objectApiName, bidScenarios);
                } else {
                    throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + CON_CPQ.CONGA_LICENSE_VALIDATION_MSG);
                }
            } else {
                return createQuote(pricingTools, gbu, recordId, objectApiName, bidScenarios);
            }
        } catch (Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean checkPricingAssistant(String recordId) {
       List<Proxy_Pricing_Assistant__c> proxyPricingAssistantList = new SLT_ProxyPricingAssistant().getByOpportunityIds(new Set<String>{CON_CPQ.ID}, 'PA_Status__c != \'' + CON_CPQ.REJECTED_STATUS + '\' AND Opportunity__c IN: opportunityIdSet', new Set<Id>{recordId});
       return !proxyPricingAssistantList.isEmpty();
    }

    @AuraEnabled
    public static Boolean hasCustomPermission() {
        return FeatureManagement.checkPermission(CON_CPQ.CPQ_IQ_QUOTE);
    }
}
