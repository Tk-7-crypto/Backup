/*
* Version       : 1.0
* Description   : Test class for Opportunity Wrapper Class  
*/
@isTest
private class TST_OpportunityWrapper {
    
    /**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        insert oppLineItem;
    }
    
    /**
* test method to test constructors of OpportunityWrapper class
*/  
    static testmethod void testOpportunityWrapper() {
        //OpportunitySplit splitRecord, String operationType
        Opportunity opportunityRecord = new Opportunity();
        List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList = new List<OpportunityWrapper.OpportunitySplitWrapper>();
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItemScheduleWrapper> olischWrapperList = new List<OpportunityLineItemScheduleWrapper>();
        OpportunitySplit splitRecord = new OpportunitySplit();
        String operationType = 'edit';
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        OpportunityLineItemSchedule schRecord = new OpportunityLineItemSchedule();
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper est = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, System.today(), 100, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DAILY, 5, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE);
        Test.startTest();
        OpportunityWrapper oppWrapper = new OpportunityWrapper();
        oppWrapper = new OpportunityWrapper(opportunityRecord, oppSplitWrapperList, oppTeamMemberList);
        oppWrapper = new OpportunityWrapper(oliWrapperList);
        oppWrapper = new OpportunityWrapper(oliWrapperList,2,2);
        oppWrapper = new OpportunityWrapper(olischWrapperList);
        OpportunityWrapper.OpportunitySplitWrapper splitWrapper = new OpportunityWrapper.OpportunitySplitWrapper();
        splitWrapper = new OpportunityWrapper.OpportunitySplitWrapper(splitRecord, operationType);
        OpportunityLineItemWrapper olitWrapper = new OpportunityLineItemWrapper(oli);
        OpportunityLineItemScheduleWrapper olistWrapper = new OpportunityLineItemScheduleWrapper(schRecord, operationType);
        oppWrapper = new OpportunityWrapper(opportunityRecord,null,oppTeamMemberList,2,2);
        Test.stopTest();
    }
}