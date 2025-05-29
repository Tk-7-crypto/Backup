/*
 * Version       : 1.0
 * Description   : This test class is used for Select ProposalLineItems
 */
@isTest
private class TST_SLT_ProposalLineItems {
     
     /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;  
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.OCE);			 

        Apttus_Proposal__Proposal_Line_Item__c quoteLineItem = UTL_TestData.createQuoteLineItem(quote.Id);
        quoteLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        quoteLineItem.Startup_Phase__c = true;
        quoteLineItem.Unit_Name__c = 'Remote EDC Review';
        quoteLineItem.Role__c = CON_CPQ.CRA;
        quoteLineItem.Apttus_QPConfig__OptionId__c = null;
        insert quoteLineItem;
    }
    
    @IsTest
    static void testSelectByQuoteIds() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByQuoteId(quote.Id);
        Test.stopTest();
        
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');
    } 

    @IsTest
    static void testSelectByProposalIdsAndIQVIAType() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByProposalIdsAndIQVIAType(
            	new Set<Id> {quote.Id}, aliFieldSet, CON_CPQ.CRM_Product);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');
		
    }
	
    @IsTest
    static void testSelectByProposalIdsAndPhases() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID,CON_CPQ.CURRENCYISOCODE,CON_CPQ.COUNTRY};
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByProposalIdsAndPhases(
            	new Set<Id> {quote.Id}, aliFieldSet);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');

    } 
    @IsTest
    static void testSelectByProposalIdsAndUnitName() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByProposalIdsAndUnitName(
            	new Set<Id> {quote.Id}, aliFieldSet);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');

    } 
    
    @IsTest
    static void testSelectByProposalIdsAndUnitNames() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID,CON_CPQ.CURRENCYISOCODE,CON_CPQ.COUNTRY};
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = [SELECT Id, Unit_Name__c FROM Apttus_Proposal__Proposal_Line_Item__c LIMIT 1];
        proposalLineItem.Unit_Name__c = 'Internal Meetings';
        update proposalLineItem;
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByProposalIdsAndUnitNames(
                new Set<Id> {quote.Id}, aliFieldSet, new Set<String> {'Internal Meetings'}, new Set<String> {'Internal Meetings'}, new Set<String> {'Project Initial Training'}, CON_CPQ.CRA);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');

    }
    
    @IsTest
    static void testSelectByProposalIdsAndUnitCodes() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> aliFieldSet = new Set<String> {CON_CPQ.ID};
        String condition = ' Apttus_Proposal__Proposal__c IN :parentIdsSet ';
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().selectByProposalIdsAndUnitCodes(
                new Set<Id> {quote.Id}, aliFieldSet, new Set<String> {}, condition);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');
    }
    
    @IsTest
    static void testGetLineItemCountByBudgetId() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
            
        Test.startTest();
            List<AggregateResult> aggResList = new SLT_ProposalLineItems().getLineItemCountByBudgetId(new Set<Id> {quote.Id});
        Test.stopTest();
        System.assertEquals(aggResList.size()>0, true, 'aggResList exists');
    }
    
    @IsTest
    static void testgetProposalLineItemsByQuoteId() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
            
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().getProposalLineItemsByQuoteId(new Set<Id> {quote.Id}, fieldSet);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size()>0, true, 'quoteLineItem exists');
    }
	
    @IsTest
    static void testgetProposalLineItemsWithAttributesByQuoteId() {
        
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        Set<String> optionCodes = new Set<String>{'OCEP_SUB_CS','OCEP_SUB_AS'};
        Set<String> bundleCodes = new Set<String>{'CES_1448A'};
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS CORPORATE SEAT', 'Option', 'OCEP_SUB_CS', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.isActive = true;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS ADMIN SEAT', 'Option', 'OCEP_SUB_AS', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.isActive = true;
        prodList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod3.CanUseRevenueSchedule = true;
        prod3.isActive = true;
        prodList.add(prod3);
        insert prodList;
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for(Product2 p : prodList){
            PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(p.Id);
        	testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
            priceBookEntryList.add(testPricebookEntry);
        }
        insert priceBookEntryList;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 2000, Apttus_QPConfig__OptionId__c= prodList[0].Id, Apttus_Proposal__Quantity__c = 1));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 3000, Apttus_QPConfig__OptionId__c= prodList[1].Id, Apttus_Proposal__Quantity__c = 1));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 5000, Apttus_Proposal__Product__c= prodList[2].Id, Apttus_Proposal__Quantity__c = 1));
		insert proposalLineItemList;
        
        List<Apttus_QPConfig__ProposalProductAttributeValue__c> attributeList = new List<Apttus_QPConfig__ProposalProductAttributeValue__c>();
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[0].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[1].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[2].Id));
        insert attributeList;
        
        proposalLineItemList[0].Apttus_QPConfig__AttributeValueId__c = attributeList[0].Id;
        proposalLineItemList[1].Apttus_QPConfig__AttributeValueId__c = attributeList[1].Id;
        proposalLineItemList[2].Apttus_QPConfig__AttributeValueId__c = attributeList[2].Id;
        update proposalLineItemList;
        Test.startTest();
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem = new SLT_ProposalLineItems().getProposalLineItemsWithAttributesByQuoteId(new Set<Id> {quote.Id}, fieldSet, optionCodes, bundleCodes);
        Test.stopTest();
        System.assertEquals(quoteLineItem.size() > 0, true, 'Records Exists');
    }
    @isTest
    static void testGetPLIByCreatedDateDescending() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
            
        Test.startTest();
            Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = new SLT_ProposalLineItems().getPLIByCreatedDateDescending(new Set<String>{CON_CPQ.ID}, proposal.Id);
        Test.stopTest();
        System.assertEquals(proposalLineItem != null, true, 'proposalLineItem exists');
    }
}
