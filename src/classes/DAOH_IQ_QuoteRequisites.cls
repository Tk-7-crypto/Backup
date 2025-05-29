public class DAOH_IQ_QuoteRequisites {
    
    public static boolean isSkipUpdateLanguagesOnQuote = false;
    public static boolean skipPopulateFieldsOnQuoteRequisite = false;
    public static void populateFields(List<Quote_Requisites__c> requisitesList, Map<Id, Quote_Requisites__c> oldMap) {
        if (skipPopulateFieldsOnQuoteRequisite) {
            return;
        }
        Set<String> countryNamesSet = new Set<String>();
        Map<Id, String> countryByQuoteRequisit = new Map<Id, String>();
        for (Quote_Requisites__c req : requisitesList) {
            if ((oldMap == null && (req.Country__c != null || req.Site_Count__c != null)) || (oldMap != null && (oldMap.get(req.Id).Country__c != req.Country__c
                || oldMap.get(req.Id).Site_Count__c != req.Site_Count__c))) {
                countryByQuoteRequisit.put(req.Id, req.Country__c);
                countryNamesSet.add(req.Country__c);
            }
        }
        if (countryNamesSet.size() > 0) {
            List<CPQ_Country_Master_Data__c> countryDataList = new SLT_CPQCountryMasterData().getCountryMasterDataByNames(countryNamesSet, new Set<String>{CON_CPQ.COUNTRY, CON_CPQ.LANGUAGE, CON_CPQ.SITE_ADOPTION_PROBABILITY});
            Map<String, CPQ_Country_Master_Data__c> countryDataMap = new Map<String, CPQ_Country_Master_Data__c>();
            for (CPQ_Country_Master_Data__c country : countryDataList) {
                countryDataMap.put(country.Country__c, country);
            }
            for (Quote_Requisites__c req : requisitesList) {
                if (countryByQuoteRequisit.containsKey(req.Id)) {
                    if (countryDataMap.containsKey(req.Country__c) && countryDataMap.get(req.Country__c) != null) {
                        if (req.Site_Count__c != null && countryDataMap.get(req.Country__c).Site_Adoption_Probability__c != null) {
                            req.Site_Count_Adjusted__c = (req.Site_Count__c * (countryDataMap.get(req.Country__c).Site_Adoption_Probability__c / 100)).round(System.RoundingMode.DOWN);
                        } else {
                            req.Site_Count_Adjusted__c = 0;
                        }
                        String languages = countryDataMap.get(req.Country__c).Language__c;
                        req.Document_Language__c = String.isBlank(languages) ? 0 : languages.split(';').size();
                    }
                }
            }
        }
    }
    
    public static void calculateAndUpdateTotalSiteCount(List<Quote_Requisites__c> requisitesList, Map<Id, Quote_Requisites__c> oldMap) {
        Map<String, List<Decimal>> quoteKpiMap = new Map<String, List<Decimal>>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<String> countryNamesSet = new Set<String>();
        Map<Id, Quote__c> quotesToUpdateMap = new Map<Id, Quote__c>();
        for (Quote_Requisites__c req : requisitesList) {
            if ((oldMap == null && req.Document_Language__c != null) || (oldMap != null && oldMap.containsKey(req.Id) && oldMap.get(req.Id).Document_Language__c != req.Document_Language__c)) {
                quoteIdSet.add(req.Quote__c);
            }
            if (oldMap == null && req.Country__c != null) {
                countryNamesSet.add(req.Country__c);
            }
        }
        if (quoteIdSet.size() > 0) {
            String condition = 'Quote__c IN: quoteIdSet AND Type__c = \'' + CON_CPQ.COUNTRY_INPUT + '\'';
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteIdSet, CON_CPQ.QUOTE_REQUISITES_FIELD_SET, condition);
            Map<Id, Decimal> documentMap = new Map<Id, Decimal>();
            for (Quote_Requisites__c qr : quoteReqList) {
                Decimal documentNumber = qr.Document_Number__c == null ? 0.0 : qr.Document_Number__c;
                if (!documentMap.containsKey(qr.Quote__c)) {
                    documentMap.put(qr.Quote__c, documentNumber);
                } else {
                    documentMap.put(qr.Quote__c, documentMap.get(qr.Quote__c) + documentNumber);
                }
                if (!quotesToUpdateMap.containsKey(qr.Quote__c)) {
                    quotesToUpdateMap.put(qr.Quote__c, Qr.Quote__r);
                }
            }
            for (Id quoteId : quoteIdSet) {
                quotesToUpdateMap.get(quoteId).Total_ICF_Documents__c = (quotesToUpdateMap.get(quoteId).ICFs__c != null ? documentMap.get(quoteId) * quotesToUpdateMap.get(quoteId).ICFs__c : documentMap.get(quoteId)).round(System.RoundingMode.HALF_UP);
            }
            if (countryNamesSet.size() > 0 && !isSkipUpdateLanguagesOnQuote) {
                updateLanguagesOnQuote(requisitesList, quotesToUpdateMap, countryNamesSet);
            }
            if (quotesToUpdateMap.values().size() > 0) {
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote__c.SobjectType
                    }
                );
                uowProposal.registerDirty(quotesToUpdateMap.values());
                uowProposal.commitWork();
            }
        }
    }  

    public static void updateLanguagesOnQuote(List<Quote_Requisites__c> requisitesList, Map<Id, Quote__c> quotesToUpdateMap, Set<String> countryNamesSet) {
        if (countryNamesSet.size() > 0) {
            List<CPQ_Country_Master_Data__c> countryDataList = new SLT_CPQCountryMasterData().getCountryMasterDataByNames(
                countryNamesSet, 
                new Set<String>{CON_CPQ.COUNTRY, CON_CPQ.LANGUAGE, CON_CPQ.SITE_ADOPTION_PROBABILITY}
            );
            Map<String, CPQ_Country_Master_Data__c> countryDataMap = new Map<String, CPQ_Country_Master_Data__c>();
            for (CPQ_Country_Master_Data__c country : countryDataList) {
                countryDataMap.put(country.Country__c, country);
            }
            for (Quote_Requisites__c req : requisitesList) {
                if (req.Country__c != null && countryDataMap.containsKey(req.Country__c) && countryDataMap.get(req.Country__c) != null && countryDataMap.get(req.Country__c).Language__c != null) {
                    String languages = countryDataMap.get(req.Country__c).Language__c;
                    Set<String> languageSet = new Set<String>(languages.split(';'));
                    List<String> languageList = new List<String>(languageSet);
                    Integer languageCount = languageList.size();
                    if (!quotesToUpdateMap.containsKey(req.Quote__c)) {
                        Quote__c quote = new Quote__c(Id = req.Quote__c);
                        quote.Selected_Languages__c = String.join(languageList, ';');
                        quote.Languages__c = languageCount;
                        quote.Adjusted_Languages__c = languages.contains('English(US)') ? languageCount - 1 : languageCount;
                        quotesToUpdateMap.put(req.Quote__c, quote);
                    } else {
                        Quote__c quote = quotesToUpdateMap.get(req.Quote__c);
                        if (quote.Selected_Languages__c == null) {
                            quote.Selected_Languages__c = String.join(languageList, ';');
                            quote.Languages__c = languageCount;
                            quote.Adjusted_Languages__c = languages.contains('English(US)') ? languageCount - 1 : languageCount;
                            quotesToUpdateMap.put(req.Quote__c, quote);
                        } else {
                            Set<String> existingLanguagesSet = new Set<String>(quote.Selected_Languages__c.split(';'));
                            existingLanguagesSet.addAll(languageSet);
                            List<String> existingLanguagesList = new List<String>(existingLanguagesSet);
                            languageCount = existingLanguagesList.size();
                            quote.Selected_Languages__c = String.join(existingLanguagesList, ';');
                            quote.Languages__c = languageCount;
                            quote.Adjusted_Languages__c = existingLanguagesSet.contains('English(US)') ? languageCount - 1 : languageCount;
                            quotesToUpdateMap.put(req.Quote__c, quote);
                        }
                    }
                }
            }
        }    
    }
    
    public static Map<String, List<Quote_Requisites__c>> getQuoteRequisitesByType(List<Quote_Requisites__c> records) {
        Map<String, List<Quote_Requisites__c>> quoteRequistesByTypeMap = new Map<String, List<Quote_Requisites__c>>();
        for (Quote_Requisites__c qrst : records) {
            if (qrst.Type__c != null) {
                List<Quote_Requisites__c> quoteRequisteList;
                if (!quoteRequistesByTypeMap.containsKey(qrst.Type__c)) {
                    quoteRequistesByTypeMap.put(qrst.Type__c, new List<Quote_Requisites__c>());
                }
                quoteRequisteList = quoteRequistesByTypeMap.get(qrst.Type__c);
                quoteRequisteList.add(qrst);
                quoteRequistesByTypeMap.put(qrst.Type__c, quoteRequisteList);
            }
        }
        return quoteRequistesByTypeMap;
    }
}