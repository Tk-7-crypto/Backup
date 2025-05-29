@isTest
public class TST_OpportunityLineItemWrapper {
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
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
    static testmethod void test1() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
        OpportunityLineItemWrapper oliWrapper = new OpportunityLineItemWrapper(oli[0]);
        oliWrapper = new OpportunityLineItemWrapper(oli[0], 'Delete');
    }
}