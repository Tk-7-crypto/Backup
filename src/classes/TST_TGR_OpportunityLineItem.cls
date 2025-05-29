/**
 * This test class is used to test all methods in opportunityLineItem trigger.
 * version : 1.0
 */
@isTest
private class TST_TGR_OpportunityLineItem {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
    }
    
    /**
     * This test method used for insert opportunityLineItem record
     */
    @isTest
    static void testOpportunityInsert() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
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
        List<OpportunityLineItem> oliList = [SELECT id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(1, oliList.size());
    }
}