/*
* Version       : 0.0.1
* Description   : This Apex class is Utility Class for Quote
* Created By    : Danish khan
* Created For   : Sync and utility for quote
*/ 
public class CPQ_QuoteUtility {
    
    public static Map<String, Schema.SObjectField> mapOfDescribeFields = Schema.getGlobalDescribe().get(CON_CPQ.QUOTE_REQUISITES).getDescribe().fields.getMap();
    private static final String featureSettingsForQuoteLineItems = '{"partialSave" : false, "internalCall" : true}';
    
    public static void syncQuoteWithOpportunityDynamically(Id budgetId, String tool, String stageName, String bidCurrency, String oppCurrencyCode, Decimal requestedCurrencyConversionRate, Decimal currentCurrencyConversionRate) {
        try {
            Integer ordinaryLineCount = 0;
            Map<String, Boolean> pricingToolToOliRepititionMap = new Map<String, Boolean>();
            Boolean revenueSchedulesRequired = false;
            String budgetType = String.valueOf(budgetId.getsobjecttype());
            Set<String> objForSync = new Set<String>{budgetType};
            Map<String, Map<String, List<String>>> objToAttributes = new Map<String, Map<String, List<String>>>();
            Set<String> attributeFieldSet = new Set<String>();
            Map<String, String> toolToCountry = new Map<String, String>();
            Map<String, Set<String>> pricingToolToProductSyncMap = new Map<String, Set<String>>();
            if (stageName == CON_CPQ.IN_PROGRESS_STATUS && checkCongaPermission()) {
                objForSync.add(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
            }
            for (CPQ_Opp_Sync_Attribute__mdt syncAttr : [SELECT Attribute_List__c, Country__c, Pricing_Tool__c, Object_Name__c, OLI_Repetition__c, Default_Country__c FROM CPQ_Opp_Sync_Attribute__mdt WHERE Pricing_Tool__c IN: tool.split(';') AND Object_Name__c IN: objForSync]) {
                if (!toolToCountry.containsKey(syncAttr.Pricing_Tool__c)) {
                    if (syncAttr.Default_Country__c != null) {
                        toolToCountry.put(syncAttr.Pricing_Tool__c + ':' + syncAttr.Object_Name__c, syncAttr.Default_Country__c);
                    } else if (syncAttr.Country__c != null) {
                        toolToCountry.put(syncAttr.Pricing_Tool__c + ':' + syncAttr.Object_Name__c, syncAttr.Country__c);
                    }
                }
                if (syncAttr.Attribute_List__c != null) {
                    if (!objToAttributes.containsKey(syncAttr.Object_Name__c)) {
                        objToAttributes.put(syncAttr.Object_Name__c, new Map<String, List<String>>{syncAttr.Pricing_Tool__c => new List<String>(syncAttr.Attribute_List__c.split(';'))});
                    } else {
                        objToAttributes.get(syncAttr.Object_Name__c).put(syncAttr.Pricing_Tool__c, new List<String>(syncAttr.Attribute_List__c.split(';')));
                    }
                    if (syncAttr.Object_Name__c == CON_CPQ.APTTUS_PROPOSAL_PROPOSAL) {
                        attributeFieldSet.addAll(syncAttr.Attribute_List__c.split(';'));
                    }
                }
                if (!pricingToolToOliRepititionMap.containsKey(syncAttr.Pricing_Tool__c)) {
                    pricingToolToOliRepititionMap.put(syncAttr.Pricing_Tool__c, syncAttr.OLI_Repetition__c);
                }
            }
            Map<String, List<CPQ_Opp_Sync_Product_Mappings__c>> pricingToolToProductMappingMap = new Map<String, List<CPQ_Opp_Sync_Product_Mappings__c>>();
            Set<String> productSyncType = new Set<String>();
            for (CPQ_Opp_Sync_Product_Mappings__c cospm : [SELECT Id, Attribute_Value_1__c, Attribute_Value_2__c, Attribute_Value_3__c, Attribute_Value_4__c, Attribute_Value_5__c, 
                                                            CPQ_Product_Code__c, MDM_Product_Code__c, OLIS_Required__c, Product_Name__c, Product_Sync_Type__c, Pricing_Tool__c 
                                                            FROM CPQ_Opp_Sync_Product_Mappings__c 
                                                            WHERE Pricing_Tool__c IN: tool.split(';')]) {
                if (cospm.OLIS_Required__c == true) {
                    revenueSchedulesRequired = true;
                }
                if (!pricingToolToProductMappingMap.containsKey(cospm.Pricing_Tool__c)) {
                    pricingToolToProductSyncMap.put(cospm.Pricing_Tool__c, new Set<String>{cospm.Product_Sync_Type__c});
                    pricingToolToProductMappingMap.put(cospm.Pricing_Tool__c, new List<CPQ_Opp_Sync_Product_Mappings__c>{cospm});
                } else {
                    pricingToolToProductSyncMap.get(cospm.Pricing_Tool__c).add(cospm.Product_Sync_Type__c);
                    pricingToolToProductMappingMap.get(cospm.Pricing_Tool__c).add(cospm);
                }
                productSyncType.add(cospm.Product_Sync_Type__c);
            }
            Map<String, Id> mdmCodeToProductIdMap = new Map<String, Id>();
            Map<Id, String> productIdToMDMCodeMap = new Map<Id, String>();
            Map<String, Product2> mdmProductDetailMap = new Map<String, Product2>();
            Map<String, String> productCodeToMDMCodeMappingMap = new Map<String, String>();
            Map<String, List<String>> mdmCodeToProductCodeMappingMap = new Map<String, List<String>>();
            Map<String, CPQ_Opp_Sync_Product_Mappings__c> mdmCodeToMetadataMap = new Map<String, CPQ_Opp_Sync_Product_Mappings__c>();
            Set<String> optionSet = new Set<String>();
            Set<String> bundleSet = new Set<String>();
            List<OpportunityLineItem> opportunityLinetemList = new List<OpportunityLineItem>();
            Set<Id> oppProductIdsSet = new Set<Id>();
            Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
            for (String pricingTool : pricingToolToProductMappingMap.keySet()) {
                for (CPQ_Opp_Sync_Product_Mappings__c cospm : pricingToolToProductMappingMap.get(pricingTool)) {
                    Integer noOfAttributes;
                    if (objToAttributes.containsKey(budgetType) && objToAttributes.get(budgetType).containsKey(pricingTool)) { 
                        noOfAttributes = objToAttributes.get(budgetType).get(pricingTool).size();
                    }
                    String productCodeToMDMCodeMapKey = cospm.CPQ_Product_Code__c;
                    if (noOfAttributes > 0) {
                        productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_1__c;
                    }
                    if (noOfAttributes > 1) {
                        productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_2__c;
                    }
                    if (noOfAttributes > 2) {
                        productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_3__c;
                    }
                    if (noOfAttributes > 3) {
                        productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_4__c;
                    }
                    if (noOfAttributes > 4) {
                        productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_5__c;
                    }
                    productCodeToMDMCodeMappingMap.put(productCodeToMDMCodeMapKey, cospm.MDM_Product_Code__c);
                    mdmCodeToMetadataMap.put(cospm.MDM_Product_Code__c, cospm);
                    if (mdmCodeToProductCodeMappingMap.containsKey(cospm.MDM_Product_Code__c)) {
                        List<String> productCodesSet = mdmCodeToProductCodeMappingMap.get(cospm.MDM_Product_Code__c);
                        productCodesSet.add(cospm.CPQ_Product_Code__c);
                        mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, productCodesSet);
                    } else {
                        mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, new List<String> {cospm.CPQ_Product_Code__c});
                    }
                    if (cospm.Product_Sync_Type__c == CON_CPQ.OPTION) {
                        optionSet.add(cospm.CPQ_Product_Code__c);
                    } else {
                        bundleSet.add(cospm.CPQ_Product_Code__c);
                    }
                }
            }

            Map<String, List<Quote_Line_Item__c>> pricingToolToQLIMap = new Map<String, List<Quote_Line_Item__c>>();
            List<String> pricingToolSet = tool.split(';');
            String condition = 'Quote__c =  \'' + budgetId + '\' AND Pricing_Tool__c IN: pricingToolSet ';
            List<Quote_Line_Item__c> quoteLineItemsList = new SLT_QuoteLineItem().getQuoteLineItemByPricingTools(condition, CON_CPQ.QLI_FIELD_SET, optionSet, bundleSet, pricingToolSet);
            if (!quoteLineItemsList.isEmpty()) {
                for (Quote_Line_Item__c qli : quoteLineItemsList) {
                    if (!pricingToolToProductSyncMap.isEmpty() && pricingToolToProductSyncMap.containsKey(qli.Pricing_Tool__c)) {
                        if ((pricingToolToProductSyncMap.get(qli.Pricing_Tool__c)).contains('Option') && qli.Option_Product__c != null) {
                            if (!pricingToolToQLIMap.containsKey(qli.Pricing_Tool__c)) {
                                pricingToolToQLIMap.put(qli.Pricing_Tool__c, new List<Quote_Line_Item__c>()); 
                            }	
                            pricingToolToQLIMap.get(qli.Pricing_Tool__c).add(qli);
                        } else if (!(pricingToolToProductSyncMap.get(qli.Pricing_Tool__c)).contains('Option') && qli.Option_Product__c == null) {
                            if (!pricingToolToQLIMap.containsKey(qli.Pricing_Tool__c)) {
                                pricingToolToQLIMap.put(qli.Pricing_Tool__c, new List<Quote_Line_Item__c>()); 
                            }	
                            pricingToolToQLIMap.get(qli.Pricing_Tool__c).add(qli);   
                        }
                    }  else {
                        if (!pricingToolToQLIMap.containsKey(qli.Pricing_Tool__c)) {
                            pricingToolToQLIMap.put(qli.Pricing_Tool__c, new List<Quote_Line_Item__c>()); 
                        }	
                        pricingToolToQLIMap.get(qli.Pricing_Tool__c).add(qli);
                    }
                    if (pricingToolSet.contains(qli.Pricing_Tool__c) && !pricingToolToProductMappingMap.containsKey(qli.Pricing_Tool__c)) {
                        String pCode = qli.Option_Product__c != null ? qli.Option_Product__r.ProductCode : qli.Bundle_Product__r.ProductCode;
                        mdmCodeToProductCodeMappingMap.put(pCode, new List<String>{pCode});
                    }
                }
            }
            fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote__c.SobjectType
                }
            );
            if (quoteLineItemsList.size() > 0) {
                Date oppCloseDate = quoteLineItemsList.get(0).Quote__r.Related_Opportunity__r.CloseDate;
                String oppStage = quoteLineItemsList.get(0).Quote__r.Related_Opportunity__r.StageName;
                Id oppId = quoteLineItemsList.get(0).Quote__r.Related_Opportunity__c;
                String quotePricingTool = quoteLineItemsList.get(0).Pricing_Tool__c;
                Boolean isCurrencySame = true;
                if (bidCurrency != oppCurrencyCode) {
                    isCurrencySame = false;
                }
                for (Product2 p : [Select Id, ProductCode, IsActive From Product2 Where ProductCode IN :mdmCodeToProductCodeMappingMap.keySet()]) {
                    mdmCodeToProductIdMap.put(p.ProductCode, p.Id);
                    productIdToMDMCodeMap.put(p.Id, p.ProductCode);
                    mdmProductDetailMap.put(p.ProductCode, p);
                }
                List<OpportunityLineItem> oppLineItemList = new SLT_OpportunityLineItems().selectOLIByOpportunityId(new Set<ID>{oppId});
                Map<String, List<OpportunityLineItem>> product_countryToLineItemMap = new Map<String, List<OpportunityLineItem>>();
                Set<Id> sAPOLISet = new Set<Id>();
                for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                    if (opportunityLineItem.Agreement_Line_Item_Id__c != null) {
                        if (opportunityLineItem.Billing_System__c == CON_CPQ.SAP) {
                            sAPOLISet.add(opportunityLineItem.Id);
                        }
                        String oliKey = quotePricingTool == CON_CPQ.Q2_Solutions ? opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c : opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c + '&&' + opportunityLineItem.Revenue_Start_Date__c + '&&' + opportunityLineItem.Revenue_End_Date__c;
                        if (product_countryToLineItemMap.containsKey(oliKey)) {
                            List<OpportunityLineItem> oliList = product_countryToLineItemMap.get(oliKey);
                            oliList.add(opportunityLineItem);
                            product_countryToLineItemMap.put(oliKey, oliList);
                        } else {
                            product_countryToLineItemMap.put(oliKey, new List<OpportunityLineItem> {opportunityLineItem});
                        }
                    }
                }       
                Map<String, Id> productToPriceBookMap = new Map<String, Id>();
                Set<String> nonExistingMDMProductsSet = new Set<String>();
                Set<String> inactiveMDMProductsSet = new Set<String>();
                productToPriceBookMap = CPQ_QuoteUtility.getProductToPriceBookMap(productToPriceBookMap, productIdToMDMCodeMap, oppCurrencyCode);
                Map<Id, List<OpportunityLineItemSchedule>> oLIScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                for (OpportunityLineItemSchedule oli : new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(sAPOLISet, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITYLINEITEMID})) {
                    if (!oLIScheduleMap.containskey(oli.OpportunityLineItemId)) {
                        oLIScheduleMap.put(oli.OpportunityLineItemId, new List<OpportunityLineItemSchedule> {oli});
                    } else {
                        List<OpportunityLineItemSchedule> oliList = oLIScheduleMap.get(oli.OpportunityLineItemId);
                        oliList.add(oli);
                        oLIScheduleMap.put(oli.OpportunityLineItemId, oliList);
                    }
                }
                Map<String, List<SObject>> mergeBudgetLineItemMap = new Map<String, List<SObject>>();
                for (String pricingTool : pricingToolToQLIMap.keySet()) {
                    if (pricingTool == CON_CPQ.EMEA) {
                        revenueSchedulesRequired = true;
                    }
                    for (Quote_Line_Item__c quoteLineItem : pricingToolToQLIMap.get(pricingTool)) { 
                        ordinaryLineCount++;
                        String mapKey = quoteLineItem.Option_Product__c != null ? quoteLineItem.Option_Product__r.ProductCode : quoteLineItem.Bundle_Product__r.ProductCode;
                        String country = '';
                        if (quoteLineItem != null) {
                            if (objToAttributes.containsKey(budgetType) && objToAttributes.get(budgetType).containsKey(pricingTool)) {
                                for (String attributeFieldName : objToAttributes.get(budgetType).get(pricingTool)) {
                                    mapKey = mapKey + ':' + quoteLineItem.get(attributeFieldName);
                                }
                            }
                            if (toolToCountry.containsKey(pricingTool + ':' + CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME)) {
                                country = toolToCountry.get(pricingTool + ':' + CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME).contains('__c') ? (String)quoteLineItem.get(toolToCountry.get(pricingTool + ':' + CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME)) : toolToCountry.get(pricingTool + ':' + CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME);
                            } else if (quoteLineItem.Country__c != null) {
                                country = quoteLineItem.Country__c;
                            }
                        }
                        String  mdmProductCode = productCodeToMDMCodeMappingMap.containsKey(mapKey) ? productCodeToMDMCodeMappingMap.get(mapKey) : (quoteLineItem.Option_Product__c != null ? quoteLineItem.Option_Product__r.ProductCode : quoteLineItem.Bundle_Product__r.ProductCode);
                        Product2 mdmProduct = mdmProductDetailMap.get(mdmProductCode);
                        if (mdmProduct == null) {
                            nonExistingMDMProductsSet.add(mdmProductCode);
                        } else if(!mdmProduct.IsActive) {
                            inactiveMDMProductsSet.add(mdmProductCode);
                        }
                        Date startDate;
                        Date endDate;
                        String qLIRevenueType;
                        String qliSalesType;
                        String qliDiscountReason = ''; 
                        String qliSurchargeReason = '';
                        if (quoteLineItem.Start_Date__c != null) {
                            startDate = quoteLineItem.Start_Date__c;
                            endDate = (quoteLineItem.End_Date__c != null ? quoteLineItem.End_Date__c : quoteLineItem.Start_Date__c.addMonths(11));
                        } else {
                            startDate = oppCloseDate;
                            endDate = oppCloseDate.addMonths(11);
                        }
                        if (quoteLineItem.Revenue_Type__c != null) {
                            qLIRevenueType = quoteLineItem.Revenue_Type__c;
                        } else {
                           qLIRevenueType = CON_CPQ.AD_HOC; 
                        }
                        If (quoteLineItem.Sales_Type__c != null) {
                            qliSalesType = quoteLineItem.Sales_Type__c;
                        } else {
                            qliSalesType =  CON_CPQ.SALE_TYPE_NEW;
                        }
                        if (quotePricingTool == CON_CPQ.EMEA) {
                            qliDiscountReason = quoteLineItem.Discount_Reason__c != null ? quoteLineItem.Discount_Reason__c : '';
                            qliSurchargeReason = quoteLineItem.Surcharge_Reason__c != null ? quoteLineItem.Surcharge_Reason__c : '';
                        } 
                        String key = mdmProductCode + '&&' + country + '&&' + startDate + '&&' + endDate + '&&' + qLIRevenueType + '&&' + qliSalesType + '&&' + qliDiscountReason + '&&' + qliSurchargeReason;
                        if (pricingToolToOliRepititionMap.get(pricingTool) == false) {
                            if (mergeBudgetLineItemMap.containsKey(key)) {
                                List<SObject> mergeBudgetLineItemList = mergeBudgetLineItemMap.get(key);
                                mergeBudgetLineItemList.add(quoteLineItem);
                                mergeBudgetLineItemMap.put(key, mergeBudgetLineItemList);
                            } else {
                                mergeBudgetLineItemMap.put(key, new List<SObject> {quoteLineItem});
                            }
                        } else {
                            mergeBudgetLineItemMap.put(key + '&&' + ordinaryLineCount, new List<SObject> {quoteLineItem});
                        }
                    }
                }
                
                if (nonExistingMDMProductsSet.size() > 0 || inactiveMDMProductsSet.size() > 0) {
                    String exeMSG = 'Synchronization to Opportunity cannot be done. ' ;
                    exeMSG = nonExistingMDMProductsSet.size() > 0 ? exeMSG + 'These MDM Products does not exist : ' + string.join(new List<String>(nonExistingMDMProductsSet),', ') : inactiveMDMProductsSet.size() > 0 ? 'Inactive MDM Products found : ' + string.join(new List<String>(inactiveMDMProductsSet),', ') : exeMSG;
                    throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + exeMSG);
                } else {
                    Map<String, Double> oliToQLINoOfInstallment = new Map<String, Double>();
                    Map<String, String> oliToQLIInstallmentPeriod = new Map<String, String>();
                    for (String key : mergeBudgetLineItemMap.keySet()) {
                        List<String> keyList = key.split('&&');
                        String mdmProductCode = keyList[0];
                        String country = keyList[1];
                        Date startDate = Date.valueOf(keyList[2]);
                        Date endDate = Date.valueOf(keyList[3]);
                        String revenueType = keyList[4];
                        String salesType = keyList[5];
                        String discountReason = keyList.size() > 6 ? keyList[6] : '';
                        String surchargeReason = keyList.size() > 7 ? keyList[7] : '';
                        Id priceBookEntryId = productToPriceBookMap.get(mdmProductCode + oppCurrencyCode);
                        ID productId = mdmCodeToProductIdMap.get(mdmProductCode);
                        Double price = 0;
                        Double listPrice = 0;
                        String pliIds = '';
                        String description = '';
                        Double noOfInstallment = 0;
                        String installmentPeriod = '';
                        for (SObject budgetLine : mergeBudgetLineItemMap.get(key)) {
                            if (String.valueOf(budgetLine.Id.getsobjecttype()).equals(CON_CPQ.QUOTE_LINE_ITEM)) {
                                price = price + (Double)budgetLine.get(CON_CPQ.NET_PRICE);
                                listPrice = listPrice + (budgetLine.get(CON_CPQ.QLI_BASE_PRICE) != null ? (Double)budgetLine.get(CON_CPQ.QLI_BASE_PRICE) : 0);
                                pliIds = (pliIds == '' ? (String)budgetLine.Id : pliIds + ';' + (String)budgetLine.Id);
                                description = (description == '' ? (String)budgetLine.get(CON_CPQ.DESCRIPTION) : (String)(description + '\n' + budgetLine.get(CON_CPQ.DESCRIPTION)));
                                noOfInstallment = (Double)budgetLine.get('Number_of_Installment__c');
                                installmentPeriod = (String)budgetLine.get('Installment_Period__c');
                            } else {
                                price = price + (Double)budgetLine.get(CON_CPQ.LINE_ITEM_NETPRICE);
                                pliIds = (pliIds == '' ? (String)budgetLine.Id : pliIds + ';' + (String)budgetLine.Id);
                                description = (description == '' ? (String)budgetLine.get(CON_CPQ.LINE_ITEM_DESCRIPTION) : (String)(description + '\n' + budgetLine.get(CON_CPQ.LINE_ITEM_DESCRIPTION)));
                            }
                        }
                        String oliKey = quotePricingTool == CON_CPQ.Q2_Solutions ? productId + '&&' + country : productId + '&&' + country + '&&' + startDate + '&&' + endDate;
                        if (product_countryToLineItemMap != null && productId != null && product_countryToLineItemMap.containskey(oliKey)){
                            List<OpportunityLineItem> lineItemList = product_countryToLineItemMap.get(oliKey);
                            OpportunityLineItem oppLineItem = lineItemList[0];
                            oppLineItem.UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(requestedCurrencyConversionRate, currentCurrencyConversionRate, price));
                            oppLineItem.Quantity = 1;
                            oppLineItem.Description = description;
                            oppLineItem.Delivery_Country__c = country;
                            oppLineItem.Sale_Type__c = salesType;
                            oppLineItem.Revenue_Type__c = revenueType;
                            oppLineItem.Revenue_End_Date__c = endDate;
                            oppLineItem.Revenue_Start_Date__c = startDate;
                            oppLineItem.Therapy_Area__c = CON_CPQ.NONE;
                            oppLineItem.Agreement_Line_Item_Id__c = pliIds;
                            if (quotePricingTool == CON_CPQ.EMEA) {
                                oppLineItem.Discount_Reason__c = discountReason;
                                oppLineItem.Surcharge_Text__c = surchargeReason;
                                oppLineItem.List_Price__c = isCurrencySame ? listPrice : (CPQ_Utility.getCurrencyConvertedValue(requestedCurrencyConversionRate, currentCurrencyConversionRate, listPrice));
                            } 
                            opportunityLinetemList.add(oppLineItem);
                            oppProductIdsSet.add(oppLineItem.Id);
                            if (sAPOLISet.Size() > 0 && sAPOLISet.contains(oppLineItem.Id) ) {
                                if (oLIScheduleMap != null && oLIScheduleMap.Size() > 0 && oLIScheduleMap.containsKey(oppLineItem.Id)) {
                                    List<OpportunityLineItemSchedule> oliSchList = oLIScheduleMap.get(oppLineItem.Id);
                                    Integer numberOfInstallment = oliSchList.size();
                                    Decimal unitPrice = oppLineItem.UnitPrice;
                                    Decimal amount = Math.floor(unitPrice / numberOfInstallment);
                                    Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                                    for (integer index = 0; index < numberOfInstallment; index++) {
                                        oliSchList[index].Revenue = amount;
                                    }
                                    oliSchList[numberOfInstallment - 1].Revenue = unitPrice - sumOfAmount;
                                    lineItemScheduleMap.put(oppLineItem.Id, oliSchList);
                                }
                            } 
                            lineItemList.remove(0);
                            if (lineItemList.size() > 0 ) {
                                product_countryToLineItemMap.put(oliKey, lineItemList);
                            } else {
                                product_countryToLineItemMap.remove(oliKey);
                            }
                            if (!oliToQLINoOfInstallment.containsKey(oppLineItem.Agreement_Line_Item_Id__c) && noOfInstallment != null) {
                                oliToQLINoOfInstallment.put(oppLineItem.Agreement_Line_Item_Id__c, noOfInstallment);
                            }
                            if (!oliToQLIInstallmentPeriod.containsKey(oppLineItem.Agreement_Line_Item_Id__c) && installmentPeriod != null) {
                                oliToQLIInstallmentPeriod.put(oppLineItem.Agreement_Line_Item_Id__c, installmentPeriod);
                            }
                        } else if (productId != null && productIdToMDMCodeMap.containsKey(productId) && productToPriceBookMap.containsKey(mdmProductCode + oppCurrencyCode)){
                            OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppId,
                                priceBookEntryId =  priceBookEntryId,
                                Product2Id =  productId,
                                UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(requestedCurrencyConversionRate, currentCurrencyConversionRate, price)),
                                Quantity = 1,
                                Delivery_Country__c = country,
                                Description = description,
                                Revenue_End_Date__c = endDate,
                                Revenue_Start_Date__c = startDate,
                                Agreement_Line_Item_Id__c = pliIds,
                                Sale_Type__c = salesType, 
                                Revenue_Type__c = revenueType,
                                Therapy_Area__c = CON_CPQ.NONE
                            );
                            if (quotePricingTool == CON_CPQ.EMEA) {
                                oppLineItem.Discount_Reason__c = discountReason;
                                oppLineItem.Surcharge_Text__c = surchargeReason;
                                oppLineItem.List_Price__c = isCurrencySame ? listPrice : (CPQ_Utility.getCurrencyConvertedValue(requestedCurrencyConversionRate, currentCurrencyConversionRate, listPrice));
                            }
                            opportunityLinetemList.add(oppLineItem);
                            if (!oliToQLINoOfInstallment.containsKey(oppLineItem.Agreement_Line_Item_Id__c) && noOfInstallment != null) {
                                oliToQLINoOfInstallment.put(oppLineItem.Agreement_Line_Item_Id__c, noOfInstallment);
                            }
                            if (!oliToQLIInstallmentPeriod.containsKey(oppLineItem.Agreement_Line_Item_Id__c) && installmentPeriod != null) {
                                oliToQLIInstallmentPeriod.put(oppLineItem.Agreement_Line_Item_Id__c, installmentPeriod);
                            }
                        }
                    }
                    fflib_SObjectUnitOfWork uowOpplineItem = new fflib_SObjectUnitOfWork (
                        new Schema.SObjectType[] {
                            OpportunityLineItem.SobjectType
                        }
                    );
                    List<OpportunityLineItem> opportunityLinetemListToUpdate = new List<OpportunityLineItem>();
                    if (quotePricingTool == CON_CPQ.Q2_Solutions && !CON_CPQ.OPPORTUNITY_STAGES.contains(oppStage)) {
                        opportunityLinetemListToUpdate = CPQ_QuoteUtility.setOppLineItemUnitPriceToZero(oppProductIdsSet, oppLineItemList);
                    } else {
                        if (oppProductIdsSet.size() > 0) {
                            List<OpportunityLineItem> opportunityLinetemListToDeleteList = CPQ_QuoteUtility.deleteOppLineItem(oppProductIdsSet, oppLineItemList);
                            if (opportunityLinetemListToDeleteList.size() > 0) {
                                uowOpplineItem.registerDeleted(opportunityLinetemListToDeleteList);
                                uowOpplineItem.commitWork();
                            }
                        } else {
                            uowOpplineItem.registerDeleted(oppLineItemList);
                            uowOpplineItem.commitWork();
                        }
                    }
                    if (opportunityLinetemList.size() > 0) {
                        fflib_SObjectUnitOfWork uowUpsertOpplineItem = new fflib_SObjectUnitOfWork (
                            new Schema.SObjectType[] {
                                OpportunityLineItem.SobjectType
                            }
                        );
                        List<OpportunityLineItem> mergedDataset = new List<OpportunityLineItem>(opportunityLinetemList);
                        if (!CON_CPQ.OPPORTUNITY_STAGES.contains(oppStage) && !opportunityLinetemListToUpdate.isEmpty()) {
                            mergedDataset.addAll(opportunityLinetemListToUpdate);
                        }
                        uowUpsertOpplineItem.registerUpsert(mergedDataset);
                        uowUpsertOpplineItem.commitWork();
                        if (revenueSchedulesRequired == true) {
                            lineItemScheduleMap = CPQ_QuoteUtility.getOppLineItemSchedMap(productIdToMDMCodeMap, mdmCodeToMetadataMap, oLIScheduleMap, lineItemScheduleMap, opportunityLinetemList, oliToQLINoOfInstallment, oliToQLIInstallmentPeriod);
                            if (lineItemScheduleMap.size() > 0) {
                                if (!test.isRunningTest()) {
                                    QUE_CPQ_TimeDelayForSchedule scheduleUpdate = new QUE_CPQ_TimeDelayForSchedule(lineItemScheduleMap, budgetId); 
                                    Id jobId = System.enqueueJob(scheduleUpdate);
                                }
                            } else {
                                uowProposal.registerDirty(new Quote__c(Id = budgetId, Execution_Message__c = (CON_CPQ.FAILED)));
                                uowProposal.commitWork();
                            }
                        }
                        else {
                            UTL_ExecutionControl.stopTriggerExecutionCPQ = true;
                            uowProposal.registerDirty(new Quote__c(Id = budgetId, Execution_Status__c = (CON_CPQ.COMPLETED)));
                            uowProposal.commitWork();
                            UTL_ExecutionControl.stopTriggerExecutionCPQ = false;
                        }
                    }
                }
            } else {
                throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + CON_CPQ.NO_QUOTE_LINE_ITEM_OR_CART_TO_SYNC_TO_OPPORTUNITY);
            }
        } catch (DmlException ex) {
            throw new CPQ_CustomException(ex.getDmlMessage(0));
        } catch (Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }
    private static  Map<String, Id> getProductToPriceBookMap(Map<String, Id> productToPriceBookMap, Map<Id, String> productIdToMDMCodeMap, String oppCurrencyCode) {
        List<PriceBook2> standardPriceBookList = new SLT_PriceBook2().getstandardPriceBook(new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.ISACTIVE});
        if (standardPriceBookList.size() > 0) {
            Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.PRODUCTCODE, CON_CPQ.ISACTIVE, CON_CPQ.CURRENCYISOCODE, CON_CPQ.PRODUCTID};
            List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getStandardPriceBookByName(fieldSet, productIdToMDMCodeMap.keySet(), standardPriceBookList[0].Id, new List<String>{oppCurrencyCode});
            if (!priceBookEntryList.isEmpty()) {
                for (PricebookEntry priceBookEntry : priceBookEntryList) {
                    if (priceBookEntry.IsActive == true) {
                        productToPriceBookMap.put(priceBookEntry.ProductCode + priceBookEntry.CurrencyIsoCode, priceBookEntry.Id);
                    }
                }
            } else {
                throw new CPQ_CustomException(CON_CPQ.FAILED + ': ' + 'There are no PriceBook Entries present for the product to be synced.');
            }
        }
        return productToPriceBookMap;
    }

    @TestVisible
    private static List<OpportunityLineItem> deleteOppLineItem(Set<Id> oppProductIdsSet, List<OpportunityLineItem> oppLineItemList) {
        List<OpportunityLineItem> opportunityLinetemListToDeleteList = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
            if (!oppProductIdsSet.contains(opportunityLineItem.Id)) {
                opportunityLinetemListToDeleteList.add(opportunityLineItem);
            }
        }
        return opportunityLinetemListToDeleteList;
    }
    @TestVisible
    private static List<OpportunityLineItem> setOppLineItemUnitPriceToZero(Set<Id> oppProductIdsSet, List<OpportunityLineItem> oppLineItemList) {
        List<OpportunityLineItem> opportunityLinetemListToUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
            if (!oppProductIdsSet.contains(opportunityLineItem.Id)) {
                opportunityLineItem.UnitPrice = 0;
                opportunityLinetemListToUpdate.add(opportunityLineItem);
            }
        }
        return opportunityLinetemListToUpdate;
    }
    private static Map<Id, List<OpportunityLineItemSchedule>> getOppLineItemSchedMap(Map<Id, String> productIdToMDMCodeMap, Map<String, CPQ_Opp_Sync_Product_Mappings__c> mdmCodeToMetadataMap, Map<Id, List<OpportunityLineItemSchedule>> oLIScheduleMap, Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap, List<OpportunityLineItem> opportunityLinetemList, Map<String, Double> oliToQLINoOfInstallment, Map<String, String> oliToQLIInstallmentPeriod) {
        for (OpportunityLineItem oppLineItem : opportunityLinetemList) {
            CPQ_Opp_Sync_Product_Mappings__c metaDataRecord = mdmCodeToMetadataMap.get(productIdToMDMCodeMap.get(oppLineItem.Product2Id));
            Boolean oLIsRequired = metaDataRecord != null ? metaDataRecord.OLIS_Required__c : true;
            if (oLIsRequired && !oLIScheduleMap.containskey(oppLineItem.ID)) {
                List<OpportunityLineItemSchedule> oliSchList = (lineItemScheduleMap.containsKey(oppLineItem.ID) ? lineItemScheduleMap.get(oppLineItem.ID) : new List<OpportunityLineItemSchedule>());
                Integer numberOfInstallment = (Integer)(oliToQLINoOfInstallment.get(oppLineItem.Agreement_Line_Item_Id__c) != null ? oliToQLINoOfInstallment.get(oppLineItem.Agreement_Line_Item_Id__c) : oppLineItem.Revenue_End_Date__c.day() >= oppLineItem.Revenue_Start_Date__c.day() ? (oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c))+1 : oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c));
                Decimal price = oppLineItem.UnitPrice;
                Decimal amount = Math.floor(price / numberOfInstallment);
                Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                Date revenueDate = oppLineItem.Revenue_Start_Date__c; 
                Boolean revenueTpyeADHOC = false;
                String numberOfInstallmentPeriod =  oliToQLIInstallmentPeriod.get(oppLineItem.Agreement_Line_Item_Id__c);
                if (numberOfInstallmentPeriod == CON_CPQ.ONCE) {
                    numberOfInstallment = 1;
                    price = oppLineItem.UnitPrice;
                    amount = Math.floor(price);
                    sumOfAmount = amount;
                    OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                    oliSchList.add(oliSchedule);
                    revenueTpyeADHOC = true;
                }
                for (integer index = 0; index < numberOfInstallment - 1; index++) {
                    OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                    if (numberOfInstallmentPeriod == null || numberOfInstallmentPeriod == CON_CPQ.MONTHLY) {
                        revenueDate = revenueDate.addMonths(1); 
                    } else if (numberOfInstallmentPeriod == CON_CPQ.YEARLY) {
                        revenueDate = revenueDate.addYears(1);  
                    } else if (numberOfInstallmentPeriod == CON_CPQ.QUARTERLY) {
                        revenueDate = revenueDate.addMonths(3); 
                    } else if (numberOfInstallmentPeriod == CON_CPQ.SEMESTERLY) {
                        revenueDate = revenueDate.addMonths(6);
                    }  else if (numberOfInstallmentPeriod == CON_CPQ.WEEKLY) {
                        revenueDate = revenueDate.addDays(7);
                    } else if (numberOfInstallmentPeriod == CON_CPQ.DAILY) {
                        revenueDate = revenueDate.addDays(1); 
                    }
                    oliSchList.add(oliSchedule);
                }
                if (!revenueTpyeADHOC) {
                    OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                    oliSchList.add(oliSchedule);
                }
                lineItemScheduleMap.put(oppLineItem.ID, oliSchList);
            }
        }
        return lineItemScheduleMap;
    }

    @AuraEnabled
    public static String getBatchStatus(Id jobId) {
        try {
            List<AsyncApexJob> apexJobList = [SELECT Id, ApexClass.Name, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Id =: jobId ORDER BY CreatedDate];
            return apexJobList.size() > 0 ? apexJobList[0].Status == CON_CPQ.FAILED ? apexJobList[0].ExtendedStatus : apexJobList[0].Status == CON_CPQ.COMPLETED ? apexJobList[0].Status : null : null;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static void createQuoteLineItemsUsingProposalLineItem(Id quoteId, Id proposalId, String proposalPricingTool, String pathway) {
        Set<String> fieldSet = new Set<String>{CON_CPQ.QUOTE_LINE_ITEM_ADJUSTEMENT_TYPE, CON_CPQ.QUOTE_LINE_ITEM_EXTENDEDPRICE, CON_CPQ.QUOTE_LINE_ITEM_NETPRICE, CON_CPQ.QUOTE_LINE_ITEM_OPTION_ID, CON_CPQ.QUOTE_LINE_ITEM_PRODUCT, CON_CPQ.QUOTE_LINE_ITEM_LINE_NUMBER};
        Map<String, String> QLIFieldByPLIFieldMap = new Map<String, String>();
        String pricingTool = '%' + proposalPricingTool + '%';
        for (CPQ_Mapping_Field_Set__mdt mapFields : [SELECT Id, Opportunity_Field__c, Pricing_Tool__c, Quote_Field__c
                                                     FROM CPQ_Mapping_Field_Set__mdt
                                                     WHERE Feature_Selection__c = 'Conga Finalization'
                                                     AND Sobject_Name__c = 'Quote_Line_Item__c'
                                                     AND Source_Object__c = 'Apttus_Proposal__Proposal_Line_Item__c'
                                                     AND Pricing_Tool__c LIKE: pricingTool]) {
            if (mapFields.Opportunity_Field__c != null) {
                If (mapFields.Quote_Field__c != null) {
                   QLIFieldByPLIFieldMap.put(mapFields.Opportunity_Field__c, mapFields.Quote_Field__c); 
                }
                fieldSet.add(mapFields.Opportunity_Field__c);
            }
        }
        Quote__c quote = new Quote__c(Id = quoteId);
        Map<Integer, List<Apttus_Proposal__Proposal_Line_Item__c>> pliListByLineNumberMap = new Map<Integer, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        for (Apttus_Proposal__Proposal_Line_Item__c pli : new SLT_ProposalLineItems().getPLI(fieldSet, proposalId)) {
            if (!pliListByLineNumberMap.containsKey(Integer.valueOf(pli.Apttus_QPConfig__LineNumber__c))) {
                pliListByLineNumberMap.put(Integer.valueOf(pli.Apttus_QPConfig__LineNumber__c), new List<Apttus_Proposal__Proposal_Line_Item__c>());
            }    
            List<Apttus_Proposal__Proposal_Line_Item__c> tempList = pliListByLineNumberMap.get(Integer.valueOf(pli.Apttus_QPConfig__LineNumber__c));
            tempList.add(pli);
            pliListByLineNumberMap.put(Integer.valueOf(pli.Apttus_QPConfig__LineNumber__c), tempList);
            
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.X2_day_visits__c') && pli.Apttus_QPConfig__AttributeValueId__r.X2_day_visits__c != null) {
                quote.On_Site_Training_Days__c = pli.Apttus_QPConfig__AttributeValueId__r.X2_day_visits__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Webinars_1_hour_session__c') && pli.Apttus_QPConfig__AttributeValueId__r.Webinars_1_hour_session__c != null) {
                quote.Webinars__c = pli.Apttus_QPConfig__AttributeValueId__r.Webinars_1_hour_session__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Participant_Comprehension_Quizzes__c') && pli.Apttus_QPConfig__AttributeValueId__r.Participant_Comprehension_Quizzes__c != null) {
                quote.Participant_Comprehension_Quizzes__c = pli.Apttus_QPConfig__AttributeValueId__r.Participant_Comprehension_Quizzes__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.ICF_Documents_to_Amend__c') && pli.Apttus_QPConfig__AttributeValueId__r.ICF_Documents_to_Amend__c != null) {
                quote.Amendments_to_ICF_Documents__c = pli.Apttus_QPConfig__AttributeValueId__r.ICF_Documents_to_Amend__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Patient_Education_Glossary_Definitions__c') && pli.Apttus_QPConfig__AttributeValueId__r.Patient_Education_Glossary_Definitions__c != null) {
                quote.Patient_Education_Glossary_Definitions__c = pli.Apttus_QPConfig__AttributeValueId__r.Patient_Education_Glossary_Definitions__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c') && pli.Apttus_QPConfig__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c != null){
                quote.Amendments_to_Patient_Videos__c = pli.Apttus_QPConfig__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Patient_Videos__c') && pli.Apttus_QPConfig__AttributeValueId__r.Patient_Videos__c != null) {
                quote.Patient_Videos__c = pli.Apttus_QPConfig__AttributeValueId__r.Patient_Videos__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Sponsor_Tablets__c') && pli.Apttus_QPConfig__AttributeValueId__r.Sponsor_Tablets__c != null) {
                quote.Sponsor_Tablets__c = pli.Apttus_QPConfig__AttributeValueId__r.Sponsor_Tablets__c;
            }
            if (fieldSet.contains('Apttus_QPConfig__AttributeValueId__r.Site_Tablets__c') && pli.Apttus_QPConfig__AttributeValueId__r.Site_Tablets__c != null) {
                quote.Site_Tablets__c = pli.Apttus_QPConfig__AttributeValueId__r.Site_Tablets__c;
            }
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> resultList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for (Integer key: pliListByLineNumberMap.keySet()) {
            List<Apttus_Proposal__Proposal_Line_Item__c> tempList2 = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            for (Apttus_Proposal__Proposal_Line_Item__c pli: pliListByLineNumberMap.get(key)) {
                if (pli.Apttus_QPConfig__OptionId__c == null) {
                    resultList.add(pli);
                } else {
                    tempList2.add(pli);
                }
            }
            resultList.addAll(tempList2);
        }
        Id bundleId;
        Double bundleTotal, bundleCostPrice;
        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> pliByIdMap = new Map<Id, Apttus_Proposal__Proposal_Line_Item__c>();
        if (resultList.size() >0) {
            for (Apttus_Proposal__Proposal_Line_Item__c pli: resultList) {
                pliByIdMap.put(pli.Id, pli);
                if (pli.Apttus_QPConfig__OptionId__c  == null) {
                    bundleId = pli.Id;
                    bundleTotal = bundleCostPrice = 0;
                } else {
                    bundleTotal += pli.Apttus_QPConfig__ExtendedPrice__c != null ? pli.Apttus_QPConfig__ExtendedPrice__c : 0;
                    bundleCostPrice += pli.Cost_Price__c != null ? pli.Cost_Price__c : 0;
                    pliByIdMap.get(bundleId).Apttus_QPConfig__BasePriceOverride__c = bundleTotal;
                    pliByIdMap.get(bundleId).Apttus_QPConfig__ExtendedPrice__c = bundleTotal;
                    pliByIdMap.get(bundleId).Cost_Price__c = bundleCostPrice;
                }
            }
        }
        Decimal totalDiscountAmountWOMarkup = null;
        Map<String,Object> qliObj = new Map<String,Object>();
        Map<Id, Object> qliByIdMap = new Map<Id, Object>();
        List<Object> quoteLineItems = new List<Object>();
        Integer bundleIndex = null;
        Integer optionIndex = null;
        Boolean isSpecialPricing = false;
        if (pliByIdMap.size() >0) {
            for (Apttus_Proposal__Proposal_Line_Item__c pli : pliByIdMap.values()) {
                Map<String,Object> qli = new Map<String,Object>();
                qli.put('Quote__c', quoteId);
                qli.put('Pricing_Tool__c', proposalPricingTool);
                qli.put('Proposal_Line_Item__c', pli.Id);
                qli.put('Pathway__c', pathway);
                qli.put('Country__c', CON_CPQ.USA);
                qli.put('Bundle_Product__c', pli.Apttus_Proposal__Product__c);
                qli.put('Option_Product__c', pli.Apttus_QPConfig__OptionId__c);
                if (qli.get('Bundle_Product__c') != null && qli.get('Option_Product__c') == null) {
                    qli.put('Include_In_Summary__c', true);
                }
                if (QLIFieldByPLIFieldMap.size() >0) {
                    for (String key: QLIFieldByPLIFieldMap.keySet()) {
                        if (key.contains('.')) {
                            List<String> parentObj = key.split('\\.');
                            qli.put(QLIFieldByPLIFieldMap.get(key), pli.getSObject(parentObj[0]).get(parentObj[1]));
                        } else {
                            qli.put(QLIFieldByPLIFieldMap.get(key), pli.get(key));
                            if (key == CON_CPQ.QUOTE_LINE_ITEM_ADJUSTEMENT_AMOUNT && pli.Apttus_QPConfig__AdjustmentType__c == CON_CPQ.PERCENT_MARKUP) {
                                Decimal discountAmount = (Decimal)(pli.get(key));
                                qli.put(QLIFieldByPLIFieldMap.get(key), (discountAmount) * (-1));
                            }
                        }
                    }
                }
                qli.put('Discount_Amount__c', (pli.Apttus_QPConfig__ExtendedPrice__c != null ? pli.Apttus_QPConfig__ExtendedPrice__c : 0) - (pli.Apttus_QPConfig__NetPrice__c != null ? pli.Apttus_QPConfig__NetPrice__c : 0));
                Decimal discountAmount = (Decimal) qli.get('Discount_Amount__c');
                qli.put('Discount_Percent__c', ((discountAmount != null && discountAmount != 0 && pli.Apttus_QPConfig__ExtendedPrice__c != null && pli.Apttus_QPConfig__ExtendedPrice__c != 0) ? (discountAmount / pli.Apttus_QPConfig__ExtendedPrice__c) * 100 : 0));
                Id pli_Id = (Id) qli.get('Proposal_Line_Item__c');
                qliByIdMap.put(pli_Id, qli);
                quoteLineItems.add(qli);
                if (qli.get('Option_Product__c') == null) {
                    qliObj.put('Discount_Amount_W_O_Markup__c', totalDiscountAmountWOMarkup);
                    if (totalDiscountAmountWOMarkup != null) {
                        quoteLineItems.set(bundleIndex, qliObj);
                    }
                    bundleIndex = quoteLineItems.indexOf(qli);
                    bundleId = (Id) qli.get('Proposal_Line_Item__c');
                    qliObj = (Map<String,Object>) qliByIdMap.get(bundleId);
                    totalDiscountAmountWOMarkup = 0;
                } else {
                    optionIndex = quoteLineItems.indexOf(qli);
                    if (discountAmount != null && discountAmount > 0) {
                        qli.put('Discount_Amount_W_O_Markup__c', discountAmount);
                        totalDiscountAmountWOMarkup += discountAmount;
                    }
                    quoteLineItems.set(optionIndex, qli);
                }
                if ((String) qli.get('Special_Pricing__c') == CON_CPQ.YES_TITLE_CASE) {
                    isSpecialPricing = true;
                }
            }
            qliObj.put('Discount_Amount_W_O_Markup__c', totalDiscountAmountWOMarkup);
            quoteLineItems.set(bundleIndex, qliObj);
        }
        if (proposalPricingTool == CON_CPQ.Q2_Solutions) {
            Map<String, Quote_Requisites__c> qrByStudyNumberMap = new Map<String, Quote_Requisites__c>();
            String condition = 'Quote__c IN: quoteIdSet';
            List<Quote_Requisites__c> quoteRequisitesList = new SLT_QuoteRequisites().getQuoteRequisitesRecord(new Set<Id>{quoteId}, new Set<String>{CON_CPQ.ID, CON_CPQ.BID_HISTORY_STUDY_NUMBER}, condition);
            for (Quote_Requisites__c qr: quoteRequisitesList) {
                qrByStudyNumberMap.put(qr.Study_Number__c, qr);
            }
            if (quoteLineItems.size() > 0) {
                for (Object qli: quoteLineItems) {
                    Map<String, Object> rli = (Map<String, Object>) qli;
                    if (qrByStudyNumberMap.containsKey((String) rli.get('Study_Number__c'))) {
                        rli.put('Quote_Requisites__c', qrByStudyNumberMap.get((String) rli.get('Study_Number__c')).Id);
                    }
                }
            }
        }
        fflib_SObjectUnitOfWork uow;
        if (!quoteLineItems.isEmpty()) {
            try {
                String condition = 'Quote__c = \'' + quoteId + '\' AND Pricing_Tool__c = \'' + proposalPricingTool + '\'' + ' AND Pathway__c = \'' + pathway + '\'';
                List<Quote_Line_Item__c> quoteLineItemsToDelete = new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new set<String>{CON_CPQ.ID});
                if (!quoteLineItemsToDelete.isEmpty()) {
                    uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            Quote_Line_Item__c.SObjectType
                        }
                    );
                    DAOH_IQ_Quote_Line_Item.ALLOW_QLI_DELETION = true;
                    uow.registerDeleted(quoteLineItemsToDelete);
                    uow.commitWork();
                }
                uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote_Line_Item__c.SObjectType, Quote__c.SObjectType
                    }
                );
                String jsonInput = JSON.serialize(quoteLineItems);
                UTL_CPQ_Services.insertQLIs(jsonInput, featureSettingsForQuoteLineItems);
                quote.Special_Pricing__c = isSpecialPricing;
                uow.registerDirty(quote);
                uow.commitWork(); 
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }  
        }
    }

    public static void createQuoteLineItemsUsingConfigLineItem(Id quoteId, Id proposalId, String proposalPricingTool, String pathway) {
        Set<String> fieldSet = new Set<String>{CON_CPQ.LINE_ITEM_ADJUSTMENT_TYPE, CON_CPQ.LINE_ITEM_EXTENDEDPRICE, CON_CPQ.LINE_ITEM_NETPRICE, CON_CPQ.LINE_ITEM_OPTION_ID, CON_CPQ.LINE_ITEM_PRODUCT, CON_CPQ.LINE_NUMBER};
        Map<String, String> QLIFieldByCLIFieldMap = new Map<String, String>();
        String pricingTool = '%' + proposalPricingTool + '%';
        for (CPQ_Mapping_Field_Set__mdt mapFields : [SELECT Id, Opportunity_Field__c, Pricing_Tool__c, Quote_Field__c
                                                     FROM CPQ_Mapping_Field_Set__mdt
                                                     WHERE Feature_Selection__c = 'Conga Finalization'
                                                     AND Sobject_Name__c = 'Quote_Line_Item__c'
                                                     AND Source_Object__c = 'Apttus_Config2__LineItem__c'
                                                     AND Pricing_Tool__c LIKE: pricingTool]) {
            if (mapFields.Opportunity_Field__c != null) {
                if (mapFields.Quote_Field__c != null) {
                   QLIFieldByCLIFieldMap.put(mapFields.Opportunity_Field__c, mapFields.Quote_Field__c); 
                }
                fieldSet.add(mapFields.Opportunity_Field__c);
            }
        }
        Quote__c quote = new Quote__c(Id = quoteId);
        Map<Integer, List<Apttus_Config2__LineItem__c>> cliListByLineNumberMap = new Map<Integer, List<Apttus_Config2__LineItem__c>>();
        for (Apttus_Config2__LineItem__c cli : new SLT_LineItem().getLineItemsByProposalId(new Set<Id>{proposalId}, fieldSet)) {
            if (!cliListByLineNumberMap.containsKey(Integer.valueOf(cli.Apttus_Config2__LineNumber__c))) {
                cliListByLineNumberMap.put(Integer.valueOf(cli.Apttus_Config2__LineNumber__c), new List<Apttus_Config2__LineItem__c>());
            }    
            List<Apttus_Config2__LineItem__c> tempList = cliListByLineNumberMap.get(Integer.valueOf(cli.Apttus_Config2__LineNumber__c));
            tempList.add(cli);
            cliListByLineNumberMap.put(Integer.valueOf(cli.Apttus_Config2__LineNumber__c), tempList);
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.X2_day_visits__c') && cli.Apttus_Config2__AttributeValueId__r.X2_day_visits__c != null) {
                quote.On_Site_Training_Days__c = cli.Apttus_Config2__AttributeValueId__r.X2_day_visits__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Webinars_1_hour_session__c') && cli.Apttus_Config2__AttributeValueId__r.Webinars_1_hour_session__c != null) {
                quote.Webinars__c = cli.Apttus_Config2__AttributeValueId__r.Webinars_1_hour_session__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Participant_Comprehension_Quizzes__c') && cli.Apttus_Config2__AttributeValueId__r.Participant_Comprehension_Quizzes__c != null) {
                quote.Participant_Comprehension_Quizzes__c = cli.Apttus_Config2__AttributeValueId__r.Participant_Comprehension_Quizzes__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.ICF_Documents_to_Amend__c') && cli.Apttus_Config2__AttributeValueId__r.ICF_Documents_to_Amend__c != null) {
                quote.Amendments_to_ICF_Documents__c = cli.Apttus_Config2__AttributeValueId__r.ICF_Documents_to_Amend__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Patient_Education_Glossary_Definitions__c') && cli.Apttus_Config2__AttributeValueId__r.Patient_Education_Glossary_Definitions__c != null) {
                quote.Patient_Education_Glossary_Definitions__c = cli.Apttus_Config2__AttributeValueId__r.Patient_Education_Glossary_Definitions__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c') && cli.Apttus_Config2__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c != null){
                quote.Amendments_to_Patient_Videos__c = cli.Apttus_Config2__AttributeValueId__r.No_of_Patient_Videos_to_Amend__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Patient_Videos__c') && cli.Apttus_Config2__AttributeValueId__r.Patient_Videos__c != null) {
                quote.Patient_Videos__c = cli.Apttus_Config2__AttributeValueId__r.Patient_Videos__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Sponsor_Tablets__c') && cli.Apttus_Config2__AttributeValueId__r.Sponsor_Tablets__c != null) {
                quote.Sponsor_Tablets__c = cli.Apttus_Config2__AttributeValueId__r.Sponsor_Tablets__c;
            }
            if (fieldSet.contains('Apttus_Config2__AttributeValueId__r.Site_Tablets__c') && cli.Apttus_Config2__AttributeValueId__r.Site_Tablets__c != null) {
                quote.Site_Tablets__c = cli.Apttus_Config2__AttributeValueId__r.Site_Tablets__c;
            }
        }
        List<Apttus_Config2__LineItem__c> resultList = new List<Apttus_Config2__LineItem__c>();
        for (Integer key: cliListByLineNumberMap.keySet()) {
            List<Apttus_Config2__LineItem__c> tempList2 = new List<Apttus_Config2__LineItem__c>();
            for (Apttus_Config2__LineItem__c cli: cliListByLineNumberMap.get(key)) {
                if (cli.Apttus_Config2__OptionId__c == null) {
                    resultList.add(cli);
                } else {
                    tempList2.add(cli);
                }
            }
            resultList.addAll(tempList2);
        }
        Id bundleId;
        Double bundleTotal, bundleCostPrice;
        Map<Id, Apttus_Config2__LineItem__c> cliByIdMap = new Map<Id, Apttus_Config2__LineItem__c>();
        if (resultList.size() > 0) {
            for (Apttus_Config2__LineItem__c cli: resultList) {
                cliByIdMap.put(cli.Id, cli);
                if (cli.Apttus_Config2__OptionId__c  == null) {
                    bundleId = cli.Id;
                    bundleTotal = bundleCostPrice = 0;
                } else {
                    bundleTotal += cli.Apttus_Config2__ExtendedPrice__c != null ? cli.Apttus_Config2__ExtendedPrice__c : 0;
                    bundleCostPrice += cli.Cost_Price__c != null ? cli.Cost_Price__c : 0;
                    cliByIdMap.get(bundleId).Apttus_Config2__BasePriceOverride__c = bundleTotal;
                    cliByIdMap.get(bundleId).Apttus_Config2__ExtendedPrice__c = bundleTotal;
                    cliByIdMap.get(bundleId).Cost_Price__c = bundleCostPrice;
                }
            }
        }
        Decimal totalDiscountAmountWOMarkup = null;
        Map<String,Object> qliObj = new Map<String,Object>();
        Map<Id, Object> qliByIdMap = new Map<Id, Object>();
        List<Object> quoteLineItems = new List<Object>();
        Integer bundleIndex = null;
        Integer optionIndex = null;
        Boolean isSpecialPricing = false;
        if (cliByIdMap.size() >0) {
            for (Apttus_Config2__LineItem__c cli : cliByIdMap.values()) {
                Map<String,Object> qli = new Map<String,Object>();
                qli.put('Quote__c', quoteId);
                qli.put('Pricing_Tool__c', proposalPricingTool);
                qli.put('Proposal_Line_Item__c', cli.Id);
                qli.put('Pathway__c', pathway);
                qli.put('Country__c', CON_CPQ.USA);
                qli.put('Bundle_Product__c', cli.Apttus_Config2__ProductId__c);
                qli.put('Option_Product__c', cli.Apttus_Config2__OptionId__c);
                if (qli.get('Bundle_Product__c') != null && qli.get('Option_Product__c') == null) {
                    qli.put('Include_In_Summary__c', true);
                }
                if (QLIFieldByCLIFieldMap.size() >0) {
                    for (String key: QLIFieldByCLIFieldMap.keySet()) {
                        if (key.contains('.')) {
                            List<String> parentObj = key.split('\\.');
                            qli.put(QLIFieldByCLIFieldMap.get(key), cli.getSObject(parentObj[0]).get(parentObj[1]));
                        } else {
                            qli.put(QLIFieldByCLIFieldMap.get(key), cli.get(key));
                            if (key == CON_CPQ.QUOTE_LINE_ITEM_ADJUSTEMENT_AMOUNT && cli.Apttus_Config2__AdjustmentType__c == CON_CPQ.PERCENT_MARKUP) {
                                Decimal discountAmount = (Decimal)(cli.get(key));
                                qli.put(QLIFieldByCLIFieldMap.get(key), (discountAmount) * (-1));
                            }
                        }
                    }
                }
                qli.put('Discount_Amount__c', (cli.Apttus_Config2__ExtendedPrice__c != null ? cli.Apttus_Config2__ExtendedPrice__c : 0) - (cli.Apttus_Config2__NetPrice__c != null ? cli.Apttus_Config2__NetPrice__c : 0));
                Decimal discountAmount = (Decimal) qli.get('Discount_Amount__c');
                qli.put('Discount_Percent__c', ((discountAmount != null && discountAmount != 0 && cli.Apttus_Config2__ExtendedPrice__c != null && cli.Apttus_Config2__ExtendedPrice__c != 0) ? (discountAmount / cli.Apttus_Config2__ExtendedPrice__c) * 100 : 0));
                Id pli_Id = (Id) qli.get('Proposal_Line_Item__c');
                qliByIdMap.put(pli_Id, qli);
                quoteLineItems.add(qli);
                if (qli.get('Option_Product__c') == null) {
                    qliObj.put('Discount_Amount_W_O_Markup__c', totalDiscountAmountWOMarkup);
                    if (totalDiscountAmountWOMarkup != null) {
                        quoteLineItems.set(bundleIndex, qliObj);
                    }
                    bundleIndex = quoteLineItems.indexOf(qli);
                    bundleId = (Id) qli.get('Proposal_Line_Item__c');
                    qliObj = (Map<String,Object>) qliByIdMap.get(bundleId);
                    totalDiscountAmountWOMarkup = 0;
                } else {
                    optionIndex = quoteLineItems.indexOf(qli);
                    if (discountAmount != null && discountAmount > 0) {
                        qli.put('Discount_Amount_W_O_Markup__c', discountAmount);
                        totalDiscountAmountWOMarkup += discountAmount;
                    }
                    quoteLineItems.set(optionIndex, qli);
                }
                if ((String) qli.get('Special_Pricing__c') == CON_CPQ.YES_TITLE_CASE) {
                    isSpecialPricing = true;
                }
            }
            qliObj.put('Discount_Amount_W_O_Markup__c', totalDiscountAmountWOMarkup);
            quoteLineItems.set(bundleIndex, qliObj);
        }
        if (proposalPricingTool == CON_CPQ.Q2_Solutions) {
            Map<String, Quote_Requisites__c> qrByStudyNumberMap = new Map<String, Quote_Requisites__c>();
            String condition = 'Quote__c IN: quoteIdSet';
            List<Quote_Requisites__c> quoteRequisitesList = new SLT_QuoteRequisites().getQuoteRequisitesRecord(new Set<Id>{quoteId}, new Set<String>{CON_CPQ.ID, CON_CPQ.BID_HISTORY_STUDY_NUMBER}, condition);
            for (Quote_Requisites__c qr: quoteRequisitesList) {
                qrByStudyNumberMap.put(qr.Study_Number__c, qr);
            }
            if (quoteLineItems.size() >0) {
                for (Object qli: quoteLineItems) {
                    Map<String, Object> rli = (Map<String, Object>) qli;
                    if (qrByStudyNumberMap.containsKey((String) rli.get('Study_Number__c'))) {
                        rli.put('Quote_Requisites__c', qrByStudyNumberMap.get((String) rli.get('Study_Number__c')).Id);
                    }
                }
            }
        }
        fflib_SObjectUnitOfWork uow;
        if (!quoteLineItems.isEmpty()) {
            try {
                String condition = 'Quote__c = \'' + quoteId + '\' AND Pricing_Tool__c = \'' + proposalPricingTool + '\'' + ' AND Pathway__c = \'' + pathway + '\'';
                List<Quote_Line_Item__c> quoteLineItemsToDelete = new SLT_QuoteLineItem().selectedQuoteLineItemList(condition, new set<String>{CON_CPQ.ID});
                if (!quoteLineItemsToDelete.isEmpty()) {
                    uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            Quote_Line_Item__c.SObjectType
                        }
                    );
                    DAOH_IQ_Quote_Line_Item.ALLOW_QLI_DELETION = true;
                    uow.registerDeleted(quoteLineItemsToDelete);
                    uow.commitWork();
                }
                uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote_Line_Item__c.SObjectType, Quote__c.SObjectType
                    }
                );
                String jsonInput = JSON.serialize(quoteLineItems);
                UTL_CPQ_Services.insertQLIs(jsonInput, featureSettingsForQuoteLineItems);
                quote.Special_Pricing__c = isSpecialPricing;
                uow.registerDirty(quote);
                uow.commitWork(); 
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }  
        }
    }

    public static boolean checkCongaPermission() {
        boolean havePermission = false;
        CPQ_Settings__c res = [SELECT Id, Package_Namespace_Prefix__c FROM CPQ_Settings__c LIMIT 1];
        for (String nameSpacePrefix : res.Package_Namespace_Prefix__c.split(';')) {
            havePermission = userinfo.isCurrentUserLicensed(nameSpacePrefix);
            if (havePermission == false) {
                break;
            }
        }
        return havePermission;
    }
    public static Boolean checkEditPermissionForQuoteRequisiteField(String fieldApiName) {
        return mapOfDescribeFields.get(fieldApiName).getDescribe().isUpdateable();
    }
    public static String checkPathway(List<String > listOfCongaPathway) {
        if (!listOfCongaPathway.isEmpty() && CPQ_QuoteUtility.checkCongaPermission() && Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()) {
            return CON_CPQ.HASCONGAACCESS;
        }
        if(!listOfCongaPathway.isEmpty() && !Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()){
            return CON_CPQ.NEEDCONGAACCESS;
        } 
        return CON_CPQ.BLANK;
    }
    public static Boolean checkCongaCLMPermission() {
        boolean haveCLMPermission = false;
        CPQ_Settings__c res = [SELECT Id, Document_Package_Namespace_Prefix__c FROM CPQ_Settings__c LIMIT 1];
        if (res.Document_Package_Namespace_Prefix__c != null) {
            for (String nameSpacePrefix : res.Document_Package_Namespace_Prefix__c.split(';')) {
                haveCLMPermission = userinfo.isCurrentUserLicensed(nameSpacePrefix);
                if (haveCLMPermission == false) {
                    break;
                }
            }
        }
        return haveCLMPermission;
    }
}