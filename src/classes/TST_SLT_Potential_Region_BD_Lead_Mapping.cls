/**
* This test class is used to test all methods in SLT_Potential_Region_BD_Lead_Mapping.
* version : 1.0
*/
@isTest
private class TST_SLT_Potential_Region_BD_Lead_Mapping {
     /**
     * This test method used to cover basic methods
     */
     static testMethod void testGetPotentialRegionToBDLeadMappings(){
        SLT_Potential_Region_To_BD_Lead_Mapping sltPotentialRegion = new SLT_Potential_Region_To_BD_Lead_Mapping();
        Test.startTest();
        List<Potential_Region_To_BD_Lead_Mapping__mdt> potentialRegionList = 
            sltPotentialRegion.getPotentialRegionToBDLeadMappings(new Set<String> {'Id'});
        Test.stopTest();
    }
}