/*
 * Version       : 1.0
 * Description   : This test class is used for Select Opportunity
 */
@isTest
private class TST_SLT_TerritoryLookup {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
   
    }
    
    /**
     * This method used to create map of Territory Lookup.
     */    
    @IsTest
    static void testTerritoryLookupMap() {
        Test.startTest();
        Map<String, Territory_lookup__mdt> territoryLookupMetadataMap = new SLT_TerritoryLookup().getTerritoryLookup();
        Test.stopTest();
        Boolean expected = true;
        Boolean actual = territoryLookupMetadataMap.size() > 0 ;
        System.assertEquals(expected, actual);
    }
}