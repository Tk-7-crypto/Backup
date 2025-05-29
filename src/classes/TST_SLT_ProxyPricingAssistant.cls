/*
 * Version       : 1.0
 * Description   : This test class is used for Select ProxyPricingAssistant
 */
@isTest
private class TST_SLT_ProxyPricingAssistant {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
    }

    /**
     * This method used to Select ProxyPricingAssistant by opportunity ids
     */  
    static testmethod void testselectByOpportunityIds() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> fieldSet = new Set<String>{'Id', 'PA_Status__c', 'LI_Record_Id__c', 'Opportunity__c'};
        List<Proxy_Pricing_Assistant__c> proxyPAList = null;
        Test.startTest();
            proxyPAList = new SLT_ProxyPricingAssistant().selectByOpportunityIds(new Set<Id>{opp.Id}, fieldSet);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = proxyPAList.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to Select ProxyPricingAssistant by opportunity ids
     */  
    @isTest 
    static void testGetByOpportunityIds() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity' Limit 1];
        Set<String> fieldSet = new Set<String>{'Id', 'PA_Status__c', 'LI_Record_Id__c', 'Opportunity__c'};
        List<Proxy_Pricing_Assistant__c> proxyPAList = null;
        Test.startTest();
            proxyPAList = new SLT_ProxyPricingAssistant().getByOpportunityIds(fieldSet, 'PA_Status__c != \'' + CON_CPQ.REJECTED_STATUS + '\' AND Opportunity__c IN: opportunityIdSet', new Set<Id>{opp.Id});
        Test.stopTest();
        Integer expected = 0;
        Integer actual = proxyPAList.size();
        System.assertEquals(expected, actual);
    }
}