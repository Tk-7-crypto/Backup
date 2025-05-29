@isTest
private class TST_DAO_Quote {
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
        
        Bid_History__c bid = TST_CLM_TestDataFactory.createBidHistory(
            CON_CLM.CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID, Opp.Id, true);
            
    }
    
    @isTest
    static void testQuoteInsert() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic',opp.Id, false);

        Test.startTest();
            insert quote; 
        Test.stopTest();
    }
    
    @isTest
    static void testQuoteStatusUpdate() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic',opp.Id, true);
        quote.Status = CON_CLM.ON_HOLD;
        
        Test.startTest();
            update quote;
        Test.stopTest();
        
        Quote result = [SELECT Id, Status, Status_Change_Date__c FROM Quote LIMIT 1];
        System.assertEquals(Date.today(), result.Status_Change_Date__c, 'Date must have populated with current date but it is not.');
    }
    
    @isTest
    static void testQuotePlannedExecutionUpdate() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Bid_History__c bid = [SELECT Id FROM Bid_History__c LIMIT 1];
        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic', opp.Id, true);
        quote.Bid_History__c = bid.Id;
        quote.Planned_Execution_Date__c = Date.today();
        
        Test.startTest();
            update quote;
        Test.stopTest();
        
        System.assertEquals(Date.today(), quote.Planned_Execution_Date__c, 'Date must have populated with current date but it is not.');
    }
}