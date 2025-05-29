/**
 * This test class is used to test all methods in SLT_OppStageToBidTypeMapping.
 * version : 1.0
 */
@isTest
private class TST_SLT_OppStageToBidTypeMapping {

    /**
     * This method is used to test the get all Opp_Stage_to_Bid_Type_Mapping__mdt method
     */
    static testMethod void testGetOppStageToBidTypeMappings(){
        Set<String> fieldSet = new Set<String>{'Opp_Stage__c'};
        List<Opp_Stage_to_Bid_Type_Mapping__mdt> oppStageToBidMapping = new SLT_OppStageToBidTypeMapping(false, false).getOppStageToBidTypeMappings(fieldSet);
        oppStageToBidMapping = new SLT_OppStageToBidTypeMapping().getOppStageToBidTypeMappings(fieldSet);
    }
}