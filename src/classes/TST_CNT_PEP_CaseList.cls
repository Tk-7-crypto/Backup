/*
 * Version       : 1.0
 * Description   : Test Class for CNT_PEP_CaseList
 */
@isTest
private class TST_CNT_PEP_CaseList {
    @testSetup
    static void dataSetup() {
        PRM_Community_List_View_Config__c lvConfig= new PRM_Community_List_View_Config__c();
        lvConfig.Name='TestListView';
        lvConfig.en__c='ListViewEn';
        lvConfig.order__c = 0;
        lvConfig.portal_Case_Type__c = 'TestPortalCaseType';
        insert lvConfig;
        
        Account account = UTL_TestData.createAccount();
        account.Website = 'http://www.iqvia.com';
        insert account;
    }
    
    @IsTest
    static void testGetUserContact() {
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
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
        insert contact;
        
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john123@prm.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john123@prm.com', LastName= 'testPRMLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        
        Test.startTest();
        List<Contact> c = new List<Contact>();
        system.runAs(user){
            c = CNT_PEP_CaseList.getUserContact();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = c.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testGetPRMCommunityListViewConfig() {
        Test.startTest();
        List<PRM_Community_List_View_Config__c> config = new List<PRM_Community_List_View_Config__c>();
        config = CNT_PEP_CaseList.getPRMCommunityListViewConfig();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = config.size();
        System.assertEquals(expected, actual);
    }
}