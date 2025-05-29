/**
* This test class is used to test all methods in Quote/Proposal trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Quote {

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity Opp = UTL_TestData.createOpportunity(acc.Id);
        Opp.Name = 'Test Opportunity';
        insert Opp;
    }
    
    @isTest
    static void testQuoteInsert() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic', opp.Id, false);

        Test.startTest();
            insert quote; 
        Test.stopTest();
    }
}