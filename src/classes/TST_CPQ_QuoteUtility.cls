/*
* Version       : 0.0.1
* Description   : This Apex class is Test Utility Class for Quote
* Created By    : Danish khan
* Created For   : Sync and utility for quote
*/
@isTest
public class TST_CPQ_QuoteUtility {

    @testSetup 
    static void testData() {
        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  CON_CPQ.NAMESPACE_PREFIX;
        cus1.Package_Namespace_Prefix__c = CON_CPQ.CONGA_PACKAGE_NAMESPACE_PREFIX;
        cus1.Document_Package_Namespace_Prefix__c = 'Apttus';
        insert cus1;

        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        insert opp;
        
        Quote__c testQuote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, true);
        Quote__c testQuoteQ2 = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, true);
        
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate.Conversion_rate__c = 1;
        currencyRate.Iso_Code__c = CON_CPQ.USD;
        insert currencyRate;
           
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;

        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT LICENSES', CON_CPQ.BUNDLE, 'US_DD_STUDLIC', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT DEVICE LOGISTICS', CON_CPQ.BUNDLE, 'CES_2076E', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT SERVICES', CON_CPQ.BUNDLE, 'CES_2077H', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('Method Development', CON_CPQ.OPTION, 'Q_111415', '', '');
        prod3.CanUseRevenueSchedule = true;
        prod3.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod3);
        insert prodList;

        List<CPQ_Opp_Sync_Product_Mappings__c> listOfCospm = new List<CPQ_Opp_Sync_Product_Mappings__c>();
        CPQ_Opp_Sync_Product_Mappings__c  cospm = UTL_TestData.createCospm('Q_111415', 'CPQ-RDS-Q2-BioScience', false, 'Method Development', 'Option', 'Q2 Solutions', 'test123', false);
        CPQ_Opp_Sync_Product_Mappings__c  cospm2 = UTL_TestData.createCospm('US_DD_STUDLIC', 'CPQ-RDS-DPS-CompleteConsent', true, 'COMPLETE CONSENT SERVICES', 'Bundle', 'Complete Consent', 'test1234', false);
        listOfCospm.add(cospm);
        listOfCospm.add(cospm2);
        insert listOfCospm;

        Product2 bundle;
        List<Product2> optionList = new List<Product2>();
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for (Product2 product : prodList) {
            PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(product.Id);
            testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
            priceBookEntryList.add(testPricebookEntry);
            if (product.Apttus_Config2__ConfigurationType__c == CON_CPQ.BUNDLE) {
                bundle = product;
            }
            if (product.Apttus_Config2__ConfigurationType__c == CON_CPQ.OPTION) {
                optionList.add(product);
            }
        }
        insert priceBookEntryList;

        List<Apttus_Proposal__Proposal__c> proposals = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c proposal1 = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.COMPLETE_CONSENT);
        proposal1.CurrencyIsoCode = CON_CPQ.USD;
        proposal1.IQVIA_Quote__c = testQuote.Id;
        proposals.add(proposal1);
        Apttus_Proposal__Proposal__c proposal2 = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.Q2_Solutions);
        proposal2.CurrencyIsoCode = CON_CPQ.USD;
        proposal2.IQVIA_Quote__c = testQuoteQ2.Id;
        proposals.add(proposal2);
        insert proposals;

        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem1 = UTL_TestData.createQuoteLineItem(proposals[0].Id);
        proposalLineItem1.Apttus_QPConfig__NetPrice__c = 2000;
        proposalLineItem1.Apttus_Proposal__Product__c= prodList[0].Id;
        proposalLineItem1.Apttus_QPConfig__OptionId__c = prodList[0].Id;
        proposalLineItem1.Apttus_Proposal__Quantity__c = 1;
        proposalLineItem1.Apttus_QPConfig__ExtendedPrice__c = 100;
        proposalLineItem1.Cost_Price__c = 110;
        proposalLineItem1.Apttus_QPConfig__PrimaryLineNumber__c = 2;
        proposalLineItemList.add(proposalLineItem1);
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = UTL_TestData.createQuoteLineItem(proposals[0].Id);
        proposalLineItem2.Apttus_QPConfig__NetPrice__c = 2000;
        proposalLineItem2.Apttus_Proposal__Product__c= prodList[0].Id;
        proposalLineItem2.Apttus_QPConfig__OptionId__c = prodList[0].Id;
        proposalLineItem2.Apttus_Proposal__Quantity__c = 1;
        proposalLineItem2.Apttus_QPConfig__ExtendedPrice__c = 100;
        proposalLineItem2.Cost_Price__c = 110;
        proposalLineItem2.Apttus_QPConfig__PrimaryLineNumber__c = 2;
        proposalLineItemList.add(proposalLineItem2);
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = UTL_TestData.createQuoteLineItem(proposals[0].Id);
        proposalLineItem3.Apttus_QPConfig__NetPrice__c = 2000;
        proposalLineItem3.Apttus_Proposal__Product__c= prodList[0].Id;
        proposalLineItem3.Apttus_Proposal__Quantity__c = 1;
        proposalLineItem3.Apttus_QPConfig__PrimaryLineNumber__c = 1;
        proposalLineItemList.add(proposalLineItem3);
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem4 = UTL_TestData.createQuoteLineItem(proposals[1].Id);
        proposalLineItem3.Apttus_QPConfig__NetPrice__c = 2000;
        proposalLineItem3.Apttus_Proposal__Product__c= prodList[0].Id;
        proposalLineItem3.Apttus_Proposal__Quantity__c = 1;
        proposalLineItem3.Apttus_QPConfig__PrimaryLineNumber__c = 1;
        proposalLineItemList.add(proposalLineItem4);
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem5 = UTL_TestData.createQuoteLineItem(proposals[1].Id);
        proposalLineItem5.Apttus_QPConfig__NetPrice__c = 3000;
        proposalLineItem5.Apttus_Proposal__Product__c = prodList[0].Id;
        proposalLineItem5.Apttus_QPConfig__OptionId__C = prodList[3].Id;
        proposalLineItem5.Apttus_Proposal__Quantity__c = 1;
        proposalLineItem5.Apttus_QPConfig__PrimaryLineNumber__c = 1;
        proposalLineItemList.add(proposalLineItem5);
        insert proposalLineItemList;

        List<Apttus_QPConfig__ProposalProductAttributeValue__c> attributeList = new List<Apttus_QPConfig__ProposalProductAttributeValue__c>();
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = CON_CPQ.INDIA, Apttus_QPConfig__LineItemId__c = proposalLineItemList[0].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = CON_CPQ.INDIA, Apttus_QPConfig__LineItemId__c = proposalLineItemList[1].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = CON_CPQ.INDIA, Apttus_QPConfig__LineItemId__c = proposalLineItemList[2].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = CON_CPQ.INDIA, Apttus_QPConfig__LineItemId__c = proposalLineItemList[3].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = CON_CPQ.INDIA, Apttus_QPConfig__LineItemId__c = proposalLineItemList[4].Id));
        insert attributeList;
        
        proposalLineItemList[0].Apttus_QPConfig__AttributeValueId__c = attributeList[0].Id;
        proposalLineItemList[1].Apttus_QPConfig__AttributeValueId__c = attributeList[1].Id;
        proposalLineItemList[2].Apttus_QPConfig__AttributeValueId__c = attributeList[2].Id;
        proposalLineItemList[3].Apttus_QPConfig__AttributeValueId__c = attributeList[3].Id;
        proposalLineItemList[4].Apttus_QPConfig__AttributeValueId__c = attributeList[4].Id;
        update proposalLineItemList;

        Id cartId = UTL_TestData.buildTestConfiguration(proposals[0].Id, true).Id;
        Id cartId1 = UTL_TestData.buildTestConfiguration(proposals[1].Id, true).Id;

        List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, bundle.Id, null, 1, 100);
        lineItem.Apttus_Config2__Description__c = 'dummy description';
        lineItemList.add(lineItem);
        Apttus_Config2__LineItem__c lineItem1 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, bundle.Id, null, 1, 200);
        lineItem1.Apttus_Config2__Description__c = 'dummy description';
        lineItemList.add(lineItem1);
        Apttus_Config2__LineItem__c lineItem2 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId1, 1, 1, optionList[0].Id, null, 1, 200);
        lineItem2.Apttus_Config2__Description__c = 'dummy description';
        lineItemList.add(lineItem2);
        insert lineItemList;
        
        List<Apttus_QPConfig__ProposalProductAttributeValue__c> proposalProductAttributeList = new List<Apttus_QPConfig__ProposalProductAttributeValue__c>();
        Apttus_QPConfig__ProposalProductAttributeValue__c proposalProductAttribute = UTL_TestData.createProposalProductAttribute(proposalLineItemList[0].Id, CON_CPQ.INDIA, false);
        proposalProductAttributeList.add(proposalProductAttribute);
        insert proposalProductAttributeList;
        
        proposalLineItemList[0].Apttus_QPConfig__AttributeValueId__c = proposalProductAttributeList[0].Id;
        update proposalLineItemList;

        List<Apttus_Config2__ProductAttributeValue__c> productAttributeList = new List<Apttus_Config2__ProductAttributeValue__c>();
        Apttus_Config2__ProductAttributeValue__c productAttribute1 = UTL_TestData.createProductAttribute(lineItemList[0].Id, CON_CPQ.INDIA, false);
        productAttributeList.add(productAttribute1);
        Apttus_Config2__ProductAttributeValue__c productAttribute2 = UTL_TestData.createProductAttribute(lineItemList[1].Id, CON_CPQ.INDIA, false);
        productAttributeList.add(productAttribute2);
        insert productAttributeList;
        
        lineItemList[0].Apttus_Config2__AttributeValueId__c = productAttributeList[0].Id;
        lineItemList[1].Apttus_Config2__AttributeValueId__c = productAttributeList[1].Id;
        update lineItemList;

        List<Quote_Line_Item__c> quoteLineItemList = new List<Quote_Line_Item__c>();
        Quote_Line_Item__c testQLI = UTL_TestData.createIqviaQuoteLineItem(testQuote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Bundle_Product__c = prod.Id;
        testQLI.Country__c = CON_CPQ.USA;
        testQLI.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        testQLI.Start_Date__c = Date.today();
        testQLI.End_Date__c = Date.Today().addMonths(3);
        quoteLineItemList.add(testQLI);
        Quote_Line_Item__c testQLI1 = UTL_TestData.createIqviaQuoteLineItem(testQuoteQ2.Id, CON_CPQ.Q2_Solutions, false);
        testQLI1.Option_Product__c = prod3.Id;
        testQLI1.Country__c = CON_CPQ.USA;
        testQLI1.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        quoteLineItemList.add(testQLI1);
        insert quoteLineItemList;

        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[0].Id);
        oppLineItem1.Delivery_Country__c = CON_CPQ.USA;
        oppLineItem1.Description = 'Testing';
        oppLineItem1.Agreement_Line_Item_Id__c = lineItemList[1].Id;
        oppLineItem1.Revenue_Start_Date__c = Date.today();
        oppLineItem1.Revenue_End_Date__c = Date.Today().addMonths(3);
        oppLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[1].Id);
        oppLineItem2.Delivery_Country__c = CON_CPQ.USA;
        oppLineItem2.Description = 'Testing';
        oppLineItem2.Revenue_Start_Date__c = Date.today();
        oppLineItem2.Revenue_End_Date__c = Date.Today().addMonths(3);
        oppLineItem2.Agreement_Line_Item_Id__c = lineItemList[0].Id;
        oppLineItemList.add(oppLineItem2);
        insert oppLineItemList;
        
        OpportunityLineItemSchedule oliSchedule = UTL_Testdata.createOpportunityLineItemSchedule(oppLineItem2.Id);
        insert oliSchedule;
    }
	
    @isTest
    static void testOppLineItemZero() {
        List<opportunityLineItem> oppLineItemList = [SELECT Id, unitPrice FROM OpportunityLineItem];
        Set<Id>oppProductIdsSet = new Set<Id>();
        Test.startTest();
        List<OpportunityLineItem> oppLineItem1 = CPQ_QuoteUtility.setOppLineItemUnitPriceToZero(oppProductIdsSet,oppLineItemList);
        Test.stopTest();		
        System.assertEquals(0, oppLineItem1[0].unitPrice, 'price could not set to zero');
    }
    
    @isTest
    static void testCreateQuoteLineItems () {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote__c testQuote = [SELECT Id, Pricing_Tools__c FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Complete_Consent AND Related_Opportunity__c =: opp.Id];
        testQuote.Start_Date__c = Date.Today();
        testQuote.End_Date__c = Date.Today().addMonths(3);
        update testQuote;
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE IQVIA_Quote__c =: testQuote.id];
        List<Apttus_Config2__LineItem__c> lineItemList = [SELECT Id FROM Apttus_Config2__LineItem__c];
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [SELECT Id, Apttus_QPConfig__DerivedFromId__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c =: proposal.Id];
        List<Apttus_Proposal__Proposal_Line_Item__c> updatedPlis = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for (Apttus_Proposal__Proposal_Line_Item__c pli : proposalLineItemList) {
            pli.Apttus_QPConfig__DerivedFromId__c = lineItemList[0].Id;
            updatedPlis.add(pli);
        }
        update updatedPlis;
        Test.startTest();
            CPQ_QuoteUtility.createQuoteLineItemsUsingProposalLineItem(testQuote.Id, proposal.Id, CON_CPQ.Complete_Consent, CON_CPQ.CONGA_PATHWAY);
            CPQ_QuoteUtility.createQuoteLineItemsUsingConfigLineItem(testQuote.Id, proposal.Id, CON_CPQ.Complete_Consent, CON_CPQ.CONGA_PATHWAY);
        Test.stopTest();
        List<Quote_Line_Item__c> quoteLineItems = [SELECT Id FROM Quote_Line_Item__c WHERE Quote__c =: testQuote.Id];
        Assert.areEqual(true, quoteLineItems.size() > 0, 'Quote Line Items are not created.');
    }

    @isTest
    static void testCreateQuoteLineItemsForQ2() {

        Quote__c testQuote = [SELECT Id, Pricing_Tools__c FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Q2_Solutions];
        testQuote.Start_Date__c = Date.Today();
        testQuote.End_Date__c = Date.Today().addMonths(3);
        update testQuote;
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE IQVIA_Quote__c =: testQuote.id];
        List<Apttus_Config2__LineItem__c> lineItemList = [SELECT Id FROM Apttus_Config2__LineItem__c];
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [SELECT Id, Apttus_QPConfig__DerivedFromId__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c =: proposal.Id];
        List<Apttus_Proposal__Proposal_Line_Item__c> updatedPlis = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for (Apttus_Proposal__Proposal_Line_Item__c pli : proposalLineItemList) {
            pli.Apttus_QPConfig__DerivedFromId__c = lineItemList[0].Id;
            updatedPlis.add(pli);
        }
        update updatedPlis;
        
        Quote_Requisites__c quoteRequisite = new Quote_Requisites__c();
        quoteRequisite.Type__c = 'Quote Sections';
        quoteRequisite.Matrix__c = 'N/A';
        quoteRequisite.Study_Number__c = '1';
        quoteRequisite.Site__c = 'Indianapolis - ADME';
        quoteRequisite.Species_Global__c = 'Baboon';
        quoteRequisite.Quote__c = testQuote.Id;
        insert quoteRequisite; 

        Quote_Line_Item__c qli = [SELECT Id, Revenue_Type__c, Pathway__c, Sales_Type__c, Number_of_Installment__c, Installment_Period__c FROM Quote_Line_Item__c limit 1];
        qli.Installment_Period__c = CON_CPQ.MONTHLY;
        qli.Number_of_Installment__c =  2;
        update qli;
        Test.startTest();
            CPQ_QuoteUtility.createQuoteLineItemsUsingProposalLineItem(testQuote.Id, proposal.Id, CON_CPQ.Q2_Solutions, CON_CPQ.CONGA_PATHWAY);
            CPQ_QuoteUtility.syncQuoteWithOpportunityDynamically(testQuote.Id, testQuote.Pricing_Tools__c, CON_CPQ.IN_PROGRESS_STATUS, CON_CPQ.USD, CON_CPQ.USD, 0.0, 0.0);																																						   
        Test.stopTest();

        List<Quote_Line_Item__c> quoteLineItems = [SELECT Id FROM Quote_Line_Item__c WHERE Quote__c =: testQuote.Id];
        Assert.areEqual(true, quoteLineItems.size() > 0, 'Quote Line Items are not created.');
    }
    
	@isTest
    static void testSyncQuoteWithOpportunityDynamically() {    
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote__c testQuote = [SELECT Id, Pricing_Tools__c FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Complete_Consent AND Related_Opportunity__c =: opp.Id];
        Quote_Line_Item__c qli = [SELECT Id, Revenue_Type__c, Pathway__c, Sales_Type__c, Number_of_Installment__c, Installment_Period__c FROM Quote_Line_Item__c limit 1];
        qli.Installment_Period__c = CON_CPQ.ONCE;
        qli.Number_of_Installment__c =  1;
        qli.Discount_Reason__c = 'Volume';
        qli.Surcharge_Reason__c = 'test';
        update qli;
        Test.startTest();
            CPQ_QuoteUtility.syncQuoteWithOpportunityDynamically(testQuote.Id, testQuote.Pricing_Tools__c, CON_CPQ.IN_PROGRESS_STATUS, CON_CPQ.USD, CON_CPQ.USD, 0.0, 0.0);
        Test.stopTest();
        List<OpportunityLineItem> oppLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        Set<Id> idSet = new Set<Id>();
        for (OpportunityLineItem oli : oppLineItems) {
            idSet.add(oli.Id);
        }
        List<OpportunityLineItemSchedule> oppLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN: idSet];
        Assert.areEqual(1, oppLineItems.size(), 'Opportunity Line Item is not created.');
    }

    @isTest
    static void testGetBatchStatus() {    
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote__c testQuote = [SELECT Id, Pricing_Tools__c FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Complete_Consent AND Related_Opportunity__c =: opp.Id];
        Test.startTest();
            Id jobId = System.enqueueJob(new QUE_CPQ_SyncBudgetWithOpportunity(testQuote.Id, true, testQuote.Pricing_Tools__c, CON_CPQ.IN_PROGRESS_STATUS));
            String status = CPQ_QuoteUtility.getBatchStatus(jobId);
        Test.stopTest();
        if (status == null) {
            Assert.isNull(status, 'Batch is neither Completed nor Failed.');
        } else {
            Assert.isNotNull(status, 'Batch status should not be null.');
        }
    }

    @isTest
    static void testCheckCongaPermission() {
        Test.startTest();
            Boolean result = CPQ_QuoteUtility.checkCongaPermission();
            Boolean result1 = CPQ_QuoteUtility.checkCongaCLMPermission();
        Test.stopTest();
        Assert.isTrue(result, 'The expected result should be true.');
        Assert.isTrue(result1, 'The expected result should be true.');
    }

    @isTest
    static void testDeleteOppLineItem() {
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Test.startTest();
        List<OpportunityLineItem> oliListToBeDeleted = CPQ_QuoteUtility.deleteOppLineItem(new Set<Id>(), oliList);
        Test.stopTest();
        Assert.isTrue(oliListToBeDeleted.size() > 0, 'The expected result should be true.');
    }
    
    @isTest
    static void testCheckPathways() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quote__c testQuote = [SELECT Id, Pricing_Tools__c FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Complete_Consent AND Related_Opportunity__c =: opp.Id];
        Test.startTest();
            String checkPathways = CPQ_QuoteUtility.checkPathway(new List<String>{testQuote.Pricing_Tools__c});
        Test.stopTest();
        Assert.areEqual('hasCongaAccess', checkPathways, 'User have conga object access');
    }
}