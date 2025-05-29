/**
 * This class is used to Test SRV_CRM_RecallApproval class
 */ 
@isTest
public class TST_SRV_CRM_RecallApproval {
    
    @isTest
    static void testRecallApproval() {
        //Create test data 
        Account acc= UTL_TestData.createAccount();
        insert acc;

        Test.startTest();
        SRV_CRM_RecallApproval.unlockRecord(acc.id);
        SRV_CRM_RecallApproval.lockRecord(acc.id);
        Test.stopTest();
    }
}