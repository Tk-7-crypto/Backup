public class UTL_CPQ_PricingCallBack {

    public static String metaDataMapKey;
    public static Set<String> africanCountries = CON_CPQ.NEW_AFRICA_COUNTRIES;
       
    public static void cpqPricingCalculation(List<Apttus_Config2__LineItem__c> listLineItem, Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator, Map<Id, Decimal> conversionRateByLineItem, Map<String, Decimal> freqToDiscountedPriceFactor) {
        for (Apttus_Config2__LineItem__c li : listLineItem) {
            if (li.Apttus_Config2__AttributeValueId__r.Catergory__c == CON_CPQ.PARTIAL && li.Apttus_Config2__AttributeValueId__r.Market_Share__c != null) {
                if (li.Apttus_Config2__LineType__c == CON_CPQ.OPTION) {
                    metaDataMapKey = li.Apttus_Config2__AttributeValueId__r.Sub_Product__c != null ? li.Apttus_Config2__OptionId__r.ProductCode + ':' + li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c + ':' + li.Apttus_Config2__AttributeValueId__r.Sub_Product__c + ':' + Integer.valueOf(li.Start_Date_Year__c) : li.Apttus_Config2__OptionId__r.ProductCode + ':' + li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c + ':' + Integer.valueOf(li.Start_Date_Year__c);
                    if (productCodeMapingwithParticalCalculator.containsKey(metaDataMapKey)) {
                        productPricingCalculation(metaDataMapKey, li, productCodeMapingwithParticalCalculator.get(metaDataMapKey), li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, conversionRateByLineItem, freqToDiscountedPriceFactor);
                    }
                } else {
                    metaDataMapKey = li.Apttus_Config2__ProductId__r.ProductCode + ':' + li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c;
                    if (productCodeMapingwithParticalCalculator.containsKey(metaDataMapKey)) {
                        productPricingCalculation(metaDataMapKey, li, productCodeMapingwithParticalCalculator.get(metaDataMapKey), li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, conversionRateByLineItem, freqToDiscountedPriceFactor);
                    } else {
                        li.Apttus_Config2__BasePriceOverride__c = null;
                    }
                }
            } else if (li.Apttus_Config2__AttributeValueId__r.Catergory__c != CON_CPQ.PARTIAL) {
                if (li.Apttus_Config2__AttributeValueId__r.Number_of_Lists__c != null && li.Apttus_Config2__AttributeValueId__r.Number_of_Lists__c > 0 ) {
				    li.Apttus_Config2__Quantity__c = li.Apttus_Config2__AttributeValueId__r.Number_of_Lists__c;
                } else if (li.Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c != null && li.Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c > 0 ) {
                    li.Apttus_Config2__Quantity__c = li.Apttus_Config2__AttributeValueId__r.No_of_Deliveries__c;
                } else if(li.Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c != null && li.Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c > 0) {
                    li.Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c = li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c > 0 && li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c == CON_CPQ.SAUDIARABIA ? 1 : li.Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c;
                    li.Apttus_Config2__Quantity__c = li.Apttus_Config2__AttributeValueId__r.Number_of_product_Line__c;
                } else if(li.Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c != null && li.Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c > 0) {
                    li.Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c = li.Apttus_Config2__AttributeValueId__r.Number_of_Repos__c > 0 && li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c != CON_CPQ.SAUDIARABIA ? 1 : li.Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c;
                    li.Apttus_Config2__Quantity__c = li.Apttus_Config2__AttributeValueId__r.Number_of_Repos_SA__c;
                } else if(li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c != null && li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c > 0 && li.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c == CON_CPQ.SOUTH_AFRICA) {
                    li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c = li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c > 0 ? li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c : 1;
                    li.Apttus_Config2__Quantity__c = li.Apttus_Config2__AttributeValueId__r.No_of_Lines__c;
                } else {
                    li.Apttus_Config2__BasePriceOverride__c = null;
                }
                if (conversionRateByLineItem.containsKey(li.Id) && conversionRateByLineItem.get(li.Id) != 1) {
                    if (li.Apttus_Config2__BasePrice__c != null) {
                        li.Apttus_Config2__BasePriceOverride__c = Math.round(li.Apttus_Config2__BasePrice__c * conversionRateByLineItem.get(li.Id));
                    }
                }
            }
        }
    }

    public static Map<Id, Set<String>> getAllParents(Set<String> accountId) {
        Map<Id, Set<String>> idToParentMDMIds = new Map<Id, Set<String>>();
        Set<String> allAccounts;
        for (Account parentAccounts : [SELECT Id, Name, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, MDMID__c, Parent.MDMID__c, Parent.Parent.MDMID__c, Parent.Parent.Parent.MDMID__c, Parent.Parent.Parent.Parent.MDMID__c FROM Account WHERE Id IN: accountId]) {
            allAccounts = new Set<String>();
            if (parentAccounts != null) {
                allAccounts.add(parentAccounts.MDMID__c);
            }
            if (parentAccounts.ParentId != null) {
                allAccounts.add(parentAccounts.Parent.MDMID__c);
            }
            if (parentAccounts.Parent.ParentId != null) {
                allAccounts.add(parentAccounts.Parent.Parent.MDMID__c);
            }
            if (parentAccounts.Parent.Parent.ParentId != null) {
                allAccounts.add(parentAccounts.Parent.Parent.Parent.MDMID__c);
            }
            if (parentAccounts.Parent.Parent.Parent.ParentId != null) {
                allAccounts.add(parentAccounts.Parent.Parent.Parent.Parent.MDMID__c);
            }
            allAccounts.remove(null);
            idToParentMDMIds.put(parentAccounts.Id, allAccounts);
        }
        return idToParentMDMIds;
    }

    public static Integer getRequiredDocument(Integer documentCount) {
        Integer factor = documentCount > 100 ? 250 : 25;  
        if (Math.Mod(documentCount, factor) != 0) {
            return (documentCount/factor + 1) * factor;
        }
        return (documentCount/factor) * factor;
    }

    public static List<Apttus_Config2__LineItem__c> handleDPSPriceCalculation(List<Apttus_Config2__LineItem__c> listLineItem, Apttus_Proposal__Proposal__c proposal, Set<String> optionProductCodes, Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap, String numberOfConsent, Boolean isReprice) {
        Decimal useTotalSite = (proposal.IQVIA_Quote__r.Total_Sites__c < 100) ? (proposal.IQVIA_Quote__r.Total_Sites__c != null ? proposal.IQVIA_Quote__r.Total_Sites__c : 0) : (proposal.IQVIA_Quote__r.Total_Adjusted_Sites__c != null ? proposal.IQVIA_Quote__r.Total_Adjusted_Sites__c : 0);
        Integer documentCount = proposal.IQVIA_Quote__r.Total_ICF_Documents__c != null ? getRequiredDocument(Integer.valueOf(proposal.IQVIA_Quote__r.Total_ICF_Documents__c)) : 0;
        List<Apttus_Config2__LineItem__c> itemsToReprice = new List<Apttus_Config2__LineItem__c>();
        Set<String> productGroup2 = new Set<String>{'CES_2077L', 'CES_2077M'};
        Map<String, String> productCodeToQuantityField = new Map<String, String>();
        for (CPQ_Mapping_Field_Set__mdt fieldMapping : [SELECT Id, DeveloperName, Pricing_Tool__c, Sobject_Name__c, Feature_Selection__c, Field_Api_Name__c FROM CPQ_Mapping_Field_Set__mdt WHERE Feature_Selection__c = 'Pricing Callback' AND Sobject_Name__c = 'Quote__c' AND DeveloperName IN: optionProductCodes]) {
            if (!productCodeToQuantityField.containsKey(fieldMapping.DeveloperName) && fieldMapping.Field_Api_Name__c != null) {
                productCodeToQuantityField.put(fieldMapping.DeveloperName, fieldMapping.Field_Api_Name__c);
            }
        }
        Map<String, List<IQVIA_Price_Matrix__c>> productCodeToCustomPriceCombination = new Map<String, List<IQVIA_Price_Matrix__c>>();
        String condition = '(Account__r.MDMID__c IN :serviceLineNameSet OR Account__c = null) AND ' +
            '(Opportunity_Phase__c = \'' + proposal.IQVIA_Quote__r.Related_Opportunity__r.Phase__c + '\' OR Opportunity_Phase__c = null) AND ' +
            'Min_site_count__c <= '          + (useTotalSite != null ? useTotalSite : 0) + 
            ' AND Max_site_count__c >= '     + (useTotalSite != null ? useTotalSite : 0) + 
            ' AND Min_document_count__c <= ' + (documentCount != null ? documentCount : 0) + 
            ' AND Max_document_count__c >= ' + (documentCount != null ? documentCount : 0) +
            ' AND Min_consent_count__c <= '  + (numberOfConsent != null ? (numberOfConsent.contains(' ') ? Integer.valueOf(numberOfConsent.replaceAll('[a-zA-Z\\s]', '')) + 1 : Integer.valueOf(numberOfConsent.replaceAll('[a-zA-Z\\s]', ''))) : 0) + 
            ' AND Max_consent_count__c >= '  + (numberOfConsent != null ? (numberOfConsent.contains(' ') ? Integer.valueOf(numberOfConsent.replaceAll('[a-zA-Z\\s]', '')) + 1 : Integer.valueOf(numberOfConsent.replaceAll('[a-zA-Z\\s]', ''))) : 0) + 
            ' AND Pricing_Tool__c = \''      + proposal.Select_Pricing_Tool__c + 
            '\' AND Product_Code__c IN :productCodeSet';
        for (IQVIA_Price_Matrix__c iqviaMatrix : new SLT_IQVIAPriceMatrix().getIqviaPriceMatrixByCondition(CON_CPQ.DPS_IQVIA_PRICE_MATRIX_FIELDSET, condition, optionProductCodes, getAllParents(new Set<String>{proposal.IQVIA_Quote__r.Related_Account__c}).get(proposal.IQVIA_Quote__r.Related_Account__c), null, null, null, null, null, null)) {
            if (!productCodeToCustomPriceCombination.containsKey(iqviaMatrix.Product_Code__c)) {
                productCodeToCustomPriceCombination.put(iqviaMatrix.Product_Code__c, new List<IQVIA_Price_Matrix__c>{iqviaMatrix});
            } else {
                productCodeToCustomPriceCombination.get(iqviaMatrix.Product_Code__c).add(iqviaMatrix);
            }
        }
        for (Apttus_Config2__LineItem__c li : listLineItem) {
            Decimal totalPrice = 0.0;
            Decimal costPrice = 0.0;
            Decimal quantity = li.Apttus_Config2__Quantity__c != null ? li.Apttus_Config2__Quantity__c : 0;
            Decimal baseOverride = li.Apttus_Config2__BasePriceOverride__c != null ? li.Apttus_Config2__BasePriceOverride__c : 0;
            if (productCodeToCustomPriceCombination.containsKey(li.Apttus_Config2__OptionId__r.ProductCode)) {
                for (IQVIA_Price_Matrix__c iqviaMatrix : productCodeToCustomPriceCombination.get(li.Apttus_Config2__OptionId__r.ProductCode)) {
                    if (li.Apttus_Config2__OptionId__r.ProductCode == 'CES_2077K') {
                        if (proposal.IQVIA_Quote__r.Document_Type__c != CON_CPQ.INTERACTIVE_DOCUMENT_BUNDLE) {
                            li.Apttus_Config2__Quantity__c = 0;
                        } else {
                            li.Apttus_Config2__Quantity__c = documentCount;
                        }
                    } else if (productGroup2.contains(li.Apttus_Config2__OptionId__r.ProductCode) && proposal.IQVIA_Quote__r.Document_Type__c != CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS && proposal.IQVIA_Quote__r.Document_Type__c != CON_CPQ.PDF_DOCUMENT_BUNDLES) {
                        li.Apttus_Config2__Quantity__c = 0;
                    } else if (li.Apttus_Config2__OptionId__r.ProductCode == 'CES_2077E' && proposal.IQVIA_Quote__r.Document_Type__c != CON_CPQ.INTERACTIVE_INDIVIDUAL_DOCUMENT) {
                        li.Apttus_Config2__Quantity__c = 0;
                    } else if (li.Apttus_Config2__OptionId__r.ProductCode == 'US_CC_ENT_CONSCOMP') {
                        if (li.Apttus_Config2__AttributeValueId__c != null && li.Apttus_Config2__AttributeValueId__r.No_of_Consent__c != null) {
                            if (li.Apttus_Config2__AttributeValueId__r.No_of_Consent__c != CON_CPQ.GREATER_THAN_TWO_THOUSAND) {
                            	li.Apttus_Config2__Quantity__c = Integer.valueOf(li.Apttus_Config2__AttributeValueId__r.No_of_Consent__c.replaceAll('[a-zA-Z\\s]', ''));
                            } else if (li.Apttus_Config2__Quantity__c <= 20000) {
                                li.Apttus_Config2__Quantity__c = Integer.valueOf(li.Apttus_Config2__AttributeValueId__r.No_of_Consent__c.replaceAll('[a-zA-Z\\s]', '')) + 1;
                            }
                        } else {
                            li.Apttus_Config2__Quantity__c = 0;
                        }
                    } else {
                        if (productCodeToQuantityField.containsKey(li.Apttus_Config2__OptionId__r.ProductCode)) {
                            li.Apttus_Config2__Quantity__c = 1;
                            for (String field : productCodeToQuantityField.get(li.Apttus_Config2__OptionId__r.ProductCode).split(';')) {
                                if (field != null) {
                                    if (li.Apttus_Config2__OptionId__r.ProductCode == 'US_CC_STUDLIC' && field == CON_CPQ.STUDY_DURATION && Integer.valueOf(proposal.IQVIA_Quote__r.get(field)) <= 12) {
                                        li.Apttus_Config2__Quantity__c = 12;
                                        break;
                                    } else if (field == CON_CPQ.TOTAL_SITES) {
                                        li.Apttus_Config2__Quantity__c *= useTotalSite;
                                    } else if (li.Apttus_Config2__OptionId__r.ProductCode == 'CES_2077M' && field == CON_CPQ.TOTAL_ICF_DOCUMENT) {
                                        li.Apttus_Config2__Quantity__c = documentCount;
                                    } else {
                                    	li.Apttus_Config2__Quantity__c *= (double)(proposal.IQVIA_Quote__r.get(field) != null ? proposal.IQVIA_Quote__r.get(field) : 0);
                                    }
                                }
                            }
                        }
                    }
                    if (iqviaMatrix.Account__c != null) {
                        if (iqviaMatrix.Discount__c != null && iqviaMatrix.Discount__c != 0 && iqviaMatrix.Parent_Price_Matrix__r.Base_Price__c != null) {
                            totalPrice = iqviaMatrix.Parent_Price_Matrix__r.Base_Price__c * (1 - iqviaMatrix.Discount__c / 100);
                        } else {
                            totalPrice = iqviaMatrix.Base_Price__c;
                        }
                        li.Special_Pricing__c = CON_CPQ.YES_TITLE_CASE;
                    } else {
                        totalPrice = iqviaMatrix.Base_Price__c;
                    }
                    costPrice = li.Apttus_Config2__Quantity__c * iqviaMatrix.Cost_Price__c;
                    if (proposal.Apttus_QPConfig__PriceListId__r.CurrencyIsoCode != iqviaMatrix.CurrencyIsoCode) {
                        totalPrice *= isoCodeTocurrencyTypeMap.get(proposal.Apttus_QPConfig__PriceListId__r.CurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(iqviaMatrix.CurrencyIsoCode).Conversion_rate__c;
                        costPrice *= isoCodeTocurrencyTypeMap.get(proposal.Apttus_QPConfig__PriceListId__r.CurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(iqviaMatrix.CurrencyIsoCode).Conversion_rate__c;
                    }
                    li.Apttus_Config2__BasePriceOverride__c = totalPrice.setScale(2);
                    li.Cost_Price__c = costPrice.setScale(2);
                    if (totalPrice.setScale(2) * li.Apttus_Config2__Quantity__c != quantity * baseOverride) {
                        itemsToReprice.add(li);
                    }
                    break;
                }
            }
        }
        if (isReprice) {
            return itemsToReprice;
        }
        return null;
    }
    
    public static void productPricingCalculation(String metaDataMapKey, Apttus_Config2__LineItem__c lineItem, CPQ_AMESA_Partial_Product_Pricings__c productMetaData, String country, Map<Id, Decimal> conversionRateByLineItem, Map<String, Decimal> freqToDiscountedPriceFactor) {
        Double tempPrice = 0.0;
        if (africanCountries.contains(country)) {
            tempPrice = (lineItem.Apttus_Config2__AttributeValueId__r.National_Subscription__c) ? productMetaData.Final_Price_with_LMPT__c : productMetaData.Final_Price__c;
            tempPrice = tempPrice * (lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c <= 3 ? 0.2 : lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c <= 5 ? 0.3 : lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c <= 10 ? 0.4 : lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c <= 20 ? 0.5 : 1);
            tempPrice += lineItem.Apttus_Config2__AttributeValueId__r.With_Molecule__c ? (lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c <= 5 ? 600: 800) : 0;
        } else {
            tempPrice = (lineItem.Apttus_Config2__AttributeValueId__r.With_Molecule__c) ? productMetaData.Final_Price_with_molecule__c : productMetaData.Final_Price__c;
            tempPrice = (lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c < 15) ? tempPrice * (0.9623*(Math.pow(Double.valueof(lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c/100),Double.valueOf(0.339)))) : tempPrice * ((0.5882*(Double.valueof(lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c)))/100 + 0.4118);
        }
        if (freqToDiscountedPriceFactor.containsKey(lineItem.Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c) && freqToDiscountedPriceFactor.get(lineItem.Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c) != null) {
            tempPrice = tempPrice * freqToDiscountedPriceFactor.get(lineItem.Apttus_Config2__AttributeValueId__r.Data_Delivery_Frequency__c);
        }
        if (conversionRateByLineItem.containsKey(lineItem.Id) && conversionRateByLineItem.get(lineItem.Id) != 1) {
            tempPrice *= conversionRateByLineItem.get(lineItem.Id);
        }
        lineItem.Apttus_Config2__BasePriceOverride__c = Math.round(tempPrice);
    }
    
    // used to Calculate Gross Margin for OCE Pricing Tool
    public static void oceGrossMarginCalculation (List<Apttus_Config2__LineItem__c> lineItemList) {
        set<String> chargeTypesSet = new Set<String>{CON_CPQ.OCE_ADD_ON_PROD_GRP, CON_CPQ.OCE_SUBS_PROD_GRP, CON_CPQ.OCE_IMPLEM_PROD_GRP};
        set<ID> implementationIDs = new set<ID>();
        set<ID> subscriptionIDs = new set<ID>();
        set<ID> addOnIDs = new set<ID>();
        List<Apttus_Config2__ProductGroupMember__c> pGroupMemberList  = [SELECT Id, Apttus_Config2__ProductId__r.Name, Apttus_Config2__ProductId__c, Apttus_Config2__ProductGroupId__r.Name FROM Apttus_Config2__ProductGroupMember__c WHERE Apttus_Config2__ProductGroupId__r.Name IN : chargeTypesSet];
        for (Apttus_Config2__ProductGroupMember__c pgMember : pGroupMemberList ) {
            if (pgMember.Apttus_Config2__ProductGroupId__r.Name == CON_CPQ.OCE_ADD_ON_PROD_GRP) {
                addOnIDs.add(pgMember.Apttus_Config2__ProductId__c);
            }
            else if (pgMember.Apttus_Config2__ProductGroupId__r.Name == CON_CPQ.OCE_SUBS_PROD_GRP) {
                subscriptionIDs.add(pgMember.Apttus_Config2__ProductId__c);
            }
            else if (pgMember.Apttus_Config2__ProductGroupId__r.Name == CON_CPQ.OCE_IMPLEM_PROD_GRP) {
                implementationIDs.add(pgMember.Apttus_Config2__ProductId__c);
            }
        }
        for (Apttus_Config2__LineItem__c li : lineItemList) {
            if (li.Apttus_Config2__LineType__c == CON_CPQ.OPTION) {
                Decimal oceProdutCost = 0.0;
                Decimal calculatedMargin = 0.0;
                if (subscriptionIDs.contains(li.Apttus_Config2__OptionId__c)) {
                    oceProdutCost = li.Apttus_Config2__ExtendedPrice__c *0.3;
                }
                else if (addOnIDs.contains(li.Apttus_Config2__OptionId__c)) {
                    oceProdutCost = li.Apttus_Config2__ExtendedPrice__c *0.8;
                }
                else if (implementationIDs.contains(li.Apttus_Config2__OptionId__c)) {
                    oceProdutCost = li.Apttus_Config2__ExtendedPrice__c/2.5;
                }
                else {
                    oceProdutCost = 0;
                }
                calculatedMargin = li.Apttus_Config2__NetPrice__c > 0 ? ((li.Apttus_Config2__NetPrice__c - oceProdutCost)/li.Apttus_Config2__NetPrice__c)*100 : 0;
                if (calculatedMargin != li.Gross_Margin__c) {
                    li.Gross_Margin__c = calculatedMargin;
                }
            }
            else {
                li.Gross_Margin__c = null;
            }
        }
        if (lineItemList.size() > 0) {
            update lineItemList;
        }
        	
    }
    
    public static void changeProductStatusToPending (List<Apttus_Config2__LineItem__c> lineItemList, String proposalCurrencyIsoCode, Map<String, String> isoCodeByCountryMap) {
        for (Apttus_Config2__LineItem__c lineItem :lineItemList) {
            if (lineItem.Apttus_Config2__BasePriceOverride__c == null && lineItem.Apttus_Config2__BasePrice__c != null && lineItem.Apttus_Config2__BasePrice__c != 0) {
                if (isoCodeByCountryMap.containsKey(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) 
                   && isoCodeByCountryMap.get(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) != null 
                   && isoCodeByCountryMap.get(lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c) != proposalCurrencyIsoCode) {
                       lineItem.Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING;
                }
            }
        }
    }

    public static void handleQ2PriceCalculation(List<Apttus_Config2__LineItem__c> lineItemList, String pricingToolName, Id accountId, Id quoteId, String proposalCurrencyIsoCode, Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap) {
        Set<String> serviceLineNameSet = new Set<String>(); 
        Set<String> studyNumberSet = new Set<String>();
        Set<String> productCodeSet = new Set<String>();
        Set<String> premiumSet = new Set<String>{CON_CPQ.ALL}; 
        Set<String> clinicalTypeSet = new Set<String>{CON_CPQ.ALL}; 
        Set<String> specimenTypeSet = new Set<String>{CON_CPQ.ALL}; 
        Set<Integer> analyteSet = new Set<Integer>{9999};
        Set<String> bundleProductCodeSet = new Set<String>{CON_CPQ.ALL};
        for (Apttus_Config2__LineItem__c lineItem : lineItemList) {
            if (lineItem.Apttus_Config2__AttributeValueId__r.Study_Number__c != null) {
                studyNumberSet.add(lineItem.Apttus_Config2__AttributeValueId__r.Study_Number__c);
            }
            if (lineItem.Apttus_Config2__ProductId__c != null) {
                serviceLineNameSet.add(lineItem.Apttus_Config2__ProductId__c);
            }
            if (lineItem.Apttus_Config2__OptionId__r.ProductCode != null) {
                if (lineItem.Apttus_Config2__Description__c == null || lineItem.Apttus_Config2__Description__c == lineItem.Apttus_Config2__OptionId__r.Name) {
                    lineItem.Apttus_Config2__Description__c = lineItem.Apttus_Config2__OptionId__r.Name + ' (' + lineItem.Apttus_Config2__OptionId__r.ProductCode + ')';
                }
                productCodeSet.add(lineItem.Apttus_Config2__OptionId__r.ProductCode);
            }
            if (lineItem.Apttus_Config2__AttributeValueId__r.Premium__c != null) {
                premiumSet.addAll(lineItem.Apttus_Config2__AttributeValueId__r.Premium__c.split(';'));
            }
            if (lineItem.Apttus_Config2__AttributeValueId__r.Clinical_Type__c != null) {
               clinicalTypeSet.add(lineItem.Apttus_Config2__AttributeValueId__r.Clinical_Type__c); 
            }
            if (lineItem.Apttus_Config2__AttributeValueId__r.Specimen_Type__c != null) {
               specimenTypeSet.add(lineItem.Apttus_Config2__AttributeValueId__r.Specimen_Type__c);
            }
            if (lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c != null && lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c != CON_CPQ.MORE_THAN_THREE && lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c != 'N/A') {
                analyteSet.add(Integer.valueOf(lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c));
            }
            if (lineItem.Apttus_Config2__ProductId__r.ProductCode != null) {
                bundleProductCodeSet.add(lineItem.Apttus_Config2__ProductId__r.ProductCode);
            }
        }
        String conditionQuoteReq = 'Quote__c = \'' + quoteId + '\' AND Study_Number__c IN :studyNumberSet AND Service_Line_Product__c IN :serviceLineNameSet AND Type__c = \'' + CON_CPQ.STUDY_TYPE + '\'';
        List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteIdAndCartParams(CON_CPQ.Q2_QR_FIELDSET, conditionQuoteReq, studyNumberSet, serviceLineNameSet);
        Set<String> siteSet = new Set<String>{CON_CPQ.ALL};
        Decimal quoteConversionRate = (quoteReqList.size() > 0 && (quoteReqList[0].Quote__r.Conversion_Rate__c != 0 && quoteReqList[0].Quote__r.Conversion_Rate__c != null)) ? quoteReqList[0].Quote__r.Conversion_Rate__c : null; 
        for (Quote_Requisites__c quoteReqRecord : quoteReqList) {
            siteSet.add(quoteReqRecord.Site__c);
        }
        Map<String, List<IQVIA_Price_Matrix__c>> iqviaPriceMatrixMap = new Map<String, List<IQVIA_Price_Matrix__c>>();
        Map<String, List<IQVIA_Price_Matrix__c>> iqviaPriceMatrixMap2 = new Map<String, List<IQVIA_Price_Matrix__c>>();
        String condition = '(Account__c = \'' + accountId + '\' OR Account__c = null) AND Pricing_Tool__c = \'' + pricingToolName + '\' AND Product_Code__c IN :productCodeSet AND Bundle_Product_Code__c IN :bundleProductCodeSet AND Site__c IN:siteSet AND Clinical_Type__c IN :clinicalTypeSet AND Number_of_Analyte__c IN :analyteSet AND Premium__c IN :premiumSet AND Specimen_Type__c IN :specimenTypeSet AND Start_Date__c <= TODAY AND (End_Date__c = null OR End_Date__c >= TODAY)';
        for (IQVIA_Price_Matrix__c iqviaPriceMatrixItem : new SLT_IQVIAPriceMatrix().getIqviaPriceMatrixByConditionOrderByStartDate(CON_CPQ.Q2_IQVIA_PRICE_MATRIX_FIELDSET, condition, productCodeSet, serviceLineNameSet, siteSet, clinicalTypeSet, analyteSet, premiumSet, specimenTypeSet, bundleProductCodeSet)) {
            String metaDataMapKey = iqviaPriceMatrixItem.Bundle_Product_Code__c + ':' + iqviaPriceMatrixItem.Product_Code__c + ':' + string.valueOf(iqviaPriceMatrixItem.Number_of_Analyte__c) + ':' + iqviaPriceMatrixItem.Clinical_Type__c + ':' + iqviaPriceMatrixItem.Premium__c + ':' + iqviaPriceMatrixItem.Specimen_Type__c;
            String metaDataMapKey2 = iqviaPriceMatrixItem.Bundle_Product_Code__c + ':' + iqviaPriceMatrixItem.Product_Code__c;
            if (iqviaPriceMatrixMap.containsKey(metaDataMapKey)) {
                iqviaPriceMatrixMap.get(metaDataMapKey).add(iqviaPriceMatrixItem);    
            } else {
                iqviaPriceMatrixMap.put(metaDataMapKey, new List<IQVIA_Price_Matrix__c>{iqviaPriceMatrixItem});
            }
            if (iqviaPriceMatrixMap2.containsKey(metaDataMapKey2)) {
                iqviaPriceMatrixMap2.get(metaDataMapKey2).add(iqviaPriceMatrixItem);    
            } else {
                iqviaPriceMatrixMap2.put(metaDataMapKey2, new List<IQVIA_Price_Matrix__c>{iqviaPriceMatrixItem});
            }
        }
        for (Apttus_Config2__LineItem__c lineItem : lineItemList) {
            String analyte = String.isEmpty(lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c) || lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c == 'N/A' ? ':9999' : (':' + (lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c  == CON_CPQ.MORE_THAN_THREE ? '9999' : lineItem.Apttus_Config2__AttributeValueId__r.Number_of_Analyte__c ));
            String clinicalType = String.isEmpty(lineItem.Apttus_Config2__AttributeValueId__r.Clinical_Type__c) || lineItem.Apttus_Config2__AttributeValueId__r.Clinical_Type__c == 'N/A' ? ':All' : ':' + lineItem.Apttus_Config2__AttributeValueId__r.Clinical_Type__c;
            String premium = String.isEmpty(lineItem.Apttus_Config2__AttributeValueId__r.Premium__c) ? CON_CPQ.ALL : lineItem.Apttus_Config2__AttributeValueId__r.Premium__c;
            String specimenType = String.isEmpty(lineItem.Apttus_Config2__AttributeValueId__r.Specimen_Type__c) ? ':All' : ':' + lineItem.Apttus_Config2__AttributeValueId__r.Specimen_Type__c;
            String metaDataMapKey = lineItem.Apttus_Config2__ProductId__r.ProductCode + ':' + lineItem.Apttus_Config2__OptionId__r.ProductCode;
            String metaDataMapKey_All = CON_CPQ.ALL + ':' + lineItem.Apttus_Config2__OptionId__r.ProductCode;
            List<IQVIA_Price_Matrix__c> iqviaPriceMatrixItemList = processMatrixMatch(
                iqviaPriceMatrixMap,
                iqviaPriceMatrixMap2,
                metaDataMapKey,
                metaDataMapKey_All,
                analyte,
                clinicalType,
                premium,
                specimenType,
                lineItem.Apttus_Config2__ProductId__r.ProductCode,
                lineItem.Apttus_Config2__OptionId__r.ProductCode
            );
            
            if (iqviaPriceMatrixItemList != null && iqviaPriceMatrixItemList.size() > 0) {
                Decimal basePrice = 0.0;
                for (IQVIA_Price_Matrix__c matrix : iqviaPriceMatrixItemList) {
                    basePrice += matrix.Base_Price__c;
                }
                if (proposalCurrencyIsoCode != iqviaPriceMatrixItemList[0].CurrencyISOCode || quoteConversionRate != 1) {
                    if (quoteConversionRate != null) {
                        basePrice *= quoteConversionRate;
                    } else {
                        basePrice *= (Decimal)(isoCodeTocurrencyTypeMap.get(proposalCurrencyIsoCode).Conversion_rate__c / isoCodeTocurrencyTypeMap.get(iqviaPriceMatrixItemList[0].CurrencyISOCode).Conversion_rate__c);
                    }
                }
                if (lineItem.Apttus_Config2__BasePriceOverride__c == null || lineItem.Apttus_Config2__BasePriceOverride__c == lineItem.Base_Price_Callback__c || (lineItem.Base_Price_Callback__c == null && lineItem.Apttus_Config2__BasePriceOverride__c != null && lineItem.Apttus_Config2__BasePriceOverride__c != 0)) {
                    lineItem.Apttus_Config2__BasePriceOverride__c = basePrice.setScale(2);
                    lineItem.Base_Price_Callback__c = lineItem.Apttus_Config2__BasePriceOverride__c;
                }
            } else if (lineItem.Apttus_Config2__BasePriceOverride__c == null) {
                lineItem.Apttus_Config2__BasePriceOverride__c = lineItem.Base_Price_Callback__c = 0.0;
            } else if (lineItem.Base_Price_Callback__c != 0.0 && iqviaPriceMatrixItemList.isEmpty()){
                lineItem.Apttus_Config2__BasePriceOverride__c = 0;
            }
        }
    }

    private static List<IQVIA_Price_Matrix__c> processMatrixMatch(
        Map<String, List<IQVIA_Price_Matrix__c>> iqviaPriceMatrixMap,
        Map<String, List<IQVIA_Price_Matrix__c>> iqviaPriceMatrixMap2,
        String metaDataMapKey,
        String metaDataMapKey_All,
        String analyte,
        String clinicalType,
        String premium,
        String specimenType,
        String productCode,
        String optionCode
    ) {
        List<IQVIA_Price_Matrix__c> iqviaPriceMatrixItemList = new List<IQVIA_Price_Matrix__c>();
        Integer maxMatchCount = 0;
        String partialMetaDataMapKey = '';
        Set<String> premiumSet2 = new Set<String>();
        String keyToUse = iqviaPriceMatrixMap2 != null && iqviaPriceMatrixMap2.containsKey(metaDataMapKey) 
            ? metaDataMapKey 
            : metaDataMapKey_All;
        String allString = (keyToUse == metaDataMapKey_All) ? CON_CPQ.ALL : productCode;
        if (iqviaPriceMatrixMap2 != null && iqviaPriceMatrixMap2.containsKey(keyToUse)) {
            List<IQVIA_Price_Matrix__c> matrixList = iqviaPriceMatrixMap2.get(keyToUse);
            if (matrixList != null) {
                for (IQVIA_Price_Matrix__c matrix : matrixList) {
                    Integer matchCount = 0;
                    String innerKey = '';
                    String keyPrefixString = ':';
                    
                    if (matrix.Number_of_Analyte__c != null && (keyPrefixString + String.valueOf(matrix.Number_of_Analyte__c)).equals(analyte)) {
                        matchCount++;
                        innerKey += analyte;
                    } else {
                        innerKey += ':9999';
                    }
                    
                    if (matrix.Clinical_Type__c != null && (keyPrefixString + matrix.Clinical_Type__c).equals(clinicalType)) {
                        matchCount++;
                        innerKey += clinicalType;
                    } else {
                        innerKey += ':All';
                    }
                    innerKey += 'tempPremium';
                    if (premium != null) {
                        for (String premiumTemp : premium.split(';')) {
                            if (matrix.Premium__c != null && matrix.Premium__c.equals(premiumTemp)) {
                                matchCount++;
                                premiumSet2.add(':' + premiumTemp);
                            } else {
                                premiumSet2.add(':All');
                            }
                        }
                    }
                    if (matrix.Specimen_Type__c != null && (keyPrefixString + matrix.Specimen_Type__c).equals(specimenType)) {
                        matchCount++;
                        innerKey += specimenType;
                    } else {
                        innerKey += ':All';
                    }
                    if (matchCount > maxMatchCount) {
                        maxMatchCount = matchCount;
                        partialMetaDataMapKey = innerKey;
                    }
                }
            }
        }
        if (!premiumSet2.isEmpty()) {
            for (String premiumValue : premiumSet2) {
                String metaDataMapKey2 = allString + ':' + optionCode + partialMetaDataMapKey.replace('tempPremium', premiumValue);
                if (iqviaPriceMatrixMap != null && iqviaPriceMatrixMap.containsKey(metaDataMapKey2)) {
                    List<IQVIA_Price_Matrix__c> matrixItems = iqviaPriceMatrixMap.get(metaDataMapKey2);
                    if (matrixItems != null) {
                        iqviaPriceMatrixItemList.addAll(matrixItems);
                    }
                }
            }
        }
        return iqviaPriceMatrixItemList;
    }
}