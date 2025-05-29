@isTest
public class TST_MIBNFCompWrapper {

     @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        OpportunityLineItemSchedule olis =UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id); 
        insert olis; 
    }
    
     @isTest
    static void testWrapperConstructor(){
        Opportunity opp = [select id, AccountId from Opportunity limit 1][0];
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Quantity, TotalPrice, UnitPrice, HasRevenueSchedule, Product_Material_Type_Text__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
        Account acc = [select id from Account where id =:opp.AccountId limit 1][0];
        system.debug(Limits.getLimitQueries());
        Test.startTest();
        Revenue_Analyst__c testRA = UTL_TestData.createRevenueAnalyst();
        insert testRA;
        MIBNF2__c mibnf = UTL_TestData.createMIBNF(opp, testRA);
        insert mibnf;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        
        List<MIBNF_Component__c> mibnfComponentList = new List<MIBNF_Component__c>();
        MIBNF_Component__c mibnfComponent1 =  UTL_TestData.createMIBNF_Comp(mibnf, addressList); 
        mibnfComponent1.BNF_Status__c = 'New';
        mibnfComponentList.add(mibnfComponent1);
        insert mibnfComponentList;
        
        List<MI_BNF_LineItem__c> mibnfLineItemList = new List<MI_BNF_LineItem__c>();
        MI_BNF_LineItem__c mibnfLineItem = new MI_BNF_LineItem__c();
        mibnfLineItem.MIBNF_Component__c = mibnfComponentList[0].id;
        mibnfLineItem.Opportunity_Line_Itemid__c = oliList[0].id;
        mibnfLineItem.MIBNFComponent_OLI_ID__c = String.valueOf(mibnfComponentList[0].id) + String.valueOf(oliList[0].id);
        mibnfLineItemList.add(mibnfLineItem);

        insert mibnfLineItemList;
        system.debug(Limits.getQueries());
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList[0].id);
        insert sche;
        Billing_Schedule_Item__c schItem = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        insert schItem;
        system.debug(schItem.Id);
        system.debug(Limits.getQueries());
        Map<Id,Date> billingMap = new Map<Id,Date>();
        billingMap.put(schItem.Id, schItem.Billing_Date__c);
        system.debug(Limits.getQueries());
        List<Billing_Schedule_Item__c> billschList = new List<Billing_Schedule_Item__c>();
        billschList.add(schItem);
        Map<Id, List<Billing_Schedule_Item__c>> billMap = new Map<Id, List<Billing_Schedule_Item__c>>();
        billMap.put(schItem.id,billschList);
        MIBNFCompWrapper mibnfCompWrapper = new MIBNFCompWrapper();
        mibnfCompWrapper = new MIBNFCompWrapper(mibnfComponent1, new Map<Id,OpportunityLineItem>(oliList), billMap, false);
        Test.stopTest(); 
    }
}