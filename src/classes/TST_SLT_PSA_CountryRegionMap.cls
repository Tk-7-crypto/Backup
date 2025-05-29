/*
 * Version       : 1.0
 * Description   : Test Class for SLT_PSA_CountryRegionMap
 */
@isTest
private class TST_SLT_PSA_CountryRegionMap {

   
    /**
     * This method used to test set up type of sobject
     * @return  Schema.SObjectType
     */

@IsTest
    static void testGetSObjectType () {
        //setupTestData();
        Test.startTest();
        PSA_Country_Region_Map__mdt cRMP = new PSA_Country_Region_Map__mdt();
        Schema.SObjectType ss= cRMP.getSObjectType();
        Test.stopTest();
        System.assertEquals('PSA_Country_Region_Map__mdt', String.valueOf(ss));
    }

    /**
     This method will return the complete country name/country code/region listing with all entries and fields
     */
     @IsTest
    static void testselectAllMappings() {
        //setupTestData();
        Test.startTest();
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        List <PSA_Country_Region_Map__mdt> crmpList = sltCRMP.selectAllMappings();
        Test.stopTest();
        System.assertNotEquals(0, crmpList.size());
    }


   /**
     * This method will return the complete country name/country code/region listing with all entries and fields
     */
     @IsTest
    static void testSelectMappingsByQIPCountry() {
        //setupTestData();
        Test.startTest();
        Set<String> qipCountrySet = new Set<String>{'Albania','Algeria'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByQIPCountry(qipCountrySet);
        Test.stopTest();
        System.assertEquals('ALB', codesMapReturned.get('Albania').Country_Code_3_Char__c);
    }

    /**
     * This method will return a region mapping for 2 digit country codes
     */
      @IsTest
    static void testSelectMappingsByCountryCode2NoFieldset() {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'AL','DZ'};
        Set<String> fieldset = new Set<String> {'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'QIP_Country__c', 'Region__c', 'SFDC_Country__c'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByCountryCode2(countryCodes);
        Test.stopTest();
        System.assertEquals('Albania', codesMapReturned.get('AL').QIP_Country__c);
    }

 /**
     * This method will return a region mapping for 2 digit country codes
     */
      @IsTest
    static void testSelectMappingsByCountryCode2() {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'AL','DZ'};
        Set<String> fieldset = new Set<String> {'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'QIP_Country__c', 'Region__c', 'SFDC_Country__c'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByCountryCode2(countryCodes,fieldset);
        Test.stopTest();
        System.assertEquals('Albania', codesMapReturned.get('AL').QIP_Country__c);
    }

     /**
     * This method will return a region mapping for 3 digit country codes
     */
      @IsTest
    static void testSelectMappingsByCountryCode3NoFieldset() {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'ALB','DZA'};
        Set<String> fieldset = new Set<String> {'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'QIP_Country__c', 'Region__c', 'SFDC_Country__c'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByCountryCode3(countryCodes);
        Test.stopTest();
        System.assertEquals('Albania', codesMapReturned.get('ALB').QIP_Country__c);
    }
 
    /**
     * This method will return a region mapping for 3 digit country codes
     */ 
    @IsTest
    static void testSelectMappingsByCountryCode3() {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'ALB','DZA'};
        Set<String> fieldset = new Set<String> {'Country_Code_2_Char__c', 'Country_Code_3_Char__c', 'QIP_Country__c', 'Region__c', 'SFDC_Country__c'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByCountryCode3(countryCodes,fieldset);
        Test.stopTest();
        System.assertEquals('Albania', codesMapReturned.get('ALB').QIP_Country__c);
    }
 
 
 
    /**
     * This method will return a region mapping for any mix of 2 or 3 digit country code
     */
       @IsTest
    static void testSelectMappingsByCountryCode () {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'AL','DZA'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Map<String,PSA_Country_Region_Map__mdt> codesMapReturned = sltCRMP.selectMappingsByCountryCode(countryCodes);
        Test.stopTest();
        System.debug('codesMapReturned'+codesMapReturned);
        //System.assertEquals('XXX', new list<String>(codesReturned)[0]);
    }

    /**
     * This method returns and country codes that are not found with a mapping
     */
     @IsTest
    static void testFindInvalidCountryCodes () {
        //setupTestData();
        Test.startTest();
        Set<String> countryCodes = new Set<String>{'XXX'};
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Set<String> codesReturned = sltCRMP.findInvalidCountryCodes(countryCodes);
        Test.stopTest();
        System.assertEquals('XXX', new list<String>(codesReturned)[0]);
    }



@IsTest
    static void testGetFields () {
        //setupTestData();
        Test.startTest();
        SLT_PSA_CountryRegionMap sltCRMP = new SLT_PSA_CountryRegionMap();
        Set<String> fieldsReturned = sltCRMP.getFields();
        Test.stopTest();
        System.assertEquals('Country_Code_2_Char__c', new list<String>(fieldsReturned)[0]);
    }


 

}