/*
 * Version       : 1.0
 * Description   : Test Class for SLT_CurrencyType
 */
@isTest
private class TST_SLT_GridRateCurrency {
	
	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
    }
   
    @IsTest
    static void testGetSelectedPCGridCurrencyTypeByIsoCode() {

        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        insert currencyRate;

        Map<String,Currency_Exchange_Rates__c> currencyTypeMap = new Map<String,Currency_Exchange_Rates__c>();
        Test.startTest();
            currencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{CON_CPQ.CHF},Date.Today());
        Test.stopTest();
        System.assertEquals(true, currencyTypeMap.size() > 0, 'currency type is fetched');
    }
    @IsTest
    static void testGetSelectedPCGridCurrencyTypeByIsoCodeBulk() {
        
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        insert currencyRate;

        Map<String,Currency_Exchange_Rates__c> currencyTypeMap = new Map<String,Currency_Exchange_Rates__c>();
        Test.startTest();
        currencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCodeBulk(new Set<String>{CON_CPQ.CHF},new Set<Date>{Date.Today()});
        Test.stopTest();
        System.assertEquals(true, currencyTypeMap.size() > 0, 'currency type is fetched');
    }
}