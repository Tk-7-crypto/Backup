@isTest
private class TST_QUE_CLM_QuoteBoxFoldersJob {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        acc.Name = 'Test Account';
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Name = 'Test Opportunity';
        insert opp;

        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic', opp.Id, false);
        insert quote; 
        
    }

    @isTest 
    static void testQuoteBoxFoldersJob() {
        List<Quote> quoteList = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        Test.startTest();
            System.enqueueJob(new QUE_CLM_QuoteBoxFoldersJob(quoteList));
        Test.stopTest();
    }
}