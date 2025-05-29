/**
 * This class is used to test DAOH_TST_DAOH_ContractStageDetail class
 */ 
@isTest
public class TST_DAOH_ContractStageDetail {
    
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
        Contract_Lifecycle__c cntrtLifeCycle = new Contract_Lifecycle__c();
        cntrtLifeCycle.Account__c = acc.Id;
        cntrtLifeCycle.Contract__c = cntrt.Id;
        cntrtLifeCycle.CurrencyIsoCode = 'USD';
        insert cntrtLifeCycle;
    }
    
    @isTest
    static void testContractStageDetail() {
        Test.startTest();
        Contract_Lifecycle__c cntrtLifeCycle = [SELECT Id FROM Contract_Lifecycle__c LIMIT 1];
        Contract_Stage_Detail__c cntrtStageDetail = new Contract_Stage_Detail__c();
        cntrtStageDetail.Contract_Lifecycle__c = cntrtLifeCycle.Id;
        cntrtStageDetail.Analyst_Start_Date__c = System.today();
        insert cntrtStageDetail;
        cntrtStageDetail.Analyst_Start_Date__c = System.today() + 1;
        update cntrtStageDetail;
        cntrtStageDetail = [SELECT Id FROM Contract_Stage_Detail__c LIMIT 1];
        List<Contract_Stage_Detail__c> cntrtStageDetailList = [SELECT Id FROM Contract_Stage_Detail__c];
        try {
            delete cntrtStageDetailList;
        } catch(Exception ex) {
            
        }
        cntrtStageDetailList = [SELECT Id FROM Contract_Stage_Detail__c];
        System.assertEquals(0, cntrtStageDetailList.size());
        Test.stopTest();
    }
}