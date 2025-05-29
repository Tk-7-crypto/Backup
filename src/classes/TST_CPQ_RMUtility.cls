@isTest
private class TST_CPQ_RMUtility {
    private static Id clinicalBidID;
    private static Id testOpportunityId;
    private static Id testProductId;
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
        testOpportunityId = testOpportunity.Id;
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        testProductId = testProduct.Id;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        clinicalBidID = testClinicalBid.ID;
        
        CPQ_Settings__c cpqSettings = new CPQ_Settings__c();
        cpqSettings.Name = 'CPQ Setting';
        cpqSettings.Timeline_Month_For_Remote_EDC__c = 0.02;
        insert cpqSettings;
    }
    
    private static Apttus_Proposal__Proposal__c createQuoteRecord(Id testOpportunityId, Id clinicalBidID){
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunityId, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBidID);
        createPLIs(budget.Id, testProductId); 
        return budget;
    }
    
    static void createPLIs(Id proposalId, Id productId){
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = UTL_TestData.createProposalLineItem(proposalId, productId);        
        proposalLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = UTL_TestData.createProposalLineItems(proposalId); 
        proposalLineItemList.addAll(UTL_TestData.createProposalLineItemsForClinicalVisitFrequency(proposalId));
        proposalLineItemList.add(proposalLineItem);
        insert proposalLineItemList;
        List<Timeline__c> timelineList = UTL_TestData.createQuoteTimelines(proposalId); 
        insert timelineList;
        List<Country_Input__c> countryInputList = UTL_TestData.createQuoteCountryInputs(proposalId); 
        insert countryInputList;
    }
    
    @isTest
    static void testCreateTimelineQuoteData(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c quote = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        Test.startTest();
            CPQ_RMUtility.createTimelineDataFuture(new Set<ID> {quote.ID});
        Test.stopTest();
        
        List<Timeline__c> timelineList = [SELECT Id FROM Timeline__c];
        System.assertEquals(true, timelineList.size() > 15);
    }
    
    @isTest
    static void testCreateAdminTimeEntryQuoteData() {
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c quote = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        Test.startTest();
            CPQ_RMUtility.createAdminTimeEntryDatafuture(new Set<ID> {quote.ID});
        Test.stopTest();
        
        List<Admin_Time_Entry_Data__c> adminTimeEntryList = [SELECT Id, Name FROM Admin_Time_Entry_Data__c];
        System.assertEquals(true, adminTimeEntryList.size() > 0);
    }
    
    @isTest
    static void testCreateClinicalVisitFrequencyQuoteData(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c quote = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        Test.startTest();
            CPQ_RMUtility.createClinicalVisitFrequencyDataFuture(new Set<ID> {quote.ID});																
        Test.stopTest();
        
        List<Clinical_Visit_Frequency_Data__c> clinicalVisitFrequencyList = [SELECT Id, Name FROM Clinical_Visit_Frequency_Data__c];
        System.assertEquals(true, clinicalVisitFrequencyList.size() > 0);
    }
    
    @isTest
    static void testDeleteCountryInput(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        List<Country_Input__c> countryInput = UTL_TestData.createQuoteCountryInputs(proposal.Id);
        
        Test.startTest();
            CPQ_RMUtility.deleteCountryInput(proposal.Id);
        Test.stopTest();
        
        List<Country_Input__c> countryInputList = [SELECT Id, Name FROM Country_Input__c where Proposal__c = :proposal.Id];
        System.assertEquals(true, countryInputList.size() == 0);
    }
    
    @isTest
    static void testDeleteTimeline(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        List<Timeline__c> timeline = UTL_TestData.createQuoteTimelines(proposal.Id);
        
        Test.startTest();
            CPQ_RMUtility.deleteTimelineByOrder(new Set<Id> {proposal.Id});
            CPQ_RMUtility.deleteTimeline(proposal.Id);
        Test.stopTest();
        
        List<Timeline__c> timelineList = [SELECT Id, Name FROM Timeline__c where Proposal__c = :proposal.Id];
        System.assertEquals(true, timelineList.size() == 0);
    }
    
    @isTest
    static void testDeleteAdminTimeEntryData(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        List<Admin_Time_Entry_Data__c> adminTimeEntryData = UTL_TestData.createAdminTimeEntryData(proposal.Id);
        
        Test.startTest();
            CPQ_RMUtility.deleteAdminTimeEntryData(new Set<Id> {proposal.Id});
        Test.stopTest();
        
        List<Admin_Time_Entry_Data__c> adminTimeEntryDataList = [SELECT Id, Name FROM Admin_Time_Entry_Data__c where Proposal__c = :proposal.Id];
        System.assertEquals(true, adminTimeEntryDataList.size() == 0);
    }
    
    @isTest
    static void testDeleteClinicalVisitFrequencyData(){
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Bid_History__c testClinicalBid = [SELECT Id, Name FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = createQuoteRecord(testOpportunity.Id, testClinicalBid.Id);
        List<Clinical_Visit_Frequency_Data__c> clinicalVisitFrequencyData = UTL_TestData.createClinicalVisitFrequencyData(proposal.Id);
        
        Test.startTest();
            CPQ_RMUtility.deleteClinicalVisitFrequencyData(new Set<Id> {proposal.Id});
        Test.stopTest();
        
        List<Clinical_Visit_Frequency_Data__c> clinicalVisitFrequencyDataList = [SELECT Id, Name FROM Clinical_Visit_Frequency_Data__c where Proposal__c = :proposal.Id];
        System.assertEquals(true, clinicalVisitFrequencyDataList.size() == 0);
    }
    
    @isTest
    static void testUnlockApprovalProcess(){
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Min_Gross_Margin__c = 15;
        proposal.Vendor_Use__c = true;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINALIZED;
        insert proposal;
        
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(proposal.Id);
        request.setSubmitterId(proposal.OwnerId);
        request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);
        
        Test.startTest();
        CPQ_RMUtility.unlockApprovalProcess(new List<Apttus_Proposal__Proposal__c>{proposal});
        Test.stopTest();
    }
}