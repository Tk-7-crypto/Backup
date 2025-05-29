@isTest
public class TST_OpportunityLineItemScheduleWrapper {
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis; 
    }
    static testmethod void testEstablishSchedule() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = system.today();
        Decimal revenue = 100;
        String scheduleType = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE;
        String installmentPeriod = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY;
        Integer noOfInstallment = 10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
        OpportunityWrapper opp = CNT_CRM_OpportunityProductSearch.establishSchedule(JSON.serialize(establishWrapper));
    }
}