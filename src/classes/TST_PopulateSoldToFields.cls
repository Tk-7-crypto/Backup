/*
* Version       : 1.0
* Description   : Test Class for populateSoldToFields trigger
*/
@isTest
public class TST_PopulateSoldToFields {
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
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
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
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
    }
    
    /**
    * This method used to test sobject field list
    */    
    @IsTest
    static void testpopulateSoldToFields() {
        Test.startTest();
        	Account acc = [SELECT Id FROM Account LIMIT 1];
        	MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
            List<Address__c> addressesList = UTL_TestData.createAddresses(acc);
            insert addressesList;
            MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF,addressesList);
            insert TestMIBNF_Comp;
            MIBNF_Component__c mibnfComp = [SELECT Id FROM MIBNF_Component__c LIMIT 1];
            Address__c address = [SELECT Id FROM Address__c LIMIT 1];
            mibnfComp.Sold_To__c = address.Id;
            update mibnfComp;
        Test.stopTest();
    }
}