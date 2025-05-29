/**
* @Author: Babita Dadarwal
* @Description : Test Class for CommunitiesLandingController
*/
@isTest(SeeAllData=false)
private class TST_TPA_CommunitiesLandingController {

    @TestSetup static void setup() {
        //UTL_TPA_SetupTestData.createTPASettingsData();
        //Date todayDate = Date.today();
    }

    @isTest static void testCommunitiesLandingController() {
        TPA_Settings__c tpaSetting = UTL_TPA_SetupTestData.createTPASettingsData();
        tpaSetting.TPA_Forgot_UserName_Email__c = 'testForgotEmail@test.com';
        tpaSetting.TPA_Admin_Email_Address__c = 'tpaAdminEmail@test.com';
        update tpaSetting;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Account 1';
        insert testAccount1;

        Contact testContact1 = UTL_TPA_SetupTestData.getContact();
        testContact1.LastName = 'Test Contact 1';
        testContact1.Email = 'testEmail1@test.com';
        testContact1.AccountId = testAccount1.Account__c;
        testContact1.Portal_Case_Type__c = 'R&D';
        insert testContact1;

        Contact testContact2 = UTL_TPA_SetupTestData.getContact();
        testContact2.LastName = 'Test Contact 2';
        testContact2.Email = 'testEmail2@test.com';
        testContact2.AccountId = testAccount1.Account__c;
        insert testContact2;

        Contact testContact3 = UTL_TPA_SetupTestData.getContact();
        testContact3.LastName = 'Test Contact 3';
        testContact3.Email = 'testEmail2@test.com';
        testContact3.AccountId = testAccount1.Account__c;
        insert testContact3;

        Contact testContact4 = UTL_TPA_SetupTestData.getContact();
        testContact4.LastName = 'Test Contact 3';
        testContact4.Email = 'testEmail@test.com';
        testContact4.AccountId = testAccount1.Account__c;
        insert testContact4;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1];
        //User usr = UTL_TPA_SetupTestData.createTestUser(testContact1, testProfile);

        test.startTest();

        User currentCommUser = [select id, TPA_Is_Privacy_Policy_Agreed__c from user where id =: UserInfo.getUserId()];
        currentCommUser.TPA_Is_Privacy_Policy_Agreed__c = true;
        currentCommUser.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        update currentCommUser;

        ApexPages.currentPage().setCookies(new System.Cookie[] { new System.Cookie('extUserActionVal', 'extAction=ExtNewReq', null, -1, false) });

        // Instantiate a new controller with all parameters in the page
        TPA_CommunitiesLandingController controller = new TPA_CommunitiesLandingController();
        controller.forwardToStartPage();
        currentCommUser.TPA_Is_Privacy_Policy_Agreed__c = false;
        update currentCommUser;
        controller.forwardToStartPage();
        ApexPages.currentPage().getCookies().put('extUserActionVal', null);
        controller.forwardToStartPage();
        TPA_CommunitiesLandingController.sendUserName(jSON.serialize('testEmail@test.com'));
        TPA_CommunitiesLandingController.sendUserName(jSON.serialize('testEmail1@test.com'));
        TPA_CommunitiesLandingController.sendUserName(jSON.serialize('testEmail2@test.com'));
        TPA_CommunitiesLandingController.sendUserName(jSON.serialize('standarduser@testorg.com'));
        String resArg = TPA_CommunitiesLandingController.communityUrl;
        test.stopTest();
    }
    
    

    @isTest static void testCommunitiesLandingController2() {
        TPA_Settings__c tpaSetting = UTL_TPA_SetupTestData.createTPASettingsData();
        tpaSetting.TPA_Forgot_UserName_Email__c = 'testForgotEmail@test.com';
        tpaSetting.TPA_Admin_Email_Address__c = 'tpaAdminEmail@test.com';
        update tpaSetting;
		
		test.startTest(); 
        
        User adminUser = [Select Id, UserRoleId From User Where Id=:UserInfo.getUserId() Limit 1];
        if(adminUser != null) {
            if(adminUser.UserRoleId == null) {
                UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
                adminUser.UserRoleId = userRole.Id;
                update adminUser;
            }
            system.debug(':::'+adminUser.userRoleId);
            System.runAs(adminUser){
                Address__c testAccount1 = UTL_TPA_SetupTestData.getTestAccount();
        
                Contact testContact1 = UTL_TPA_SetupTestData.getContact();
                testContact1.LastName = 'Test Contact 1';
                testContact1.Email = 'testEmail1@test.com';
                testContact1.AccountId = testAccount1.Account__c;
                testContact1.Portal_Case_Type__c = 'R&D';
                insert testContact1;
                
                Id p = [select id from profile where name='TPA Customer Community Plus Login User'].id;
                User user = new User(alias = 'test123', email='testEmail1@test.com', EmployeeNumber = String.valueOf(System.currentTimeMillis()), 
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                    ContactId = testContact1.Id, TPA_Is_Privacy_Policy_Agreed__c = true,
                                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com.invalid');
		
                insert user;
            	TPA_CommunitiesLandingController.sendUserName(jSON.serialize('testEmail1@test.com'));
            }
        }
        test.stopTest();
    }
}