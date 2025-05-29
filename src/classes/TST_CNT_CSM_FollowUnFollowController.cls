/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_FollowUnFollowController
 */
@isTest
private class TST_CNT_CSM_FollowUnFollowController {
    @testSetup
    static void dataSetup() {
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        accOwner.EmployeeNumber = '0707070719';
        insert accOwner;
        
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.Website = 'www.test.com';
            account.ownerId=accOwner.Id;
            insert account;
            Contact contact = new Contact( 
                Firstname='Brian', 
                Lastname='Dent', 
                Phone='(619)852-4569', 
                Department='Mission Control', 
                Title='Mission Specialist - Neptune', 
                Email='john@acme.com',
                Portal_Case_Type__c = 'Technology Solutions',
                Contact_User_Type__c='HO User',
                AccountId = account.Id);
            insert contact;
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
            insert qurPortal;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
            User user = new User(Alias = 'com', Email = 'johnCommunity@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            insert user;
            Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
            queues.Name ='Q1';
            queues.QueueName__c ='Q1';
            queues.Type__c ='Queue';
            queues.User__c = UserInfo.getUserId();
            insert queues;
            Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
            queueUser.Name ='Q1';
            queueUser.QueueName__c ='Q1';
            queueUser.Type__c ='User';
            queueUser.User__c = UserInfo.getUserId();
            insert queueUser;
            Case c = new Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
            insert c;
            system.runAs(user) {
                CSM_QI_Case_Follower__c cf = new CSM_QI_Case_Follower__c(Contact__c=user.ContactId, Case__c=c.Id);
                insert cf;
            }
        }
    }

    @IsTest
    static void testRecordIsFollowed() {
        Boolean isFollowed = false;
        List<Case> cases = [SELECT Id FROM Case WHERE Subject = 'TestCase' ];
        User u = [Select id from User where Email = 'johnCommunity@acme.com'][0];
        Test.startTest();
        system.runAs(u) {
            isFollowed = CNT_CSM_FollowUnFollowController.recordIsFollowed(cases[0].Id);
        }
        Test.stopTest();
        Boolean expected = true;
        System.assertEquals(expected, isFollowed);
    }

    @IsTest
    static void testFollowRecord() {
        Boolean isFollowed = true;
        List<Case> cases = [SELECT Id FROM Case WHERE Subject = 'TestCase' ];
        User u = [Select id from User where Email = 'johnCommunity@acme.com'][0];
        Test.startTest();
        system.runAs(u) {
            isFollowed = CNT_CSM_FollowUnFollowController.followRecord(cases[0].Id, isFollowed);
        }
        Boolean expected = false;
        System.assertEquals(expected, isFollowed);

        system.runAs(u) {
            isFollowed = CNT_CSM_FollowUnFollowController.followRecord(cases[0].Id, isFollowed);
        }
        Test.stopTest();
        expected = true;
        System.assertEquals(expected, isFollowed);
    }

}