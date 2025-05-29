/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Currency_Exchange_Rates__c
 */
public without sharing class SLT_GridRateCurrency extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Currency_Exchange_Rates__c.Id,
            Currency_Exchange_Rates__c.Conversion_rate__c,
            Currency_Exchange_Rates__c.Iso_Code__c,
            Currency_Exchange_Rates__c.IsActive__c,
            Currency_Exchange_Rates__c.Effective_Date__c,
            Currency_Exchange_Rates__c.Expiration_Date__c
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Currency_Exchange_Rates__c.sObjectType;
    }

     //Method to get currency conversion rate from PC_Grid RateCurrency based on isoCode
     public Map<String,Currency_Exchange_Rates__c> getSelectedPCGridCurrencyTypeByIsoCode(Set<String> setOfIsoCode, Date conversionDate){
        Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap = new Map<String, Currency_Exchange_Rates__c>();
        if (setOfIsoCode.contains(CON_CPQ.USD)) {
            setOfIsoCode.remove(CON_CPQ.USD);
        }
        List<Currency_Exchange_Rates__c> currencyRateList = SLT_PC_GridRateCurrency.records([SELECT Id, Conversion_rate__c, Iso_Code__c, Effective_Date__c FROM Currency_Exchange_Rates__c WHERE Iso_Code__c IN : setOfIsoCode AND IsActive__c = 1 AND (Effective_Date__c <=:conversionDate  AND (Expiration_Date__c = null OR Expiration_Date__c >=: conversionDate)) ORDER BY Effective_Date__c DESC]);
        for (Currency_Exchange_Rates__c currencyType : currencyRateList) { 
            if (!isoCodeTocurrencyTypeMap.containsKey(currencyType.Iso_Code__c)) {
				isoCodeTocurrencyTypeMap.put(currencyType.Iso_Code__c, currencyType);
            }
        }
        isoCodeTocurrencyTypeMap.put(CON_CPQ.USD, new Currency_Exchange_Rates__c(Conversion_rate__c = 1, Iso_Code__c = CON_CPQ.USD));
        return isoCodeTocurrencyTypeMap;
    }
    
    public Map<String, Currency_Exchange_Rates__c> getSelectedPCGridCurrencyTypeByIsoCodeBulk(Set<String> setOfIsoCode, Set<Date> conversionDateSet){
        Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap = new Map<String, Currency_Exchange_Rates__c>();
        if (setOfIsoCode.contains(CON_CPQ.USD)) {
            setOfIsoCode.remove(CON_CPQ.USD);
        }
        Date maxConversionDate;
        Date minConversionDate;
        for (Date conversionDate : conversionDateSet) {
            if (maxConversionDate == null || maxConversionDate <= conversionDate) {
                maxConversionDate = conversionDate;
            }
            if (minConversionDate == null || minConversionDate >= conversionDate) {
                minConversionDate = conversionDate;
            }      
        }
        List<Currency_Exchange_Rates__c> currencyRateList = SLT_PC_GridRateCurrency.records([SELECT Id, Conversion_rate__c, Iso_Code__c, Effective_Date__c, Expiration_Date__c FROM Currency_Exchange_Rates__c WHERE Iso_Code__c IN :setOfIsoCode AND IsActive__c = 1 AND (Effective_Date__c <= :minConversionDate AND (Expiration_Date__c = null OR Expiration_Date__c >= :maxConversionDate)) ORDER BY Effective_Date__c DESC]);
        for (Currency_Exchange_Rates__c pcGridRate : currencyRateList) {
            for (Date conversionDate : conversionDateSet) {
                if (!isoCodeTocurrencyTypeMap.containsKey(pcGridRate.Iso_Code__c + '&&&' + conversionDate) && (pcGridRate.Effective_Date__c <= conversionDate && (pcGridRate.Expiration_Date__c == null ||  pcGridRate.Expiration_Date__c >= conversionDate))) {
                    isoCodeTocurrencyTypeMap.put(pcGridRate.Iso_Code__c + '&&&' + conversionDate, pcGridRate);
                }
            }    
        }
        for (Date conversionDate : conversionDateSet) {
            isoCodeTocurrencyTypeMap.put(CON_CPQ.USD + '&&&' + conversionDate, new Currency_Exchange_Rates__c(Conversion_rate__c = 1, Iso_Code__c = CON_CPQ.USD));
        }
        return isoCodeTocurrencyTypeMap;
    }
}