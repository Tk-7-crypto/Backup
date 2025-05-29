/**
* This test class is used to test all methods in Quote/Proposal trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_Proposal {

    static Apttus_Proposal__Proposal__c getBudgetData(Id OpportuntiyId)
    {
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, OpportuntiyId, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        Apttus_Proposal__Proposal__c testBudget = UTL_TestData.createQuote();
        testBudget.Apttus_Proposal__Opportunity__c = OpportuntiyId;
        testBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        return testBudget;
    }

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
    
    @isTest
    static void testProposalInsert()
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus_Proposal__Proposal__c budget = getBudgetData(testOpportunity.Id);

        Test.startTest();
            insert budget;
        Test.stopTest();
    }
}