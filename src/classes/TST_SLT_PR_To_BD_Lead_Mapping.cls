/**
 * This test class is used to test all methods in SLT_Potential_Region_To_BD_Lead_Mapping 
 * version : 1.0
 */
@isTest
private class TST_SLT_PR_To_BD_Lead_Mapping {

    /**
     * This method is used to test the get all SLT_Potential_Region_To_BD_Lead_Mapping method
     */
    static testMethod void testGetPrToBdMappings(){
        Set<String> fieldSet = new Set<String>{'Potential_Region__c'};
        List<Potential_Region_To_BD_Lead_Mapping__mdt> prToBdMapping = new SLT_Potential_Region_To_BD_Lead_Mapping(false, false).getPotentialRegionToBDLeadMappings(fieldSet);
        prToBdMapping = new SLT_Potential_Region_To_BD_Lead_Mapping().getPotentialRegionToBDLeadMappings(fieldSet);
    }
}