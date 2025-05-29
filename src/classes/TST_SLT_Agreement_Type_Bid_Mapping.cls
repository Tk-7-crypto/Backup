/**
 * This test class is used to test all methods in opportunity trigger helper.
 * version : 1.0
 */
@isTest
private class TST_SLT_Agreement_Type_Bid_Mapping {

    /**
     * This method is used to test the get all Agreement_Type_Bid_Mapping method
     */
    static testMethod void testGetAgreementTypeBidMappings(){
        Set<String> fieldSet = new Set<String>{'Bid_No__c'};
        List<Agreement_Type_Bid_Mapping__mdt> agreementTypeBidMapping = new SLT_Agreement_Type_Bid_Mapping(false, false).getAgreementTypeBidMappings(fieldSet);
        agreementTypeBidMapping = new SLT_Agreement_Type_Bid_Mapping().getAgreementTypeBidMappings(fieldSet);
        
        //checking size 
        system.assert(agreementTypeBidMapping.size()>0);
    }
}