@isTest
private class TST_TGR_LineItem {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;
        
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('DPS - USD');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
       
        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        quote.Quote_Type__c = CON_CPQ.CHANGE_ORDER;
        insert quote;

        Id recordTypeId  = UTL_TestData.getProposalRecordtypeId(CON_CPQ.TECH_SOLUTION);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.createProposalData(acc.Id, testOpportunity.Id, quote.Id, recordTypeId, CON_CPQ.Complete_Consent, 'Draft', false);
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        budget.CurrencyIsoCode = CON_CPQ.USD;
        insert budget;
        Apttus_Config2__ProductConfiguration__c productConfig = UTL_TestData.createProductConfiguration(budget.Id, budget.Apttus_Proposal__Approval_Stage__c);
        insert productConfig;
    }
    
    @isTest
    static void testLineItemUpdate() {
        Id prodConfigId  = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE Name = :CON_OCE.TEST_PRODUCT_CONFIG_NAME LIMIT 1].Id;
        Product2 prod = UTL_OCE_TestData.createProduct('Test product 1', 'UAV', null, null);
        insert prod;
        Apttus_Config2__LineItem__c lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;
        lineItem = UTL_OCE_TestData.createPrimaryConfigLineItem(prodConfigId, 1, 1, prod.Id, 1, 0);
        insert lineItem;

        Test.startTest();
            lineItem.Apttus_Config2__Quantity__c = 2;
            update lineItem;
        Test.stopTest();
        System.assertEquals(2, lineItem.Apttus_Config2__Quantity__c, 'Qunatity updated' );
    }
}