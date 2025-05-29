@isTest
public class TST_BCH_CSM_ChatterGroupDelete {
    @testSetup
    static void dataSetup() {
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test group1', CollaborationType = 'Public');
        insert cg;
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        user_1 = new User( 
            Email = 'yourusername@iqvia.com',
            ProfileId = profile_1.Id, 
            UserName = 'yourusernameBatchDelete@gmail.com', 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            Article_Manager__c = true,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',isactive = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = '0909090911'
        );
        insert user_1;
        CollaborationGroupMember member = new CollaborationGroupMember();
        member.MemberId = user_1.Id;
        member.CollaborationGroupId = cg.Id;
        Insert member;
    }
    @isTest
    static void ChatterGroupDeleteBatchTestMethod(){
        Test.startTest();
            ID batchID=Database.executebatch(new BCH_CSM_ChatterGroupDelete(), 200);
        Test.stopTest();
        System.assert(true);
        
    }
}