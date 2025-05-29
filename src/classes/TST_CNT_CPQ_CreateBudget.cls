@isTest
public class TST_CNT_CPQ_CreateBudget {
    
    static Bid_History__c setClinicalBidData(String recordTypeName, Id opportunityId, String pricingTool) {
        
        Id recordTypeId =
            SObjectType.Bid_History__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = opportunityId;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        testClinicalBid.Select_Pricing_Tool__c = pricingTool;
        testClinicalBid.Unblinded_CVs_required__c = 'None';
        testClinicalBid.Is_PPT_Format_Required__c = 'No';
        insert testClinicalBid;
        return testClinicalBid;
    }

    static Opportunity setOpportunityData(Id accountId) {
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Account setAccountData() {
        
        Account testAccount = UTL_TestData.createAccount();
        testAccount.AccountStatus__c = 'active';
        insert testAccount;
        return testAccount;
    }
    
    static OWF_Config__c setOWFConfigData(Id grpId) {
        
        OWF_Config__c owfConfig = [Select Id, GSK_Account_Name__c,OWF_Standard_Group__c from OWF_Config__c Limit 1];
        owfConfig.GSK_Account_Name__c = 'GLAXOSMITH';
        owfConfig.OWF_Standard_Group__c = grpId;
        update owfConfig;
        return owfConfig;
    }
    
    static ID getRecordTypeId(String recordTypeName) {
        return [SELECT ID FROM RecordType WHERE Name =:recordTypeName Limit 1].Id;
    }
    
    @isTest
    static void testCreatAnySobject() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        update proposal;

        Test.startTest();
            CNT_CPQ_CreateBudget.WPR_CPQ_Status status = CNT_CPQ_CreateBudget.createAnySobject(null, null, null, CON_CPQ.TEST_USER, CON_CPQ.UNIT_PRICING_TOOL,
                CON_CPQ.OPPORTUNITY_BALLPARK, '', 1, 1, false, testOpportunity.Id, null, CON_CPQ.Rebid, null, null);
        Test.stopTest();
    }

    @isTest
    static void TestSetWrapper() {
       Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
       CNT_CPQ_CreateBudget.setWrapper(proposal); 
    }
    
    @isTest
    static void testGetAllRelatedBudgets() {
        
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c clonedBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        clonedBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        update clonedBudget;
        Test.startTest();
            CNT_CPQ_CreateBudget.WPR_CPQ_Status budgetId = CNT_CPQ_CreateBudget.createAnySobject(clinicalBid.Id, null, null, CON_CPQ.TEST_USER, CON_CPQ.UNIT_PRICING_TOOL,
                CON_CPQ.OPPORTUNITY_BALLPARK, '', 1, 1, false, testOpportunity.Id, null, CON_CPQ.PROJECT_SPECIFIC, null, null);
        
            CNT_CPQ_CreateBudget.AllDetails allDetails = CNT_CPQ_CreateBudget.getAllRelatedBudgets(testOpportunity.Id, CON_CPQ.UNIT_PRICING_TOOL);
            List<CNT_CPQ_CreateBudget.BudgetWrapper> budgetWrapperList = allDetails.budgetWrapperList;
        Test.stopTest();
        System.assertEquals(budgetWrapperList.size(), 2, 'Budget details retrieved successfully.');
    }
    
    @isTest
    static void testGetPickListValues() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Test.startTest();
        CNT_CPQ_CreateBudget.WPR_CPQ_PicklistValues picklistValuesObj = CNT_CPQ_CreateBudget.getPicklistvalues(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.RFP_SCENARIO, 'Create_Budget_SF', testOpportunity.Id);
        Test.stopTest();
        System.assertNotEquals(picklistValuesObj.budgetTypes.size(), 0 , 'Picklist values are fetched');
    }
    
    @isTest
    static void testValidateChangeOrderQuoteWRTAgreement() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        clinicalBid.Bid_History_Account__c = testAccount.Id;
        update clinicalBid;
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Related_Opportunity__c = testOpportunity.Id;
        agreement.RecordTypeId = CON_CLM.PSA_RECORDTYPEID;
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        agreement.Apttus__Contract_End_Date__c = Date.newInstance(2022, 12, 31);
        insert agreement;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        update proposal;
        Test.startTest();
        CNT_CPQ_CreateBudget.validateChangeOrderQuoteWRTAgreement(new List<Apttus_Proposal__Proposal__c>{proposal});
        CNT_CPQ_CreateBudget.isFieldAccessible('');
        CNT_CPQ_CreateBudget.checkPostAward(clinicalBid.Id);
        Test.stopTest();
    }
    @isTest
    static void testCheckPostAward() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        clinicalBid.Bid_History_Account__c = testAccount.Id;
        update clinicalBid;
        testAccount.AccountStatus__c = 'Inactive';
        update testAccount;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        Test.startTest();
        CNT_CPQ_CreateBudget.checkPostAward(clinicalBid.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetBudgetTypesValues() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Test.startTest();
        CNT_CPQ_CreateBudget.WPR_CPQ_PicklistValues picklistValuesObj = CNT_CPQ_CreateBudget.getBudgetTypesValues(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.RFP_SCENARIO, CON_CPQ.CONTRACT_POST_AWARD, 'Bid History', testOpportunity.Id, 'Work Order');
        Test.stopTest();
        System.assertNotEquals(picklistValuesObj.budgetTypes.size(), 0 , 'Picklist values are fetched');
    }
    
    @isTest
    static void testSecondQuoteValidation() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.CONTRACT_POST_AWARD, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.PROJECT_SPECIFIC;
        update proposal;

        Test.startTest();
            CNT_CPQ_CreateBudget.WPR_CPQ_Status status = CNT_CPQ_CreateBudget.createAnySobject(null, null, null, CON_CPQ.TEST_USER, CON_CPQ.UNIT_PRICING_TOOL,
                CON_CPQ.OPPORTUNITY_BALLPARK, '', 1, 1, false, testOpportunity.Id, null, CON_CPQ.PROJECT_SPECIFIC, null, null);
        Test.stopTest();
        
        System.assertEquals( status.isSuccess,false, '2nd quote not created.' );
    }
    
    @isTest
    static void testPSQuoteValidation() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.CONTRACT_POST_AWARD, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.PROJECT_SPECIFIC;
        update proposal;

        Test.startTest();
            Boolean psExists = CNT_CPQ_CreateBudget.restrictSecondPSQuoteCreation(testOpportunity.Id);
        Test.stopTest();
        
        Assert.areEqual(false, psExists,'PS Quote Already Exsists');
    }
    
    @isTest
    static void testCreatFirstQuote() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Test.startTest();
            CNT_CPQ_CreateBudget.WPR_CPQ_Status status = CNT_CPQ_CreateBudget.createAnySobject(null, null, null, CON_CPQ.TEST_USER, CON_CPQ.UNIT_PRICING_TOOL,
                'Bid to Spec', '', 1, 1, true, testOpportunity.Id, null, CON_CPQ.Rebid, null, null);
        Test.stopTest();
        
        Assert.areEqual(true, status.isSuccess,'Quote created successfully');
    }
}
