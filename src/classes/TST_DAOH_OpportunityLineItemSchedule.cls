/**
 * This test class is used to test all methods for opportunity line item schedule trigger helper.
 * version : 1.0
 */
@isTest
private class TST_DAOH_OpportunityLineItemSchedule {

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
        upsert new RWEStudyProduct__c(Name='Q_100339', Product_Code__c='Q_100339');
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true,SetupOwnerId = UserInfo.getOrganizationId());
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.LI_Opportunity_Id__c = '0661234567890';
        opp.Proposal_Sent_Date__c = System.today() - 1 ;
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode = 'Test01';
        product.Material_Type__c = 'ZQUI';
        product.ZQUI_Product__c = true;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        PrivacyAnalyticsProductCode__c papc = new PrivacyAnalyticsProductCode__c();
        papc.Name = 'Test01';
        papc.Product_Code__c = 'Test01';
        insert papc;
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
		insert userList;
        OpportunityTeamMember otm = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert otm;
        Group gp = new Group();
        gp.Name = 'Platform Analytics Sales Group';
        insert gp;
        System.runAs(userList[0]) {
            GroupMember gm = UTL_TestData.createGroupMember(gp.Id, userList[0].Id);
            insert gm;
        }
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        System.runAs(userList[0]) {  
            insert oppLineItem;
        }
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