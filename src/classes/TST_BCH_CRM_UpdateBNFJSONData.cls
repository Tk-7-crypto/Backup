@isTest
public class TST_BCH_CRM_UpdateBNFJSONData {
    
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        upsert mulesoft;
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
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
    }
    
    static testMethod void test1(){
        Opportunity opp = [SELECT Id, AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        OpportunityLineItem oppLineItem = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList= [SELECT Id FROM Address__c];
        Test.startTest();
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        BNF2__c bnfRecord = UTL_TestData.createBNFRecord(opp, oppLineItem, addressList, revenueAnalyst.Id);
        bnfRecord.CurrencyIsoCode = 'INR';
        bnfRecord.JSON_Correction__c = true;
        bnfRecord.OLI_Json_Data_1__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
        bnfRecord.OLI_Json_Data_2__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
        bnfRecord.OLI_Json_Data_3__c = JSON.serialize(new List<OpportunityLineItem>{oppLineItem});
        insert bnfRecord; 
        Database.executeBatch(new BCH_CRM_UpdateBNFJSONData());
        Test.stopTest();
    }
}