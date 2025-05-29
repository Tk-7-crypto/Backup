/**
 * This class is used to test BCH_CRM_UserLicenseExpiry Batch class
 */ 
@isTest
public class TST_BCH_CRM_UserLicenseExpiry {
    
    @testSetup
    static void dataSetup() {
        List<User> userList = UTL_TestData.createUser('System Administrator', 2);
        userList[0].isActive = true;
        userList[0].License_Expiry_Date__c = System.today() - 5;
        insert userList;
        
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
    static void testBCHCRMUserLicenseExpiry() {
        
        Test.startTest();
        BCH_CRM_UserLicenseExpiry batchUserLicenseExpiry = new BCH_CRM_UserLicenseExpiry();
        Database.executeBatch(batchUserLicenseExpiry);
        BCH_CRM_UserLicenseExpiry.sendMailOnException(new List<String>{'Error'},new List<String>{'arun.parmar@metcube.com'});
        BCH_CRM_UserLicenseExpiry.sendMailOnError(new List<String>{'Error'},new List<String>{'arun.parmar@metcube.com'});
        Test.stopTest();
    }
    
     //SFDCDEVOPS-834 : Created method to test package license removal from deactivated user excluding licenses to be retained
     @isTest
     static void testBCHCRMDeactivatedUserLicenseExpiry() {
         User usr = [SELECT Id,IsActive FROM User WHERE IsActive = true LIMIT 1]; 
         PackageLicense packageLicense = [SELECT Id, namespaceprefix FROM PackageLicense WHERE namespaceprefix ='trailheadapp'];
 
         UserPackageLicense pack = new UserPackageLicense();
         pack.userId = usr.Id;
         pack.PackageLicenseId = packageLicense.Id;
         Insert pack;
         
         Package_License_Configuration__mdt packageLicenseMd = [SELECT Package_License_Name__c, Id FROM Package_License_Configuration__mdt LIMIT 1];
         Test.startTest();
         BCH_CRM_UserLicenseExpiry batchUserLicenseExpiry = new BCH_CRM_UserLicenseExpiry();
         BCH_CRM_UserLicenseExpiry.removePackageLicenseOfDeactivatedUser(new Set<Id>{usr.Id}, new Set<String>{packageLicenseMd.Package_License_Name__c});
         Test.stopTest();
     }
     
}