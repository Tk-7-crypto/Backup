/**
* This class is used to test DAO_ContractLifecycle class
*/
@isTest
public class TST_DAO_ContractLifecycle {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc; 
        Contract cntrt = new Contract();
        cntrt.AccountId = acc.Id;
        cntrt.Status = 'Draft';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        insert cntrt;
    }
    
    static testMethod void testContractLifecycle() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contract cntrt = [SELECT Id FROM Contract LIMIT 1];
        Contract_Lifecycle__c cntrtLifeCycle = new Contract_Lifecycle__c();
        cntrtLifeCycle.Account__c = acc.Id;
        cntrtLifeCycle.Contract__c = cntrt.Id;
        cntrtLifeCycle.CurrencyIsoCode = 'USD';
        insert cntrtLifeCycle;
        cntrtLifeCycle.CurrencyIsoCode = 'INR';
        update cntrtLifeCycle;
        cntrtLifeCycle = [SELECT Id, CurrencyIsoCode FROM Contract_Lifecycle__c LIMIT 1];
        System.assertEquals('INR', cntrtLifeCycle.CurrencyIsoCode);
        try {
            delete cntrtLifeCycle;
        } catch(Exception ex) {
            
        }
        List<Contract_Lifecycle__c> cntrtLifeCycleList = [SELECT Id, CurrencyIsoCode FROM Contract_Lifecycle__c];
        System.assertEquals(0, cntrtLifeCycleList.size());
        Test.stopTest();
    }
}