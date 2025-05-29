/**
* This class is used to test BCH_CRM_MIBNFSync Batch class
*/ 
@isTest
public class TST_BCH_CRM_MIBNFSync {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        List<Product2> product2List = new List<Product2>();
        Product2 product2 = UTL_TestData.createProduct();
        product2List.add(product2);
        product2 = UTL_TestData.createProduct();
        product2List.add(product2);
        product2 = UTL_TestData.createProduct();
        product2List.add(product2);
        insert product2List;
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2List[0].Id);
        pbeList.add(pbe);
        pbe = UTL_TestData.createPricebookEntry(product2List[1].Id);
        pbeList.add(pbe);
        pbe = UTL_TestData.createPricebookEntry(product2List[2].Id);
        pbeList.add(pbe);
        insert pbeList;
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbeList[0].Id);
        oliList.add(oli);
        oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbeList[1].Id);
        oliList.add(oli);
        oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbeList[2].Id);
        oliList.add(oli);
        insert oliList;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        mibnfComp.OLI_Json_Data_1__c = '[ { "Id": "' + oliList[0].Id + '"}]';
        mibnfComp.OLI_Json_Data_2__c = '[ { "Id": "' + oliList[1].Id + '"}]';
        mibnfComp.OLI_Json_Data_3__c = '[ { "Id": "' + oliList[2].Id + '"}]';
        insert mibnfComp;
    }
    
    static testMethod void testBCHCRMMIBNFSyncBatch() {
        Test.startTest();
            BCH_CRM_MIBNFSync batchable = new BCH_CRM_MIBNFSync();
            Database.executeBatch(batchable);
        Test.stopTest();
    }
}