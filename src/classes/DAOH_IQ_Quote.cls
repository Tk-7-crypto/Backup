public class DAOH_IQ_Quote {

    public static Map<String, Map<Integer, CNT_CPQ_DynamicApprovalProcess.WPR_CPQ_ApprovalMatrix>> approvalMatrixByPriorityByLevel =null;
    
    public static void setCurrency(List<Quote__c> quotes, Map<Id, Quote__c> oldRecordsMap) {
        Set<Id> quoteIdSet = new Set<Id>();
        List<String> pricingToolList = new List<String>();
        List<String> congaToolList = new List<String>();
        Set<String> currencyISOSet = new Set<String>();
        Map<String, String> pricingToolFXRateTypeMap = new Map<String, String>();
        for (Quote__c quote : quotes) {
            if (quote.CurrencyIsoCode != oldRecordsMap.get(quote.id).CurrencyIsoCode && quote.GBU__c != CON_CPQ.GBU_RDS_NON_SF_WRF) {
                quoteIdSet.add(quote.Id);
                currencyISOSet.add(quote.CurrencyIsoCode);
                currencyISOSet.add(oldRecordsMap.get(quote.id).CurrencyIsoCode);
                pricingToolList.addAll(quote.Pricing_Tools__c.split(';'));
            }
        }
        
        if (pricingToolList.size() > 0) {
            for (CPQ_Proposal_Create_Settings__c customSetting : [SELECT Available_Pricing_Tools__c, Conga_Setup__c, FX_Rate_Type__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN: pricingToolList]) {
                if (customSetting.Conga_Setup__c == true) {
                    congaToolList.add(customSetting.Available_Pricing_Tools__c);
                }
                if (customSetting.FX_Rate_Type__c != null) {
                    pricingToolFXRateTypeMap.put(customSetting.Available_Pricing_Tools__c, customSetting.FX_Rate_Type__c);
                }
            }
        }
        if (quoteIdSet.size() > 0 && !pricingToolFXRateTypeMap.isEmpty()) {
            setQuoteLineItemCurrency(quoteIdSet, currencyISOSet, pricingToolFXRateTypeMap);
        }

        if (quoteIdSet.size() > 0 && congaToolList.size() > 0 && CPQ_QuoteUtility.checkPathway(congaToolList) == CON_CPQ.HASCONGAACCESS) {
            List<Apttus_Proposal__Proposal__c> proposalListForUpdate = new List<Apttus_Proposal__Proposal__c>();
            Set<String> proposalFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE, CON_CPQ.IQVIA_QUOTE};
            String condition = 'IQVIA_Quote__c IN :quoteIdSet';
            Map<Id, List<Apttus_Proposal__Proposal__c>> iqviaQuoteToProposalMap = new Map<Id, List<Apttus_Proposal__Proposal__c>>();
            
            for (Apttus_Proposal__Proposal__c proposal : new SLT_Proposal().getProposalByQuoteIds(proposalFieldSet, condition, quoteIdSet)) {
                if (iqviaQuoteToProposalMap != null && iqviaQuoteToProposalMap.containsKey(proposal.IQVIA_Quote__c)) {
                    List<Apttus_Proposal__Proposal__c> proposals = iqviaQuoteToProposalMap.get(proposal.IQVIA_Quote__c);
                    proposals.add(proposal);
                    iqviaQuoteToProposalMap.put(proposal.IQVIA_Quote__c, proposals);
                } else {
                    iqviaQuoteToProposalMap.put(proposal.IQVIA_Quote__c, new List<Apttus_Proposal__Proposal__c>{proposal});
                }
            }  
            for (Quote__c quote : quotes) {
                if (quote.CurrencyIsoCode != oldRecordsMap.get(quote.id).CurrencyIsoCode && iqviaQuoteToProposalMap.containsKey(quote.Id)) {
                    for (Apttus_Proposal__Proposal__c proposal : iqviaQuoteToProposalMap.get(quote.Id)) {
                        if (quote.CurrencyIsoCode != proposal.CurrencyIsoCode) {
                            proposal.CurrencyIsoCode = quote.CurrencyIsoCode;
                            proposalListForUpdate.add(proposal);
                            
                        }
                    }
                }
            }
            if (proposalListForUpdate.size() > 0) {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new List<Schema.SObjectType> {
                        Apttus_Proposal__Proposal__c.SobjectType
                    }
                );
                uowProposal.registerDirty(proposalListForUpdate);
                uowProposal.commitWork();
                
            } 
        }
    }
    public static void checkAvailableCurrency(List<Quote__c> quotes, Map<Id, Quote__c> oldRecordsMap) {
        Map<Id, List<String>> quoteIdToPricingToolsMap = new Map<Id, List<String>>(); 
        Set<String> selectedPricingTools = new Set<String>();
        Set<String> quoteCurrencyIsoCodes = new Set<String>();
        List<String> congaToolList = new List<String>();
        
        for (Quote__c quote : quotes) {
            if (quote.CurrencyIsoCode != oldRecordsMap.get(quote.id).CurrencyIsoCode && quote.GBU__c != CON_CPQ.GBU_RDS_NON_SF_WRF) {
                quoteIdToPricingToolsMap.put(quote.Id, quote.Pricing_Tools__c.split(';'));
                selectedPricingTools.addAll(quote.Pricing_Tools__c.split(';'));
                quoteCurrencyIsoCodes.add(quote.CurrencyIsoCode);
            }
        }
        
        if (selectedPricingTools.size() > 0) {
            for (CPQ_Proposal_Create_Settings__c customSetting : [SELECT Available_Pricing_Tools__c,  Conga_Setup__c FROM CPQ_Proposal_Create_Settings__c WHERE Available_Pricing_Tools__c IN: selectedPricingTools]) {
                if (customSetting.Conga_Setup__c == true) {
                    congaToolList.add(customSetting.Available_Pricing_Tools__c);
                }
            }
            if (congaToolList.size() > 0 && CPQ_QuoteUtility.checkPathway(congaToolList) != CON_CPQ.HASCONGAACCESS) {
                Map<String, CPQ_Currency_PriceList_Mapping__mdt> currencyPriceListByPricingToolMap = new Map<String, CPQ_Currency_PriceList_Mapping__mdt>();
                for (CPQ_Currency_PriceList_Mapping__mdt currencyPricelistMTDObj : [SELECT Id, CurrencyIsoCode__c, Price_List_Name__c, Pricing_Tool__c FROM CPQ_Currency_PriceList_Mapping__mdt WHERE Pricing_Tool__c IN :selectedPricingTools AND CurrencyIsoCode__c IN :quoteCurrencyIsoCodes]) {
                     currencyPriceListByPricingToolMap.put(currencyPricelistMTDObj.CurrencyIsoCode__c + '&&' + currencyPricelistMTDObj.Pricing_Tool__c, currencyPricelistMTDObj);
                }
                for (Quote__c quote : quotes) {
                    if (oldRecordsMap.get(quote.Id).CurrencyIsoCode != quote.CurrencyIsoCode && quoteIdToPricingToolsMap.containsKey(quote.Id)) {
                        for (String pricingTool : quoteIdToPricingToolsMap.get(quote.Id)) {
                            if (!currencyPriceListByPricingToolMap.containsKey(quote.CurrencyIsoCode + '&&' + pricingTool)) {
                                quote.addError('For ' + pricingTool + ', there is no respective price list exist for selected currency.');
                            }  
                        }   
                    }
                }
            } 
        }
    }

    public static void updateIterationOnQuote(List<Quote__c> quotes, Map<Id, Quote__c> oldRecordsMap) {
        if (!quotes.isEmpty()) {
            String initialItration = '1';
            Set<Id> relatedOpportunityIdSet = new Set<Id>();
            Map<Id, Map<Decimal, String>> opportunityToQuoteDetailsMap = new Map<Id, Map<Decimal, String>>();
            for (Quote__c quote : quotes) {
                if (quote.Related_Opportunity__c != null && ((oldRecordsMap == null && quote.Scenario__c != null) || (oldRecordsMap != null && quote.Scenario__c != oldRecordsMap.get(quote.Id).Scenario__c))) {
                    relatedOpportunityIdSet.add(quote.Related_Opportunity__c);
                }
            }
            if (!relatedOpportunityIdSet.isEmpty()) {
                Set<String> quoteFieldSet = new Set<String>{'Id', 'Scenario__c', 'Iteration__c', 'Related_Opportunity__c', 'GBU__c', 'Pricing_Tools__c', 'Opportunity_Number__c'};
                String condition = 'Scenario__c != null AND Iteration__c != null AND Related_Opportunity__c IN: relatedOpportunityIdSet';
                for (Quote__c quote : new SLT_IQVIA_Quote().getQuotesByCondition(quoteFieldSet, condition, relatedOpportunityIdSet)) {
                    quote.Iteration__c = quote.Iteration__c.removeStart(quote.Opportunity_Number__c +'.');
                    if (!opportunityToQuoteDetailsMap.containsKey(quote.Related_Opportunity__c)) {
                        opportunityToQuoteDetailsMap.put(quote.Related_Opportunity__c, new Map<Decimal, String>());
                    }
                    Map<Decimal, String> scenarioToIterationMap = opportunityToQuoteDetailsMap.get(quote.Related_Opportunity__c);
                    if (!scenarioToIterationMap.containsKey(quote.Scenario__c)) {
                        scenarioToIterationMap.put(quote.Scenario__c, quote.Iteration__c);
                    } else {
                        if (Integer.valueOf(quote.Iteration__c.remove(String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.')) > Integer.valueOf(scenarioToIterationMap.get(quote.Scenario__c).remove(String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.'))) {
                            scenarioToIterationMap.put(quote.Scenario__c, quote.Iteration__c);
                        }
                    }
                    opportunityToQuoteDetailsMap.put(quote.Related_Opportunity__c, scenarioToIterationMap);
                }
                
                for (Quote__c quote: quotes) {
                    String oppNumber = quote.Opportunity_Number__c;
                    Decimal iteration;
                    if (quote.Related_Opportunity__c != null && ((oldRecordsMap == null && quote.Scenario__c != null) || (oldRecordsMap != null && quote.Scenario__c != oldRecordsMap.get(quote.Id).Scenario__c))) {
                        if (opportunityToQuoteDetailsMap.containsKey(quote.Related_Opportunity__c) && opportunityToQuoteDetailsMap.get(quote.Related_Opportunity__c).containsKey(Integer.valueOf(quote.Scenario__c))) {
                            if (quote.GBU__c == CON_CPQ.RECORD_TYPE_TECH_SOLUTION && quote.Pricing_Tools__c.contains(CON_CPQ.EMEA)) { 
                                iteration = Decimal.valueOf(opportunityToQuoteDetailsMap.get(quote.Related_Opportunity__c).get(Integer.valueOf(quote.Scenario__c)).remove(String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.')) + Decimal.valueOf(initialItration);
                                quote.Iteration__c = oppNumber + '.' + String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.' + String.valueOf(iteration);
                            } else {
                                iteration = Decimal.valueOf(opportunityToQuoteDetailsMap.get(quote.Related_Opportunity__c).get(Integer.valueOf(quote.Scenario__c)).remove(String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.')) + Decimal.valueOf(initialItration);
                                quote.Iteration__c = String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.' + String.valueOf(iteration);
                            }
                        } else {
                            if (quote.GBU__c == CON_CPQ.RECORD_TYPE_TECH_SOLUTION && quote.Pricing_Tools__c.contains(CON_CPQ.EMEA)) {
                                quote.Iteration__c = oppNumber + '.' + String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.' + initialItration;
                            } else {
                                quote.Iteration__c = String.valueOf(Integer.valueOf(quote.Scenario__c)) + '.' + initialItration;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void setDefaults(List<Quote__c> newQuoteList) {
        if (!newQuoteList.isEmpty()) {
            for (Quote__c quote : newQuoteList) {
                if (quote.CurrencyIsoCode == CON_CPQ.USD) {
                    quote.Conversion_Rate__c = 1;
                }
                if (quote.Pricing_Tools__c == CON_CPQ.Complete_Consent && Trigger.isUpdate) {
                    quote.Sponsor_Tablets__c = quote.Sponsor_Tablets__c == null ? 0 : quote.Sponsor_Tablets__c;
                    quote.No_of_Countries__c = quote.No_of_Countries__c == null ? 0 : quote.No_of_Countries__c;
                    quote.Enrollment_Period__c = quote.Enrollment_Period__c == null ? 0 : quote.Enrollment_Period__c;
                    quote.Patient_Videos__c = quote.Patient_Videos__c == null ? 0 : quote.Patient_Videos__c;
                    quote.Participant_Comprehension_Quizzes__c = quote.Participant_Comprehension_Quizzes__c == null ? 0 : quote.Participant_Comprehension_Quizzes__c;
                    quote.Webinars__c = quote.Webinars__c == null ? 0 : quote.Webinars__c;
                    quote.Site_Tablets__c = quote.Site_Tablets__c == null ? 0 : quote.Site_Tablets__c;
                    quote.Amendments_to_ICF_Documents__c = quote.Amendments_to_ICF_Documents__c == null ? 0 : quote.Amendments_to_ICF_Documents__c;
                    quote.Study_Duration__c = quote.Study_Duration__c == null ? 0 : quote.Study_Duration__c;
                    quote.Total_ICF_Documents__c = quote.Total_ICF_Documents__c == null ? 0 : quote.Total_ICF_Documents__c;
                    quote.Patient_Education_Glossary_Definitions__c = quote.Patient_Education_Glossary_Definitions__c == null ? 0 : quote.Patient_Education_Glossary_Definitions__c;
                    quote.On_Site_Training_Days__c = quote.On_Site_Training_Days__c == null ? 0 : quote.On_Site_Training_Days__c;
                    quote.Languages__c = quote.Languages__c == null ? 0 : quote.Languages__c;
                    quote.Amendments_to_Patient_Videos__c = quote.Amendments_to_Patient_Videos__c == null ? 0 : quote.Amendments_to_Patient_Videos__c;
                    quote.Adjusted_Languages__c = quote.Adjusted_Languages__c == null ? 0 : quote.Adjusted_Languages__c;
                }
            }
        }
    }   
    
    public static void setConversionRate(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        Map<String, String> pricingToolFXRateTypeMap = new Map<String, String>();
        for (CPQ_Proposal_Create_Settings__c cPCS : CPQ_Proposal_Create_Settings__c.getAll().values()) {
            if (cPCS.FX_Rate_Type__c != null) {
                pricingToolFXRateTypeMap.put(cPCS.Available_Pricing_Tools__c, cPCS.FX_Rate_Type__c);
            }
        }
        Map<Id, Quote__c> quoteMapToBeUpdate = new Map<Id, Quote__c>();
        Set<String> currencyISOCode = new Set<String>();
        Set<String> yearlyCurrencyIsoCodes = new Set<String>();
        for (Quote__c quote : newQuoteList) {
            if (quote.CurrencyIsoCode != CON_CPQ.USD && ((oldMap != null && quote.CurrencyIsoCode != null && quote.CurrencyIsoCode != oldMap.get(quote.Id).CurrencyIsoCode) 
                || (oldMap == null && quote.CurrencyIsoCode != null))) {
                quoteMapToBeUpdate.put(quote.Id, quote);
                if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.MONTHLY) {
                    currencyISOCode.add(quote.CurrencyIsoCode);
                    if (oldMap != null) {
                        currencyISOCode.add(oldMap.get(quote.Id).CurrencyIsoCode); 
                     }
                }
                if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.YEARLY) {
                    yearlyCurrencyIsoCodes.add(quote.CurrencyIsoCode);
                    if (oldMap != null) {
                        yearlyCurrencyIsoCodes.add(oldMap.get(quote.Id).CurrencyIsoCode); 
                     }
                }
            }
            if (quote.CurrencyIsoCode == CON_CPQ.USD && quote.Pricing_Tools__c == CON_CPQ.Q2_Solutions) {
                quote.Upfront_Payment_Amount__c = quote.Upfront_Payment_Amount__c != null ? (oldMap != null ? quote.Upfront_Payment_Amount__c / oldMap.get(quote.Id).Conversion_Rate__c : quote.Upfront_Payment_Amount__c) : null;
            }
        }
        Map<String, CurrencyType> isoCodeTocurrencyTypeYearlyMap = new Map<String, CurrencyType>();
        Map<String, Currency_Exchange_Rates__c> isoCodeToCurrencyTypeMap = new Map<String, Currency_Exchange_Rates__c>();
        if (!yearlyCurrencyIsoCodes.isEmpty()) {
            isoCodeTocurrencyTypeYearlyMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(yearlyCurrencyIsoCodes);
        }
        if (!currencyISOCode.isEmpty()) {
            isoCodeToCurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(currencyISOCode, System.today());
        }
        for (Quote__c quote : quoteMapToBeUpdate.values()) {
            if (quote.Quote_Type__c != CON_CPQ.CHANGE_ORDER || quote.Pricing_Tools__c != CON_CPQ.Q2_Solutions) {
                if (!isoCodeToCurrencyTypeMap.isEmpty() && isoCodeToCurrencyTypeMap.containsKey(quote.CurrencyIsoCode) && isoCodeToCurrencyTypeMap.get(quote.CurrencyIsoCode) != null && pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.MONTHLY) {
                    if (quote.Pricing_Tools__c == CON_CPQ.Q2_Solutions && quote.Quote_Type__c != CON_CPQ.CHANGE_ORDER && oldMap == null && quote.Conversion_Rate__c != isoCodeToCurrencyTypeMap.get(quote.CurrencyIsoCode).Conversion_rate__c) {
                        quote.Upfront_Payment_Amount__c = quote.Upfront_Payment_Amount__c != null ? quote.Upfront_Payment_Amount__c * (isoCodeToCurrencyTypeMap.get(quote.CurrencyIsoCode).Conversion_rate__c / quote.Conversion_Rate__c) : null;
                    }
                    quote.Conversion_Rate__c = isoCodeToCurrencyTypeMap.get(quote.CurrencyIsoCode).Conversion_rate__c;
                    quote.Conversion_Date__c = isoCodeToCurrencyTypeMap.get(quote.CurrencyIsoCode).Effective_Date__c;
                } else if (!isoCodeTocurrencyTypeYearlyMap.isEmpty() && isoCodeTocurrencyTypeYearlyMap.containsKey(quote.CurrencyIsoCode) && isoCodeTocurrencyTypeYearlyMap.get(quote.CurrencyIsoCode) != null && pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.YEARLY) {
                    quote.Conversion_Rate__c = isoCodeTocurrencyTypeYearlyMap.get(quote.CurrencyIsoCode).ConversionRate / (oldMap != null ? isoCodeTocurrencyTypeYearlyMap.get(oldMap.get(quote.Id).CurrencyIsoCode).ConversionRate : 1);
                    quote.Conversion_Date__c = System.today();
                }
                if (quote.Pricing_Tools__c == CON_CPQ.Q2_Solutions && quote.Quote_Type__c != CON_CPQ.CHANGE_ORDER && oldMap != null && quote.Conversion_Rate__c != oldMap.get(quote.Id).Conversion_rate__c) {
                    quote.Upfront_Payment_Amount__c = quote.Upfront_Payment_Amount__c != null ? quote.Upfront_Payment_Amount__c * (quote.Conversion_Rate__c / oldMap.get(quote.Id).Conversion_rate__c) : null;
                }
            }
        }
    }
    public static void setSharing(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        UTL_Sharing.setSharing(newQuoteList, oldMap, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME);
    }

    public static void setAccountCountry(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        Set<Id> accountIdSet = new Set<Id>();
        List<Quote__c> updatedList = new List<Quote__c>();
        for (Quote__c quote : newQuoteList) {
            if ((Trigger.isInsert || Trigger.isUpdate) && quote.Related_Account__c != null) { 
                accountIdSet.add(quote.Related_Account__c);
                updatedList.add(quote);
            } else if (Trigger.isUpdate && quote.Related_Account__c == null) {
                quote.Account_Country__c = null;    
            }
        }
        if (accountIdSet.size() > 0) {
            Map<Id,Account> accountIdMap = new SLT_Account().selectByAccountId(accountIdSet, new Set<String> {CON_CPQ.ID, CON_CPQ.ACCOUNT_COUNTRY, CON_CPQ.RECORD_TYPE_ID});
            for (Quote__c quote : updatedList) {
                if (accountIdMap.containsKey(quote.Related_Account__c) && accountIdMap.get(quote.Related_Account__c).RecordType.Id != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
                    quote.Account_Country__c = accountIdMap.get(quote.Related_Account__c).AccountCountry__c;    
                } else {
                    quote.Account_Country__c = null;
                }
            }   
        }
    }

    public static void setLastSharingCalculationTimestamp(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if (Trigger.isUpdate) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newQuoteList, oldMap, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.SHR_PARENT_FIELDSET);
            if (recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if (isFieldToUpdate) {
            for (Quote__c quote :newQuoteList) {
                if (Trigger.isInsert || recordIdSet.contains(quote.Id)) {
                    quote.Last_Sharing_Calculation_Timestamp__c = System.Now();
                }
            }   
        }
    }

    public static void setDummyCreatorAccess(List<Quote__c> newQuoteList) {
        UTL_Sharing.setDummyCreatorAccess(newQuoteList, CON_CPQ.IQVIA_QUOTE_SHARE, CON_CPQ.PROPOSAL_TERRITORY);
    }

    public static void setLastManualSharingFieldUpdate(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        for (Quote__c quote : newQuoteList) {
            if (quote.Run_Sharing__c) {
                quote.Run_Sharing__c = false;
                quote.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }
    
	public static void validateDiscount(List<Quote__c> quotesList, Map<Id, Quote__c> oldRecordsMap) {
        
        Map<Id, Set<String>> idToParentAccount = new Map<Id, Set<String>>();
        Set<String> allPriceMatrixAccount = new Set<String>();
        Set<String> allAccounts = new Set<String>();
        List<Quote__c> discountedQuotes = new List<Quote__c>();
        
        for (Quote__c quote : quotesList) {
            if (quote.Related_Account__c != null && quote.Discount_Percent__c != null) {
                allAccounts.add(quote.Related_Account__c);
                discountedQuotes.add(quote);
            }
        }
        if (discountedQuotes.size() > 0) {
            idToParentAccount = UTL_CPQ_PricingCallBack.getAllParents(allAccounts);

            for (IQVIA_Price_Matrix__c ipm : new SLT_IQVIAPriceMatrix().getIQVIAPriceMatrix(new Set<String>{CON_CPQ.ID, CON_CPQ.ACCOUNT_FIELD, 'Account__r.MDMID__c'}, 'Account__c != null')) {
                if (ipm.Account__r.MDMID__c != null) {
                    allPriceMatrixAccount.add(ipm.Account__r.MDMID__c);
                }
            }
            for (Quote__c quote : discountedQuotes) {
                if (idToParentAccount.containsKey(quote.Related_Account__c) ) {
                    for (String mdmId : idToParentAccount.get(quote.Related_Account__c)) {
                        if (mdmId != null && allPriceMatrixAccount.contains(mdmId) && quote.Discount_Percent__c != null) {
                            quote.addError('You can\'t apply additional discount for this account');       
                        }
                    }
                }
            }
        }
    }

    public static void setAcceptedDate(List<Quote__c> newList, Map<Id, Quote__c> oldRecordsMap) {
        for (Quote__c quote : newList) {
            if (quote.Approval_Stage__c == CON_CPQ.ACCEPTED && oldRecordsMap.get(quote.Id).Approval_Stage__c != quote.Approval_Stage__c) {
                quote.Accepted_Date__c = System.now();
            }
        }
    }

    public static void setTotolICFDocuments(List<Quote__c> newList, Map<Id, Quote__c> oldRecordsMap) {
        Map<Id, Quote__c> quoteByIdMap = new Map<Id, Quote__c> ();
        for (Quote__c quote : newList) {
            if (oldRecordsMap.get(quote.Id).Document_Type__c != quote.Document_Type__c || oldRecordsMap.get(quote.Id).ICFs__c != quote.ICFs__c || oldRecordsMap.get(quote.Id).US_Central_IRBs__c != quote.US_Central_IRBs__c
                || oldRecordsMap.get(quote.Id).Total_Sites__c != quote.Total_Sites__c || oldRecordsMap.get(quote.Id).Total_Adjusted_Sites__c != quote.Total_Adjusted_Sites__c) {
                quoteByIdMap.put(quote.Id, quote);
            }
        }
        if (quoteByIdMap.size() > 0) {
            String condition = 'Quote__c IN: quoteIdSet AND Type__c = \'' + CON_CPQ.COUNTRY_INPUT + '\'';
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteByIdMap.keySet(), CON_CPQ.QUOTE_REQUISITES_FIELD_SET, condition);
            Map<Id, Decimal> siteCountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> siteCountAdjustedMap = new Map<Id, Decimal>();
            Map<Id, Decimal> documentMap = new Map<Id, Decimal>();
            for (Quote_Requisites__c qr : quoteReqList) {
                Decimal siteCount = qr.Site_Count__c == null ? 0.0 : qr.Site_Count__c;
                Decimal siteCountAdjusted = qr.Site_Count_Adjusted__c == null ? 0.0 : qr.Site_Count_Adjusted__c;
                if (!siteCountMap.containsKey(qr.Quote__c)) {
                    siteCountMap.put(qr.Quote__c, siteCount);
                } else {
                    siteCountMap.put(qr.Quote__c, siteCountMap.get(qr.Quote__c) + siteCount);
                }
                if (!siteCountAdjustedMap.containsKey(qr.Quote__c)) {
                    siteCountAdjustedMap.put(qr.Quote__c, siteCountAdjusted);
                } else {
                    siteCountAdjustedMap.put(qr.Quote__c, siteCountAdjustedMap.get(qr.Quote__c) + siteCountAdjusted);
                }
            }
            for (Quote_Requisites__c qr : quoteReqList) {
                Decimal docNumber = 0;
                Decimal siteCount = qr.Site_Count__c == null ? 0.0 : qr.Site_Count__c;
                Decimal siteCountAdjusted = qr.Site_Count_Adjusted__c == null ? 0.0 : qr.Site_Count_Adjusted__c;
                if (qr.Document_Language__c != null) {
                    if (siteCountMap.get(qr.Quote__c) < 100) {
                        docNumber = siteCount * qr.Document_Language__c;
                    } else {
                        docNumber = siteCountAdjusted * qr.Document_Language__c;
                    }
                    docNumber = qr.Country__c == CON_CPQ.USA && (quoteByIdMap.get(qr.Quote__c).Document_Type__c == CON_CPQ.INTERACTIVE_INDIVIDUAL_DOCUMENT || quoteByIdMap.get(qr.Quote__c).Document_Type__c == CON_CPQ.INTERACTIVE_DOCUMENT_BUNDLE) && quoteByIdMap.get(qr.Quote__c).US_Central_IRBs__c != null ? ((docNumber * (100 - quoteByIdMap.get(qr.Quote__c).US_Central_IRBs__c)) / 100) + qr.Document_Language__c : docNumber;
                    docNumber = docNumber.round(System.RoundingMode.HALF_UP);
                }
                if (!documentMap.containsKey(qr.Quote__c)) {
                    documentMap.put(qr.Quote__c, docNumber);
                } else {
                    documentMap.put(qr.Quote__c, documentMap.get(qr.Quote__c) + docNumber);
                }
            }
            List<Quote__c> quoteListToUpdate = new List<Quote__c>();
            for (Quote__c quote: newList) {
                if (quoteByIdMap.containsKey(quote.Id) && documentMap.containsKey(quote.Id)) {
                    quote.Total_ICF_Documents__c = (documentMap.get(quote.Id) * (quote.ICFs__c != null ? quote.ICFs__c : 1)).round(System.RoundingMode.HALF_UP);
                }
            }
        }
    }
    public static void setApprovalStage(List<Quote__c> newQuoteList, Map<Id, Quote__c> oldMap) {
        for (Quote__c quote : newQuoteList) {
            if (oldMap != null && quote.Status__c != null && quote.Status__c != oldMap.get(quote.Id).Status__c && quote.GBU__c == CON_CPQ.GBU_RDS_NON_SF_WRF && quote.Quote_Type__c == CON_CPQ.CNF) {
                    if (quote.Status__c == CON_CPQ.STATUS_IN_PROGRESS || quote.Status__c == CON_CPQ.ON_HOLD) {
                        quote.Approval_Stage__c = CON_CPQ.DRAFT;
                    } else if (quote.Status__c == CON_CPQ.STATUS_EXECUTED) {
                        if (quote.Approval_Rejected_Completed_Date__c == null ) {
                            quote.Approval_Rejected_Completed_Date__c.addError(CON_CPQ.ERROR_MSG_FOR_STATUS_REJECTED);
                        }
                        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
                    } else if (quote.Status__c == CON_CPQ.REJECTED_STATUS) {
                        if (quote.Approval_Rejected_Completed_Date__c == null ) {
                            quote.Approval_Rejected_Completed_Date__c.addError(CON_CPQ.ERROR_MSG_FOR_STATUS_REJECTED);
                        }
                        quote.Approval_Stage__c = CON_CPQ.CANCELLED_STATUS;
                    }
            }  
        } 
    }
    public static void updateNextApprovalStep(List<Quote__c> newList, Map<Id, Quote__c> oldRecordsMap) {
       CNT_CPQ_DynamicApprovalProcess.updateNextApprovalStep(newList, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, oldRecordsMap);
    }
	
    public static void checkForAutoApproval(List<Quote__c> newList, Map<Id, Quote__c> oldRecordsMap) {
       CNT_CPQ_DynamicApprovalProcess.checkForAutoApproval(newList, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, oldRecordsMap);
    }

    public static void setQuoteName(List<Quote__c> newQuoteList) {
        for (Quote__c quote : newQuoteList) {
            if (quote.GBU__c == CON_CPQ.GBU_RDS_NON_SF_WRF) {
                quote.Quote_Name__c += CON_CPQ.HYPHEN + quote.Scenario__c;
            }
        }
    }

    public static void setAmountOnQuote(List<Quote__c> quotes, Map<Id, Quote__c> oldRecordsMap) {
        Map<String, String> pricingToolFXRateTypeMap = new Map<String, String>();
        for (CPQ_Proposal_Create_Settings__c cPCS : CPQ_Proposal_Create_Settings__c.getAll().values()) {
            if (cPCS.FX_Rate_Type__c != null) {
                pricingToolFXRateTypeMap.put(cPCS.Available_Pricing_Tools__c, cPCS.FX_Rate_Type__c);
            }
        }
        Set<String> currencyIsoCodes = new Set<String>();
        Set<String> yearlyCurrencyIsoCodes = new Set<String>();
        for (Quote__c quote : quotes) {
            if (quote.CurrencyIsoCode != CON_CPQ.USD) {
                if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.MONTHLY) {
                    currencyIsoCodes.add(quote.CurrencyIsoCode);
                }
                if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.YEARLY) {
                    yearlyCurrencyIsoCodes.add(quote.CurrencyIsoCode);
                }
            }
        }
    
        Map<String, Currency_Exchange_Rates__c> conversionRates = new Map<String, Currency_Exchange_Rates__c>();
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        
        if (!yearlyCurrencyIsoCodes.isEmpty()) {
            isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(yearlyCurrencyIsoCodes);
        }
        if (!currencyIsoCodes.isEmpty()) {
            conversionRates = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(currencyIsoCodes, System.today());
        }
        List<Quote__c> updatedQuoteList = new List<Quote__c>();
        for (Quote__c quote : quotes) {
            if (quote.TotalAmount__c != oldRecordsMap.get(quote.id).TotalAmount__c || quote.TotalNetAmount__c != oldRecordsMap.get(quote.id).TotalNetAmount__c || quote.Total_Cost__c != oldRecordsMap.get(quote.id).Total_Cost__c) {
                Quote__c updateExistingQuoteFields = new Quote__c(Id = quote.Id );
                updateExistingQuoteFields.Aggregate_Discount_Amount__c = (quote.TotalAmount__c != 0) ? (quote.TotalAmount__c - quote.TotalNetAmount__c).setScale(2, RoundingMode.HALF_UP) : 0;
                updateExistingQuoteFields.Aggregate_Discount_Percent__c = (quote.TotalAmount__c != 0) ? ((updateExistingQuoteFields.Aggregate_Discount_Amount__c / quote.TotalAmount__c) * 100).setScale(2, RoundingMode.HALF_UP) : 0;
                updateExistingQuoteFields.Total_Margin__c = (quote.TotalNetAmount__c != 0) ? (quote.TotalNetAmount__c - quote.Total_Cost__c).setScale(2, RoundingMode.HALF_UP) : 0;
                updateExistingQuoteFields.Margin_Percent__c = (quote.TotalNetAmount__c != 0) ? ((updateExistingQuoteFields.Total_Margin__c / quote.TotalNetAmount__c) * 100).setScale(2, RoundingMode.HALF_UP) : 0;
                
                if (quote.CurrencyIsoCode != CON_CPQ.USD) {
                    Decimal conversionRate = 1;
                    if (quote.Pricing_Tools__c.contains(CON_CPQ.Q2_Solutions)) {
                        conversionRate = (quote.Conversion_Rate__c != null && quote.Conversion_Rate__c != 0) ? quote.Conversion_Rate__c : conversionRates.containsKey(quote.CurrencyIsoCode) ? conversionRates.get(quote.CurrencyIsoCode).Conversion_rate__c : 1.0;
                    }
                    else if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.MONTHLY && !conversionRates.isEmpty()) {
                        conversionRate = conversionRates.containsKey(quote.CurrencyIsoCode) ? conversionRates.get(quote.CurrencyIsoCode).Conversion_rate__c : 1.0;
                    } else if (pricingToolFXRateTypeMap.get(quote.Pricing_Tools__c.split(';')[0]) == CON_CPQ.YEARLY && !isoCodeTocurrencyTypeMap.isEmpty()) {
                        conversionRate = isoCodeTocurrencyTypeMap.containsKey(quote.CurrencyIsoCode) ? isoCodeTocurrencyTypeMap.get(quote.CurrencyIsoCode).ConversionRate : 1.0;
                    }
                    Decimal conversionFactor = 1.0 / conversionRate;
                    
                    updateExistingQuoteFields.Total_Amount_USD__c = (quote.TotalAmount__c * conversionFactor).setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Total_Net_Amount_USD__c = (quote.TotalNetAmount__c * conversionFactor).setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Total_Margin_USD__c = (updateExistingQuoteFields.Total_Margin__c * conversionFactor).setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Aggregate_Discount_Amount_USD__c = (updateExistingQuoteFields.Aggregate_Discount_Amount__c * conversionFactor).setScale(2, RoundingMode.HALF_UP);
                } else {
                    updateExistingQuoteFields.Total_Amount_USD__c = quote.TotalAmount__c.setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Total_Net_Amount_USD__c = quote.TotalNetAmount__c.setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Total_Margin_USD__c = updateExistingQuoteFields.Total_Margin__c.setScale(2, RoundingMode.HALF_UP);
                    updateExistingQuoteFields.Aggregate_Discount_Amount_USD__c = updateExistingQuoteFields.Aggregate_Discount_Amount__c.setScale(2, RoundingMode.HALF_UP);
                }
                updatedQuoteList.add(updateExistingQuoteFields);
            }
        }
        if (updatedQuoteList.size() > 0) {
            fflib_SObjectUnitOfWork uowQuote = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType> {
                    Quote__c.SobjectType
                }
            );
            uowQuote.registerDirty(updatedQuoteList);
            uowQuote.commitWork();
        }
    }
    
    public static void setQuoteLineItemCurrency (Set<Id> quoteIdSet, Set<String> currencyISOSet, Map<String, String> pricingToolFXRateTypeMap) {
        List<Quote_Line_Item__c> quoteLineItemList = new SLT_QuoteLineItem().getQuoteLineItemByQuoteId(quoteIdSet, new Set<String>{CON_CPQ.CURRENCYISOCODE, CON_CPQ.ID, CON_CPQ.QLI_BASE_PRICE, CON_CPQ.QLI_DISCOUNT_AMOUNT, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.QLI_TO_QUOTE_CURRENCYISOCODE, CON_CPQ.PRICING_TOOL, CON_CPQ.QLI_COST_PRICE});
        Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyExchangeTypeMap = new Map<String, Currency_Exchange_Rates__c>();
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        if (pricingToolFXRateTypeMap.values().contains(CON_CPQ.YEARLY)) {
           isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(currencyISOSet);
        }
        if (pricingToolFXRateTypeMap.values().contains(CON_CPQ.MONTHLY)) {
           isoCodeTocurrencyExchangeTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(currencyISOSet, System.today());
        }
        List<Quote_Line_Item__c> updateQuoteLineItemList = new List<Quote_Line_Item__c>();
        if (quoteLineItemList.size() > 0) {
            List<Quote_Line_Item__c> qliListToUpdate = new List<Quote_Line_Item__c>();
            for (Quote_Line_Item__c qli : quoteLineItemList) {
                if (qli.CurrencyIsoCode != qli.Quote__r.CurrencyIsoCode) {
                    if(pricingToolFXRateTypeMap.get(qli.Pricing_Tool__c) == CON_CPQ.MONTHLY && !isoCodeTocurrencyExchangeTypeMap.isEmpty()) {
                        qli.BasePrice__c = qli.BasePrice__c != null ? qli.BasePrice__c * isoCodeTocurrencyExchangeTypeMap.get(qli.Quote__r.CurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyExchangeTypeMap.get(qli.CurrencyIsoCode).Conversion_rate__c : 0;
                        qli.Discount_Amount__c =  qli.Discount_Amount__c != null ? qli.Discount_Amount__c *isoCodeTocurrencyExchangeTypeMap.get(qli.Quote__r.CurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyExchangeTypeMap.get(qli.CurrencyIsoCode).Conversion_rate__c : 0;
                        qli.Cost_Price__c = qli.Cost_Price__c != null ? qli.Cost_Price__c * isoCodeTocurrencyExchangeTypeMap.get(qli.Quote__r.CurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyExchangeTypeMap.get(qli.CurrencyIsoCode).Conversion_rate__c : 0;
                    } else if (pricingToolFXRateTypeMap.get(qli.Pricing_Tool__c) == CON_CPQ.YEARLY && !isoCodeTocurrencyTypeMap.isEmpty()) {
                        qli.BasePrice__c = qli.BasePrice__c != null ? qli.BasePrice__c * isoCodeTocurrencyTypeMap.get(qli.Quote__r.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(qli.CurrencyIsoCode).ConversionRate : 0;
                        qli.Discount_Amount__c = qli.Discount_Amount__c != null ? qli.Discount_Amount__c * isoCodeTocurrencyTypeMap.get(qli.Quote__r.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(qli.CurrencyIsoCode).ConversionRate : 0;
                        qli.Cost_Price__c = qli.Cost_Price__c != null ? qli.Cost_Price__c * isoCodeTocurrencyTypeMap.get(qli.Quote__r.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(qli.CurrencyIsoCode).ConversionRate : 0;
                    }
                    qli.CurrencyIsoCode = qli.Quote__r.CurrencyIsoCode;
                    updateQuoteLineItemList.add(qli);
                }
            }
        }
        if (updateQuoteLineItemList.size() > 0) {
            fflib_SObjectUnitOfWork uowQLI = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType> {
                    Quote_Line_Item__c.SobjectType
                }
            );
            uowQLI.registerDirty(updateQuoteLineItemList);
            uowQLI.commitWork();
        }
    }
    public static void validateRDSQuoteStages(List<Quote__c> newList, Map<Id, Quote__c> oldRecordsMap) {
        Map<Id, Quote__c> quoteMap = new Map<Id, Quote__c>([SELECT Id, Related_Opportunity__c,Related_Opportunity__r.StageName FROM Quote__c WHERE Id IN : newList]);
        for (Quote__c quote :newList) {
            if ((quote.Quote_Type__c == CON_CPQ.PROJECT_SPECIFIC || quote.Quote_Type__c == CON_CPQ.CHNAGE_ORDER || quote.Quote_Type__c == CON_CPQ.CNF || quote.Quote_Type__c == CON_CPQ.BALLPARK ) && quote.Approval_Stage__c == CON_CPQ.ACCEPTED) {
                String oppStageName = quoteMap.get(quote.Id).Related_Opportunity__r.StageName;
                Boolean oppStageCheck = CON_CPQ.OPPORTUNITY_STAGES.contains(oppStageName) && oppStageName != CON_CPQ.OPPORTUNITY_STAGE_7B_CLOSED_LOST;
                if (oppStageCheck) {
                    quote.addError('The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.');
                }
                AgreementWrapper.CPQCLMWrapper wrapper = new AgreementWrapper.CPQCLMWrapper();
                wrapper = UTL_CLM.isNonInflightAgreement(quote.Id);
                if (quote.Quote_Type__c == CON_CPQ.CHNAGE_ORDER && (wrapper.isNonInflightAgreement == null || wrapper.isNonInflightAgreement == false)) {
                    quote.addError('There is no activated Change Order Agreement associated with this Quote so it could not be marked as Accepted. Please ensure the related Change Order Agreement is Activated before Accepting the Quote.');
                }
            }
        }
    }
}