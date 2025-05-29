@isTest
public class TST_DAOH_MIBNF_Component {
    
    @testSetup
    public static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Opportunity opp = UTL_TestData.createOpportunity(account.Id);
        insert opp;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(account);
        insert addressList;
    }
    
    @isTest
    public static void testUpdateOpportunityFields() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity];
        Revenue_Analyst__c revenueAnalyst = [SELECT Id FROM Revenue_Analyst__c];
        List<Address__c> addressList = [SELECT Id FROM Address__c];
        
        Test.startTest();
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert TestMIBNF;
        MIBNF_Component__c mc= UTL_TestData.createMIBNF_Comp(TestMIBNF, addressList);
        insert mc;
        
        Opportunity_Extension__c oe = [SELECT Id, BNF_Count__c FROM Opportunity_Extension__c];
        System.assertEquals(1, oe.BNF_Count__c);
        
        delete mc;
        oe = [SELECT Id, BNF_Count__c FROM Opportunity_Extension__c];
        System.assertEquals(0, oe.BNF_Count__c);
        Test.stopTest();
    }
    
}