/*
* Version       : 1.0
* Description   : Test Class for SRV_CRM_OpportunityLineItem
*/
@isTest
public class TST_SRV_CRM_OpportunityLineItem {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
		crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
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
        OpportunityLineItemSchedule olisch = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olisch;
    }
    
    /**
    * test method to get field Details of Product Object
    */  
    static testmethod void testGetListOfOLI() {
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        Set<String> fieldSet = new Set<String>{'Name', 'Id'}; 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = new Set<Id> {opp.Id};
        Test.startTest();
        	List<OpportunityLineItem> oliList = SRV_CRM_OpportunityLineItem.getListOfOLI(oppIdSet, fieldSet);
            Set<Id> oliIdSet = new Set<Id> {opp.Id};
            SRV_CRM_OpportunityLineItem.getOpportunityLineItemsDetail(oliIdSet, fieldSet);
            Set<String> oliFields = new Set<String>{'Id'};
            Set<String> schFields = new Set<String>{'Id'};
        	SRV_CRM_OpportunityLineItem.getOliByIdWithSchedule(oppIdSet, oliFields, schFields);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oliList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get field Details of Product Object with exception
     */  
    static testmethod void testGetListOfOLIException() {
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        Set<String> fieldSet = new Set<String>{'Name', 'Ids'}; 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> oppIdSet = new Set<Id> {opp.Id};
        Test.startTest();
            try {
                List<OpportunityLineItem> oliList = SRV_CRM_OpportunityLineItem.getListOfOLI(oppIdSet, fieldSet);
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_OpportunityLineItem.SRV_CRM_OpportunityLineItem_Exception', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
    * test method to update oli record
    */  
    static testmethod void testUpdateOliRecords() {
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        String action = CON_CRM.EDIT_LABEL;
        List<OpportunityLineItem> oliList = [SELECT Id, Description FROM OpportunityLineItem LIMIT 1];
        oliList[0].Description = 'Tested';
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oliList[0], 'edit');
        oliWrapperList.add(oliWrapper);
        Test.startTest();
        	SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapperList);
        	oliList = [SELECT Id, Description FROM OpportunityLineItem LIMIT 1];
        Test.stopTest();
        String expected = 'Tested';
        String actual = oliList[0].Description;
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to update oli record exception
     */  
    static testmethod void testUpdateOliRecordsException() {
        String objectName = 'Opportunit';
        String action = CON_CRM.EDIT_LABEL;
        List<OpportunityLineItem> oliList = [SELECT Id, TotalPrice FROM OpportunityLineItem LIMIT 1];
        oliList[0].TotalPrice =  null;
        oliList[0].UnitPrice =  null;
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oliList[0], 'create');
        oliWrapperList.add(oliWrapper);
        Test.startTest();
            try {
                SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapperList);
                system.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_OpportunityLineItem.SRV_CRM_OpportunityLineItem_Exception', ex.getTypeName());
            }
        Test.stopTest();
    }
    
    /**
    * test method to update oli record
    */  
    static testmethod void testCreateOliRecords1() {
        Test.startTest();
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        String action = CON_CRM.CREATE_LABEL;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Sale_Type__c = 'New';
        oppLineItem.Revenue_Type__c = 'Subscription';
        insert oppLineItem;
        OpportunityLineItemSchedule olisch = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olisch;
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, PriceBookEntryId, Description, Quantity, TotalPrice, Delivery_Country__c, Sale_Type__c ,Revenue_Type__c, (Select Id, Revenue, Type, Description, ScheduleDate from OpportunityLineItemSchedules) FROM OpportunityLineItem Where Id = :oppLineItem.Id];
        oliList[0].Id = null;
        oliList[0].OpportunityLineItemSchedules[0].Id = null;
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oliList[0], action);
        oliWrapper.revSchWrapperList[0].operationType = action;
        oliWrapperList.add(oliWrapper);
        
        	SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapperList);
        	oliList = [SELECT Id, Description FROM OpportunityLineItem LIMIT 1];
        Test.stopTest();
    }
    
    /**
    * test method to create oli record
    */  
    static testmethod void testCreateOliRecords() {
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        String action = CON_CRM.CREATE_LABEL;
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, PricebookEntryId FROM OpportunityLineItem LIMIT 1];
        Id oppId = oliList[0].OpportunityId;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(oppId, oliList[0].PricebookEntryId);
        oliList.clear();
        oliList.add(oli);
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oliList[0], 'create');
        oliWrapperList.add(oliWrapper);
        Test.startTest();
        	SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapperList);
        	oliList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: oppId];
        Test.stopTest();
        Integer expected = 2;
        Integer actual = oliList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
    * test method to delete oli record
    */  
    //updateOliRecords(List<OpportunityLineItem> oliList, String objectName, String action)
    static testmethod void testDeleteOliRecords() {
        String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
        String action = CON_CRM.DELETE_LABEL;
        List<OpportunityLineItem> oliList = [SELECT Id, Description FROM OpportunityLineItem LIMIT 1];
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oliList[0], 'delete');
        oliWrapperList.add(oliWrapper);
        Test.startTest();
        	SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapperList);
        	oliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        Test.stopTest();
        Integer expected = 0;
        Integer actual = oliList.size();
        System.assertEquals(expected, actual);
    }
}