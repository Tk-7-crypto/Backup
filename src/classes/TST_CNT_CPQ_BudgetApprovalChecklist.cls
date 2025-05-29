@isTest
private class TST_CNT_CPQ_BudgetApprovalChecklist
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
    
    static Bid_History__c getClinicalBidData(Id opportuntiyId, String recordTypeAPIName)
    {
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Id recordTypeId = SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get(recordTypeAPIName).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = opportuntiyId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Unblinded_CVs_required__c = 'None';
        testClinicalBid.Is_PPT_Format_Required__c = 'No';
        return testClinicalBid;
    }
    
    static Apttus_Proposal__Proposal__c getBudgetData(Id parentBid, String recordTypeAPIName)
    {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, parentBid);
        return testBudget;
    }
   
    static void setQCCheckListItemData(String opportunityType, String budgetType, String pricingTool, String stage, String filter, String migrationId)
    {
        QC_Check_List_Item__c qcCheckListItem = UTL_TestData.createQCCheckListItem();
        qcCheckListItem.Opportunity_Type__c = opportunityType;
        qcCheckListItem.Budget_Type__c = budgetType;
        qcCheckListItem.Pricing_Tool__c = pricingTool;
        qcCheckListItem.Stage__c = Stage;
        qcCheckListItem.Filter__c = filter;
        qcCheckListItem.Reviewer_s_Response__c = CON_CPQ.YES_TITLE_CASE;
        qcCheckListItem.Migration_Id__c = migrationId;
        insert qcCheckListItem;
    }

    @isTest
    static void testFetchDataShouldReturnApprovalPSList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c parentBid = getClinicalBidData(testOpportunity.Id, CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID);
        parentBid.Bid_Type__c = CON_CPQ.INITIAL;
        parentBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        insert parentBid;
        
        Apttus_Proposal__Proposal__c proposal = getBudgetData(parentBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        proposal.PS_Number_of_Budgets_Requested__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
        proposal.Approval_Status__c = CON_CPQ.PS_APPROVAL_PENDING;
        update proposal;
        
        setQCCheckListItemData(parentBid.Opportunity_Type__c,
            proposal.Apttus_Proposal__Proposal_Category__c,
            proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c,
            CON_CPQ.PS,
            'QCLI-006');

        Test.startTest();
            CNT_CPQ_BudgetApprovalChecklist.ProposalDetails proposalDetail = CNT_CPQ_BudgetApprovalChecklist.fetchData(proposal.Id);
        Test.stopTest();

        System.assertEquals(1, proposalDetail.questionList.size(),'Should Return Approval Checklist');
    }
   
    @isTest
    static void testFetchDataShouldReturnApprovalSPList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c parentBid = getClinicalBidData(testOpportunity.Id, CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID);
        parentBid.Bid_Type__c = CON_CPQ.INITIAL;
        parentBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        insert parentBid;
        
        Apttus_Proposal__Proposal__c proposal = getBudgetData(parentBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        proposal.SP_Number_of_Budgets_Requested__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
        proposal.Approval_Status__c = CON_CPQ.SP_APPROVAL_PENDING;
        update proposal;
            
        setQCCheckListItemData(parentBid.Opportunity_Type__c,
            proposal.Apttus_Proposal__Proposal_Category__c,
            proposal.Select_Pricing_Tool__c,
            proposal.Apttus_Proposal__Approval_Stage__c,
            CON_CPQ.SP,
            'QCLI-007');

        Test.startTest();
            CNT_CPQ_BudgetApprovalChecklist.ProposalDetails proposalDetail = CNT_CPQ_BudgetApprovalChecklist.fetchData(proposal.Id);
        Test.stopTest();

        System.assertEquals(1, proposalDetail.questionList.size(),'Should Return Approval Checklist');
    }
    
    @isTest
    static void testsaveAllDataActionShouldSavePSList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c parentBid = getClinicalBidData(testOpportunity.Id, CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID);
        insert parentBid;
        
        Apttus_Proposal__Proposal__c budget = getBudgetData(parentBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        
        Proposal_QA_Self_Check_List__c question = new Proposal_QA_Self_Check_List__c();
        CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper questionWrapper = new CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper();
        questionWrapper.isNew = true;
        questionWrapper.question = question;
        questionWrapper.reviewersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};

        CNT_CPQ_BudgetApprovalChecklist.ProposalDetails proposalDetails = new CNT_CPQ_BudgetApprovalChecklist.ProposalDetails();
        proposalDetails.recordId = budget.Id;
        proposalDetails.approvalStage = CON_CPQ.PENDING_APPROVAL;
        proposalDetails.approvalStatus = CON_CPQ.PS_APPROVAL_PENDING;
        proposalDetails.selectedFilterType = CON_CPQ.PS;
        proposalDetails.actionPerformed = CON_CPQ.APPROVED_STATUS;
        proposalDetails.spApprover = UserInfo.getUserId();
        proposalDetails.questionList = new List<CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper>{questionWrapper};
        String proposalDetailsString = JSON.serialize(proposalDetails);

        Test.startTest();
            CNT_CPQ_BudgetApprovalChecklist.saveAllDataAction(proposalDetailsString);
        Test.stopTest();
    }
    
    @isTest
    static void testsaveAllDataActionShouldSaveSPList()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c parentBid = getClinicalBidData(testOpportunity.Id, CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID);
        insert parentBid;
        
        Apttus_Proposal__Proposal__c budget = getBudgetData(parentBid.Id, CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET);
        
        Proposal_QA_Self_Check_List__c question = new Proposal_QA_Self_Check_List__c();
        CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper questionWrapper = new CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper();
        questionWrapper.isNew = true;
        questionWrapper.question = question;
        questionWrapper.reviewersResponseValues = new List<String>{CON_CPQ.YES_TITLE_CASE};

        CNT_CPQ_BudgetApprovalChecklist.ProposalDetails proposalDetails = new CNT_CPQ_BudgetApprovalChecklist.ProposalDetails();
        proposalDetails.recordId = budget.Id;
        proposalDetails.approvalStage = CON_CPQ.PENDING_APPROVAL;
        proposalDetails.approvalStatus = CON_CPQ.SP_APPROVAL_PENDING;
        proposalDetails.selectedFilterType = CON_CPQ.SP;
        proposalDetails.actionPerformed = CON_CPQ.APPROVED_STATUS;
        proposalDetails.spApprover = UserInfo.getUserId();
        proposalDetails.questionList = new List<CNT_CPQ_BudgetApprovalChecklist.ProposalQASelfCheckListWrapper>{questionWrapper};
        String proposalDetailsString = JSON.serialize(proposalDetails);

        Test.startTest();
            CNT_CPQ_BudgetApprovalChecklist.saveAllDataAction(proposalDetailsString);
        Test.stopTest();
    }
}