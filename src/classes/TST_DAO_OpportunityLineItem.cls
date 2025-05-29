/**
 * This test class is used to test all methods in opportunity trigger helper.
 * version : 1.0
 */
@isTest
private class TST_DAO_OpportunityLineItem {

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
     * This test method used for insert opportunityLineItem record
     */ 
    static testMethod void testAfterInsert() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
        Contact cnt = [SELECT id FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Offering_Group__c = CON_CRM.OFFERING_GROUP_GLOBAL_RND;
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        Test.startTest();
            OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
            insert oppLineItem;
        Test.stopTest();
        List<OpportunityLineItem> actualOppLineItem = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(2, actualOppLineItem.size());
    }
    
    /**
     * This test method used to create OutboundMessageDeletionQueue
     */ 
    static testMethod void testCreateOutboundMessageDeletionQueue() {   
        List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem];
        Test.startTest();
            delete oliList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        Test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    
    /**
     * This test method used to test before update methods of OpportunityLineItem
     */ 
    static testMethod void testBeforeUpdate() {   
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false);
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem LIMIT 1];
        oli.Delivery_Country__c = 'India';
        Test.startTest();
            upsert oli;
            oli = [SELECT Id, OpportunityLineItemSchedule_JSON__c FROM  OpportunityLineItem LIMIT 1];
        Test.stopTest();
        system.assertEquals(false, String.ISBLANK(oli.OpportunityLineItemSchedule_JSON__c));
    }
    
    /**
    * This test method used to test after update on OpportunityLineItem. 
    */
    @isTest
    public static void testAfterUpdate(){
        Product2 testProduct = [Select id from Product2 limit 1];
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem where Product2Id = : testProduct.id];
        oli.Delivery_Country__c = 'Angola';
        Test.startTest();
        update oli;
        Test.stopTest();
    }
    
     /**
    * This test method used to test after delete on OpportunityLineItem.  
    */
    @isTest
    public static void testAfterDelete(){
        Product2 testProduct = [Select id from Product2 limit 1];
        OpportunityLineItem oli = [SELECT Id, Delivery_Country__c FROM OpportunityLineItem where Product2Id = : testProduct.id];
        Test.startTest();
        delete oli;
        Test.stopTest();
    }
}