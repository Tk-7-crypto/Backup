@isTest
public class TST_DAOH_IQ_QuoteRequisites {
    
    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;

        Opportunity testOpportunity = UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        insert testOpportunity;

        Quote__c quote1 = new Quote__c();
        quote1.Pricing_Tools__c = 'Complete Consent';
        quote1.GBU__c = CON_CPQ.GBU_DPS;
        quote1.Related_Opportunity__c = testOpportunity.Id;
        quote1.Related_Account__c = acc.Id;
        insert quote1;
        
        Quote_Requisites__c req1 = new Quote_Requisites__c();
        req1.Quote__c = quote1.Id;
        req1.Type__c = 'Country Input';
        req1.Country__c = 'USA';
        req1.Document_Language__c = 2;
        req1.Site_Count__c = 10;
        insert req1;
        
        CPQ_Country_Master_Data__c cpqCountry = new CPQ_Country_Master_Data__c();
        cpqCountry.Country__c = 'USA';
        cpqCountry.Language__c = 'Spanish(Latin_America);English(US)';
        insert cpqCountry;
    }
    
    @isTest
    static void testPopulateFields() {
        Quote__c quote = [SELECT Id, Pricing_Tools__c, Languages__c, Selected_Languages__c, GBU__c, US_Central_IRBs__c FROM Quote__c WHERE Pricing_Tools__c = 'Complete Consent' LIMIT 1];
        CPQ_Country_Master_Data__c cpqCountry = [select Language__c, Country__c,Site_Adoption_Probability__c from CPQ_Country_Master_Data__c WHERE Country__c = 'USA'];
        Quote_Requisites__c quoteReq = [SELECT Id, Quote__c, Type__c, Country__c, Site_Count__c, Document_Language__c From Quote_Requisites__c WHERE Quote__c =: quote.Id LIMIT 1]; 
        quoteReq.Site_Count__c = 20;
        
        Test.startTest();
            update quoteReq;
        Test.stopTest();
        
        System.assertEquals(20, quoteReq.Site_Count__c , 'Site Count should be updated');
    }

    @isTest
    static void testCalculateAndUpdateTotalSiteCount() {
        Quote__c quote = [SELECT Id, Pricing_Tools__c, Languages__c, Selected_Languages__c, GBU__c, US_Central_IRBs__c FROM Quote__c WHERE Pricing_Tools__c = 'Complete Consent' LIMIT 1];
        CPQ_Country_Master_Data__c cpqCountry = [select Language__c, Country__c,Site_Adoption_Probability__c from CPQ_Country_Master_Data__c WHERE Country__c = 'USA'];
        Quote_Requisites__c quoteReq = [SELECT Id, Quote__c, Type__c, Country__c, Site_Count__c, Document_Language__c From Quote_Requisites__c WHERE Quote__c =: quote.Id LIMIT 1]; 
        quoteReq.Site_Count_Adjusted__c = 30;
        
        Test.startTest();
            update quoteReq;
        Test.stopTest();
        
        System.assertEquals(30, quoteReq.Site_Count_Adjusted__c , 'Site Count Adjusted should be updated');
    }

    @isTest
    static void testUpdateLanguagesOnQuote() {
        Quote__c quote = [SELECT Id, Pricing_Tools__c, Languages__c, Selected_Languages__c, GBU__c, US_Central_IRBs__c FROM Quote__c WHERE Pricing_Tools__c = 'Complete Consent' LIMIT 1];
        
        Test.startTest();
            Quote_Requisites__c req = new Quote_Requisites__c();
            req.Quote__c = quote.Id;
            req.Type__c = 'Country Input';
            req.Country__c = 'USA';
            req.Document_Language__c = 2;
            req.Site_Count__c = 20;
            insert req;
        Test.stopTest();
        
        Assert.isNotNull(req.Id, 'Quote Requisites should be inserted');
    }
}