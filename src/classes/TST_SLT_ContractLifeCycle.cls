/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Account
 */
@isTest
private class TST_SLT_ContractLifeCycle {
    
    /**
     * This method used to get User Metric By Id
     */    
    @IsTest
    static void testSelectById() {
        Test.startTest();
            new SLT_ContractLifeCycle().selectByContractId(new Set<Id>());
        Test.stopTest();
    }
}