/**
* This class is used to test DAO_ContractInOutLog class
*/ 
@isTest
public class TST_DAO_ContractInOutLog {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue; 
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
    
    static testMethod void testContractInOutLog() {   
        Test.startTest();
        Contract cntrt = [SELECT Id FROM Contract LIMIT 1];
        Contract_In_Out_Log__c contractInOutLog  = new Contract_In_Out_Log__c();
        contractInOutLog.Contract__c = cntrt.Id;
        insert contractInOutLog;
        List<Contract_In_Out_Log__c> cioList = [SELECT Id, Number_of_Documents__c,Contract__c FROM Contract_In_Out_Log__c];
        cioList[0].Number_of_Documents__c = 10;
        update cioList;
        cioList = [SELECT Id, Number_of_Documents__c,Contract__c FROM Contract_In_Out_Log__c];
        System.assertEquals(10, cioList[0].Number_of_Documents__c);
        try{
            delete cioList;
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        Test.stopTest();
    }
}