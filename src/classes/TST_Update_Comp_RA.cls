/*
* Version       : 1.0
* Description   : Test Class for Update_Comp_RA MIBNF trigger
*/
@isTest
public class TST_Update_Comp_RA {
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
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        List<Address__c> addressesList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressesList.size(); index++) {
            addressesList[index].MDM_Validation_Status__c = 'Validated';
            addressesList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressesList;
    }
    
    /**
    * This method used to test sobject field list
    */    
    @IsTest
    static void testUpdateCompRA() {
        Test.startTest();
            MIBNF2__c TestMIBNF = [SELECT id FROM MIBNF2__c LIMIT 1];
            List<Address__c> addressesList= [SELECT Id FROM Address__c];
            MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF,addressesList);
            insert TestMIBNF_Comp;
            
            Revenue_Analyst__c revenueAnalyst2 = UTL_TestData.createRevenueAnalyst();
            insert revenueAnalyst2;

        	MIBNF2__c mibnf = [SELECT Id FROM MIBNF2__c LIMIT 1];
            mibnf.Revenue_Analyst__c = revenueAnalyst2.Id;
            update mibnf;
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateSalesOrgCode() {
        Test.startTest();
            MIBNF2__c TestMIBNF = [SELECT id FROM MIBNF2__c LIMIT 1];
            List<Address__c> addressesList= [SELECT Id FROM Address__c];
            MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF,addressesList);
            insert TestMIBNF_Comp;
            
            TestMIBNF.Sales_Org_Code__c = 'CH07';
            update TestMIBNF;
        Test.stopTest();
    }
    
}