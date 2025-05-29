/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunitySplit
 */
@isTest
private class TST_SLT_OpportunitySplit {

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
     * This method used to Select Opportunity by opportunity id set
     */    
    @IsTest
    static void testSelectByOppId() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> fieldSet = new Set<String> {'Id'};
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        Test.startTest();
            List<OpportunitySplit> opportunitySplitList = new SLT_OpportunitySplit().selectByOpportunityId(oppIdSet, CON_CRM.SPLIT_TYPE_NAME, fieldSet);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = opportunitySplitList.size();
        System.assertEquals(expected, actual);
    }
}