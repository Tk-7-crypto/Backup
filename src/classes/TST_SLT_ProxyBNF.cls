/**
 * This class is used to test SLT_ProxyBNF class
 */ 
@isTest
public class TST_SLT_ProxyBNF {

    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Proxy_BNF__c proxyBnf = new Proxy_BNF__c();
        proxyBnf.Opportunity__c = opp.Id;
        proxyBnf.Name = 'Test Proxy Bnf';
        proxyBnf.LI_Record_Id__c = 'xyz';
        insert proxyBnf;
    }
    
    static testMethod void testSelectByFilter() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        String filterCondition = 'Opportunity__c in :oppIdSet';
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Test.startTest();
        List<Proxy_BNF__c> proxyBnfList = new SLT_ProxyBNF().selectByFilter(oppIdSet, fieldSet, filterCondition);
        System.assertEquals('Test Proxy Bnf', proxyBnfList[0].Name);
        Test.stopTest();
    }
}