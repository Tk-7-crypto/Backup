/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_OpportunityLineItemSchedule
 */
@isTest
private class TST_SRV_CRM_OpportunityLineItemSchedule {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c currentReleaseVersion=new Current_Release_Version__c(Current_Release__c ='2019.02' ,Name = 'a');
        insert currentReleaseVersion;
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
    
    /**
     * test method for getOpportunityLineItemSchedule
     */
    static testmethod void testGetOpportunityLineItemSchedule() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Set<String> oliFields = new Set<String>{'Id'};
        Set<String> schFields = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.getOpportunityLineItemSchedule(new Set<Id>{oli.Id}, oliFields, schFields);
        Test.stopTest();
        List<OpportunityLineItemSchedule> olisList = idToOliMap.get(oli.id).OpportunityLineItemSchedules;
        Integer expected = 1;
        Integer actual = olisList.size();
        system.assertEquals(expected, actual);
    }
    
    /**
     * test method for getOpportunityLineItemSchedule with Exception
     */
    static testmethod void testGetOpportunityLineItemScheduleException() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Set<String> oliFields = new Set<String>{'Id', 'Nam'};
        Set<String> schFields = new Set<String>{'Id'};
        Test.startTest();
        try {   
            Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.getOpportunityLineItemSchedule(new Set<Id>{oli.Id}, oliFields, schFields);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.SRV_CRM_OPPORTUNITYLINEITEMSCHEDULE_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    /**
     * test method for insertOLISch
     */
    static testmethod void testInsertOLISch() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = system.today();
        Decimal revenue = 100;
        String scheduleType = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DIVIDE_SCHEDULE;
        String installmentPeriod = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_QUARTERLY;
        Integer noOfInstallment = 10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
            Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.insertOLISch(establishWrapper);
            List<OpportunityLineItemSchedule> olisList = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId =: oli.Id];
        Test.stopTest();
        Integer expected = 10;
        Integer actual = olisList.size();
        system.assertEquals(expected, actual);
    }
    
    /**
     * test method for insertOLISch
     */
    static testmethod void testInsertOLISch1() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = system.today();
        Decimal revenue = 100;
        String scheduleType = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_REPEAT_SCHEDULE;
        String installmentPeriod = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_MONTHLY;
        Integer noOfInstallment = 10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
            Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.insertOLISch(establishWrapper);
            List<OpportunityLineItemSchedule> olisList = [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId =: oli.Id];
        Test.stopTest();
        Integer expected = 10;
        Integer actual = olisList.size();
        system.assertEquals(expected, actual);
    }
    
    /**
     * test method for insertOLISch with Exception
     */
    static testmethod void testInsertOLISchException() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Date startDate = null;
        Decimal revenue = -1;
        String scheduleType = null;
        String installmentPeriod = null;
        Integer noOfInstallment = -10;
        String type = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_TYPE;
        OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = new OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper(oli.Id, startDate, revenue, scheduleType, installmentPeriod, noOfInstallment, type);
        Test.startTest();
        try {   
            Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.insertOLISch(establishWrapper);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.SRV_CRM_OPPORTUNITYLINEITEMSCHEDULE_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    /**
     * test method for insertOLISch with Exception
     */
    static testmethod void testInsertOLISchException11() {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oli.Id);
        List<OpportunityLineItemScheduleWrapper> olisWrapperList = new List<OpportunityLineItemScheduleWrapper>();
        olisWrapperList.add(new OpportunityLineItemScheduleWrapper(olis, CON_CRM.DELETE_LABEL));
        Test.startTest();
        try {
            SRV_CRM_OpportunityLineItemSchedule.crudOliSchedule(olisWrapperList);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals(CON_CRM.SRV_CRM_OPPORTUNITYLINEITEMSCHEDULE_EXCEPTION, ex.getTypeName());
        }   
        Test.stopTest();
    }
    
    
    
    /**
     * test method for insertOLISch with Exception
     */
    /*static testmethod void testInsertOLISchExceptionv1() {
        Test.startTest();
        try {   
            Map<Id, OpportunityLineItem> idToOliMap = SRV_CRM_OpportunityLineItemSchedule.insertOLISch(null);
            System.assert(false);
        } catch(Exception ex) {
            System.assertEquals('System.NullPointerException', ex.getTypeName());
        }   
        Test.stopTest();
    }*/
    
    /**
     * test method for insertOLISch with Exception
     */
    static testmethod void testInsertOLISchException1() {
        Date startDate = System.today();
        Integer noOfInstallment = 10;
        Test.startTest();
            SRV_CRM_OpportunityLineItemSchedule.setDateOfOLIS(startDate, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_YEARLY, noOfInstallment);
            SRV_CRM_OpportunityLineItemSchedule.setDateOfOLIS(startDate, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_WEEKLY, noOfInstallment);
            SRV_CRM_OpportunityLineItemSchedule.setDateOfOLIS(startDate, CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_DAILY, noOfInstallment);
        Test.stopTest();
    }
}