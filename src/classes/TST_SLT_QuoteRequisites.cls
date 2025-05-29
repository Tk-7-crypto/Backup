@isTest
public class TST_SLT_QuoteRequisites {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        insert testOpportunity;

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.Approval_Stage__c = 'Draft';
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;  

        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;

        Quote_Requisites__c quoteRequisites = new Quote_Requisites__c();
        quoteRequisites.Quote__c = quote.Id;
        quoteRequisites.Country__c = 'Mexico';
        quoteRequisites.Study_Number__c = '1';
        quoteRequisites.Service_Line_Product__c = prod.Id;
        quoteRequisites.Type__c = 'Quote Sections';
        quoteRequisites.Site__c = 'Indianapolis - ADME';
        quoteRequisites.Species_Global__c = 'Baboon';
        insert quoteRequisites;
    }

    @isTest static void testGetQuoteRequisitesByQuoteId() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Set<Id> quoteIdSet = new Set<Id>{quote.Id};
        String condition = 'Quote__c IN: quoteIdSet';

        Test.startTest();
            List<Quote_Requisites__c> countryInputList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteId(quoteIdSet, new Set<String>{'Id', 'Country__c'}, condition);
        Test.stopTest();

        System.assertEquals(true, countryInputList.size() > 0);
    }

    @isTest static void testGetQuoteRequisitesById() {
        Quote_Requisites__c quoteReq = [SELECT Id FROM Quote_Requisites__c LIMIT 1];
        Set<Id> idSet = new Set<Id>{quoteReq.Id};

        Test.startTest();
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesById(idSet, new Set<String>{'Id', 'Country__c'});
        Test.stopTest();

        System.assertEquals(true, quoteReqList.size() > 0);
    }

    @isTest static void testGetQuoteRequisitesByStudyNumber() {
        String studyNumber = '1';
        String condition = 'Study_Number__c =: studyNumber';

        Test.startTest();
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByStudyNumber(studyNumber, null, new Set<String>{'Id', 'Type__c', 'Study_Number__c'}, condition);
        Test.stopTest();

        System.assertEquals(true, quoteReqList.size() > 0);
    }

    @isTest
    static void testGetQuoteRequisitesByQuoteIdAndCartParams() {
        Test.startTest();
            Set<String> fieldSet = new Set<String>{'Site__c', 'Service_Line_Product__c'};
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            Set<String> serviceLineNameSet = new Set<String>{prod.Id};
            Set<String> studyNumberSet = new Set<String>{'1'}; 
            String condition = 'Service_Line_Product__c IN :serviceLineNameSet AND Study_Number__c IN:studyNumberSet'; 
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesByQuoteIdAndCartParams(fieldSet, condition, studyNumberSet, serviceLineNameSet);
        Test.stopTest();
        System.assertEquals(1, quoteReqList.size(), 'The number of records returned should match the number of test records added');
    }
    
    @isTest 
    static void testGetQuoteRequisitesRecord() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        String condition = 'Quote__c = \'' + quote.Id + '\'' + 'AND Service_Line_Product__c != Null';
        Test.startTest();
            List<Quote_Requisites__c> quoteReqList = new SLT_QuoteRequisites().getQuoteRequisitesRecord(null, new Set<String>{CON_CPQ.ID, CON_CPQ.SERVICE_LINE, CON_CPQ.BID_HISTORY_STUDY_NUMBER}, condition);
        Test.stopTest();
        System.assertEquals(true, quoteReqList.size() > 0);
    }
}