/**
 * This class is used to Test TGR_CRM_Recall_Approval Trigger
 */ 
@isTest
public class TST_TGR_CRM_Recall_Approval {
    
     @isTest
    static void testRecallApproval() {
        //Create test data 
        Account acc= UTL_TestData.createAccount();
        insert acc;

        Test.startTest();
        SRV_CRM_RecallApproval.unlockRecord(acc.id);
        Test.stopTest();
    }
}