@isTest
public without sharing class TST_CPQ_QuoteUtilityWO {

    private static Id clinicalBidID;
    private static Id testOpportunityId;
    private static Id testProductId;
    
    @testSetup
    static void dataSetUp() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.EMEA_Go_Live__c = Date.today()-5;
        insert cpqSetting;
        
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
        
        Opportunity testOpportunityNew= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunityNew.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunityNew.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunityNew.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunityNew.Legacy_Quintiles_Opportunity_Number__c = 'MVP1234';
        insert testOpportunityNew;

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

        Quote__c quote = UTL_TestData.createIqviaQuote(testAccount.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS;
        quote.License_Type__c = 'Per Study';
        insert quote;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Draft_Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            FirstPublishLocationId = quote.Id
        );
        insert contentVersion;
    }

    @isTest
    static void testDeletePreviewDocuments() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId];
        contentDoc.Description = CON_CPQ.DRAFT_PREFIX;
        update contentDoc;
        Test.startTest();
            CPQ_QuoteUtilityWO.deletePreviewDocuments(quote.Id);
        Test.stopTest();
        Assert.areEqual(0, [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId].size(), 'The list size must be 0');
    }

    @isTest
    public static void testCancelActiveQuotes() {
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.EMEA;
        quote.Scenario__c = 2;
        quote.Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
        quote.Related_Account__c = testOpportunity.AccountId;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        insert quote;
        
        Test.startTest();
            CPQ_QuoteUtilityWO.cancelActiveQuotes(testOpportunity.Id);
        Test.stopTest();
        
       Quote__c canceledQuote = [SELECT Id, Approval_Stage__c FROM Quote__c WHERE Id = :quote.Id LIMIT 1];
	   System.assertEquals(CON_CPQ.CANCELLED_STATUS, canceledQuote.Approval_Stage__c, 'The quote should be canceled after calling cancelActiveQuotes.');
    }
    
    @isTest
    public static void testShowErrorOnPricingAssistant() {
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.EMEA;
        quote.Scenario__c = 2;
        quote.Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
        quote.Related_Account__c = testOpportunity.AccountId;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        insert quote;
        
        Test.startTest();
            Boolean result = CPQ_QuoteUtilityWO.isQuoteExist(testOpportunity.Id);
        Test.stopTest();
        System.assert(result, 'The method should return true when there is an active quote.');
    }

    @isTest
    public static void testIsPrimaryQuoteAccepted() {
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.EMEA;
        quote.Scenario__c = 2;
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        quote.Related_Account__c = testOpportunity.AccountId;
        quote.Primary__c = True;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        insert quote;
        
        Test.startTest();
            Boolean result = CPQ_QuoteUtilityWO.isPrimaryQuoteAccepted(testOpportunity.Id);
        Test.stopTest();
        System.assert(result, 'The method should return true when there is an accpeted and primary quote.');
    }
    
    @isTest
    public static void testValidateQuoteSyncWithOpportunity() {
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.EMEA;
        quote.Scenario__c = 2;
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        quote.Related_Account__c = testOpportunity.AccountId;
        quote.Primary__c = True;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        insert quote;

        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        insert prod2;   
       
        Quote_Line_Item__c qli1 = new Quote_Line_Item__c(
            Quote__c = quote.Id,
            Bundle_Product__c = prod2.Id,
            Quantity__c = 1
        );
        insert qli1;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(prod2.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(testOpportunity.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Agreement_Line_Item_Id__c = qli1.Id;
        insert oppLineItem;
        
        Test.startTest();
            Map<Id, String> result = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(new set<Id>{testOpportunity.Id});
        Test.stopTest();
        System.assertEquals('Error:NonEMEAEligibleOpportunity',  result.get(testOpportunity.Id), 'Quote Line Items and Opportunity Line Items should not sync.');
    }

    @isTest
    public static void testCheckForRecordLock() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Approval.lock(quote.Id);
        Test.startTest();
        	String result = CPQ_QuoteUtilityWO.checkForRecordLock(quote.Id);
        Test.stopTest();
        Assert.areEqual('Success', result, 'Record should be unlocked');
    }

    @IsTest
    static void testIqviaQuoteCloneWithOpportunity() {
        List<Opportunity> testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 2];
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.EMEA;
        quote.Scenario__c = 2;
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        quote.Related_Account__c = testOpportunity[0].AccountId;
        quote.Primary__c = True;
        quote.Related_Opportunity__c = testOpportunity[0].Id;
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        insert quote;
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        insert prod2;   
        Quote_Line_Item__c qli1 = new Quote_Line_Item__c(
            Quote__c = quote.Id,
            Bundle_Product__c = prod2.Id,
            Quantity__c = 1
        );
        insert qli1;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(prod2.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(testOpportunity[0].Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Agreement_Line_Item_Id__c = qli1.Id;
        oppLineItem.Product2Id = prod2.Id;
        oppLineItem.Revenue_Start_Date__c = Date.today();
        oppLineItem.Revenue_End_Date__c = Date.today().addYears(1);
        insert oppLineItem;
        Map<Id,Id> oppMap= new Map<Id,Id>();
        oppMap.put(testOpportunity[0].Id,testOpportunity[1].Id);
        Test.startTest();
            Map<Id, String> result = CPQ_QuoteUtilityWO.iqviaQuoteCloneForMultipleOpportunities(oppMap);
        Test.stopTest();
        System.assertEquals('Success',  result.get(testOpportunity[1].Id));
    }

    @isTest
    static void testCreateQLIFromOLI() {
        List<Opportunity> testOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        insert prod2;  
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(prod2.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(testOpportunity[0].Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Product2Id = prod2.Id;
        oppLineItem.Revenue_Start_Date__c = Date.today();
        oppLineItem.Revenue_End_Date__c = Date.today().addYears(1);
        insert oppLineItem;
        
        Test.startTest();
            Quote_Line_Item__c qli = CPQ_QuoteUtilityWO.createQLIFromOLI(oppLineItem);
        Test.stopTest();
        
        Assert.isNOtNull(qli, 'QLI should be created');
    }
    
    @isTest 
    static void testQuoteLineItemsFromQuote() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', CON_CPQ.BUNDLE, 'Q_111813', 'US', 'Go Blue');
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('Tablet Initiation', CON_CPQ.OPTION, 'CES_2076D', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT SERVICES', CON_CPQ.BUNDLE, 'CES_2077H', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod2);
        insert prodList;
        
        Quote_Line_Item__C testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Option_Product__c = prodList[1].Id;
        insert testQLI;
        
        Test.startTest();
        List<CPQ_QuoteUtilityWO.QuoteLineItemWrapper> wrappers = CPQ_QuoteUtilityWO.getQuoteLineItemDetails(new Set<Id>{quote.Id});
        Test.stopTest();
        
        System.assertEquals(1, wrappers.size(), 'WrapperNotCreated' );
    }
}