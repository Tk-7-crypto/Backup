@isTest
public class TST_UTL_JITHandler {

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
        userConfig.Reactivation_of_non_infrequent_users__c = true;
        insert userConfig;

    }

    @isTest
    static void testValidateAndActivateUserCase1() {
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = true;
        testUser[0].Change_Request_Description__c = 'test JIT Reactivation';
        insert testUser;

        test.startTest();
        UTL_JITHandler.validateAndActivateUser(testUser[0].id);
        test.stopTest();
    }

    @isTest
    static void testValidateAndActivateUserCase2() {
        List<User> testUser = UTL_TestData.createUser('PSA User', 1);
        testUser[0].isActive = false;
        testUser[0].Change_Request_Description__c = 'test JIT Reactivation';
        testUser[0].Infrequent_User__c = false;
        insert testUser;
		
        try { 
            test.startTest();
            UTL_JITHandler.validateAndActivateUser(testUser[0].id);
            test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('#Profile.Name'));
        }
    }

    @isTest
    static void testValidateAndActivateUserCase3() {
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Active_Inactive_Reason__c = 'Deactivation (Inactivity)';
        testUser[0].Infrequent_User__c = true;
        insert testUser;
        try {
            test.startTest();
            UTL_JITHandler.validateAndActivateUser(testUser[0].id);
            test.stopTest();
        } catch (Exception e) {
            /*if(UTL_JITHandler.checkUserLicenseAvailability('Salesforce') == false) {
                System.assert(e.getMessage().contains('#Profile.Name'));
            }*/
        }   
    }
    
    @isTest
    static void testValidateAndActivateUserCase4() {
        List<User> testUser = UTL_TestData.createUser('System Administrator', 1);
        testUser[0].isActive = false;
        testUser[0].Active_Inactive_Reason__c = 'Termination';
        testUser[0].Infrequent_User__c = true;
        insert testUser;

        try { 
            test.startTest();
            UTL_JITHandler.validateAndActivateUser(testUser[0].id);
            test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('#Profile.Name'));
        }
    }
    
    @isTest
    static void testSendMailToSupportAndAdmin() {
        List<User> testUser = UTL_TestData.createUser('PSA User', 1);
        insert testUser;
        test.startTest();
        UTL_JITHandler.sendMailToSupportAndAdmin('Error Details', testUser[0].Profile.Name);
        test.stopTest();
    }

    @isTest
    static void testCheckUserLicenseAvailability() {
        String licenseName = 'Salesforce';
        test.startTest();
        Boolean licenseAvailable = UTL_JITHandler.checkUserLicenseAvailability(licenseName);
        test.stopTest();
    }

    @isTest
    static void testCreateErrorLog() {
        String errorMessage = 'error message';
        List<User> testUser = UTL_TestData.createUser('Sales User', 1);
        insert testUser;

        test.startTest();
        UTL_JITHandler.createErrorLog(errorMessage, testUser[0].id);
        test.stopTest();
    }

    @isTest
    static void testGetUserCategoryAdminEmailAddressCase1() {
        String userProfile = 'PSA User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String adminEmailList = userConfig.PSA_Admin_Email_Address__c;
        test.startTest();
        String emailList = UTL_JITHandler.getUserCategoryAdminEmailAddress(userProfile);
        test.stopTest();
        System.assertEquals(emailList, adminEmailList);
    }

    @isTest
    static void testGetUserCategoryAdminEmailAddressCase2() {
        String userProfile = 'Service User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String adminEmailList = userConfig.PSA_Admin_Email_Address__c;
        test.startTest();
        String emailList = UTL_JITHandler.getUserCategoryAdminEmailAddress(userProfile);
        test.stopTest();
        System.assertEquals(emailList, adminEmailList);
    }

    @isTest
    static void testGetUserCategoryAdminEmailAddressCase3() {
        String userProfile = 'Sales User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String adminEmailList = userConfig.PSA_Admin_Email_Address__c;
        test.startTest();
        String emailList = UTL_JITHandler.getUserCategoryAdminEmailAddress(userProfile);
        test.stopTest();
        System.assertEquals(emailList, adminEmailList);
    }

    @isTest
    static void testGetVIARequestURLCase1() {
        String userProfile = 'PSA User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String psaVIARequestURL = userConfig.PSA_User_VIA_Request_URL__c;
        test.startTest();
        String viaRequestURL = UTL_JITHandler.getVIARequestURL(userProfile);
        test.stopTest();
        System.assertEquals(viaRequestURL, psaVIARequestURL);
    }

	@isTest
    static void testGetVIARequestURLCase2() {
        String userProfile = 'Service User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String serviceVIARequestURL = userConfig.Service_User_VIA_Request_URL__c;
        test.startTest();
        String viaRequestURL = UTL_JITHandler.getVIARequestURL(userProfile);
        test.stopTest();
        System.assertEquals(viaRequestURL, serviceVIARequestURL);
    }
	
    @isTest
    static void testGetVIARequestURLCase3() {
        String userProfile = 'Sales User';
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        String salesVIARequestURL = userConfig.Sales_User_VIA_Request_URL__c;
        test.startTest();
        String viaRequestURL = UTL_JITHandler.getVIARequestURL(userProfile);
        test.stopTest();
        System.assertEquals(viaRequestURL, salesVIARequestURL);
    }
    
}