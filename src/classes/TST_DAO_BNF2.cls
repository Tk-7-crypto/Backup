@isTest
public class TST_DAO_BNF2 {
    
    @isTest
    public static void testTrigger() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Opportunity opp = UTL_TestData.createOpportunity(account.Id);
        insert opp;
        
        List<Address__c> addressList = UTL_TestData.createAddresses(account);
        insert addressList;
        
        Test.startTest();
        BNF2__c TestBnf = UTL_TestData.createBNFRecord(opp, null, addressList, revenueAnalyst.Id);
        insert TestBnf;
        Opportunity_Extension__c oe = [SELECT Id, BNF_Count__c FROM Opportunity_Extension__c];
        System.assertEquals(1, oe.BNF_Count__c);        
        
        TestBnf.Description__c = 'test';
        update TestBnf;
        
        delete TestBnf;
        oe = [SELECT Id, BNF_Count__c FROM Opportunity_Extension__c];
        System.assertEquals(0, oe.BNF_Count__c);
        Test.stopTest();
    }
    
}