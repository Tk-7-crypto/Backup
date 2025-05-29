@isTest
private class TST_CNT_CSM_ResetPassword {
  @isTest
    static void teste(){
        String profilId2 = [SELECT Id From Profile WHERE Name = 'System Administrator'].Id;
        User newUser = New User(Alias = 'com', Email = 'john.teasdast@iqvia.com',IsActive = True, EmployeeNumber='074070707',
                             ProfileId = profilId2, Username = ' john.teasdast@iqvia.com', LastName = 'testLastName', 
                             CommunityNickname = 'testCommunityNickname', TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',Change_Request_Ticket_Number__c ='test description');
        Insert newUser;

        RestRequest request = new RestRequest();
        request.requestUri ='https://test.salesforce.com/services/apexrest/ResetPassword/'+newUser.Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        CNT_CSM_ResetPassword.resetPassword();

    }
}