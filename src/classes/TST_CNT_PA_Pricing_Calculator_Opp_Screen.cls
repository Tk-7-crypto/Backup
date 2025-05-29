/*
* Name              : TST_CNT_PA_Pricing_Calculator_Opp_Screen
* Created By        : Mahima Gupta
* Created Date      : 15 April, 2019
* Revision          : 
* Description       : Test Class for CNT_PA_Pricing_Calculator_Opp_Screen apex class
*/

@isTest
private class TST_CNT_PA_Pricing_Calculator_Opp_Screen {

    @testSetup
    static void setupTestData(){
        Opportunity NewOpportunity = new Opportunity (Name='Test Opp');
        NewOpportunity.StageName = '2 - Verify Opportunity';
        NewOpportunity.CloseDate = System.today();
        NewOpportunity.Budget_Available__c = 'Yes';
        NewOpportunity.CurrencyIsoCode = 'USD';
        insert NewOpportunity;
    }
    
     testmethod static void testgetPricingError() {
        
        Opportunity testOpportunity = [select id from opportunity limit 1];
        
        Test.startTest();
         Map<String, String> pricingError = CNT_PA_Pricing_Calculator_Opp_Screen.getPricingErrors(testOpportunity.id);
        Test.stopTest();
         //System.debug('pricingError' + pricingError);
         System.assertEquals('["Opportunity Does not exist on Lagacy IMS Side."]', pricingError.get('errorMessages'));
    }
    
    testmethod static void testgetPricingError2() {
        
        Opportunity testOpportunity = [select id from opportunity limit 1];
        testOpportunity.Exclude_from_Pricing_Assistant__c = true;
        update testOpportunity;
        
        Test.startTest();
         Map<String, String> pricingError = CNT_PA_Pricing_Calculator_Opp_Screen.getPricingErrors(testOpportunity.id);
         CNT_PA_Pricing_Calculator_Opp_Screen.cancelActiveQuotes(testOpportunity.id); 
        Test.stopTest();
         //System.debug('pricingError' + pricingError) 
         System.assertNotEquals('["Opportunity Does not exist on Lagacy IMS Side."]', pricingError.get('errorMessages'));
    }
}