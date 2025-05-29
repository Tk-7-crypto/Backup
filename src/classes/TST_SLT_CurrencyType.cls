/*
 * Version       : 1.0
 * Description   : Test Class for SLT_CurrencyType
 */
@isTest
private class TST_SLT_CurrencyType {			  
	
	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
       
    }
    
    /**
	 * This method used to get List<CurrencyType> by name
	 */    
    @IsTest
    static void testGetCurrencyTypeName() {
        Map<id,CurrencyType> currencytype = new Map<id,CurrencyType>();
        Test.startTest();
        currencytype = new SLT_CurrencyType().selectAllCurrencyType();
        Test.stopTest();
        System.assertEquals(true, currencytype.size() > 0);
    }
	
    /**
	 * This method used to get List<CurrencyType> by name
	 */    
    @IsTest
    static void testGetAllCurrencyTypeByIsoCode() {
        List<CurrencyType> currencytype = new List<CurrencyType>();
        Test.startTest();
        currencytype = new SLT_CurrencyType().getAllCurrencyTypeByIsoCode(new Set<String>{'USD'});
        Test.stopTest();
        System.assertEquals(true, currencytype.size() > 0, 'currency type is fetched');
    }
    
    @IsTest
    static void testGetSelectedCurrencyTypeByIsoCode() {
        Map<String,CurrencyType> currencyTypeMap = new Map<String,CurrencyType>();
        Test.startTest();
            currencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{CON_CPQ.USD});
        Test.stopTest();
        System.assertEquals(true, currencyTypeMap.size() > 0, 'currency type is fetched');
    }
    
    @IsTest
    static void testGetAllCurrencyTypeByIsoCodeMap() {
        Map<String,CurrencyType> currencyTypeMap = new Map<String,CurrencyType>();
        Test.startTest();
            currencyTypeMap = new SLT_CurrencyType().getAllCurrencyTypeByIsoCode();
        Test.stopTest();
        System.assertEquals(true, currencyTypeMap.size() > 0, 'currency type is fetched');
    }
    
}