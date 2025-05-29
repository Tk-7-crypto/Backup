/**
* This test class is used to test Task record triggered flow - CRM_TASK_RecordTriggeredAfter
* version : 1.0
*/
@isTest
public class TST_CRM_TASK_RecordTriggeredAfter {
    
    /**
* This method used to set up testdata
*/ 
    @testSetup
    static void dataSetup() {
        
        Account acc = UTL_TestData.createAccount();
        acc.Website = 'www.test.com';
        insert acc;
        
        User user = UTL_TestData.createUser('Sales User', 1)[0];
        user.FirstName = 'Test Sales User';
        user.IsActive = true;
        insert user;
        
    }

    @isTest
    static void testCRMtaskEmailAlert(){
        
        Task task1 = UTL_TestData.createTask(null,'Not Started','Normal','Other',CON_CRM.MQL_TASK_RECORD_TYPE_ID);
        task1.Lead_Email__c = 'test@infusemedia.com';
        insert task1;
        Test.startTest();
        User user1 = [SELECT Id from User where FirstName = 'Test Sales User'];
        System.runAs(user1){
			task1.Status = 'Completed';
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void testCheckForMQLTask(){
        
        Task task1 = UTL_TestData.createTask(null,'Not Started','Normal','Other',CON_CRM.MQL_TASK_RECORD_TYPE_ID);
        task1.Lead_Email__c = 'test@infusemedia.com';
        task1.Priority = 'Urgent';
        Test.startTest();
		insert task1;
        Test.stopTest();
        
    }
}