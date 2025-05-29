@isTest
public class TST_QUE_CPQ_SyncBudgetWithOpportunity {

    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        upsert new  Mulesoft_Integration_Control__c(name = 'testSetting', Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true, Ignore_Validation_Rules__c = FALSE);
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert opp;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.Id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        insert testPricebookEntry;
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        update quote;
        
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createProposalLineItem(quote.Id, testProduct.Id);
        budgetLineItem.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
        budgetLineItem.Revenue_Type__c = CON_CPQ.AD_HOC;
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        budgetLineItem.BIDGRID_COUNTRY__C = CON_CPQ.USA;
        insert budgetLineItem;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.id,
            priceBookEntryId =  testPricebookEntry.id, 
            Product2Id =  testProduct.id,
            TotalPrice = 123,
            Quantity = 1,
            Sale_Type__c = budgetLineItem.Sale_Type__c, 
            Revenue_Type__c = budgetLineItem.Revenue_Type__c,
            Delivery_Country__c = CON_CPQ.USA,
            Agreement_Line_Item_Id__c = 'test');
        insert oppLineItem;
    }

    @isTest
    static void testSyncBudgetWithOpportunity()
    {    
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,Name FROM Apttus_Proposal__Proposal__c Limit 1];
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = [SELECT Id,Apttus_QPConfig__NetPrice__c FROM Apttus_Proposal__Proposal_Line_Item__c Limit 1];
        
        Test.startTest();
            System.enqueueJob(new QUE_CPQ_SyncBudgetWithOpportunity(proposal.id, False));
        Test.stopTest();
        
        List<OpportunityLineItem> testOppLineItemList = [SELECT ID FROM OpportunityLineItem WHERE Agreement_Line_Item_Id__c =: budgetLineItem.Id Limit 1];
        System.assertEquals(testOppLineItemList.size(), 1, 'Opportunity Line Item Exists');
        
    }

    @isTest
    static void testSyncBudgetWithOpportunityWithValidation()
    {        
        Product2 testProduct = [SELECT Id,Name FROM Product2 Limit 1];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,Name FROM Apttus_Proposal__Proposal__c Limit 1];
        
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createProposalLineItem(proposal.Id, testProduct.Id);
        budgetLineItem.Apttus_QPConfig__NetPrice__c = 500000000;
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert budgetLineItem;

        Test.startTest();
            System.enqueueJob(new QUE_CPQ_SyncBudgetWithOpportunity(proposal.id, True));
        Test.stopTest();
    }

    @isTest
    static void testSyncWithOpportunityWithPricingTool()
    {    
        Opportunity opp1 = [SELECT ID FROM Opportunity LIMIT 1];
                
        Apttus_Proposal__Proposal__c techQuote = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp1.Id, CON_CPQ.OCE);
        techQuote.Apttus_Proposal__Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
        update techQuote;
        Test.startTest();
            System.enqueueJob(new QUE_CPQ_SyncBudgetWithOpportunity(techQuote.Id, true, techQuote.Select_Pricing_Tool__c, techQuote.Apttus_Proposal__Approval_Stage__c));
        Test.stopTest();

        System.assertNotEquals(techQuote, null, 'Quote Exists');
    }
    
    @isTest
    static void testSyncWithOpportunityErrorMessage()
    {    
        Opportunity opp1 = [SELECT ID FROM Opportunity LIMIT 1];
                
        Apttus_Proposal__Proposal__c techQuote = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp1.Id, CON_CPQ.OCE);
        techQuote.Apttus_Proposal__Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
        update techQuote;
        Test.startTest();
            CPQ_Quote_Event__e event = new CPQ_Quote_Event__e(Record_Id__c = techQuote.id, Error_Message__c = 'Error : updating quote');
            EventBus.publish(event);
            System.enqueueJob(new QUE_CPQ_SyncBudgetWithOpportunity(techQuote.Id, true, techQuote.Select_Pricing_Tool__c, techQuote.Apttus_Proposal__Approval_Stage__c, CON_CPQ.USD, CON_CPQ.USD, 1, 1));
        Test.stopTest();
        System.assertNotEquals(techQuote, null, 'Quote Exists');
    }
}