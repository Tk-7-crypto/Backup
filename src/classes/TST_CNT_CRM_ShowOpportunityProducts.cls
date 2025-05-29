@isTest
private class TST_CNT_CRM_ShowOpportunityProducts {
    
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
        bs.Excluded_Products__c = 'ZQUI|test';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        upsert mulesoft;
        Account acc = UTL_TestData.createAccount();
        insert acc;
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
     * test method
     */
    @isTest
    static void test1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity Opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oppLineItem = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
            BNF2__c bnfRecord = UTL_TestData.createBNFRecord(opp, oppLineItem, addressList, revenueAnalyst.Id);
            insert bnfRecord;
            System.currentPageReference().getParameters().put('id', bnfRecord.Id);
            new CNT_CRM_ShowOpportunityProducts(new ApexPages.StandardController(bnfRecord));
            new CNT_CRM_ShowOpportunityProductsMDM(new ApexPages.StandardController(bnfRecord));
            new CNT_CRM_ShowOpportunityProductsU(new ApexPages.StandardController(bnfRecord));
        Test.stopTest();
    }

}