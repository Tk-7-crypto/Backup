@isTest
public class TST_BCH_CPQ_CreateAdminTimeEntryData 
{
    private static Opportunity setOpportunityData(Id accountId)
    {    
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    private static Account setAccountData() 
    {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    private static Product2 setProduct2Data() 
    {    
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        return testProduct;
    }
    
    static void createPLIs(Id proposalId, Id productId){
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = UTL_TestData.createProposalLineItem(proposalId, productId);        
        proposalLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = UTL_TestData.createProposalLineItems(proposalId); 
        proposalLineItemList.add(proposalLineItem);
        insert proposalLineItemList;
        List<Timeline__c> timelineList = UTL_TestData.createQuoteTimelines(proposalId); 
        insert timelineList;
        List<Country_Input__c> countryInputList = UTL_TestData.createQuoteCountryInputs(proposalId); 
        insert countryInputList;
    }

    static void createCPQ_Setting() {
        CPQ_Settings__c cpqSettings = new CPQ_Settings__c();
        cpqSettings.Name = 'CPQ Setting';
        cpqSettings.Timeline_Month_For_Remote_EDC__c = 0.02;
        insert cpqSettings;
    }
    
    @isTest
    static void testCreateAdminTimeEntryQuoteData() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Product2 testProduct = setProduct2Data();
        
        Bid_History__c bidhistory = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, bidhistory.Id);   
        createPLIs(budget.Id, testProduct.Id);
        createCPQ_Setting();
        
        Test.startTest();
            Database.executeBatch(new BCH_CPQ_CreateAdminTimeEntryData(new Set<String> {budget.Id}));
        Test.stopTest();
		
        List<Admin_Time_Entry_Data__c> adminTimeEntryList = [SELECT Id, Name FROM Admin_Time_Entry_Data__c Limit 1];
        System.assertEquals(true, adminTimeEntryList.size() > 0);
    }
}