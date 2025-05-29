@isTest
public class TST_SLT_BillingScheduleItem {
    
    @testSetup
    public static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 prod = UTL_TestData.createProduct();
        insert prod;
        PricebookEntry pe = UTL_TestData.createPricebookEntry(prod.Id);
        insert pe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pe.Id);
        insert oli;
    }
    
    @isTest
    public static void getBillingScheduleItemOliId(){
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
        Billing_Schedule__c bs = UTL_TestData.createBillingSchedule(oli.Id);
        insert bs;
        Billing_Schedule_Item__c bsi = UTL_TestData.createBillingScheduleItem(bs.Id);
        insert bsi;
        
        Test.startTest();
        List<Billing_Schedule_Item__c> bsiList = new SLT_BillingScheduleItem().getBillingScheduleItemOliId(new Set<Id>{oli.Id}, new Set<String>{'Id'});
        System.assertEquals(bsiList.size() > 0, true);
        Test.stopTest();
    }
    
}