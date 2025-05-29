/**
 * This class is used to test Address Wrapper class
 */ 
@isTest
public class TST_AddressWrapper {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        insert userList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp =  UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
    }
    
    static testMethod void testAddressWrapper() {
        User user = [SELECT Id FROM User WHERE LastName = 'lastName123' LIMIT 1];
        MIBNF_Component__c mibnfComp = [SELECT Id, Bill_To__c, Ship_To__c FROM MIBNF_Component__c LIMIT 1];
        Set<id> addressIdSet = new set<id>();
        addressIdSet.add(mibnfComp.Bill_To__c);
        addressIdSet.add(mibnfComp.Ship_To__c);
        Map<id,Address__c> addressMap = new Map<id,Address__c>( [SELECT Id, Name, SAP_Reference__c, Enabled_Sales_Orgs__c FROM Address__c WHERE Id IN :addressIdSet]);
        Map<String,Address__c> filledAddressesMap = new Map<String,Address__c>();
        filledAddressesMap.put('Bill To',addressMap.get(mibnfComp.Bill_To__c));
        filledAddressesMap.put('Ship To',addressMap.get(mibnfComp.Ship_To__c));
        System.runAs(user) {
            Test.startTest();
                AddressWrapper addressWrapper = new AddressWrapper(filledAddressesMap);
            Test.stopTest();
            System.assertEquals(filledAddressesMap.get('Bill To'), addressWrapper.map_Filled_Addresses.get('Bill To'));
        }
    }
    
}