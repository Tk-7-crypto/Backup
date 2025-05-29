/*
 * Version       : 1.0
 * Description   : This test class is used for SLT_IQVIAAccountCountryRegionMapping.
 */
@isTest
private class TST_SLT_IQVIAAccountCountryRegionMapping {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
   
    }
    
    /**
     * This method used to create map of IQVIA Account Country Region Mapping Metadata.
     */    
    @IsTest
    static void testAccountCountryToRegionMetadataMap() {
        Test.startTest();
        Map<String, IQVIA_Account_Country_Region_Mapping__mdt> accountCountryRegionMetadataMap = new SLT_IQVIAAccountCountryRegionMapping().getAccountCountryToRegionMetadataMap();
        Test.stopTest();
        Boolean expected = true;
        Boolean actual = accountCountryRegionMetadataMap.size() > 0 ;
        System.assertEquals(expected, actual);
    }
}