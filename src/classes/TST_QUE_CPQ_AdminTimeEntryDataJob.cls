@IsTest
public class TST_QUE_CPQ_AdminTimeEntryDataJob {
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
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);

        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = UTL_TestData.createProposalLineItem(budget.Id, testProduct.Id);        
        proposalLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = UTL_TestData.createProposalLineItems(budget.Id); 
        proposalLineItemList.addAll(UTL_TestData.createProposalLineItemsForClinicalVisitFrequency(budget.Id));
        proposalLineItemList.add(proposalLineItem);
        insert proposalLineItemList;
        List<Timeline__c> timelineList = UTL_TestData.createQuoteTimelines(budget.Id); 
        insert timelineList;
        List<Country_Input__c> countryInputList = UTL_TestData.createQuoteCountryInputs(budget.Id); 
        insert countryInputList;
	}
    @IsTest
    static void testExecute() {
        Set<Id> budgetIdSet = new Map<Id,Apttus_Proposal__Proposal__c>([Select id From Apttus_Proposal__Proposal__c]).keySet();
        Test.startTest();
            System.enqueueJob(new QUE_CPQ_ClinicalVisitFrequencyDataJob(budgetIdSet));
        Test.stopTest();
    }
}