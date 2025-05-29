@isTest
public class TST_DAOH_CLM_Quote {
    
    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Name = 'Test Opportunity';
        insert opp;
        Bid_History__c bid = TST_CLM_TestDataFactory.createBidHistory(
            CON_CLM.CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID, opp.Id, true);
        Quote quote = TST_CLM_TestDataFactory.createQuote('Generic',opp.Id, false);
        quote.Bid_History__c = bid.Id;
        insert quote;
    }

    @isTest
    private static void testQuoteStatusUpdate() {
        Quote oldQuote = [SELECT Id, Status, Status_Change_Date__c FROM Quote LIMIT 1];
        Quote newQuote = oldQuote.clone(true, false, false, false);
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        oldMap.put(oldQuote.Id, oldQuote);
        newQuote.Status = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;

        Test.startTest();
            DAOH_CLM_Quote.updateStatusChangeDateOnQuote(new List<Quote>{newQuote}, oldMap);
        Test.stopTest();

        System.assertEquals(System.today(), newQuote.Status_Change_Date__c, 'Date must have populated with current date but it is not.');
    }
    
    @isTest
    private static void testUpdateBidOnQuoteUpdate() {
        Quote oldQuote = [SELECT Id, Status, Status_Change_Date__c, Bid_History__c,Planned_Execution_Date__c FROM Quote LIMIT 1];
        Quote newQuote = oldQuote.clone(true, false, false, false);
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        oldMap.put(oldQuote.Id, oldQuote);
        newQuote.Planned_Execution_Date__c = Date.today();

        Test.startTest();
            DAOH_CLM_Quote.updateBidOnQuoteUpdate(new List<Quote>{newQuote}, oldMap);
        Test.stopTest();
		
        Bid_History__c bid = [SELECT Id,Bid_Due_Date__c FROM Bid_History__c WHERE Id =: oldQuote.Bid_History__c LIMIT 1];
        System.assertEquals(Date.today(), bid.Bid_Due_Date__c, 'Date must have populated with current date but it is not.');
    }

}