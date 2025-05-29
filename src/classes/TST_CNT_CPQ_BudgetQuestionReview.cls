@isTest
private class TST_CNT_CPQ_BudgetQuestionReview
{   
    static Account setAccountData()
    {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Opportunity setOpportunityData(Id accountId)
    {
        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Apttus__APTS_Agreement__c getAgreementData(Id opportuntiyId, String recordTypeAPIName)
    {
        Id recordTypeId = SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypeAPIName).getRecordTypeId();
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = opportuntiyId;
        testAgreement.RecordTypeId = recordTypeId;
        return testAgreement;
    }
	
    static Apttus_Proposal__Proposal__c getBudgetData(Id bidId, String recordTypeAPIName)
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, OPP.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, bidId);
        return testBudget;
    }
	
    static void setFilterCustomData(String filter, String defaultFilter, String budgetType, String pricingTool, String stage) 
    {
        QC_Review_Default_Filter__c filterData = new QC_Review_Default_Filter__c(Name = '1', Filter__c = filter, Default_Filter__c = defaultFilter,
            Budget_Type__c = budgetType, Budget_Tool__c = pricingTool, Budget_Stage__c = stage);
        insert filterData;
    }
    
    static void setQCCheckListItemData(String opportunityType, String budgetType, String pricingTool, String stage, String migrationId)
    {
        QC_Check_List_Item__c qcCheckListItem = UTL_TestData.createQCCheckListItem();
        qcCheckListItem.Opportunity_Type__c = opportunityType;
        qcCheckListItem.Budget_Type__c = budgetType;
        qcCheckListItem.Pricing_Tool__c = pricingTool;
        qcCheckListItem.Stage__c = stage;
        qcCheckListItem.Owner_s_Response__c = CON_CPQ.YES_TITLE_CASE;
        qcCheckListItem.Reviewer_s_Response__c = CON_CPQ.YES_TITLE_CASE;
        qcCheckListItem.Reviewer_s_Major_Findings__c = CON_CPQ.YES_TITLE_CASE;
        qcCheckListItem.Migration_Id__c = migrationId;
        insert qcCheckListItem;
    }

    @isTest
    static void testFetchDataShouldReturnQCDraftList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c proposal = getBudgetData(clinicalBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        proposal.Approval_Status__c = CON_CPQ.SELF_CHECK_DRAFT;
        proposal.Draft_QC_Number_of_Budgets_Requested__c = 0;
        update proposal;
        
        setFilterCustomData(CON_CPQ.BUDGET, CON_CPQ.BUDGET, proposal.Apttus_Proposal__Proposal_Category__c, proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c);
            
        setQCCheckListItemData(clinicalBid.Opportunity_Type__c, proposal.Apttus_Proposal__Proposal_Category__c, proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c, 'QCLI-004');

        Test.startTest();
            CNT_CPQ_BudgetQuestionReview.ProposalDetails proposalDetail = CNT_CPQ_BudgetQuestionReview.fetchData(proposal.Id);
        Test.stopTest();

        System.assertEquals(1, proposalDetail.questionList.size(),'Should Return QC List');
    }
   
    @isTest
    static void testFetchDataShouldReturnQCFinalList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c proposal = getBudgetData(clinicalBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        proposal.Final_QC_Number_of_Budgets_Requested__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINAL_REVIEW;
        proposal.Approval_Status__c = CON_CPQ.SELF_CHECK_FINAL;
        update proposal;
        
        setFilterCustomData(CON_CPQ.BUDGET, CON_CPQ.BUDGET, proposal.Apttus_Proposal__Proposal_Category__c, proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c);
            
        setQCCheckListItemData(clinicalBid.Opportunity_Type__c, proposal.Apttus_Proposal__Proposal_Category__c, proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c, 'QCLI-005');

        Test.startTest();
            CNT_CPQ_BudgetQuestionReview.ProposalDetails proposalDetail = CNT_CPQ_BudgetQuestionReview.fetchData(proposal.Id);
        Test.stopTest();

        System.assertEquals(1, proposalDetail.questionList.size(),'Should Return QC List');
    }
    
    @isTest
    static void testsaveAllDataActionShouldSaveQCDraftList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = getBudgetData(clinicalBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        
        Proposal_QA_Self_Check_List__c question = new Proposal_QA_Self_Check_List__c();
        CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper questionWrapper = new CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper();
        questionWrapper.isNew = true;
        questionWrapper.question = question;
        questionWrapper.filterValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.ownersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.reviewersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.majorFindingCompletedValues = new List<String>{CON_CPQ.YES_TITLE_CASE};

        CNT_CPQ_BudgetQuestionReview.ProposalDetails proposalDetails = new CNT_CPQ_BudgetQuestionReview.ProposalDetails();
        proposalDetails.recordId = budget.Id;
        proposalDetails.approvalStage = CON_CPQ.DRAFT;
        proposalDetails.approvalStatus = CON_CPQ.SELF_CHECK_DRAFT;
        proposalDetails.selectedFilterTypes = new List<String>{CON_CPQ.BUDGET};
        proposalDetails.questionList = new List<CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper>{questionWrapper};
        String proposalDetailsString = JSON.serialize(proposalDetails);

        Test.startTest();
            CNT_CPQ_BudgetQuestionReview.saveAllDataAction(proposalDetailsString, CON_CPQ.APPROVED_STATUS);
        Test.stopTest();
    }
    
    @isTest
    static void testsaveAllDataActionShouldSaveQCFinalList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = getBudgetData(clinicalBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        
        Proposal_QA_Self_Check_List__c question = new Proposal_QA_Self_Check_List__c();
        CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper questionWrapper = new CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper();
        questionWrapper.isNew = true;
        questionWrapper.question = question;
        questionWrapper.filterValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.ownersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.reviewersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};
        questionWrapper.majorFindingCompletedValues = new List<String>{CON_CPQ.YES_TITLE_CASE};

        CNT_CPQ_BudgetQuestionReview.ProposalDetails proposalDetails = new CNT_CPQ_BudgetQuestionReview.ProposalDetails();
        proposalDetails.recordId = budget.Id;
        proposalDetails.approvalStage = CON_CPQ.FINAL_REVIEW;
        proposalDetails.approvalStatus = CON_CPQ.SELF_CHECK_FINAL;
        proposalDetails.selectedFilterTypes = new List<String>{CON_CPQ.BUDGET};
        proposalDetails.questionList = new List<CNT_CPQ_BudgetQuestionReview.ProposalQASelfCheckListWrapper>{questionWrapper};
        String proposalDetailsString = JSON.serialize(proposalDetails);

        Test.startTest();
            CNT_CPQ_BudgetQuestionReview.saveAllDataAction(proposalDetailsString, CON_CPQ.APPROVED_STATUS);
        Test.stopTest();
    }
}