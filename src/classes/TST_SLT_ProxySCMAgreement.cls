/**
 * This class is used to test SLT_ProxySCMAgreement
 */ 
@isTest
public class TST_SLT_ProxySCMAgreement {
 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Proxy_SCM_Agreement__c proxySCMAgreement = new Proxy_SCM_Agreement__c();
        proxySCMAgreement.Opportunity__c = opp.Id;
        proxySCMAgreement.Name = 'Test Proxy SCM Agreement';
        proxySCMAgreement.LI_Record_Id__c = 'xyz';
        insert proxySCMAgreement;
    }
    
     static testMethod void testSelectByFilter() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        String filterCondition = 'Opportunity__c in :oppIdSet';
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Test.startTest();
        List<Proxy_SCM_Agreement__c> proxySCMAgreementList = new SLT_ProxySCMAgreement().selectByFilter(oppIdSet, fieldSet, filterCondition);
        System.assertEquals('Test Proxy SCM Agreement', proxySCMAgreementList[0].Name);
        Test.stopTest();
    }
}