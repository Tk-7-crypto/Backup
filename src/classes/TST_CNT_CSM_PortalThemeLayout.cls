/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalThemeLayout
 */
@isTest
private class TST_CNT_CSM_PortalThemeLayout {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='072070707', Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert accOwner;
        
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Contact contact = UTL_TestData.createContact(account.Id);
            insert contact;
            
            Id technoCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
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
            Case c = New Case(Subject = 'TestCase',RecordTypeId=technoCaseRecordTypeId, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
            insert c;

            Major_Incident__c majorIncident = new Major_Incident__c();
            majorIncident.Major_Incident_Subject__c = 'Test Subject ';
            majorIncident.Major_Incident_Description__c = 'Test Description ';
            majorIncident.Major_Incident_Internal_Communication__c = 'Internal Communication ';
            majorIncident.Major_Incident_Customer_Communication__c = 'Customer Communication ';
            
            insert majorIncident;
            
            MI_AccountRelationship__c miaRecord = new MI_AccountRelationship__c();
            miaRecord.Major_Incident__c = majorIncident.Id;
            miaRecord.Accounts_Impacted__c = account.Id;
            insert miaRecord;
            
            MI_CaseRelationship__c micRecord = new MI_CaseRelationship__c();
            micRecord.Major_Incident__c = majorIncident.Id;
            micRecord.Cases_Relationship__c = c.Id;
            insert (micRecord);
            
            majorIncident.Status__c = CON_CSM.S_IN_PROGRESS;
            update majorIncident;
        }
    }
    /**
     * This method used to get contact for current user
     */    
    @IsTest
    static void testGetUserContact() {
        List<Contact> contacts = new List<Contact>();
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
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
            
        Test.startTest();
        system.runAs(user){
            contacts = CNT_CSM_PortalThemeLayout.getUserContact();
            Boolean b = CNT_CSM_PortalThemeLayout.checkTPAPermissionSetsAssigned(new List<String>{'CSM Customer Community Plus Login User'});
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contacts.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testGetMajorIncidents() {
        List<Major_Incident__c> majorIncident = new List<Major_Incident__c>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];  
        Test.startTest();
        majorIncident = CNT_CSM_PortalThemeLayout.getMajorIncidents(acc.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = majorIncident.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    private static void testGetCurrentUserInfo() {
        Test.startTest();
            User currentUser = CNT_CSM_PortalThemeLayout.getCurrentUserInfo();
        Test.stopTest();
        System.assertEquals(true, currentUser != null, 'Should get current user detail');
    }
}