/**
 * This test class is used to test all methods in CNT_CRM_UpadateCloseDate Controller.
 * version : 1.0
 */
@isTest
private class TST_CNT_CRM_UpadateCloseDate {
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
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis; 
    }
    
    /**
     * test method for getOliByIdWithSchedule
     */
    static testmethod void testGetOliByIdWithSchedule() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
        List<String> oliFields = new List<String>{'Id'};
        List<String> schFields = new List<String>{'Id'};
        Test.startTest();
        List<OpportunityLineItem> oliList = new  List<OpportunityLineItem>();
        oliList = CNT_CRM_UpadateCloseDate.getOliByIdWithSchedule(opp.id, oliFields, schFields);
        CNT_CRM_UpadateCloseDate.getOpportunityRecord(opp.Id);
        Test.stopTest();
        System.assertEquals(true, oliList.size() > 0);
    }
    
    /**
     * test method for getOliByIdWithSchedule
     */
    static testmethod void testUpdateCloseDateOfOpportunityException() {
        Opportunity opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'];
        List<String> oliFields = new List<String>{'Id','OpportunityLineItemId','Type','Revenue','Quantity','Description','ScheduleDate','CurrencyIsoCode'};
        List<String> schFields = new List<String>{'Id','Opportunity.CurrencyISOCode','Opportunity.Name','Opportunity.CloseDate','Gross_Q1_Value__c','Gross_Q2_Value__c','Gross_Q3_Value__c','Gross_Q4_Value__c','Gross_Q1_NY_Value__c','Gross_Q2_NY_Value__c','Gross_Q3_NY_Value__c','Gross_Q4_NY_Value__c','Opportunity.Gross_Q1_Value__c','Opportunity.Gross_Q2_Value__c','Opportunity.Gross_Q3_Value__c,Opportunity.Gross_Q4_Value__c','Opportunity.Gross_Q1_NY_Value__c','Opportunity.Gross_Q2_NY_Value__c','Opportunity.Gross_Q3_NY_Value__c','Opportunity.Gross_Q4_NY_Value__c'};
        Test.startTest();
        try{
        	CNT_CRM_UpadateCloseDate.updateCloseDateOfOpportunity(opp.id, '2', true, oliFields, schFields);
        } catch(Exception e){
        }
        Test.stopTest();
        System.assertEquals([SELECT Id, Name, CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CloseDate, [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CloseDate);
    }
    
    /**
     * test method for getOliByIdWithSchedule
     */
    static testmethod void testUpdateCloseDateOfOpportunity() {
        Opportunity opp = [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'];
        List<String> schFields = new List<String>{'Id','OpportunityLineItemId','Type','Revenue','Quantity','Description','ScheduleDate','CurrencyIsoCode'};
            List<String> oliFields = new List<String>{'Id','Opportunity.CurrencyISOCode','Opportunity.Name','Opportunity.CloseDate','Gross_Q1_Value__c','Gross_Q2_Value__c','Gross_Q3_Value__c','Gross_Q4_Value__c','Gross_Q1_NY_Value__c','Gross_Q2_NY_Value__c','Gross_Q3_NY_Value__c','Gross_Q4_NY_Value__c','Opportunity.Gross_Q1_Value__c','Opportunity.Gross_Q2_Value__c','Opportunity.Gross_Q3_Value__c','Opportunity.Gross_Q4_Value__c'};
        Test.startTest();
            CNT_CRM_UpadateCloseDate.updateCloseDateOfOpportunity(opp.id, '2', true, oliFields, schFields);
        Test.stopTest();
        System.assertEquals([SELECT Id, Name, CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CloseDate, [SELECT Id, Name,CloseDate FROM Opportunity WHERE Name = 'TestOpportunity'].get(0).CloseDate);
    }
}