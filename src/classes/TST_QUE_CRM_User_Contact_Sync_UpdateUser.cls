@isTest
private  class TST_QUE_CRM_User_Contact_Sync_UpdateUser {
    
    @isTest
    public static  void test() {
        Test.startTest();
        User testUser = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE,1)[0];
        testUser.User_To_Contact_Sync_Error__c = 'Error while sync';
        insert testUser;
        Survey_Setting__c surveySetting = new Survey_Setting__c(Survey_Error_Email_Ids__c = 'test@gmail.com');
        insert surveySetting;
        List<User> userList = new List<User>();
        userList.add(testUser);
        System.enqueueJob(new QUE_CRM_User_Contact_Sync_UpdateUser(userList));
        Test.stopTest();
    }
}