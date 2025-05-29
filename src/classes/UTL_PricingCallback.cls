public class UTL_PricingCallback {

    public static Boolean runStart = true;
    public static WPR_CPQ_PartialPricing pricingWrapperGlobal;
    public static Id accountId;
    public static Id iqviaQuoteId;

    public static WPR_CPQ_PartialPricing start(Apttus_Config2.ProductConfiguration cart) {
        Id pId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        WPR_CPQ_PartialPricing pricingWrapper = new WPR_CPQ_PartialPricing();
        pricingWrapper.hasQuoteAccess = false; 
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.PRICELISTCURRENCYISOCODE, CON_CPQ.PROPOSAL_ACCOUNT};
        Set<String> completeConsentfieldSet = new Set<String>{CON_CPQ.IQVIA_QUOTE, CON_CPQ.IQVIA_QUOTE_RELATED_ACCOUNT, CON_CPQ.IQVIA_SITE, CON_CPQ.IQVIA_TOTAL_ADJUSTED_SITE, CON_CPQ.IQVIA_SITE_TABLETS, CON_CPQ.IQVIA_SPONSOR_TABLETS, CON_CPQ.IQVIA_STUDY_DURATION, 
                                                                CON_CPQ.IQVIA_QUOTE_RELATED_TOTAL_ICF_DOCUMENT, CON_CPQ.IQVIA_QUOTE_RELATED_AMEND_ICF_DOCUMENT, CON_CPQ.IQVIA_QUOTE_RELATED_DOCUMENT_TYPE, CON_CPQ.IQVIA_QUOTE_RELATED_PATIENT_VIDEOS, 
                                                                CON_CPQ.IQVIA_QUOTE_RELATED_SITE_TRAINING_DAYS, CON_CPQ.IQVIA_QUOTE_RELATED_WEBINAR, CON_CPQ.IQVIA_QUOTE_RELATED_AMEND_PATIENT_VIDEOS, CON_CPQ.IQVIA_QUOTE_RELATED_PATIENT_EDUCATION_GLOSSARY_DEFINITIONS, 
                                                                CON_CPQ.IQVIA_QUOTE_RELATED_ENROLLMENT_PERIOD, CON_CPQ.IQVIA_QUOTE_RELATED_PARTICIPANT_COMPREHENSION_QUIZZES, CON_CPQ.IQVIA_QUOTE_RELATED_ADJUSTED_LANGUAGES, CON_CPQ.QUOTE_RELATED_OPPORTUNITY_PHASE, CON_CPQ.ICF_SHORT_ONLY};
        Set<String> q2fieldSet = new Set<String>{CON_CPQ.IQVIA_QUOTE, CON_CPQ.IQVIA_QUOTE_RELATED_ACCOUNT};
        for (PermissionSetAssignment assigned: [SELECT Id, PermissionSet.name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()]) {
            if(assigned.PermissionSet.name == CON_CPQ.DPS_Permission_Set) {
                fieldSet.addAll(completeConsentfieldSet);
            } else if (assigned.PermissionSet.name == CON_CPQ.Q2_Permission_Set) {
                fieldSet.addAll(q2fieldSet);
            }
        }
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(pId, fieldSet);
        if (proposal.Select_Pricing_Tool__c == CON_CPQ.COMPLETE_CONSENT || proposal.Select_Pricing_Tool__c == CON_CPQ.Q2_Solutions) {
            accountId = proposal.IQVIA_Quote__r.Related_Account__c;
            iqviaQuoteId = proposal.IQVIA_Quote__c;
            pricingWrapper.hasQuoteAccess = true;
        }
        pricingWrapper.proposalId = proposal.Id;
        pricingWrapper.proposal = proposal;
        pricingWrapper.conversionDate = System.today();
        pricingWrapper.pricingToolName = proposal.Select_Pricing_Tool__c;
        pricingWrapper.currencyIsoCode = proposal.Apttus_QPConfig__PriceListId__r.CurrencyIsoCode;
        if (proposal.Select_Pricing_Tool__c != CON_CPQ.TS_JAPAN) {
            pricingWrapper.isoCodeByCountryMap = getcurrencyIsoCodeByCountry(pricingWrapper.pricingToolName);
            Set<String> isoCodeSet = new Set<String>(pricingWrapper.isoCodeByCountryMap.values());
            Map<String, String> pricingToolFXRateTypeMap = new Map<String, String>();
            isoCodeSet.add(pricingWrapper.currencyIsoCode);
            if(isoCodeSet.contains(CON_CPQ.USD)) {
                isoCodeSet.remove(CON_CPQ.USD);
            }
            for (CPQ_Proposal_Create_Settings__c cPCS : CPQ_Proposal_Create_Settings__c.getAll().values()) {
                if (cPCS.FX_Rate_Type__c != null) {
                    pricingToolFXRateTypeMap.put(cPCS.Available_Pricing_Tools__c, cPCS.FX_Rate_Type__c);
                }
            }
            if (pricingToolFXRateTypeMap.get(proposal.Select_Pricing_Tool__c) == CON_CPQ.MONTHLY) {
                pricingWrapper.isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(isoCodeSet, System.today());
                if (pricingWrapper.isoCodeTocurrencyTypeMap != null && pricingWrapper.isoCodeTocurrencyTypeMap.size() > 0 && !Test.isRunningTest()) {
                    pricingWrapper.conversionDate = pricingWrapper.isoCodeTocurrencyTypeMap.values()[0].Effective_Date__c;    
                } 
            } else if (pricingToolFXRateTypeMap.get(proposal.Select_Pricing_Tool__c) == CON_CPQ.YEARLY) {
                pricingWrapper.isoCodeToYearlyCurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(isoCodeSet);
                if (pricingWrapper.isoCodeToYearlyCurrencyTypeMap != null && pricingWrapper.isoCodeToYearlyCurrencyTypeMap.size() > 0 && !Test.isRunningTest()) {
                    pricingWrapper.conversionDate = System.today();    
                }
            }
            if (proposal.Select_Pricing_Tool__c == CON_CPQ.AMESA) {
                Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
                Map<String, Decimal> freqToDiscountedPriceFactor = new Map<String, Decimal>();
            
                for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetData : [SELECT Id, CPQ_Product_Code__c, Country__c, With_CD_PDF_Deliveries__c, Data_Delivery_Frequency__c, Key__c, 
                                                                           Final_Price__c, Final_Price_with_molecule__c, Frequency__c, Final_Price_with_LMPT__c 
                                                                           FROM CPQ_AMESA_Partial_Product_Pricings__c 
                                                                           WHERE isActive__c = true]) {
                    if (!productCodeMapingwithParticalCalculator.containsKey(amesaMetData.Key__c)) {
                        productCodeMapingwithParticalCalculator.put(amesaMetData.Key__c, amesaMetData);
                    }
                }
                pricingWrapper.productCodeMapingwithParticalCalculator = productCodeMapingwithParticalCalculator;
                for (CPQ_Partial_Frequency_Price_Settings__c partialDiscountedMatrix : CPQ_Partial_Frequency_Price_Settings__c.getAll().values()) {
                    freqToDiscountedPriceFactor.put(partialDiscountedMatrix.Frequency__c, partialDiscountedMatrix.Discounted_Price__c);
                }
                pricingWrapper.freqToDiscountedPriceFactor = freqToDiscountedPriceFactor;
            }
        }
        pricingWrapperGlobal = pricingWrapper;
        return pricingWrapper;
    }

    public static void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.ProductConfiguration cart, Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator, String pricingToolName,String proposalCurrencyIsoCode, Map<String, String> isoCodeByCountryMap, Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap, Map<String, Decimal> freqToDiscountedPriceFactor, Apttus_Proposal__Proposal__c proposal) {
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__LineItem__c> optionLineItemList = new List<Apttus_Config2__LineItem__c>();
        Map<Id, Decimal> conversionRateByLineItem = new Map<Id, Decimal>();
        Set<String> optionProductCodes = new Set<String>();
        String numberOfConsent;
        for (Apttus_Config2.LineItem configLineItem : itemColl.getAllLineItems()) {
            Decimal conversionFactor = 1;
            Apttus_Config2__LineItem__c lineItem = configLineItem.getLineItemSO();
            System.debug('Before Pricing Base Mode***Apttus_Config2__PricingStatus__c = ' + lineItem.Apttus_Config2__PricingStatus__c);
            System.debug('Before Pricing Base Mode***Apttus_Config2__BasePrice__c = ' + lineItem.Apttus_Config2__BasePrice__c);
            System.debug('Before Pricing Base Mode***Apttus_Config2__BasePriceOverride__c = ' + lineItem.Apttus_Config2__BasePriceOverride__c);
            if (lineItem.Apttus_Config2__OptionId__r.ProductCode != null) {
                if (lineItem.Apttus_Config2__OptionId__r.ProductCode == 'US_CC_ENT_CONSCOMP' && lineItem.Apttus_Config2__AttributeValueId__c != null) {
                    numberOfConsent = lineItem.Apttus_Config2__AttributeValueId__r.No_of_Consent__c;
                }
                optionProductCodes.add(lineItem.Apttus_Config2__OptionId__r.ProductCode);
                optionLineItemList.add(lineItem);
            }
            if (lineItem.Apttus_Config2__BasePriceOverride__c == null) {
                listLineItem.add(lineItem);
                if(isoCodeByCountryMap.containsKey(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) 
                    && isoCodeByCountryMap.get(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) != null 
                    && isoCodeByCountryMap.get(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) != proposalCurrencyIsoCode) {
                    conversionFactor = isoCodeTocurrencyTypeMap.get(proposalCurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(isoCodeByCountryMap.get(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c)).Conversion_rate__c;
                    conversionRateByLineItem.put(lineItem.Id, conversionFactor);
                }
            }    
        }
        if (pricingToolName == CON_CPQ.COMPLETE_CONSENT && optionLineItemList.size() > 0) {
            UTL_CPQ_PricingCallBack.handleDPSPriceCalculation(optionLineItemList, proposal, optionProductCodes, isoCodeTocurrencyTypeMap, numberOfConsent, false);
        } else if (pricingToolName == CON_CPQ.Q2_Solutions && optionLineItemList.size() > 0) {
            UTL_CPQ_PricingCallBack.handleQ2PriceCalculation(optionLineItemList, pricingToolName, accountId, iqviaQuoteId, proposalCurrencyIsoCode, isoCodeTocurrencyTypeMap);
        } else if (listLineItem.size() > 0 && pricingToolName != CON_CPQ.COMPLETE_CONSENT && pricingToolName != CON_CPQ.Q2_Solutions) {
            UTL_CPQ_PricingCallBack.cpqPricingCalculation(listLineItem, productCodeMapingwithParticalCalculator, conversionRateByLineItem, freqToDiscountedPriceFactor);
        }
    }
    
    public static void afterPricingBaseMode(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.ProductConfiguration cart, String pricingToolName) {
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>();
        for (Apttus_Config2.LineItem configLineItem :itemColl.getAllLineItems()) {
            Apttus_Config2__LineItem__c lineItem = configLineItem.getLineItemSO();
            System.debug('After Pricing Base Mode***Apttus_Config2__PricingStatus__c = ' + lineItem.Apttus_Config2__PricingStatus__c);
            System.debug('After Pricing Base Mode***Apttus_Config2__BasePrice__c = ' + lineItem.Apttus_Config2__BasePrice__c);
            System.debug('After Pricing Base Mode***Apttus_Config2__BasePriceOverride__c = ' + lineItem.Apttus_Config2__BasePriceOverride__c);
            listLineItem.add(lineItem);
        }
        if (pricingToolName == CON_CPQ.OCE || Test.isRunningTest()) {
            UTL_CPQ_PricingCallBack.oceGrossMarginCalculation(listLineItem);
        }
    }

    public static void afterPricingAdjustmentMode(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.ProductConfiguration cart, String pricingToolName, String proposalCurrencyIsoCode, Map<String, String> isoCodeByCountryMap) {
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>();
        for (Apttus_Config2.LineItem configLineItem :itemColl.getAllLineItems()) {
            Apttus_Config2__LineItem__c lineItem = configLineItem.getLineItemSO();
            System.debug('After Pricing Adjustment Mode***Apttus_Config2__PricingStatus__c = ' + lineItem.Apttus_Config2__PricingStatus__c);
            System.debug('After Pricing Adjustment Mode***Apttus_Config2__BasePrice__c = ' + lineItem.Apttus_Config2__BasePrice__c);
            System.debug('After Pricing Adjustment Mode***Apttus_Config2__BasePriceOverride__c = ' + lineItem.Apttus_Config2__BasePriceOverride__c);
            listLineItem.add(lineItem);
        }
        if (listLineItem.size() > 0) {
            UTL_CPQ_PricingCallBack.changeProductStatusToPending(listLineItem, proposalCurrencyIsoCode, isoCodeByCountryMap);
        }
    }

    public static Map<String, String> getcurrencyIsoCodeByCountry(String pricingToolName) {
        Map<String, String> isoCodeByCountryMap = new Map<String, String>();
        List<CPQ_Local_Currency_Mapping__mdt> localCurrencyList = [SELECT Id, Country__c, Local_Currency_Code__c FROM CPQ_Local_Currency_Mapping__mdt WHERE Pricing_Tool__c =: pricingToolName];
        for (CPQ_Local_Currency_Mapping__mdt mdt: localCurrencyList) {
            isoCodeByCountryMap.put(mdt.Country__c, mdt.Local_Currency_Code__c);
        }
        return isoCodeByCountryMap;
    }

    public static void updateConversionDateOnProposal(Id proposalId, Date conversionDate) {
        if (proposalId != null && conversionDate != null) {
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
            proposal.Id = proposalId;
            proposal.Conversion_Date__c = conversionDate;
            update proposal;
        }
    }

    public static void beforePricingAdjustmentMode(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.ProductConfiguration cart, Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator, String pricingToolName,String proposalCurrencyIsoCode, Map<String, String> isoCodeByCountryMap, Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap, Map<String, Decimal> freqToDiscountedPriceFactor, Apttus_Proposal__Proposal__c proposal, Boolean isReprice) {
        List<Apttus_Config2__LineItem__c> optionLineItemList = new List<Apttus_Config2__LineItem__c>();
        Map<Id, Decimal> conversionRateByLineItem = new Map<Id, Decimal>();
        Set<String> optionProductCodes = new Set<String>();
        String numberOfConsent;
        for (Apttus_Config2.LineItem configLineItem : itemColl.getAllLineItems()) {
            Apttus_Config2__LineItem__c lineItem = configLineItem.getLineItemSO();
            if (lineItem.Apttus_Config2__OptionId__r.ProductCode != null) {
                if (lineItem.Apttus_Config2__OptionId__r.ProductCode == 'US_CC_ENT_CONSCOMP' && lineItem.Apttus_Config2__AttributeValueId__c != null) {
                    numberOfConsent = lineItem.Apttus_Config2__AttributeValueId__r.No_of_Consent__c;
                }
                optionProductCodes.add(lineItem.Apttus_Config2__OptionId__r.ProductCode);
                if (!isReprice) {
                	lineItem.Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING;
                }
                optionLineItemList.add(lineItem);
            }
        }
        List<Apttus_Config2__LineItem__c> itemsToReprice = new List<Apttus_Config2__LineItem__c>(); 
        if (pricingToolName == CON_CPQ.COMPLETE_CONSENT && optionLineItemList.size() > 0) {
            itemsToReprice = UTL_CPQ_PricingCallBack.handleDPSPriceCalculation(optionLineItemList, proposal, optionProductCodes, isoCodeTocurrencyTypeMap, numberOfConsent, true);
        }
        for (Apttus_Config2__LineItem__c li : itemsToReprice) {
            li.Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING;
        }
    }

    public class WPR_CPQ_PartialPricing {
        public Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator;
        public Map<String, Decimal> freqToDiscountedPriceFactor;
        public String pricingToolName;
        public Boolean hasQuoteAccess;
        public String currencyIsoCode;
        public Map<String, String> isoCodeByCountryMap;
        public Id proposalId;
        public date conversionDate; 
        public Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
        public Map<String, CurrencyType> isoCodeToYearlyCurrencyTypeMap;
        public Apttus_Proposal__Proposal__c proposal;
    }
}