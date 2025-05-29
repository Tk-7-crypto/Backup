@isTest 
private class TST_SLT_IQVIA_Quote {

    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
		
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = opp.Id; 
        quote.Document_Type__c = CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS;
        quote.License_Type__c = 'Per Study';
        quote.Related_Account__c = acc.Id;
        insert quote;
    }
    
    @isTest 
    static void testGetQuoteId() { 
        Quote__c quote = [SELECT Id, Pricing_Tools__c FROM Quote__c LIMIT 1];
        SLT_IQVIA_Quote quoteSelector = new SLT_IQVIA_Quote(); 
        Quote__c retrievedQuote = quoteSelector.getQuoteId(quote.Id, new Set<String>()); 
        System.assertEquals(quote.Id, retrievedQuote.Id);  
    }
    
    @isTest 
    static void testGetQuoteDetails() { 
        Quote__c quote = [SELECT Id, Pricing_Tools__c FROM Quote__c LIMIT 1];
        SLT_IQVIA_Quote quoteSelector = new SLT_IQVIA_Quote(); 
        Quote__c retrievedQuote = quoteSelector.getQuoteDetails(Quote.Id); 
        System.assertEquals(Quote.Id, retrievedQuote.Id);
    }
    
    @isTest static void testGetQuoteRequisitesById() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Set<Id> idSet = new Set<Id>{quote.Id};
            
        Test.startTest();
            List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuoteIdslist(idSet, new Set<String>{'Id', 'Total_ICF_Documents__c'});
        Test.stopTest();
        
        System.assertEquals(true, quoteList.size() > 0);
    }
    
    @isTest
    private static void testGetQuoteMap() {
	    Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Set<Id> quoteIdsToRetrieve = new Set<Id>{quote.Id};
		Test.startTest();
            Map<Id, Quote__c> quoteMap = new SLT_IQVIA_Quote().getQuoteMap(quoteIdsToRetrieve, new Set<String>{CON_CPQ.ID, CON_CPQ.CURRENCYISOCODE});
        Test.stopTest();
        System.assertEquals(1, quoteMap.size());
    }

    @isTest
    private static void testGetQuotesByConditionOrderByAcceptedDate() {
	    Quote__c quote = [SELECT Id, Related_Opportunity__c FROM Quote__c LIMIT 1];
		Test.startTest();
            String condition = 'Related_Opportunity__c =: relatedOpportunityIdSet';
            List<Quote__c> quoteList = new SLT_IQVIA_Quote().getQuotesByConditionOrderByAcceptedDate(new Set<String>{CON_CPQ.ID}, condition, CON_CPQ.ID, CON_CPQ.SORT_DESC, new Set<Id>{quote.Related_Opportunity__c});
        Test.stopTest();
        Assert.areEqual(1, quoteList.size(), 'The expected list size is not returned.');
    }
}