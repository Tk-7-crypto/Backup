/*
 * This test class is used to test the Queable Class: 'QBL_UserConfiguration', that handles the
 * user configuration at the reactivation process.
*/
@isTest
public class TST_QBL_UserConfiguration {

    @testSetup 
    static void setup() {
        User_Activation_Input_Variables__c userConfig = new User_Activation_Input_Variables__c(Name = 'BusinessLogic');
        userConfig.Days_from_last_login__c = 7;
        userConfig.Allowed_Reactivation__c = 2;
        userConfig.Infrequent_User_Active_Days__c = 14;
        userConfig.Number_Of_Days_From_Last_Login__c = 100;
        userConfig.Failure_Notification_Emails__c = 'arun.james@iqvia.com';
        userConfig.PSA_Admin_Email_Address__c = 'ritvik.bhomia@iqvia.com';
        userConfig.Sales_Admin_Email_Address__c = 'ritvik.bhomia@iqvia.com';
        userConfig.Service_Admin_Email_Address__c = 'ritvik.bhomia@iqvia.com';
        userConfig.PSA_User_VIA_Request_URL__c = 'https://test.salesforce.com/';
        userConfig.Sales_User_VIA_Request_URL__c = 'https://test.salesforce.com/';
        userConfig.Service_User_VIA_Request_URL__c = 'https://test.salesforce.com/';
        insert userConfig;
    }

    @isTest
    static void testTSTQBLUserConfiguration1(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;

        // Assigning a permission set to the user
        PermissionSetAssignment permissionSetAssignmentToUser = UTL_TestData.createPermissionSetAssignmentRecord('CRM_Support', testUser[0].id);
        insert permissionSetAssignmentToUser;
        
        testUser[0].IsActive = false;
        update testUser;

        User updatedTestUser = [SELECT id, User_Configuration_Json__c from User where id =: testUser[0].id];

        // Removing PermissionSetAssignment after the user deactivation
        delete permissionSetAssignmentToUser;

        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(testUser[0].id, updatedTestUser.User_Configuration_Json__c);
        System.debug(updatedTestUser.User_Configuration_Json__c);

        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
    
    @isTest
    static void testTSTQBLUserConfiguration2(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;
        
        // Createing and Assigning a Group to the user.
        Group testGroup = UTL_TestData.createGroup('testGroup', 'Regular');
        insert testGroup;
        GroupMember testGroupMember = UTL_TestData.createGroupMember(testGroup.id, testUser[0].id);
        insert testGroupMember;

        testUser[0].IsActive = false;
        update testUser;

        // Removing the user user from this group.
        User updatedTestUser = [SELECT id, User_Configuration_Json__c from User where id =: testUser[0].id];
        delete testGroupMember;

        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(testUser[0].id, updatedTestUser.User_Configuration_Json__c);
        System.debug(updatedTestUser.User_Configuration_Json__c);

        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
    
    @isTest
    static void testTSTQBLUserConfiguration3(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;

        // Assign two UserPackageLicenses.
        List<PackageLicense> pl = [SELECT Id FROM PackageLicense Limit 2];
        List<UserPackageLicense> testUserPackageLicenses = new List<UserPackageLicense>();
        testUserPackageLicenses.add( new UserPackageLicense( UserId = testUser[0].id, PackageLicenseId = pl[0].id ));
        testUserPackageLicenses.add( new UserPackageLicense(UserId = testUser[0].id, PackageLicenseId = pl[1].id ));
        insert testUserPackageLicenses;
        
        testUser[0].IsActive = false;
        update testUser;

        User updatedTestUser = [SELECT id, User_Configuration_Json__c from User where id =: testUser[0].id];
        // Removing one of the  UserPackageLicense after user deactivation.
        delete testUserPackageLicenses[0];

        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(testUser[0].id, updatedTestUser.User_Configuration_Json__c);
        System.debug(updatedTestUser.User_Configuration_Json__c);

        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }

    @isTest
    static void testTSTQBLUserConfiguration4(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;

        testUser[0].IsActive = false;
        update testUser;

        User updatedTestUser = [SELECT id, User_Configuration_Json__c from User where id =: testUser[0].id];

        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(testUser[0].id, updatedTestUser.User_Configuration_Json__c);
        System.debug(updatedTestUser.User_Configuration_Json__c);

        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }

    @isTest
    static void testTSTQBLUserConfiguration5(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;
        
        // User with no User Configuration Stored.
        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(testUser[0].id, null);

        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }

    @isTest
    static void testCatchBlock(){
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        insert testUser;
        
        testUser[0].IsActive = false;
        update testUser;

        User updatedTestUser = [SELECT id, User_Configuration_Json__c from User where id =: testUser[0].id];

        QBL_UserConfiguration queuableObject = new QBL_UserConfiguration(null, updatedTestUser.User_Configuration_Json__c);

        try{
        	Test.startTest();
            System.enqueueJob(queuableObject);
        	Test.stopTest();
        } catch (Exception e) {

        }
    }


    @isTest
    static void testNotifyUser() {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        List<User> testUser = UTL_TestData.createUser('PSA User', 1);
        insert testUser;
        test.startTest();
        QBL_UserConfiguration.notifyUser(testUser[0].Id, testUser[0].Profile.UserLicense.Name, 'Exception Message' , testUser[0].Profile.Name);
        test.stopTest();
    }

    @isTest
    static void testSendFailureMailToSupport() {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        List<User> testUser = UTL_TestData.createUser('PSA User', 1);
        insert testUser;
        test.startTest();
        QBL_UserConfiguration.sendFailureMailToSupport(testUser[0].id, testUser[0].Profile.Name, 'Subject', 'Message');
        test.stopTest();
    }

}