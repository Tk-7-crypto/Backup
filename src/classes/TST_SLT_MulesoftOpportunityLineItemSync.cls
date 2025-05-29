/*
 * Version       : 1.0
 * Description   : test class for MulesoftOpportunitySync selector
 */
@isTest
private class TST_SLT_MulesoftOpportunityLineItemSync {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
    }
    
    /**
    * test method to test selectById
    */  
    static testmethod void testselectById() {
        OpportunityLineItem oli = [SELECT id FROM OpportunityLineItem Limit 1];
        Test.startTest();
            List<Mulesoft_OpportunityLineItem_Sync__c> oliSyncList = new SLT_MulesoftOpportunityLineItemSync().selectById(new Set<Id>{oli.Id});
            oliSyncList = new SLT_MulesoftOpportunityLineItemSync().selectByOLIIds(new Set<Id>{oli.Id});
        Test.stopTest();
        
    }
}