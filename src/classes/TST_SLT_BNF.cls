/*
 * Version       : 1.0
 * Description   : Test Class for SLT_BNF
 */
@isTest
private class TST_SLT_BNF {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
		crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        upsert mulesoft;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
    }
    
    /**
     * This method used to test sobject field list
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [Select Id, AccountId, Opportunity_Number__c FROM Opportunity Limit 1];
        OpportunityLineItem oppLineItem = [Select Id, TotalPrice FROM OpportunityLineItem Limit 1];
        Set<Id> oppIdSet = new Set<Id>{opp.Id}; 
        Test.startTest();
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        BNF2__c bnfRecord = UTL_TestData.createBNFRecord(opp, oppLineItem, addressList, revenueAnalyst.Id);
        bnfRecord.CurrencyIsoCode = 'INR';
        insert bnfRecord; 
        new SLT_BNF().selectByFilter(new Set<Id>(), new Set<String>{'Id'}, 'Opportunity__c IN :oppIdSet');
        new SLT_BNF().selectById(new Set<Id>(), new Set<String>{'Id'});
        Test.stopTest();
    }
}