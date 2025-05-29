@isTest
public class TST_BCH_CRM_UpdateMIBNFJSONData {

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
        opp.Is_this_IQVIA_Biotech__c = 'No';
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
    
    static testMethod void test1(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        MIBNF2__c TestMIBNF = [SELECT Id FROM MIBNF2__c LIMIT 1];
        OpportunityLineItem oppLineItem = [SELECT Id, Product2Id FROM OpportunityLineItem LIMIT 1];
        Test.startTest();
            List<Address__c> addressesList = UTL_TestData.createAddresses(acc);
            insert addressesList;
            MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF,addressesList);
            TestMIBNF_Comp.JSON_Correction__c = true;
            TestMIBNF_Comp.OLI_Json_Data_1__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
            TestMIBNF_Comp.OLI_Json_Data_2__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
            TestMIBNF_Comp.OLI_Json_Data_3__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
            insert TestMIBNF_Comp;
            Database.executeBatch(new BCH_CRM_UpdateMIBNFJSONData());
        Test.stopTest();
    }
}