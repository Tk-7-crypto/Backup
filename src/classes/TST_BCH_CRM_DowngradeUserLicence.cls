/**
 * This class is used to test BCH_CRM_DowngradeUserLicence Batch class
 */ 
@isTest
public class TST_BCH_CRM_DowngradeUserLicence {
	
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
    
    @isTest
    static void testBCHCRMDowngradeUserLicence() {
        Test.startTest();
        BCH_CRM_DowngradeUserLicence batchDownGrade = new BCH_CRM_DowngradeUserLicence();
        Database.executeBatch(batchDownGrade);
        BCH_CRM_DowngradeUserLicence.sendMailOnException(new List<String>{'Error'},new List<String>{'shubham.jain1@metacube.com'});
        BCH_CRM_DowngradeUserLicence.sendMailOnError(new List<String>{'Error'},new List<String>{'shubham.jain1@metacube.com'});
        Test.stopTest();
    }

    //SFDCDEVOPS-834 : Created method to test package license removal from deactivated user.
    @isTest
    static void testBCHCRMDowngradeDeactivatedUserLicense() {
        User usr = [SELECT Id, IsActive FROM User WHERE IsActive = true LIMIT 1];
        PackageLicense packageLicense = [SELECT Id, namespaceprefix FROM PackageLicense WHERE namespaceprefix ='trailheadapp'];
        
        UserPackageLicense pack = new UserPackageLicense();
        pack.userId = usr.Id;
        pack.PackageLicenseId = packageLicense.Id;
        Insert pack;
        
        Test.startTest();
        BCH_CRM_DowngradeUserLicence batchDownGrade = new BCH_CRM_DowngradeUserLicence();
        BCH_CRM_DowngradeUserLicence.removePackageLicence(new Set<Id> {usr.Id});
        Test.stopTest();
    }
}