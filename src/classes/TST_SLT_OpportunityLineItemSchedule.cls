/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunityLineItemSchedule
 */
@isTest
public class TST_SLT_OpportunityLineItemSchedule {

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
    
    /**
     * This method used to Select OpportunityLineItems by opportunitylineitem id
     */    
    @IsTest
    static void testSelectByOpportunityId() {
        OpportunityLineItem oli = [SELECT id FROM OpportunityLineItem LIMIT 1];
        Set<Id> oliIdset = new Set<Id>{oli.Id};
        Set<String> oliFieldSet = new Set<String> {'Id'};
        Test.startTest();
		    List<OpportunityLineItemSchedule> olisList = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(oliIdset, oliFieldSet);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = olisList.size();
        System.assertEquals(expected, actual);
	}
}