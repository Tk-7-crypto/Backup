@istest
public class TST_CNT_CSM_LoginHistory {
    
    @isTest
    public static void tst_getLoginHistory()
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        Account account = UTL_TestData.createAccount(); 
        insert account;
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        
        Test.startTest();
        system.runAs(user){
            CNT_CSM_LoginHistory.UserLoginHistory userloginWrapper = CNT_CSM_LoginHistory.getLoginHistory(user.ContactId);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void testResetPasswordOrUnlockUserShouldUnlock() {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        String profilId2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Account account = UTL_TestData.createAccount(); 
        Insert account;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        Insert contact;
        
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(), Type__c = 'Queue');
        Insert qurPortal;
        
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c = 'Queue Assignment';
        dT.Order__c = 1;
        Insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c = 'Queue Assignment';
        dd.Order__c = 1;
        Insert dd;
        
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User communityUser = new User(Alias = 'com', Email = 'john@acme.com', IsActive = true, ContactId = contact.Id, 
                                      ProfileId = profilId, Username = ' john@acme.com', LastName = 'testLastName', 
                                      CommunityNickname = 'testCommunityNickname', TimeZoneSidKey = 'America/Los_Angeles', 
                                      LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        Insert communityUser;
        
        Test.startTest();
            CNT_CSM_LoginHistory.resetPasswordOrUnlockUser(communityUser.ContactId, false, true);
        Test.stopTest();
        
        UserLogin communityUserLogin = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId =: communityUser.Id];
        System.assertEquals(false, communityUserLogin.IsPasswordLocked, 'User should be unlocked');
    }
  
    @IsTest
    public static void testResetPasswordOrUnlockUserShouldReset() {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' Limit 1];
        String profilId2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Account account = UTL_TestData.createAccount(); 
        Insert account;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        Insert contact;
        
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(), Type__c = 'Queue');
        Insert qurPortal;
        
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c = 'Queue Assignment';
        dT.Order__c = 1;
        Insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c = 'Queue Assignment';
        dd.Order__c = 1;
        Insert dd;
        
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User communityUser = new User(Alias = 'com', Email = 'john@acme.com', IsActive = true, ContactId = contact.Id, 
                                      ProfileId = profilId, Username = ' john@acme.com', LastName = 'testLastName', 
                                      CommunityNickname = 'testCommunityNickname', TimeZoneSidKey = 'America/Los_Angeles', 
                                      LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        Insert communityUser;
        
        Test.startTest();
            CNT_CSM_LoginHistory.resetPasswordOrUnlockUser(communityUser.ContactId, true, false);
        Test.stopTest();
    }
}