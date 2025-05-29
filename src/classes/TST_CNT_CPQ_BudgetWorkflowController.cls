@isTest
public class TST_CNT_CPQ_BudgetWorkflowController {
    @testSetup
    static void dataSetUp() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert testOpportunity;
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Bid_History__c testClinicalBidLCS = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT);
        testClinicalBidLCS.Budget_Tools__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT_LABEL;
        update testClinicalBidLCS;
        
        Apttus_Proposal__Proposal__c budget1 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT, testClinicalBidLCS.Id);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);   
        
        List<Team_Member__c> proposalMemberList = UTL_TestData.createTeamMembers(budget.Id);
        insert proposalMemberList;
        List<Team_Member__c> proposalMemberList1 = UTL_TestData.createTeamMembers(budget1.Id);
        insert proposalMemberList1;
    }
    
    @isTest
    static void testGetProposalDetails() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Test.startTest();
            CNT_CPQ_BudgetWorkflowController.ProposalDetails proposalObj = CNT_CPQ_BudgetWorkflowController.getProposalDetails(proposal.Id);
        Test.stopTest();
        
        System.assertEquals(null, proposalObj.error);
    }
    
    /* Commented under LC-11451
    @isTest
    static void testReject() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW, Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW);
        Test.startTest();
            String result = CNT_CPQ_BudgetWorkflowController.reject(proposal.Id);
         /*   update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Apttus_Proposal__Approval_Stage__c = CON_CPQ.SIGN_OFF, Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FINAL_SIGNOFF);
            result = CNT_CPQ_BudgetWorkflowController.reject(proposal.Id);
            update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINAL_REVIEW, Approval_Status__c = CON_CPQ.SELF_CHECK_FINAL);
            result = CNT_CPQ_BudgetWorkflowController.reject(proposal.Id); //Comment end under LC-11451
        Test.stopTest();
        
        System.assertEquals('', result);
    }*/
    /*Commented under LC-10187 to remove ref. of Reviewer/Final Reviewer picklist value from Team Member object
    @isTest
    static void testInsertQCReviewers() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Test.startTest();
            String result = CNT_CPQ_BudgetWorkflowController.insertQCReviewers(proposal.Id, '' + UserInfo.getUserId() + '');
        Test.stopTest();
        
        System.assertEquals('', result);
    }*/
    
    /* Commented under LC-11451
    @isTest
    static void testFireAprrovalRequest() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Test.startTest();
            CNT_CPQ_BudgetWorkflowController.fireAprrovalRequest(proposal.Id, UserInfo.getUserId());
        Test.stopTest();
        
        proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        System.assertEquals(CON_CPQ.PENDING_APPROVAL, proposal.Apttus_Proposal__Approval_Stage__c);
        
        String result = CNT_CPQ_BudgetWorkflowController.reject(proposal.Id);
        System.assertEquals('', result);
    }*/
    
    @isTest
    static void testCreateProductSpecialist() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c =: CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT Limit 1];
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        proposal.Approval_Status__c = CON_CPQ.SELF_CHECK_DRAFT;
        Test.startTest();
            CNT_CPQ_BudgetWorkflowController.ProposalDetails proposalObj = CNT_CPQ_BudgetWorkflowController.getProposalDetails(proposal.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, proposalObj);
    }

    @isTest
    static void testCreatePreliminaryAgreement() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c =: CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT Limit 1];
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SIGN_OFF;
        proposal.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FINAL_SIGNOFF;
        update proposal;

        Test.startTest();
            String agrRec = CNT_CPQ_BudgetWorkflowController.createPreliminaryAgreement(proposal.Id);
        Test.stopTest();

        System.assertEquals(true, agrRec != null, 'agreement record not created');
    }
    
    @isTest
    static void testCheckPLIOnProposal() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Test.startTest();
            Boolean isPLIExist = CNT_CPQ_BudgetWorkflowController.checkPLIOnProposal(proposal.Id);
        Test.stopTest();
        
         System.assertEquals(false, isPLIExist, 'PLIs not created');
    }
    
    /* Commented under LC-11451
    @isTest
    static void testApprove() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,Apttus_Proposal__Approval_Stage__c,Approval_Status__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL, Approval_Status__c = CON_CPQ.CHALLENGE_REVIEW_COMPLETED_SUBMITTED_TSL_REVIEW);
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c, Role_from_RR__c, TSL_Approve_Offline__c, Email_Body__c, Email_Subject__c, Proposal__r.Name, Proposal__r.Apttus_Proposal__Proposal_Name__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER AND Proposal__c =: proposal.ID  LIMIT 1];
        Test.startTest();
            String result = CNT_CPQ_BudgetWorkflowController.approve(proposal.Id, CON_CPQ.TEST_BODY, CON_CPQ.PENDING_APPROVAL,CON_CPQ.CHALLENGE_REVIEW_COMPLETED_SUBMITTED_TSL_REVIEW );
            update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Apttus_Proposal__Approval_Stage__c = CON_CPQ.SIGN_OFF, Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FINAL_SIGNOFF);
        Test.stopTest();
        
        System.assertEquals('', result);
    }*/
    
    @isTest
    static void testSyncBudgetWithOpportunity() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c =: CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT Limit 1];
        String jobId;
        Test.startTest();
            jobId = CNT_CPQ_BudgetWorkflowController.syncBudgetWithOpportunity(proposal.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId);
    }

    /* Commented under LC-11451
    @isTest
    static void testUpdateQuoteStatusAndSendEmail() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c =: CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT Limit 1];
        String result;
        Test.startTest();
            result = CNT_CPQ_BudgetWorkflowController.updateQuoteStatusAndSendEmail(proposal.Id, CON_CPQ.DRAFT, CON_CPQ.NONE, null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }*/
}