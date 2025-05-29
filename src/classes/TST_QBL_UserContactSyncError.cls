@isTest
public class TST_QBL_UserContactSyncError {
    
    @isTest
    public static  void test1() {
        User testUser = UTL_TestData.createUser(CON_CRM.IQVIA_SF_PLATFORM_PROFILE,1)[0];
        insert testUser;
        testUser.User_To_Contact_Sync_Error__c = 'Test Error';
        Test.startTest();        
        System.enqueueJob(new QBL_UserContactSyncError(new List<User>{testUser}));
        Test.stopTest();
    }
    
    @isTest
    public static  void test2() {
        User testUser = UTL_TestData.createUser(CON_CRM.IQVIA_SF_PLATFORM_PROFILE,1)[0];
        Test.startTest();        
        System.enqueueJob(new QBL_UserContactSyncError(new List<User>{testUser}));
        Test.stopTest();
    }
}