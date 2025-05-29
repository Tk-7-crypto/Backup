@isTest
public class TST_CNT_CPQ_ChevronStage {

    @testSetup
    static void dataSetUp() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp= UTL_TestData.createOpportunity(acc.id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert opp;
        
        Quote__c quote = UTL_TestData.createQuote(false);
        quote.Related_Opportunity__c = opp.Id;
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Account__c = acc.Id;
        insert quote;
    }
    
    @isTest
    static void testGetPickListValues() {
        Quote__c quote = [Select ID, GBU__c  from Quote__c LIMIT 1];
        Test.startTest();
            List<String> chevronStagesList = CNT_CPQ_ChevronStage.getPicklistValues(quote.Id);
        Test.stopTest();
        Assert.areNotEqual(chevronStagesList.size(), 0, 'Chevron Stages fetched');
    }
	
	@isTest
    static void testGetCurrentAndPreviousStage() {
        Quote__c quote = [Select ID, GBU__c, Approval_Stage__c  from Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.IN_PROGRESS_STATUS;
        update quote;
  
        Test.startTest();
        List<Field_History__c> listOfFHistoryData = CNT_CPQ_ChevronStage.getCurrentAndPreviousStage(quote.Id);
        Test.stopTest();

        Assert.areEqual(listOfFHistoryData[0].New_Value__c, 'In-Progress', 'Current Stage fetched');
    }
    @isTest
    static void testGetCurrentAndPreviousStage2() {
        Quote__c quote = [Select ID, GBU__c, Approval_Stage__c, Related_Opportunity__c, Pricing_Tools__c, Related_Account__c  from Quote__c LIMIT 1];
        Quote__c quoteData = new Quote__c();
        quoteData = quote.clone();
        insert quoteData;
  
        Test.startTest();
        List<Field_History__c> listOfFHistoryData = CNT_CPQ_ChevronStage.getCurrentAndPreviousStage(quoteData.Id);
        Test.stopTest();

        Assert.areEqual(listOfFHistoryData[0].New_Value__c, CON_CPQ.DRAFT, 'Current Stage should be Draft');
    }
}