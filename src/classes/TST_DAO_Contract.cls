/**
* This class is used to test DAO_Contract
*/
@isTest
public class TST_DAO_Contract {
    
    @testSetup 
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
    }
    
    static testMethod void testContract() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
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
        cntrt.ContractTerm = 13;
        update cntrt;
        cntrt = [SELECT Id, ContractTerm FROM Contract LIMIT 1];
        System.assertEquals(13, cntrt.ContractTerm);
        try {
            delete cntrt;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        List<Contract> cntrtList = [SELECT Id, ContractTerm FROM Contract];
        System.assertEquals(0, cntrtList.size());
        Test.stopTest();
    }
}