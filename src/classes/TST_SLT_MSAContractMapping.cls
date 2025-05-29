/*
 * Version       : 1.0
 * Description   : Test Class for SLT_MSAContractMapping
 */
@isTest
public class TST_SLT_MSAContractMapping {
    @isTest
    static void testSLTMSAContractMapping() {
        Test.startTest();
        new SLT_MSAContractMapping().fetchMSAContractMapping(new Set<String>{'Id'});
        Test.stopTest();
    }
}