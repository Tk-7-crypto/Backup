/**
 * This class is used to test DAOH_ContractMilestone
 */ 
@isTest
public class TST_DAOH_ContractMilestone {
    
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
* This method used to set Contract_Milestone__c fields
*/    
    @IsTest
    static void testsetContractMilestoneFields() {
        Test.startTest();
        Contract ctnrt = [Select Id,Current_Milestone__c from Contract LIMIT 1];
        System.assertEquals(2,ctnrt.Current_Milestone__c);
        List<Contract_Milestone__c> contractMileStoneList = [SELECT Id, Milestone__c, V1_Completed_Date__c FROM Contract_Milestone__c];
        contractMileStoneList[0].V1_Completed_Date__c = Date.today().addDays(3);
        update contractMileStoneList;
        contractMileStoneList = [SELECT Id, Milestone__c, V1_Completed_Date__c FROM Contract_Milestone__c];
        System.assertEquals(Date.today().addDays(3), contractMileStoneList[0].V1_Completed_Date__c);
        try {
            delete contractMileStoneList;
        } catch(Exception ex) {
            
        }
        contractMileStoneList = [SELECT Id, Milestone__c, V1_Completed_Date__c FROM Contract_Milestone__c];
        System.assertEquals(0, contractMileStoneList.size());
        Test.stopTest();
    }    
}