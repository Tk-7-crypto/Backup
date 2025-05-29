@isTest
private class TST_CNT_CSM_UserResetPassword {

    @isTest
    static void testSendEmailToUser(){
        UserRole portalRole = [Select Id,DeveloperName,PortalType  From UserRole Where DeveloperName = 'IQVIA_Global' and PortalType='None'];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User newUser = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='075070707', Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert newUser;
        
        Test.startTest();
            CNT_CSM_UserResetPassword.sendEmailToUser(new List<User>{newUser});
        Test.stopTest();
        
    }
}