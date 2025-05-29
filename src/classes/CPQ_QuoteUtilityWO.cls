public without sharing class CPQ_QuoteUtilityWO {
    
    public static void deletePreviewDocuments(Id recordId) {
        Set<Id> idSet = new Set<Id>();
        if (recordId != null || recordId != CON_CPQ.BLANK) {
            for (ContentDocumentLink contentDocumentLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId AND ContentDocument.Title LIKE 'Draft_%' AND ContentDocument.Description = :CON_CPQ.DRAFT_PREFIX]) {
                idSet.add(contentDocumentLink.ContentDocumentId);
            }
            if (idSet.size() > 0) {
                delete [SELECT Id FROM ContentDocument WHERE Id IN :idSet];
            }
        }
    }

    @AuraEnabled
    public static String cancelActiveQuotes(Id opportunityId) {
        List<Quote__c> relatedQuotes = [SELECT Id, Approval_Stage__c FROM Quote__c WHERE Approval_Stage__c NOT IN (:CON_CPQ.CANCELLED_STATUS, :CON_CPQ.REJECTED_STATUS) AND Related_Opportunity__c =: opportunityId];
        if (!relatedQuotes.isEmpty()) {
            for (Quote__c quote : relatedQuotes) {
                quote.Approval_Stage__c = CON_CPQ.CANCELLED_STATUS;
            }
            try {
                UTL_ExecutionControl.disableTriggerCRUDIQQuote = true;
                UPDATE relatedQuotes;
                UTL_ExecutionControl.disableTriggerCRUDIQQuote = false;
                return 'Success';
            } catch (DmlException e) {
                return e.getMessage();
            }
        }
        return 'Success';
    }

    @AuraEnabled
    public static Boolean isQuoteExist(Id opportunityId) {
        List<Quote__c> relatedQuotes = [SELECT Id, Approval_Stage__c FROM Quote__c WHERE Approval_Stage__c NOT IN (:CON_CPQ.CANCELLED_STATUS, :CON_CPQ.REJECTED_STATUS) AND Related_Opportunity__c =: opportunityId];
        return !relatedQuotes.isEmpty();
    }

    @AuraEnabled
    public static Boolean isPrimaryQuoteAccepted(Id opportunityId) {
        List<Quote__c> relatedQuotes = [SELECT Id, Approval_Stage__c FROM Quote__c WHERE Primary__c = true AND Approval_Stage__c =: CON_CPQ.ACCEPTED AND Related_Opportunity__c =: opportunityId];
        return !relatedQuotes.isEmpty();
    }
    
    public static Map<Id, String> validateQuoteSyncWithOpportunities(Set<Id> opportunityIds) {
        Map<Id, String> results = new Map<Id, String>();
        Map<String, String> emeaCountryByCodeMap = new Map<String, String>();
        Map<String, String> currencyCodeMap = new Map<String, String>();
        Set<String> setOfIsoCode = new Set<String>();
        Map<Id, Boolean> haveEmeaCountryCodeByOpportunity = new Map<Id, Boolean>();
        Set<String> countryToExclude = new Set<String>{'Greece', 'Italy'};
        
        Map<Id, opportunity> eligibleOppIdWithRecordMapForValidationCheck = new Map<Id, opportunity>();
        String result = CON_CPQ.SUCCESS;
        CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
        List<opportunity> oppList = [SELECT Id, CurrencyIsoCode, CreatedDate, Owner.User_country__c, Account_Country__c, (SELECT Id, Approval_Stage__c, CurrencyIsoCode FROM IQVIA_Quotes__r WHERE Primary__c = true) FROM Opportunity WHERE Id IN :opportunityIds];
        for (opportunity opp : oppList) {
            if (opp.createdDate >= cpqSetting.EMEA_GO_Live__c) {
                eligibleOppIdWithRecordMapForValidationCheck.put(opp.id, opp);
            } else {
                result = 'Error:NonEMEAEligibleOpportunity';
                results.put(opp.Id, result);   
            }
        }

        for (IQVIA_Account_Country_Region_Mapping__mdt emeaCountry : [SELECT Country__c, Country_Name__c FROM IQVIA_Account_Country_Region_Mapping__mdt WHERE Region__c = :CON_CPQ.EMEA AND Country_Name__c NOT IN: countryToExclude]) {
            emeaCountryByCodeMap.put(emeaCountry.Country__c, emeaCountry.Country_Name__c);
        }
        // This change is a part of requirement of ESPSFDCQI-17263 because the user_country__c and  Country_Name__c are mismatched for Country United Kindom
        emeaCountryByCodeMap.put('GB','UK');
        
        Map<Id, Quote__c> primaryQuotesByOpportunity = new Map<Id, Quote__c>();
        for (Opportunity opp : eligibleOppIdWithRecordMapForValidationCheck.values()) {
            if (opp.IQVIA_Quotes__r.size() > 0) {
                if (opp.IQVIA_Quotes__r[0].CurrencyIsoCode != opp.CurrencyIsoCode) {
                    currencyCodeMap.put(opp.IQVIA_Quotes__r[0].Id, opp.IQVIA_Quotes__r[0].CurrencyIsoCode + CON_CPQ.SEPARATOR + opp.CurrencyIsoCode);
                    setOfIsoCode.add(opp.IQVIA_Quotes__r[0].CurrencyIsoCode);
                    setOfIsoCode.add(opp.CurrencyIsoCode);
                }
                primaryQuotesByOpportunity.put(opp.Id, opp.IQVIA_Quotes__r[0]); 
            }
            if (!emeaCountryByCodeMap.values().contains(opp.Owner.User_country__c) || !emeaCountryByCodeMap.keySet().contains(opp.Account_Country__c)){
                haveEmeaCountryCodeByOpportunity.put(opp.Id, true);
            }
        }
        
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        if (setOfIsoCode.size() > 0) {
            List<CurrencyType> currencyTypeList = [SELECT Id, conversionRate, isoCode FROM CurrencyType WHERE isoCode IN : setOfIsoCode];
            for (CurrencyType currencyType : currencyTypeList) {
                isoCodeTocurrencyTypeMap.put(currencyType.isoCode, currencyType);
            }
        }
        Map<Id, Set<String>> quoteKeysByOpportunity = new Map<Id, Set<String>>();
        for (Quote_Line_Item__c qli : [SELECT Id, Net_Price__c, Bundle_Product__r.SAP_Code__c, Country__c, Bundle_Product__r.Material_Type__c, Quote__c, Quote__r.Related_Opportunity__c FROM Quote_Line_Item__c WHERE Quote__r.Related_Opportunity__c IN :eligibleOppIdWithRecordMapForValidationCheck.keySet() AND Quote__r.Primary__c = true]) {
            Id opportunityId = qli.Quote__r.Related_Opportunity__c;
            if (!quoteKeysByOpportunity.containsKey(opportunityId)) {
                quoteKeysByOpportunity.put(opportunityId, new Set<String>());
            }
            Decimal listPrice = qli.Net_Price__c;
            if (currencyCodeMap.containsKey(qli.Quote__c) && isoCodeTocurrencyTypeMap.size() > 0) {
                String quoteOppConversionRate = currencyCodeMap.get(qli.Quote__c);
                List<String> codes = quoteOppConversionRate.split(CON_CPQ.SEPARATOR);
                Decimal conversionRate = isoCodeTocurrencyTypeMap.get(codes[1]).conversionRate / isoCodeTocurrencyTypeMap.get(codes[0]).conversionRate;
                listPrice *= conversionRate;
            }
            listPrice = listPrice.setScale(2, RoundingMode.HALF_UP);
            String uniqueKey = qli.Id + '_' + listPrice + '_' + qli.Bundle_Product__r.SAP_Code__c + '_' + qli.Country__c + '_' + qli.Bundle_Product__r.Material_Type__c;
            quoteKeysByOpportunity.get(opportunityId).add(uniqueKey);
        }
        
        Map<Id, Set<String>> opportunityKeysByOpportunity = new Map<Id, Set<String>>();
        Map<Id, Boolean> haveEmeaCountryByOpportunity = new Map<Id, Boolean>();
        Map<Id, Boolean> haveNonZPubProductsByOpportunity = new Map<Id, Boolean>();
                
        for (OpportunityLineItem oli : [SELECT Id, Agreement_Line_Item_Id__c, UnitPrice, SAP_Code__c, Delivery_Country__c, Product_Material_Type__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :eligibleOppIdWithRecordMapForValidationCheck.keySet()]) {
            Id opportunityId = oli.OpportunityId;
            if (!opportunityKeysByOpportunity.containsKey(opportunityId)) {
                opportunityKeysByOpportunity.put(opportunityId, new Set<String>());
                haveEmeaCountryByOpportunity.put(opportunityId, false);
                haveNonZPubProductsByOpportunity.put(opportunityId, false);
            }

            if (emeaCountryByCodeMap.values().contains(oli.Delivery_Country__c)) {
                haveEmeaCountryByOpportunity.put(opportunityId, true);
            }

            if (oli.Product_Material_Type__c != CON_CPQ.ZPUB) {
                haveNonZPubProductsByOpportunity.put(opportunityId, true);
            }

            Decimal listPrice = oli.UnitPrice;
            listPrice = listPrice.setScale(2, RoundingMode.HALF_UP);
            String uniqueKey = oli.Agreement_Line_Item_Id__c + '_' + listPrice + '_' + oli.SAP_Code__c + '_' + oli.Delivery_Country__c + '_' + oli.Product_Material_Type__c;
            opportunityKeysByOpportunity.get(opportunityId).add(uniqueKey);
        }
        
        for (Id opportunityId : eligibleOppIdWithRecordMapForValidationCheck.keySet()) {
            Quote__c primaryQuote = primaryQuotesByOpportunity.containsKey(opportunityId) ? primaryQuotesByOpportunity.get(opportunityId) : null;
            Boolean isPrimaryQuoteAccepted = primaryQuote != null && primaryQuote.Approval_Stage__c == CON_CPQ.ACCEPTED  ? true : false;
            
            Boolean haveEmeaCountry = haveEmeaCountryByOpportunity.containsKey(opportunityId) && haveEmeaCountryByOpportunity.get(opportunityId);
            Boolean haveNonZPubProducts = haveNonZPubProductsByOpportunity.containsKey(opportunityId) && haveNonZPubProductsByOpportunity.get(opportunityId);
            
            Set<String> quoteKeys = quoteKeysByOpportunity.containsKey(opportunityId) ? quoteKeysByOpportunity.get(opportunityId) : new Set<String>();
            Set<String> opportunityKeys = opportunityKeysByOpportunity.containsKey(opportunityId) ? opportunityKeysByOpportunity.get(opportunityId) : new Set<String>();
            
            Boolean lineItemsMatched = quoteKeys.equals(opportunityKeys);
            
            if (((haveEmeaCountryCodeByOpportunity.containsKey(opportunityId) && haveEmeaCountryCodeByOpportunity.get(opportunityId)) || haveNonZPubProducts || !haveEmeaCountry)) {
                result = 'Error:NonEMEAEligibleOpportunity';
            } else {
                if (primaryQuote == null) {
                    result = 'Error:QuoteDoesNotExist';
                } else if (!lineItemsMatched && !isPrimaryQuoteAccepted) {
                    result = 'Error:PrimaryQuoteNotAcceptedAndSyncMissMatched';
                } else if (!isPrimaryQuoteAccepted) {
                    result = 'Error:PrimaryQuoteNotAccepted';
                } else if (!lineItemsMatched) {
                    result = 'Error:SyncMissMatched';
                }
            }
            results.put(opportunityId, result);
        }
        return results;
    }
    
    @AuraEnabled
    public static string checkForRecordLock(Id recordId){
        try {
            if (Approval.isLocked(recordId)) {
                Approval.UnlockResult result = Approval.unlock(recordId);
                return result.isSuccess() ? 'Success' : result.getErrors()[0].getMessage();
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    public static Map<Id, String> iqviaQuoteCloneForMultipleOpportunities(Map<Id, Id> opportunityIdMap) {
        Map<Id, String> resultMap = new Map<Id, String>();
        Set<Id> noQuoteOppIdSet = new Set<Id>(opportunityIdMap.keySet());
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        Set<String> currencyIsoSet = new  Set<String>();										
        List<Quote__c> oldQuotes = [SELECT Id, Client_Contact__c, CurrencyIsoCode, Contracting_Country__c, End_Date__c, GBU__c, Iteration__c, Opportunity_Number__c, Opportunity_Owner__c, Pricing_Tools__c, Quote_Name__c, Related_Account__c, Related_Bid__c, Related_Opportunity__c, Related_Quote__c, Scenario__c, Start_Date__c, Description__c, Discount_Percent__c, Discount_Reason__c, Related_Opportunity__r.StageName FROM Quote__c WHERE Primary__c = true AND Related_Opportunity__c IN :opportunityIdMap.keySet()];
        Map<Id, Quote__c> oldQuoteMap = new Map<Id, Quote__c>();
        for (Quote__c quote : oldQuotes) {
            currencyIsoSet.add(quote.CurrencyIsoCode);
            oldQuoteMap.put(quote.Related_Opportunity__c, quote);
            noQuoteOppIdSet.remove(quote.Related_Opportunity__c);
        }
        
        Map<Id, List<OpportunityLineItem>> oldOliByOppId = new Map<Id, List<OpportunityLineItem>>();
        if (noQuoteOppIdSet.size() > 0) {
            List<OpportunityLineItem> oldOppLineItems = [SELECT Id, Product2Id, OpportunityId, Delivery_Country__c, Sale_Type__c, Revenue_Type__c, Revenue_End_Date__c, Revenue_Start_Date__c, Discount_Reason__c, Surcharge_Text__c, List_Price__c, UnitPrice, Description, Discount_Amount__c FROM OpportunityLineItem WHERE OpportunityId IN: noQuoteOppIdSet];
            for (OpportunityLineItem oli: oldOppLineItems) {
                if (!oldOliByOppId.containsKey(oli.OpportunityId)) {
                    oldOliByOppId.put(oli.OpportunityId, new List<OpportunityLineItem>());
                }
                oldOliByOppId.get(oli.OpportunityId).add(oli);
            }
        }
        
        Set<String> opportunityFieldSet = new Set<String>();
        List<CPQ_Mapping_Field_Set__mdt> mappingsPricingToolList = [SELECT Opportunity_Field__c, Quote_Field__c, Pricing_Tool__c FROM CPQ_Mapping_Field_Set__mdt WHERE Sobject_Name__c = 'Quote__c' AND Feature_Selection__c = 'Quote Creation' AND Pricing_Tool__c LIKE '%EMEA%'];
        for (CPQ_Mapping_Field_Set__mdt mapFields : mappingsPricingToolList) {
            opportunityFieldSet.add(mapFields.Opportunity_Field__c);
        }
        Set<Id> newOpportunityIds = new Set<Id>(opportunityIdMap.values());
        String query = 'SELECT ' + String.join(new List<String>(opportunityFieldSet), ',') + ' FROM Opportunity WHERE Id IN :newOpportunityIds';
        List<SObject> newOpportunities = Database.query(query);
        
        Map<Id, SObject> newOpportunityMap = new Map<Id, SObject>();
        for (SObject opp : newOpportunities) {
            newOpportunityMap.put((Id)opp.get('Id'), opp);
        }
        
        List<Quote_Line_Item__c> oldLineItems = [SELECT Id, CurrencyIsoCode, Base_Price_USD__c, BasePrice__c, Bundle_Product__c, Change_From_Previous__c, Cost_Price__c, Cost_Price_USD__c, Country__c, Description__c, Discount_Amount__c, Discount_Amount_Per_Unit__c, Discount_Amount_USD__c, Discount_Percent__c, End_Date__c, Extended_Price__c, Extended_Price_USD__c, Margin__c, Margin_Percent__c, Margin_USD__c, Name, Net_Price__c, Net_Price_Per_Unit__c, Net_Price_USD__c, Option_Group__c, Option_Product__c, Pathway__c, Pricing_Tool__c, Proposal_Line_Item__c, Quantity__c, Quote__c, Quote_Requisites__c, Special_Pricing__c, Start_Date__c, Study_Number__c, Unit_of_Measure__c, Revenue_Type__c, Sales_Type__c, Include_In_Summary__c, Installment_Period__c, Number_Of_Installment__c FROM Quote_Line_Item__c WHERE Quote__c IN :oldQuoteMap.values()];
        Map<Id, List<Quote_Line_Item__c>> oldLineItemMap = new Map<Id, List<Quote_Line_Item__c>>();
        for (Quote_Line_Item__c lineItem : oldLineItems) {
            if (!oldLineItemMap.containsKey(lineItem.Quote__c)) {
                oldLineItemMap.put(lineItem.Quote__c, new List<Quote_Line_Item__c>());
            }
            oldLineItemMap.get(lineItem.Quote__c).add(lineItem);
        }
        List<Quote__c> quoteToInsert = new List<Quote__c>();
        Map<Id, Id> oldOppByNewOppMap = new Map<Id, Id>();
        for (Id oldOpportunityId : opportunityIdMap.keySet()) {
            Id newOpportunityId = opportunityIdMap.get(oldOpportunityId);
            oldOppByNewOppMap.put(newOpportunityId, oldOpportunityId);
            Quote__c clonedQuote;
            Quote__c oldQuote;
            if (!oldQuoteMap.containsKey(oldOpportunityId)) {
                clonedQuote = new Quote__c();
                clonedQuote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
                clonedQuote.Pricing_Tools__c = CON_CPQ.EMEA;
            } else {
                oldQuote = oldQuoteMap.get(oldOpportunityId);
                clonedQuote = oldQuote.clone();
            }
            
            SObject newOpportunity = newOpportunityMap.get(newOpportunityId);
            
            for (CPQ_Mapping_Field_Set__mdt mapFields : mappingsPricingToolList) {
                if (mapFields.Opportunity_Field__c.contains('.')) {
                    List<String> splitFields = mapFields.Opportunity_Field__c.split('\\.');
                    SObject nestedRecord = newOpportunity;
                    for (Integer i = 0; i < splitFields.size() - 1; i++) {
                        nestedRecord = nestedRecord.getSObject(splitFields[i]);
                    }
                    clonedQuote.put(mapFields.Quote_Field__c, nestedRecord.get(splitFields[splitFields.size() - 1]));
                } else {
                    clonedQuote.put(mapFields.Quote_Field__c, newOpportunity.get(mapFields.Opportunity_Field__c));
                }                
            }
            clonedQuote.Related_Opportunity__c = newOpportunityId;
            clonedQuote.Primary__c = true;
            clonedQuote.Related_Quote__c = oldQuote != null ? oldQuote.Id : null;
            currencyIsoSet.add(clonedQuote.CurrencyIsoCode);
            quoteToInsert.add(clonedQuote);
            resultMap.put(newOpportunityId, Null);
        }
        if (!quoteToInsert.isEmpty()) {
            try {
                if (currencyIsoSet.size() > 1) {
                    for (CurrencyType currencyType : [SELECT Id, ConversionRate, IsoCode FROM CurrencyType WHERE IsoCode IN : currencyIsoSet]) {
                        isoCodeTocurrencyTypeMap.put(currencyType.IsoCode, currencyType);
                    }
                }
                insert quoteToInsert;
                List<Quote_Line_Item__c> clonedLineItems = new List<Quote_Line_Item__c>();
                for (Quote__c quote : quoteToInsert) {
                    if (quote.Related_Quote__c != null) {
                        if (oldLineItemMap.containsKey(quote.Related_Quote__c)) {
                            for (Quote_Line_Item__c oldLineItem : oldLineItemMap.get(quote.Related_Quote__c)) {
                                Quote_Line_Item__c clonedLineItem = oldLineItem.clone();
                                clonedLineItem.Quote__c = quote.Id;
                                if (clonedLineItem.CurrencyIsoCode != quote.CurrencyIsoCode && isoCodeTocurrencyTypeMap.size() > 0 && isoCodeTocurrencyTypeMap.containsKey(clonedLineItem.CurrencyIsoCode) && isoCodeTocurrencyTypeMap.containsKey(quote.CurrencyIsoCode)) {
                                    clonedLineItem.BasePrice__c = clonedLineItem.BasePrice__c != null ? clonedLineItem.BasePrice__c * (isoCodeTocurrencyTypeMap.get(quote.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(clonedLineItem.CurrencyIsoCode).ConversionRate) : 0;
                                    clonedLineItem.Discount_Amount__c = clonedLineItem.Discount_Amount__c != null ? clonedLineItem.Discount_Amount__c * (isoCodeTocurrencyTypeMap.get(quote.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(clonedLineItem.CurrencyIsoCode).ConversionRate) : 0;
                                    clonedLineItem.Cost_Price__c = clonedLineItem.Cost_Price__c != null ? clonedLineItem.Cost_Price__c * (isoCodeTocurrencyTypeMap.get(quote.CurrencyIsoCode).ConversionRate / isoCodeTocurrencyTypeMap.get(clonedLineItem.CurrencyIsoCode).ConversionRate) : 0;
                                    clonedLineItem.CurrencyIsoCode = quote.CurrencyIsoCode;
                                }
                                clonedLineItems.add(clonedLineItem);
                            }
                        }
                    } else {
                        if (oldOliByOppId.containsKey(oldOppByNewOppMap.get(quote.Related_Opportunity__c))) {
                            for (OpportunityLineItem oldOli : oldOliByOppId.get(oldOppByNewOppMap.get(quote.Related_Opportunity__c))) {
                                Quote_Line_Item__c clonedLineItem = createQLIFromOLI(oldOli);
                                clonedLineItem.Quote__c = quote.Id;
                                clonedLineItems.add(clonedLineItem);
                            }
                        }
                    }
                    if (resultMap.containsKey(quote.Related_Opportunity__c)) {
                        resultMap.put(quote.Related_Opportunity__c, CON_CPQ.SUCCESS); 
                    }
                }
                if (!clonedLineItems.isEmpty()) {
                    insert clonedLineItems;
                }
            } catch (DmlException e) {
                for (Id newOpportunityId : opportunityIdMap.keySet()) {
                    resultMap.put(newOpportunityId, 'Error: ' + e.getMessage());
                }
            }
        }
        return resultMap;
    }

    public static Quote_Line_Item__c createQLIFromOLI(OpportunityLineItem oli) {
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Description__c = oli.Description;
        qli.Start_Date__c = oli.Revenue_Start_Date__c;
        qli.End_Date__c = oli.Revenue_End_Date__c;
        qli.Surcharge_Reason__c = oli.Surcharge_Text__c;
        qli.Discount_Reason__c = oli.Discount_Reason__c;
        qli.Country__c = oli.Delivery_Country__c;
        qli.Sales_Type__c = oli.Sale_Type__c;
        qli.Revenue_Type__c = oli.Revenue_Type__c;
        qli.BasePrice__c = oli.List_Price__c;
        qli.Quantity__c = 1;
        qli.Bundle_Product__c = oli.Product2Id;
        qli.Discount_Amount__c = oli.Discount_Amount__c;
        return qli; 
    }
    
    public class QuoteLineItemWrapper {
        @auraEnabled
        public String recordId;
        @auraEnabled
        public String name;
        @auraEnabled
        public String bundleProduct;
        @auraEnabled
        public Decimal basePrice;
        @auraEnabled
        public Decimal netPrice;
        @auraEnabled
        public String country;
        @auraEnabled
        public Date startDate;
        @auraEnabled
        public String salesType;
        @auraEnabled
        public String revenueType;
        @auraEnabled
        public String bundleProductHierarchyLevel;
        @auraEnabled
        public String bundleProductName;
    }
    
    public static List<QuoteLineItemWrapper> getQuoteLineItemDetails(Set<Id> quoteIds) {
        List<QuoteLineItemWrapper> quoteLineItemWrapperList = new List<QuoteLineItemWrapper>();
        List<Quote_Line_Item__c> quoteLineItems = [SELECT Id, Name, Bundle_Product__c, BasePrice__c, Net_Price__c, Country__c, Start_Date__c , Bundle_Product__r.Hierarchy_Level__c, Bundle_Product__r.Name, Sales_Type__c, Revenue_Type__c FROM Quote_Line_Item__c WHERE Quote__c IN :quoteIds];
        for (Quote_Line_Item__c lineItem : quoteLineItems) {
            QuoteLineItemWrapper wrapper = new QuoteLineItemWrapper();
            wrapper.recordId = lineItem.Id;
            wrapper.name = lineItem.name;
            wrapper.bundleProduct = lineItem.Bundle_Product__c;
            wrapper.basePrice = lineItem.BasePrice__c;
            wrapper.netPrice = lineItem.Net_Price__c;
            wrapper.country = lineItem.Country__c;
            wrapper.startDate = lineItem.Start_Date__c;
            wrapper.salesType = lineItem.Sales_Type__c;
            wrapper.RevenueType = lineItem.Revenue_Type__c;
            wrapper.bundleProductHierarchyLevel = lineItem.Bundle_Product__r.Hierarchy_Level__c;
            wrapper.bundleProductName = lineItem.Bundle_Product__r.Name;
            quoteLineItemWrapperList.add(wrapper);    
        }
        return quoteLineItemWrapperList;
    }
}