@isTest
public class TST_SLT_Quote {
    
	@testSetup
    public static void dataSetup() {
        Account acc = UTL_TestData.createAccount(); 
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        Contract contract = new Contract();
        contract.Name = 'Test Contract1';
        contract.AccountId = acc.Id;
        insert contract;
        
        Quote quote = new Quote();
        quote.Name = 'Test Quote';
        quote.OpportunityId = opp.Id;
        quote.ContractId = contract.Id;
        insert quote;
    }
    
    @isTest
    private static void testGetQuotesById() {
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        
        Test.startTest();
            List<Quote> lstQuote = new SLT_Quote().getQuotesById(new Set<Id>{quote.Id}, fieldSet);
        Test.stopTest();

        System.assertEquals(1, lstQuote.size(), 'Quote list is empty when not expected.');
    }
    
    @isTest
    private static void testGetQuotesByCondition() {
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        
        Test.startTest();
            List<Quote> lstQuote = new SLT_Quote().getQuotesByCondition(fieldSet,'Id IN: IdSet', new Set<Id>{quote.Id});
        Test.stopTest();

        System.assertEquals(1, lstQuote.size(), 'Quote list is empty when not expected.');
    }
}