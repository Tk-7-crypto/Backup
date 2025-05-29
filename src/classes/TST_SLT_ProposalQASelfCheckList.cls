@isTest
private class TST_SLT_ProposalQASelfCheckList {


    static Opportunity setOpportunityData(Id accountId){

        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        insert testOpportunity;
        return testOpportunity;
    }

    static Account setAccountData(){

        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }

    static Proposal_QA_Self_Check_List__c setProposalQASelfCheckListData(String proposalID, String typeOfProcessStep){

        Proposal_QA_Self_Check_List__c proposalQASelfCheckList = UTL_TestData.createProposalQASelfCheckList();
        proposalQASelfCheckList.Budget__c = proposalID;
        proposalQASelfCheckList.Type_Of_Process_Step__c = typeOfProcessStep;
        proposalQASelfCheckList.Instance_Id__c = 1;
        proposalQASelfCheckList.Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        insert proposalQASelfCheckList;
        return proposalQASelfCheckList;
    }

    @isTest
    static void testSelectProposalCheckListByIdShouldReturnProposalCheckList() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Proposal_QA_Self_Check_List__c testProposalQASelfCheckList  = setProposalQASelfCheckListData(testBudget.Id, 'Draft');

        Test.startTest();
            List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = new SLT_ProposalQASelfCheckList().selectById(new Set<Id>{testProposalQASelfCheckList.Id});
        Test.stopTest();

    system.assertEquals(1, proposalQASelfCheckList.size(), 'Should Return proposal check list by Id');
    }

    
    @isTest
    static void testGetProposalCheckListForProcessStepAndBidTypeOfBudget() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Proposal_QA_Self_Check_List__c proposalQASelfCheck = UTL_TestData.createProposalQASelfCheckList();
        proposalQASelfCheck.Budget__c = testBudget.Id;
        proposalQASelfCheck.Type_Of_Process_Step__c = CON_CPQ.DRAFT;
        proposalQASelfCheck.Instance_Id__c = 1;
        proposalQASelfCheck.Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        insert proposalQASelfCheck;

        Set<String> propsalFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.FIELD_BUDGET};

        Test.startTest();
            List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = new SLT_ProposalQASelfCheckList().getProposalCheckListForProcessStepAndBidTypeOfBudget(
                new Set<Id>{testBudget.Id}, propsalFieldSet, CON_CPQ.DRAFT, 1, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT);
        Test.stopTest();

        System.assertEquals(1, proposalQASelfCheckList.size(), 'Should Return proposal check list ');
    }
    
    @isTest
    static void testGetProposalCheckListForBudget() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Proposal_QA_Self_Check_List__c proposalQASelfCheck = UTL_TestData.createProposalQASelfCheckList();
        proposalQASelfCheck.Budget__c = testBudget.Id;
        proposalQASelfCheck.Stage__c = CON_CPQ.DRAFT;
        proposalQASelfCheck.Instance_Id__c = 1;
        insert proposalQASelfCheck;

        Set<String> propsalFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.FIELD_BUDGET};

        Test.startTest();
            List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = new SLT_ProposalQASelfCheckList().getProposalCheckListForBudget(
                testBudget.Id, propsalFieldSet, CON_CPQ.DRAFT, 1);
        Test.stopTest();

        System.assertEquals(1, proposalQASelfCheckList.size(), 'Should Return proposal check list ');
    }
    
    @isTest
    static void testGetProposalCheckListForBudgetFiltered() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Proposal_QA_Self_Check_List__c proposalQASelfCheck = UTL_TestData.createProposalQASelfCheckList();
        proposalQASelfCheck.Budget__c = testBudget.Id;
        proposalQASelfCheck.Stage__c = CON_CPQ.DRAFT;
        proposalQASelfCheck.Filter__c = CON_CPQ.PS;
        proposalQASelfCheck.Instance_Id__c = 1;
        insert proposalQASelfCheck;

        Set<String> propsalFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.FIELD_BUDGET};

        Test.startTest();
            List<Proposal_QA_Self_Check_List__c> proposalQASelfCheckList = new SLT_ProposalQASelfCheckList().getProposalCheckListForBudgetFiltered(
                testBudget.Id, propsalFieldSet, CON_CPQ.DRAFT, 1,CON_CPQ.PS);
        Test.stopTest();

        System.assertEquals(1, proposalQASelfCheckList.size(), 'Should Return proposal check list ');
    }
}