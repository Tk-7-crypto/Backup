/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalReports
 */
@isTest
public class TST_CNT_CSM_PortalReports {
    /**
    * This method used to set up testdata
    */
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 's123u',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='070701707', Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
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
            String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
            User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            insert user;
            CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
            dTSh.ParentId = dT.Id;
            dTSh.UserOrGroupId = user.Id;
            dTSh.AccessLevel = 'Read';
            dTSh.RowCause='manual';
            Database.insert(dTSh,false);
            
            Dashboards_Reports_Category__c drc = New Dashboards_Reports_Category__c (Name='drc', Pillar__c='Technology Solutions');
            insert drc;
            Dashboards_Reports_Category__Share drcS = new Dashboards_Reports_Category__Share(ParentId = drc.Id,
            UserOrGroupId = user.Id,AccessLevel = 'Read',RowCause='manual');
            Database.insert(drcS,false);
            Dashboards_Category_Relationship__c dc = New Dashboards_Category_Relationship__c (Dashboards_Reports_Category__c = drc.Id, DashboardId__c='aId' );
            insert dc;
            Dashboards_Category_Relationship__Share dcS = new Dashboards_Category_Relationship__Share(ParentId = dc.Id,
            UserOrGroupId = user.Id,AccessLevel = 'Read',RowCause='manual');
            Database.insert(dcS,false);
            Reports_Category_Relationship__c rc = New Reports_Category_Relationship__c (Dashboards_Reports_Category__c = drc.Id, Report_Id__c='aId' );
            insert rc;
            Reports_Category_Relationship__Share rcS = new Reports_Category_Relationship__Share(ParentId = rc.Id,
            UserOrGroupId = user.Id,AccessLevel = 'Read',RowCause='manual');
            Database.insert(rcS,false);
            Einstein_Analytics_Category_Relationship__c ec = New Einstein_Analytics_Category_Relationship__c (Dashboards_Reports_Category__c = drc.Id, Einstein_Analytics_Id__c='aId' );
            insert ec;
             Einstein_Analytics_Category_Relationship__Share ecS = new Einstein_Analytics_Category_Relationship__Share(ParentId = ec.Id,
            UserOrGroupId = user.Id,AccessLevel = 'Read',RowCause='manual');
            Database.insert(ecS,false);
            Account_Dashboards_Reports_Category_RS__c adrc = New Account_Dashboards_Reports_Category_RS__c (Dashboards_Reports_Category__c = drc.Id,Account__c = account.Id);
            insert adrc;
            Account_Dashboards_Reports_Category_RS__Share adrcS = new Account_Dashboards_Reports_Category_RS__Share(ParentId = adrc.Id,
            UserOrGroupId = user.Id,AccessLevel = 'Read',RowCause='manual');
            Database.insert(adrcS,false);
            
        }
    }

    /**
    * This method used to get List<Contact> for current user
    */
    /*
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
    String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
    User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
    insert user;
    Test.startTest();
    List<Contact> contacts = new List<Contact>();
    system.runAs(user){
        contacts =  CNT_CSM_PortalReports.getUserContact();
    }
    Test.stopTest();
    Integer expected = 1;
    Integer actual = contacts.size();
    }
    */
    @IsTest
    static void testGetDashboardsAndReportsForCurrentUser() {
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        User su = [select Id from User where Alias = 's123u'][0];
        User user = [select Id from User where Alias = 'com' and Email = 'john@acme.com' LIMIT 1];
        system.runAs(su){
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'CSM_Einstein_Analytic_for_Community'][0];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
        }
        Test.startTest();
        List<CNT_CSM_PortalReports.dashboardsReportsWrapper> dashboards_reports_list = new List<CNT_CSM_PortalReports.dashboardsReportsWrapper>();
        system.runAs(user){
            dashboards_reports_list =  CNT_CSM_PortalReports.getDashboardsAndReportsForCurrentUser();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = dashboards_reports_list.size();
    }

    @IsTest
    static void testGetPrivateReports() { 
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = [select Id from User where Alias = 'com' and Email = 'john@acme.com' LIMIT 1];
        Test.startTest();
        List<Report> reports_list = new List<Report>();
        system.runAs(user){
            reports_list =  CNT_CSM_PortalReports.getPrivateReports();
        }
        Test.stopTest();
    }
}