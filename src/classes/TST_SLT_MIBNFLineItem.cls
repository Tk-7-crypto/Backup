@isTest
public class TST_SLT_MIBNFLineItem {
    static testmethod void testmibnf_comp() {
        Account TestAccount = BNF_Test_Data.createAccount();
        Opportunity opp = BNF_Test_Data.createOpp();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        
        List<Address__c> TestAddress_Array = UTL_TestData.createAddresses(TestAccount);
        insert TestAddress_Array;
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        
        Test.startTest();
        
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        MI_BNF_LineItem__c TestMI_BNFLineItem = UTL_TestData.createMIBNFLineItem(TestMIBNF_Comp.Id, OLI_Array[0]);
        insert TestMI_BNFLineItem;
        
        List<MI_BNF_LineItem__c>  mibnfList = new SLT_MIBNFLineItem().selectByFilter(new Set<Id>{OLI_Array[0].Id}, new Set<String>{'Id'}, ' Id != null');
        
        Test.stopTest();
    }
}