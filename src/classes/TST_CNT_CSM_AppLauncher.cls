@isTest
public class TST_CNT_CSM_AppLauncher {
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        account.AccountCountry__c='US';
        account.Website='http://www.iqvia.com';
        insert account;
        CSM_QI_App_Launcher__c app = new CSM_QI_App_Launcher__c(Pillar__c='Technology Solutions', Country__c='US', Name='IQVIA App', Url__c='http://wwww.IQVIA.com');
        insert app;
    }
    
    @IsTest
    static void testGetAppLauncherForCurrentUser() {
        List<CSM_QI_App_Launcher__c> apps = new List<CSM_QI_App_Launcher__c>();
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
            apps = CNT_CSM_AppLauncher.getAppLauncherForCurrentUser();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = apps.size();
       // System.assertEquals(expected, actual);
        
    }
}