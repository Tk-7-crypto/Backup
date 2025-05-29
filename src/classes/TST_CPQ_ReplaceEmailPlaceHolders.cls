@isTest
public class TST_CPQ_ReplaceEmailPlaceHolders {

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

        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        budget.Total_IQVIA_Fees_BID__c = 1.0;
        update budget;
    }
    
    @isTest
    static void testSendMailToDSBReviewers() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        update new Apttus_Proposal__Proposal__c(Id = proposal.Id, Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW);
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, '');
        Test.stopTest();
        
        System.assertNotEquals(null, emailObj);
    }
    
    @isTest
    static void testSendMailToChallengeReviewers() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, CON_CPQ.CHALLENGE_REVIEW);
        Test.stopTest();
        System.assertNotEquals(null, emailObj);
    }
    
    @isTest
    static void testSendMailForFinalSignOff() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, CON_CPQ.SIGN_OFF);
        Test.stopTest();
        
        System.assertNotEquals(null, emailObj);
    }
    
    @isTest
    static void testReplaceMailBody() {        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Clinical_Bid__c, Apttus_Proposal__Account__r.Name, Apttus_Proposal__Opportunity__r.Name, Clinical_Bid__r.Indication__c,
            Clinical_Bid__r.Opportunity_Number__c, Clinical_Bid__r.Bid_Due_Date__c, Apttus_Proposal__Opportunity__r.Opportunity_Number__c, Opportunity_Number__c,
            Clinical_Bid__r.Phase__c, Administrative_Fee_on_Expenses__c, Total_IQVIA_Fees_Bottom_Line_Discount__c,
            Total_IQVIA_Fees__c, Total_INV_Grants__c, Total_Expenses_Other__c, Includes_Estimated_Inflation_of__c,
            Bottom_Line_Discount_Amount_BLDA__c, Total_Price_QActive_Sites__c, Total_Price_QActive_Sites_passthroughs__c, Total_Price_QPt_Randomised__c,
            Total_Price_QPt_Randomised_passthroughs__c, Total_Price_QPt_Completed__c, Total_Price_QPt_Completed_passthroughs__c,
            Scenario_Number__c, RFP_Scenario__c, Scenario_Description__c, Budget_Iteration__c
            FROM Apttus_Proposal__Proposal__c WHERE Clinical_Bid__c != null LIMIT 1];
        
        Team_Member__c teamMember = new Team_Member__c(User__c = UserInfo.getUserId(), Member_Role__c = CON_CPQ.FUNCTIONAL_REVIEWER, Proposal__c = proposal.Id, Role_from_RR__c = CON_CPQ.TSL);
        insert teamMember;
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
            CON_CPQ.CPQ_SEND_EMAIL_TO_FUNCTIONAL_REVIEWER, new Set<String>{CON_CPQ.Id, CON_CPQ.DeveloperName});
        Messaging.SingleEmailMessage mailTemp1 = Messaging.renderStoredEmailTemplate(
            emailTemplate[0].Id, UserInfo.getUserId(), proposal.Id);																		
        
        Test.startTest();
            CPQ_ReplaceEmailPlaceHolders.replaceMailBody(mailTemp1, proposal, false);																				 
        Test.stopTest();
        
        System.assertNotEquals(null, mailTemp1);
    }
}