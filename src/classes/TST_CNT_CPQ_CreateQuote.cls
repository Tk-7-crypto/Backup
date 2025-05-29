@isTest
public class TST_CNT_CPQ_CreateQuote {
    static Opportunity setOpportunityData(Id accountId) {
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Account setAccountData() {
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Contract setContractData(Opportunity opp, String recordTypeDevName) {
        
        Contract testContract = UTL_TestData.createContract(opp, recordTypeDevName);
        insert testContract;
        return testContract;
    }
    
    @isTest
    static void testGetRelatedQuotesDetailsFromContract() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Contract testContract = setContractData(testOpportunity, 'Generic_Contract');
        testContract.Opportunity__c = testOpportunity.Id;
        update testContract;
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Apttus_Proposal__Proposal__c testQuoteData = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        testQuoteData.Apttus_Proposal__Approval_Stage__c = CON_CPQ.CANCELLED;
        update testQuoteData;
        Test.startTest();
            CNT_CPQ_CreateQuote.AllQuoteDetails allQuoteDetails = CNT_CPQ_CreateQuote.getRelatedQuotesDetails(false,testContract.Id);
            Id newBudgetId = allQuoteDetails.quoteId;
        Test.stopTest();
        System.assertNotEquals(newBudgetId, null, 'A primary and Accepted quote is present on opportunity');
    }
    
    @isTest
    static void testGetRelatedQuotesDetailsFromOpportunity() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Apttus_Proposal__Proposal__c testQuoteData = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        testQuoteData.Apttus_Proposal__Approval_Stage__c = CON_CPQ.CANCELLED;
        update testQuoteData;
        Test.startTest();
            CNT_CPQ_CreateQuote.AllQuoteDetails allQuoteDetails = CNT_CPQ_CreateQuote.getRelatedQuotesDetails(true,testOpportunity.Id);    
        Test.stopTest();
        Id newBudgetId = allQuoteDetails.quoteId;
        System.assertNotEquals(newBudgetId, null, 'A primary and Accepted quote is present on opportunity');
    }
}