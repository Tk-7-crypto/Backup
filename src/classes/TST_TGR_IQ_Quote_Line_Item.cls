@isTest
public class TST_TGR_IQ_Quote_Line_Item {
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
        quote1.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote1.GBU__c = CON_CPQ.GBU_DPS;
        quote1.Related_Opportunity__c = testOpportunity.Id;
        quote1.Related_Account__c = acc.Id;
        insert quote1;
        
        Quote_Line_Item__c quoteLineItem = new Quote_Line_Item__c();
        quoteLineItem.Quote__c = quote1.id;
        insert quoteLineItem;
    }
    
    @isTest
    static void testOnAfterDelete() {
        Quote_Line_Item__c qli = [Select id from Quote_Line_Item__c limit 1];
        Test.startTest();
            Delete qli;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Quote_Line_Item__c limit 1], 'Quote Line Item should be deleted');
    }
    
}