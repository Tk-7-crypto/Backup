/**
 * This test class is used to test all methods in user Domain class.
 * version : 1.0
 */
@isTest
private class TST_TGR_User {
    static testMethod void testCreateAssignPermissionSetToUser() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber ='08080808');
        insert admin;
        System.runAs(admin) {            
            user_1 = new User( 
                Email = 'TST_TGR_UserPSToUser@iqvia.com',
                ProfileId = profile_1.Id, 
                UserName = 'TST_TGR_UserPSToUser@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                Article_Manager__c = true,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname',
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                EmployeeNumber ='080808081'
            );
            insert user_1;
            user_1.Article_Manager__c = false;
            update user_1;
        }
    }
}