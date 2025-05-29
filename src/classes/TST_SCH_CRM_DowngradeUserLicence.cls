/*
 * This class is used to test SCH_CRM_UserLicenseExpiry class
 */
@isTest
public class TST_SCH_CRM_DowngradeUserLicence {
    
    @testSetup
    static void dataSetup() {
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        userList[0].isActive = true;
        insert userList;
        userList[0].Activation_Date__c =  System.Today() - 90;
        update userList;
        User_Downgrade_Setting__c cs = new User_Downgrade_Setting__c();
        cs.Activation_Date_Duration_in_Days__c = 45.00;
        cs.Last_Login_Duration_in_Days__c = 45.00;
        cs.User_License_type_to_be_Included__c = 'Salesforce,Salesforce Platform';
        cs.Batch_Size__c = 200.00;
        cs.Notification_emails__c = 'shubham.jain1@metacube.com';
        cs.User_Ids__c = userList[0].Id;
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
    static void testSCHCRMDowngradeUserLicence() {
        String CRON_EXP = '0 0 13 * * ?'; 
        Test.startTest();
        SCH_CRM_DowngradeUserLicence.scheduleJob('Test User Deactivation',CRON_EXP);
        Test.stopTest();
    }
}