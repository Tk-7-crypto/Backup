/*
 * This class is used to test SCH_CRM_UserLicenseExpiry class
 */
@isTest
public class TST_SCH_CRM_UserLicenseExpiry {
    
    @testSetup
    static void dataSetup() {
    	List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        userList[0].License_Expiry_Date__c = System.today() - 5;
        userList[0].isActive = true;
        insert userList;
        Deactivate_User_Setting__c cs = new Deactivate_User_Setting__c(Name = 'Rajeev Kumar');
        cs.Batch_Size__c = 5;
        cs.User_Id__c = userList[0].Id;
        insert cs;
        User_Activation_Input_Variables__c userConfig = new User_Activation_Input_Variables__c(Name = 'BusinessLogic');
        userConfig.Days_from_last_login__c = 7;
        userConfig.Allowed_Reactivation__c = 2;
        userConfig.Infrequent_User_Active_Days__c = 14;
        userConfig.Number_Of_Days_From_Last_Login__c = 100;
        userConfig.Failure_Notification_Emails__c = 'ritvik.bhomia@metacube.com';
        insert userConfig;
    }
    
    @IsTest
    static void testSCHCRMUserLicenseExpiry() {
        String CRON_EXP = '0 0 13 * * ?'; 
        Test.startTest();
        SCH_CRM_UserLicenseExpiry.scheduleJob('Test User License Expiry',CRON_EXP);
        Test.stopTest();
    }
}