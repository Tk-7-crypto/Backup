/*
 * Version       : 1.0
 * Description   : test class for MulesoftOpportunitySync selector
 */
@isTest
private class TST_SLT_MulesoftOpportunitySync {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
    }
    
    /**
    * test method to test selectById
    */  
    static testmethod void testselectById() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
            List<Mulesoft_Opportunity_Sync__c> oppSyncList = new SLT_MulesoftOpportunitySync().selectById(new Set<Id>{opp.Id});
            oppSyncList = new SLT_MulesoftOpportunitySync().selectByOppIds(new Set<Id>{opp.Id});
        Test.stopTest();
        
    }
}