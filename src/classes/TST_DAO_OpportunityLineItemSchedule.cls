/**
 * This test class is used to test all methods in opportunity line item schedule trigger helper.
 * version : 1.0
 */
@isTest
private class TST_DAO_OpportunityLineItemSchedule {

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
        User_Permissions__c us = new User_Permissions__c();
        us.Is_ZQUI_Product_Access__c = true;
        upsert us;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.LI_Opportunity_Id__c = '0661234567890';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZQUI';	
        product.ZQUI_Product__c = true;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
    }
    
    /**
     * This test method used to create OutboundMessageDeletionQueue
     */ 
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        List<OpportunityLineItemSchedule> olisList = [SELECT Id FROM OpportunityLineItemSchedule];
        Test.startTest();
            delete olisList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }  
}