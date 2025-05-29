@isTest
public class TST_CNT_CPQ_CNFLinking {
    @TestSetup
    static void dataSetup() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;

        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;

        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
        budget.RFP_Scenario__c = 'CNF 01';
        update budget;
        
        Apttus_Proposal__Proposal__c budget1 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        budget1.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        budget1.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        budget1.RFP_Scenario__c = 'Change Order 01';
        update budget1;
    }

    @isTest
    static void testGetCNFRecords() {
        Id reocrdId = [SELECT id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c = :CON_CPQ.CNF LIMIT 1].Id;

        Test.startTest();
            CNT_CPQ_CNFLinking.WPR_CPQ_Info info = CNT_CPQ_CNFLinking.getCNFRecords(reocrdId);
        Test.stopTest();

        System.assertEquals(reocrdId, info.propList[0].Id);
    }

    @isTest
    static void testUpdateCNFs() {
        List<Apttus_Proposal__Proposal__c> propList = [SELECT id, Change_Order_Number__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c = :CON_CPQ.CNF];
        propList[0].Change_Order_Number__c = '01';

        Apttus_Proposal__Proposal__c testProposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c = :CON_CPQ.CHNAGE_ORDER LIMIT 1];
        
        Test.startTest();
            CNT_CPQ_CNFLinking.updateCNFs(propList, true, testProposal.Id);
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c updatedProp = [SELECT id, Change_Order_Number__c, Related_Change_Order__c FROM Apttus_Proposal__Proposal__c WHERE Id = :propList[0].Id LIMIT 1];
		System.assertEquals(testProposal.Id, updatedProp.Related_Change_Order__c);
    }
}