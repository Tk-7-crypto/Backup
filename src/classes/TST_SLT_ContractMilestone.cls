/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ContractMilestone
 */
@isTest
public class TST_SLT_ContractMilestone {
    /**
     * This method used to set up testdata
     */ 
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
        Contract_Milestone__c ctrMilestone = new Contract_Milestone__c();
       	ctrMilestone.V1_Start_Date__c = Date.today();
        ctrMilestone.Milestone__c = '2. Insufficient information to proceed';
        ctrMilestone.V1_Completed_Date__c = Date.today().addDays(2);
        ctrMilestone.Contract_Number__c = cntrt.Id;
        insert ctrMilestone;
        
    }
    /**
     * This method used to test sobject field list
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        Contract_Milestone__c cm = [Select Id FROM Contract_Milestone__c Limit 1];
        Set<Id> cmIdSet = new Set<Id>{cm.Id}; 
        Test.startTest();
        new SLT_ContractMilestone().selectByIdFilter(cmIdSet, new Set<String>{'Id'});
        Test.stopTest();
    }
}