@isTest
public class TST_TGR_QuotePlatformEvent {

    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        testOpportunity.AccountId = acc.Id;
        testOpportunity.Account = acc;
        insert testOpportunity;
        
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;
    }
    
    @IsTest
    static void testQuoteRecordPlatformEvent() {
        Quote__c quote = [SELECT Id, Execution_Message__c FROM Quote__c LIMIT 1];
        Test.startTest();
            CPQ_Quote_Event__e event = new CPQ_Quote_Event__e(
                Record_Id__c = quote.id,
                Error_Message__c = 'Error : updating quote'
            );
            EventBus.publish(event);
        Test.stopTest();
        Quote__c quote1 = [SELECT Id, Execution_Message__c FROM Quote__c LIMIT 1];
        System.assertEquals('Error : updating quote', quote1.Execution_Message__c, 'The Execution_Message__c should be updated.');
    }
}