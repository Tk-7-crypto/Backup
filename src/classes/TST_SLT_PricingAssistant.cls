@isTest
public class TST_SLT_PricingAssistant {
    @testSetup
       static void dataSetup() {    
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Opportunity_Number__c = '124';
        opp.Legacy_Quintiles_Opportunity_Number__c = '12';
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.LI_Opportunity_Id__c = 'scrapId';
        insert opp;
   }  
    @isTest
    static void testGetPricingAssistantRecord() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        String oppid = opp.id;
        Test.startTest();
        List<PC_Pricing_Calculator__x> paList = SLT_PricingAssistant.getPricingAssistantRecord(oppid);
        Test.stopTest();
    }
      
}