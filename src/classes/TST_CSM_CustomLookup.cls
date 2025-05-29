@isTest
public class TST_CSM_CustomLookup {
    
    @isTest
    static void testfetchRecords() {
        
        User user_1;
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusername1@gmail.com', 
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
            EmployeeNumber ='08080808'
        );
        insert user_1;
        Test.startTest();
        CNT_CSM_CustomLookup.fetchRecords('User', 'FirstName', 'Firstname');
        CNT_CSM_CustomLookup.fetchRecords('Group', 'Name', 'Tech');
        Test.stopTest();
    }
}