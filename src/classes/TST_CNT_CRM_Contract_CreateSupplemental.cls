@isTest
private class TST_CNT_CRM_Contract_CreateSupplemental {
    
    @testSetup
    static void setupData() {
        Account acc = UTL_TestData.createAccount();
    	insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Contract ctr = UTL_TestData.createContract(opp, 'Generic_Contract');
        ctr.Parent_Contract_Number__c = 123;
        ctr.Ultimate_Parent_Contract_Number__c = 345;
        insert ctr;
        
    }
    
    @isTest
    static void test1() {
        Contract ctr = [SELECT Id FROM Contract LIMIT 1];
        Test.startTest();
            CNT_CRM_Contract_CreateSupplemental.getContractFromId(ctr.Id);
            CNT_CRM_Contract_CreateSupplemental.getContractFieldSet();
            CNT_CRM_Contract_CreateSupplemental.fetchRecordTypes();
        Test.stopTest();
        
    }

}