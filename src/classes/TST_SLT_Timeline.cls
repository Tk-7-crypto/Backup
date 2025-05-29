/**
 * Version       : 1.0
 * Description   : This test class is used for Select AgreementLineItems
 */
@isTest
private class TST_SLT_Timeline {
     
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
		Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        List<Timeline__c> timelineList = UTL_TestData.createQuoteTimelines(proposal.Id); 
        insert timelineList;
    }
      
    @isTest
    static void testSelectByAgreementIds() {
        
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        String condition = ' Proposal__c IN :parentIdsSet ';
        Test.startTest();
            List<Timeline__c> timelineList = new SLT_Timeline().selectByAgreementIds(new Set<Id> {testProposal.Id}, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(timelineList.size() > 0, true, 'Timeline exists');
    } 
    
    @isTest
    static void testSelectByAgreementIdAndTimelineNames() {
        
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        String condition = ' Proposal__c IN :parentIdsSet ';
        
        Test.startTest();
            List<Timeline__c> timelineList = new SLT_Timeline().selectByAgreementIdAndTimelineNames(new Set<Id> {testProposal.Id}, fieldSet, new Set<String>{CON_CPQ.PRE_PROJECT_ACTIVITIES}, condition);
        Test.stopTest();
        
        System.assertEquals(timelineList.size() > 0, true, 'Timeline exists');
    }
    
}