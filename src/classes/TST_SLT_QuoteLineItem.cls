/*
* Version       : 0.0.1
* Description   : This Apex class is test class of selector layer for QuoteLineItem
* Created By    : Danish khan
* Created For   : SLT_QuoteLineItem
*/
@isTest
public class TST_SLT_QuoteLineItem {
    
    @testSetup
    static void dataSetup(){
        Account testAccount = UTL_TestData.createAccount();
        testAccount.Name = 'Test Acc1';
        insert testAccount;
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        testOpportunity.CloseDate = System.today();
        insert testOpportunity;
        
        Product2 product1 = new Product2();
        product1.IsActive = true;
        product1.Name = 'Test Bundle';
        product1.ProductCode = 'CPQ-Bundle';
        product1.Apttus_Config2__ConfigurationType__c = 'Bundle';
        insert product1;

        Product2 product11 = new Product2();
        product11.IsActive = true;
        product11.Name = 'Test Option';
        product11.ProductCode = 'CPQ-TS-AMESA-Data-PI-FSN';
        product11.Apttus_Config2__ConfigurationType__c = CON_CPQ.OPTION;
        insert product11;
        
        Quote__c testQuote = new Quote__c(Pricing_Tools__c = CON_CPQ.Complete_Consent);
        testQuote.Start_Date__c = System.today();
        testQuote.Related_Opportunity__c = testOpportunity.Id;
        testQuote.GBU__c = CON_CPQ.GBU_DPS;
        testQuote.Related_Account__c = testAccount.Id;
        insert testQuote;

        Quote_Line_Item__C testQLI = new Quote_Line_Item__C(Quote__c = testQuote.Id);
        testQLI.Pricing_Tool__c = CON_CPQ.Complete_Consent;
        testQLI.Bundle_Product__c = product1.Id;
        testQLI.Country__c = 'LB';
        testQLI.Option_Product__c = product11.Id;
        insert testQLI;
    }
    @isTest
    static void test() {
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID};
        Quote_Line_Item__C qli = [SELECT Id FROM Quote_Line_Item__C WHERE Pricing_Tool__c =: CON_CPQ.Complete_Consent AND Country__c = 'LB'];
        Quote__c quoteRecord = [SELECT Id FROM Quote__c WHERE Pricing_Tools__c =: CON_CPQ.Complete_Consent];
        String condition = ' Id = \'' + qli.Id + '\'';

        Test.startTest();
            new SLT_QuoteLineItem().getQuoteLineItemRecords(new Set<Id>{qli.Id}, fieldSet);
            new SLT_QuoteLineItem().selectedQuoteLineItemRecords(condition, fieldSet);
            new SLT_QuoteLineItem().getQuoteLineItemByPricingTools(condition, fieldSet, new Set<String>{'CPQ-TS-AMESA-Data-PI-FSN'}, new Set<String>{'CPQ-Bundle'}, new List<String>{CON_CPQ.AMESA});
            new SLT_QuoteLineItem().getPricingToolByQuoteLineItemRecords(quoteRecord.Id,new List<String>{CON_CPQ.Complete_Consent});
        Test.stopTest();
    }

    @isTest
    static void testGetQuoteLineItemByQuoteId() {
        Quote__c quoteRecord = [SELECT Id FROM Quote__c LIMIT 1];

        Test.startTest();
            List<Quote_Line_Item__c> qliList = new SLT_QuoteLineItem().getQuoteLineItemByQuoteId(new Set<Id>{quoteRecord.Id}, CON_CPQ.QUOTE_LINE_ITEM_FIELD_SET);
        Test.stopTest();

        Assert.areEqual(true, qliList.size() > 0, 'It should have retuned quote line items');
    }
}