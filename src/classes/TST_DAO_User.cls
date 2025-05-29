/**
 * This test class is used to test all methods in user Domain class.
 * version : 1.0
 */ 
@isTest
private class TST_DAO_User {
    static testMethod void testCreateAssignPermissionSetToUser() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'su',EmployeeNumber ='99994487',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
        );
        insert admin;
        System.runAs(admin) {
            
            user_1 = new User( 
                Email = 'yourusername@iqvia.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername12@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                EmployeeNumber ='999944387',
                LanguageLocaleKey = 'en_US',
                Article_Manager__c = true,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname',
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description'
            );
            insert user_1;
            user_1.Article_Manager__c = false;
            update user_1;
        }
    }
    
    @isTest
    static void testManageTpaRecordSharing() {
        Profile tpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP'];
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getTestAccount();
     //   testAccount1.Name = 'Test Account 1';
      //  insert testAccount1;

        Contact testContact1 = UTL_TPA_SetupTestData.getTestContact(testAccount1);
       // testContact1.AccountId = testAccount1.Id;
      //  testContact1.LastName = 'Test Contact 1';
      //  insert testContact1;

        User tpProcessor1 = UTL_TPA_SetupTestData.getUser();
        tpProcessor1.ProfileId = tpProcessorProfile.id;
        tpProcessor1.UserName='testuser1@testing.com';
        tpProcessor1.ContactId = testContact1.id;
        insert tpProcessor1;
    }
}