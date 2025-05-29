@isTest
private class TST_CNT_CPQ_RelatedListController {

    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = CON_CPQ.AL;
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.CLINICAL;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        insert testOpportunity;
        
        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        insert quote;

        Quote_Requisites__c quoteRequiste = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.COUNTRY_INPUT, false);
        quoteRequiste.Site__c = 'Indianapolis - ADME';
        quoteRequiste.Start_Date__c = Date.today();
        quoteRequiste.End_Date__c = Date.today().addDays(7);
        insert quoteRequiste;

        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', CON_CPQ.BUNDLE, 'Q_111813', 'US', 'Go Blue');
        prodList.add(prod);
        insert prodList;

        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Bundle_Product__c = prodList[0].Id;
        qli.Quote__c = quote.Id;
        insert qli;
    }

    @isTest
    static void testGetColumns() {
        Test.startTest();
        List<CNT_CPQ_RelatedListController.MappingsWrapper> result = CNT_CPQ_RelatedListController.getColumns(CON_CPQ.TIMELINE, CON_CPQ.Complete_Consent);
        Test.stopTest();
        Assert.areNotEqual(null, result.size(), 'Expected result should not be null');
        Assert.areEqual(CON_CPQ.TIMELINE, result[0].quoteRequisiteType, 'Expected output is not returned');
        Assert.areNotEqual(null, result[0].columnWrapper.label, 'Expected result should not be null');
        Assert.areNotEqual(null, result[0].columnWrapper.fieldName, 'Expected result should not be null');
        Assert.areNotEqual(null, result[0].columnWrapper.type, 'Expected result should not be null');
        Assert.areNotEqual(null, result[0].columnWrapper.editable, 'Expected result should not be null');
        Assert.areNotEqual(null, result[0].orderNumber, 'Expected result should not be null');
        Assert.areNotEqual(null, result[0].isCompact, 'Expected result should not be null');
        Assert.areEqual(CON_CPQ.QUOTE_REQUISITES, result[0].objectApiName, 'Expected output is not returned');
    }

    @isTest
    static void testGetData() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            List<Quote_Requisites__c> result = CNT_CPQ_RelatedListController.getData(quote.Id, new List<String>{CON_CPQ.NAME, CON_CPQ.TYPE}, CON_CPQ.COUNTRY_INPUT, CON_CPQ.QUOTE_REQUISITES);
        Test.stopTest();
        Assert.areNotEqual(0, result.size(), 'The expected output is not returned');
    }

    @IsTest
    static void testUpdateRecords() {
        Quote_Requisites__c quoteRequiste = [SELECT Id FROM Quote_Requisites__c LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.FINALIZED;
        quoteRequiste.End_Date__c = Date.today().addDays(10);
        Test.startTest();
            Boolean result = CNT_CPQ_RelatedListController.updateRecords(new List<Quote_Requisites__c>{quoteRequiste}, CON_CPQ.QUOTE_REQUISITES);
            update quote;
            quoteRequiste.Document_Language__c = 5;
            try {
                CNT_CPQ_RelatedListController.updateRecords(new List<Quote_Requisites__c>{quoteRequiste}, CON_CPQ.QUOTE_REQUISITES);
            } catch (Exception e){
                Assert.isNotNull(e.getMessage(), 'The expected output is not returned');
            }
        Test.stopTest();
        Assert.isTrue(result, 'Expected result to be true');
    }

    @IsTest
    static void testGetQLIsAndUpdatQLIs() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            List<CNT_CPQ_RelatedListController.QuoteLineItemWrapper> quoteLineItemWrapperList = CNT_CPQ_RelatedListController.getQLIs(quote.Id);
            Assert.isTrue(quoteLineItemWrapperList.size() > 0, 'It must have returned QLIs');
            quoteLineItemWrapperList[0].startDate = String.valueOf(System.today());
            quoteLineItemWrapperList[0].revenueType = 'Subscription';
            quoteLineItemWrapperList[0].salesType = 'New';
            quoteLineItemWrapperList[0].country = 'USA';
            quoteLineItemWrapperList[0].listPrice = 200;
            quoteLineItemWrapperList[0].discountAmount = 100;
            quoteLineItemWrapperList[0].discountPercent = 50;
            String result = CNT_CPQ_RelatedListController.updateQLIs(JSON.serialize(quoteLineItemWrapperList));
            Assert.areEqual('Success', result, 'return message should be success');
        Test.stopTest();
    }
}