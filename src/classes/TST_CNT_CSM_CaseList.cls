/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_CaseList
 */
@isTest
private class TST_CNT_CSM_CaseList {
    @testSetup
    static void dataSetup() {
        CSM_Community_ListView_Config__c lvConfig= new CSM_Community_ListView_Config__c();
        lvConfig.Name='TestListView';
        lvConfig.en__c='ListViewEn';
        lvConfig.fr__c='ListViewFr';
        lvConfig.it__c='ListViewIt';
        lvConfig.jp__c='ListViewJp';
        lvConfig.pt__c='ListViewPt';
        lvConfig.ru__c='ListViewRu';
        lvConfig.pl__c='ListViewPl';
        lvConfig.zh__c='ListViewZh';
        lvConfig.ja__c='ListViewJa';
        lvConfig.es__c='ListViewEs';
        lvConfig.de__c='ListViewDe';
        lvConfig.order__c=0;
        lvConfig.portal_Case_Type__c='Technology Solutions';
        lvConfig.Restricted_Product__c='';
        insert lvConfig;

        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
    }

    @IsTest
    static void testGetUserContact() {
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
        List<Contact> c = new List<Contact>();
        system.runAs(user){
            c = CNT_CSM_CaseList.getUserContact();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = c.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetCSMCommunityListViewForCurrentUser() {
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
        List<CSM_Community_ListView_Config__c> listviews = new List<CSM_Community_ListView_Config__c>();
        system.runAs(user){
            listviews = CNT_CSM_CaseList.getCSMCommunityListViewForCurrentUser();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = listviews.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetCSMCommunityListViewConfig() {
        Test.startTest();
        List<CSM_Community_ListView_Config__c> config = new List<CSM_Community_ListView_Config__c>();
        config = CNT_CSM_CaseList.getCSMCommunityListViewConfig();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = config.size();
        System.assertEquals(expected, actual);
    }
}