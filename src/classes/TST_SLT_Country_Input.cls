/**
 * Version       : 1.0
 * Description   : This test class is used for Select AgreementLineItems
 */
@isTest
private class TST_SLT_Country_Input {
     
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
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        List<Country_Input__c> countryInputList = UTL_TestData.createQuoteCountryInputs(proposal.Id); 
        insert countryInputList;
    }
     
    @isTest
    static void testSelectByAgreementIds() {
        
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        String condition = ' Proposal__c IN :parentIdsSet ';
        
        Test.startTest();
            List<Country_Input__c> countryInputList = new SLT_Country_Input().selectByAgreementIds(new Set<Id> {testProposal.Id}, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(countryInputList.size() > 0, true, 'countryInput exists');
    } 
}