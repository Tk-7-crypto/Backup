@isTest
public class TST_BCH_CPQ_SyncToOpp {
    @testSetup
    static void setUpTestData() {        
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;

        Opportunity testOpportunity = UTL_TestData.createOpportunity(acc.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;

        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
    }

    @isTest
    static void testProposalToOppSync(){
        Bid_History__c testClinicalBid = [SELECT Id FROM Bid_History__c LIMIT 1];
        testClinicalBid.Related_Quote_Status__c = 'Ready to Award';
        testClinicalBid.Awarded_Date__c = System.today() - 1;
        update testClinicalBid;

        Apttus_Proposal__Proposal__c budget = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
        update budget;
        
        Test.startTest();
            Database.executeBatch(new BCH_CPQ_SyncToOpp(new Map<Id, Apttus_Proposal__Proposal__c>{budget.Id => budget}));
        Test.stopTest();
    }
}