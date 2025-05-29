/**
 * This test class is used to test all methods in opportunity trigger.
 * version : 1.0
 */
@isTest
private class TST_TGR_OpportunityRenewals_OwnerCountry {
    
    /** 
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account testAccount = new Account(Name = 'TestAccount', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE'); 
        insert testAccount; 
        Opportunity testOpportunity = new Opportunity(Name = 'TestOpportunity', accountId = testAccount.id, 
                                                      stageName = CON_CRM.IDENTIFYING_OPP_STAGE, 
                                                      CloseDate = System.today().addYears(1), Probability = 10);
        insert testOpportunity; 
        
        Renewal_Task__c rt = new Renewal_Task__c();
        rt.CurrencyIsoCode = 'USD';
        rt.Price_Increase__c = 5;
        rt.Cloning_Action__c = 	'No Renew' ; 
        rt.Cloning_Status__c = 'No Renew' ; 
        rt.No_Renew_Reason__c = 'No Renew' ; 
        rt.ownerId = userInfo.getUserId();
        rt.Owner_Country__c = 'India';
        rt.Targeted_Close_Date__c = System.today();
        rt.Opportunity__c = testOpportunity.id;
        //oppIdSet.add(testOpportunity.id);
        insert rt ;
        
    }
    
    /**
     * This test method used for insert opportunity record
     */
    @isTest
    static void testRenewalTaskInsert() {   
        List<Renewal_Task__c> renewal = [SELECT Id, Name FROM Renewal_Task__c WHERE Name = 'Test Renewal'];
        Integer expected = 1;
        Integer actual = renewal.size();
        //System.assertEquals(expected, actual);
    }    
}