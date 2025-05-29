@IsTest
public class TST_DAO_IQ_Quote {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;
        
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('DPS - USD');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
       
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.CurrencyIsoCode = 'USD';
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        insert quote;
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
       
        Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
        budget.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent;
        budget.RecordTypeId = recordType.Id;
        budget.Apttus_Proposal__Account__c = acc.Id;
        budget.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        budget.IQVIA_Quote__c = quote.Id;
        budget.CurrencyIsoCode = 'USD';
        insert budget;
        
        CPQ_Proposal_Create_Settings__c customSettingsObjforDPS = UTL_TestData.createCPQProposalCreateSettings(CON_CPQ.Complete_Consent, 'CPQ_RDS_DPS_ReadWrite', CON_CPQ.Complete_Consent , true, 'DPS - USD', false);
        customSettingsObjforDPS.Conga_Setup__c = true;
        customSettingsObjforDPS.FX_Rate_Type__c = CON_CPQ.MONTHLY;
        insert customSettingsObjforDPS;
        
        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  CON_CPQ.NAMESPACE_PREFIX;
        cus1.Package_Namespace_Prefix__c = CON_CPQ.CONGA_PACKAGE_NAMESPACE_PREFIX;
        cus1.Document_Package_Namespace_Prefix__c = 'Apttus';
        insert cus1;
        
        List<Currency_Exchange_Rates__c> currencyRateList = new List<Currency_Exchange_Rates__c>();
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate.Conversion_rate__c = 0.9281;
        currencyRate.Iso_Code__c = CON_CPQ.USD;
        currencyRateList.add(currencyRate);
        Currency_Exchange_Rates__c currencyRate1 = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate1.Conversion_rate__c = 1.9281;
        currencyRate1.Iso_Code__c = 'EGP';
        currencyRateList.add(currencyRate1);
        insert currencyRateList;
        
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT LICENSES', CON_CPQ.BUNDLE, 'US_DD_STUDLIC', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        insert prod;
        
        Quote_Line_Item__c testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Bundle_Product__c = prod.Id;
        testQLI.Country__c = CON_CPQ.USA;
        testQLI.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        testQLI.Start_Date__c = Date.today();
        testQLI.End_Date__c = Date.Today().addMonths(3);
        testQLI.BasePrice__c = 100;
        testQLI.Discount_Amount__c = 10;
        testQLI.CurrencyIsoCode = CON_CPQ.USD;
        insert testQLI;

        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Quote__c iqviaQuote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, clinicalBid.Id, CON_CPQ.UNIT_PRICING_TOOL, 'RDS SF', false);
        iqviaQuote.Approval_Stage__c = CON_CPQ.DRAFT;
        iqviaQuote.Quote_Type__c = CON_CPQ.PROJECT_SPECIFIC;
        iqviaQuote.CurrencyIsoCode = CON_CPQ.USD;
        iqviaQuote.Number_of_Line_Items__c = 2;
        insert iqviaQuote;
    }
    @isTest
    static void testOnBeforeUpdate() {
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c WHERE GBU__c =: CON_CPQ.GBU_DPS LIMIT 1];
        Apttus_Config2__PriceList__c pl2 = TST_TestGeneratorClass.buildTestPriceList('DPS - EGP');
        pl2.Migration_Id__c = 'PL-13';
        insert pl2;
        
        Test.startTest();
            quote.CurrencyIsoCode = 'EGP';
            update quote;
        Test.stopTest();
         
        Apttus_Proposal__Proposal__c proposal1 = [SELECT Id, IQVIA_Quote__c, CurrencyIsoCode, Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c WHERE IQVIA_Quote__c =:quote.Id  LIMIT 1];
        System.assertEquals(pl2.Id, proposal1.Apttus_QPConfig__PriceListId__c);
    }

    @isTest
    static void testvalidateQuoteStage() {
        Quote__c quote = [SELECT Id,Approval_Stage__c  FROM Quote__c WHERE GBU__c = 'RDS SF' LIMIT 1];
        Test.startTest();
            quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
            try {
                update quote;
            } Catch(Exception e) {
                Boolean expectedExceptionThrown =  (e.getMessage().contains('The Opportunity is either at stage 7b-lost or stage should be 5 or higher to Accept the Budget.')) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
            }
        Test.stopTest();
    }
}