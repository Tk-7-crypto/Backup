/**
* This test class is used to test all methods in User Domain class.
* version : 1.0
*/
@isTest
private class TST_DAOH_User {

    @testSetup
    private static void dataSetup() {
        upsert new  Mulesoft_Integration_Control__c();
        Account accContact = CSM_TestDataFactory.createAccount();
        insert accContact;
        
        Contact con1 = CSM_TestDataFactory.createContact(accContact.Id,  'SaurabhUser0110','ramsUser0110','noreply0110@dummy.com');
        con1.Contact_User_Type__c = 'HO User';
        insert con1;
        
        Contact con2 = CSM_TestDataFactory.createContact(accContact.Id,  'RichaUser0110','ramsUser0110','noreply0110@dummy.com');
        insert con2;
        
        User_Audit_Log_Setting__c testUserCode = new User_Audit_Log_Setting__c(Enable__c = true, Licences_to_Audit__c = 'Salesforce,Salesforce Platform');
        insert testUserCode;
        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Manager';
        insert partnerUser;
    }

    static testMethod void testCreateAssignPermissionSetToUser() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where DeveloperName = 'CSM' Limit 1];
        
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'sueas',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'johneAssign2@iqvia.com',IsActive =true ,Username ='johneAssign2@iqvia.com', LastName= 'testLastNameeAssign',EmployeeNumber='43457', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        //insert admin;
        System.runAs(admin) {
            
            user_1 = new User( 
                Email = 'yourusername@iqvia.com',
                ProfileId = profile_1.Id, 
                UserName = 'youruser12name123@gmail.com', 
                Alias = 'Test',
                EmployeeNumber = '0987898',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                Article_Manager__c = true,
                PortalRole = 'Manager',
                FirstName = 'FirstnameeAssignPS',
                LastName = 'LastnameeAssignPS',
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description'

            );
            insert user_1;
            user_1.Article_Manager__c = false;
            update user_1;
        }
    }

    @isTest
    static void testUpdateContactOnPortalUser(){
        UserRole portalRole = [Select Id,DeveloperName,PortalType  From UserRole Where DeveloperName = 'IQVIA_Global' and PortalType='None'];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber=String.valueOf(System.currentTimeMillis()), Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        //insert accOwner;
        Id contactRecordId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        
        system.runAs(accOwner){
            Account accContact = CSM_TestDataFactory.createAccount();
            insert accContact;
            Contact con1 = CSM_TestDataFactory.createContact(accContact.Id, 'SaurabhUser010','ramsUser010','noreply010@dummy.com');
            con1.Contact_User_Type__c = 'HO User';
            con1.EmployeeNumber__c = String.valueOf(System.currentTimeMillis());
            con1.RecordTypeId = contactRecordId;
            insert con1;
            
            Contact con2 = CSM_TestDataFactory.createContact(accContact.Id, 'Richa','ramsUser012','noreply012@dummy.com');
            insert con2;
            List<String> listOfName = new List<String>{'Customer Community Plus Login User', 'CSM Customer Community Plus Login User'};
            List<Profile> listOfProfile = [SELECT Id FROM Profile WHERE Name IN:listOfName];
            List<User> userlist = new List<User>();
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1', User__c = UserInfo.getUserId(), Type__c = 'Queue');
            insert qurPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = accContact.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = accContact.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            
            User usr1 = new User();
            usr1.FirstName = 'Harry';
            usr1.LastName = 'Singh';
            usr1.Alias = 'hsing';
            usr1.Email = 'noreply@demouser.com';
            usr1.Username = 'HarrySingh@gmail.com';
            usr1.CommunityNickname = 'HarrySingh';
            usr1.ProfileId = listOfProfile[0].Id;
            usr1.ContactId = con1.Id;
            usr1.TimeZoneSidKey = UserInfo.getTimeZone().getID();
            usr1.LocaleSidKey = 'en_US';
            usr1.LanguageLocaleKey = 'en_US';
            usr1.EmailEncodingKey = 'UTF-8';
            usr1.EmployeeNumber = String.valueOf(System.currentTimeMillis());
            userlist.add(usr1);
            
            User usr2 = new User();
            usr2.FirstName = 'Harjit';
            usr2.LastName = 'Kaur';
            usr2.Alias = 'hkaur';
            usr2.Email = 'noreply@demouser.com';
            usr2.Username = 'Harjitkaur@gmail.com';
            usr2.CommunityNickname = 'Harjitkaur';
            usr2.ProfileId = listOfProfile[1].Id;
            usr2.ContactId = con2.Id;
            usr2.TimeZoneSidKey = UserInfo.getTimeZone().getID();
            usr2.LocaleSidKey = 'en_US';
            usr2.LanguageLocaleKey = 'en_US';
            usr2.EmployeeNumber = String.valueOf(System.currentTimeMillis());
            usr2.EmailEncodingKey = 'UTF-8';
            userlist.add(usr2);
            
            Test.startTest();
            insert userlist;
            Test.stopTest();
            
            System.assertEquals(2, userlist.size(), 'Successful Inserted');
        }
    }
    
    @isTest 
    static void testQueue() {
        //List<User> aUsers = [select Id from User];
        
        User u = new User (
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@accenture.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = '09873898',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'
        );
        
        insert u;
        u.EmployeeNumber = '887866';
        update u;
        User u1 = new User (
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last1',
            Email = 'puser001@accenture.com',
            Username = 'puser001@accenture.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title1',
            Alias = 'alias1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = '09827898',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'

        );
        
        insert u1;
        
        User u2 = new User (
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last1',
            Email = 'puser002@accenture.com',
            Username = 'puser002@accenture.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            EmployeeNumber = '02987898',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description'

        );
        
        insert u2;
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        
        GroupMember grpUser = new GroupMember (
            UserOrGroupId = u.Id,
            GroupId = g1.Id);
        
        insert grpUser;
        
        GroupMember grpUser1 = new GroupMember (
            UserOrGroupId = u1.Id,
            GroupId = g1.Id);
        
        insert grpUser1;
        
        GroupMember grpUser2 = new GroupMember (
            UserOrGroupId = u2.Id,
            GroupId = g1.Id);
        
        insert grpUser2;
        
        DAOH_User.manageQueuesRelations();
        
        DAOH_User.manageUserQueuesRelations(new List<Group>{g1});
        
    }
    
    @isTest 
    static void testCreateContactForUser() {
        User_Contact_Sync__c testUserContactSync = UTL_TestData.createUserContactSync();
        insert testUserContactSync;
        
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        Test.startTest();
        insert userList;
        userList[0].Phone = '123456';
        update userList;
        Test.stopTest();
    }
    
    @isTest static void TestUserActivationDeactivation() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@iqvia.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,EmployeeNumber = '091287898',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersugan@iqvia.com', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert u;
        List<String> t = new List<String>();
        for (AggregateResult tName : [select Territory2Id tId from UserTerritory2Association group by Territory2Id limit 3] ){
            t.add(String.valueof(tName.get('tId')));
        }
        UserTerritory2Association t1 = new UserTerritory2Association(UserId=u.Id, Territory2Id=t[0]);
        UserTerritory2Association t2 = new UserTerritory2Association(UserId=u.Id, Territory2Id=t[1]);
        UserTerritory2Association t3 = new UserTerritory2Association(UserId=u.Id, Territory2Id=t[2]);
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
        insert q1;
        
        GroupMember grpUser = new GroupMember (UserOrGroupId = u.Id,GroupId = g1.Id);
        insert grpUser;
        
        Test.startTest();
        
        insert t1;
        insert t2;
        u.IsActive = False; // To set values in the Custom field
        Database.SaveResult result = Database.update(u, false);
        System.assert(result.isSuccess());
        
        insert t3; // To test Duplicate set for territory values assigned for Inactive users before Activation
        u.IsActive = True;
        Database.SaveResult result1 = Database.update(u, false);
        //System.assert(result1.isSuccess());
        
        u.IsActive = False; // To clear the record in territory object and set field value.
        update u;
        
        u.IsActive = True; // This will auto assign the territory to the user based on field value.
        Database.SaveResult result3 = Database.update(u, false);
        u.Change_Request_Ticket_Number__c = 'IQVIA001234';
        //System.assert(result3.isSuccess());
        update u;
        Test.stopTest();
    }

    @isTest
    static void testManageTpaRecordSharing() {
        Profile tpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP'];
        
        Account testAccount = new Account( name = 'TPA Test Account1',
                                           BillingCountry = 'India',
                                           BillingState = 'Delhi',
                                           BillingCity = 'Test',
                                           BillingStreet = 'Test',
                                           BillingPostalCode = '123',
                                           CustomerSegment__c = 'GOVERNMENT',
                                           Sub_Industry__c = 'STATE' );
        insert testAccount;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAddress(); 
        testAccount1.Name = 'Test Account 1';
        testAccount1.Account__c = testAccount.Id;
	    testAccount1.Is_TPA_Account__c = true;
	    testAccount1.Vendor_Registration_Number__c = 1234;
        insert testAccount1;
        
        Contact testContact1 = UTL_TPA_SetupTestData.getContact();
        testContact1.AccountId = testAccount1.Account__c;
        testContact1.LastName = 'Test Contact 1';
        insert testContact1;
        
        List<Contact_Address_Crosswalk__c> crosswalkObjList = new List<Contact_Address_Crosswalk__c>();
        Contact_Address_Crosswalk__c crosswalkObj1 = UTL_TPA_SetupTestData.getjunctionRecord(testContact1.Id, testAccount1.Id);
        crosswalkObjList.add(crosswalkObj1);
        
        insert crosswalkObjList;
		
        List<User> tpProcessors = new List<User>();
        User tpProcessor1 = UTL_TPA_SetupTestData.getUser();
        tpProcessor1.ProfileId = tpProcessorProfile.id;
        tpProcessor1.UserName='testuser1@testing.com';
        tpProcessor1.ContactId = testContact1.id;
        tpProcessors.add(tpProcessor1);
        
        insert tpProcessors;
    }
    
    @isTest
    static void testCheckduplicateEmployeeNumber() {
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        userList[0].Audit_Employee_Number_Reason__c = 'testabc';
        insert userList;
        userList[0].EmployeeNumber = 'N/A';
        System.runAs(userList[0]) {
            update userList[0];   
        }
        Test.startTest();
        userList = UTL_TestData.createUser(CON_CRM.COMMERCIAL_OPERATION_PROFILE, 1);
        userlist[0].EmployeeNumber = '0987898344';
        insert userList;
        System.runAs(userList[0]) {
            try {
                userList[0].EmployeeNumber = 'ABCD';
                update userList;
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }   
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInsertAuditLog() {
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        userList[0].LastName = 'testsystem';
        userList[0].IsActive = true;
        userList[0].EmployeeNumber = '0987898';
        Test.startTest();
        insert userList;
        User testUser = [select id,User_License_Type__c from User where LastName = 'testsystem'][0];
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'].Id; 
        testUser.Change_Request_Description__c = 'test2';
        testUser.Change_Request_Ticket_Number__c ='test2 description';
        update testUser;
        Test.stopTest();
    }

    @isTest
    static void testUpdateResetPassword() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service User' LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where DeveloperName = 'CSM' Limit 1];
        
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber = '098783498', Email = 'john2@iqvia.com',IsActive =true ,Username ='john2.test@iqvia.com', LastName= 'testLastName', CommunityNickname ='tesuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
		
        admin.Reset_Password_Scheduled_Date__c = Date.today();
        Test.startTest();
            insert admin;
        Test.stopTest();

        admin = [select Id,Generate_New_Password__c from User where Id =: admin.Id limit 1];
        System.assertEquals(true, admin.Generate_New_Password__c,'checkbox is updated');
        
    }

    @isTest
    static void testAssignCallCenterManagePackage(){
        CallCenter callRecord = [SELECT Id, Name, Version FROM CallCenter WHERE Name = 'Connects for Cisco Contact Center V7 USA' LIMIT 1];
        UserRole portalRole = [Select Id, DeveloperName, PortalType From UserRole Where DeveloperName = 'IQVIA_Global' and PortalType='None'];
        Id profileId = [select id from Profile where Name='System Administrator'].Id;
        User adminUser = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profileId,EmployeeNumber = '098789877', Email = 'johndoe@iqvia.com', IsActive =true, Username ='johndoe@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', CallCenterId=callRecord.Id, Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        
        Test.startTest();
        insert adminUser;
        Test.stopTest();
    }
    @isTest
    static void testCon(){
        Contact testContact1 = new Contact();
        testContact1.RecordTypeId = Con_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContact1.EmployeeNumber__c = String.valueOf(System.currentTimeMillis());
        testContact1.LastName = 'Test Contact 1';
        insert testContact1;
        Id profileId = [select id from Profile where Name='System Administrator'].Id;
        User adminUser = New User(Alias = 'su', ProfileId = profileId,EmployeeNumber = testContact1.EmployeeNumber__c, Email = 'johndoe1@iqvia.com', IsActive =true, Username ='johndoe1@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        
        Test.startTest();
        insert adminUser;
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmails(){
        Contact testContact1 = new Contact();
        testContact1.RecordTypeId = Con_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContact1.EmployeeNumber__c = String.valueOf(System.currentTimeMillis());
        testContact1.LastName = 'Test Contact 1';
        insert testContact1;
        Id profileId = [select id from Profile where Name='System Administrator'].Id;
        User adminUser = New User(Alias = 'su', ProfileId = profileId,EmployeeNumber = testContact1.EmployeeNumber__c, Email = 'johndoe1@iqvia.com', IsActive =true, Username ='johndoe1@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
		CRM_Config__c crmConfig = CRM_Config__c.getOrgDefaults();
		crmConfig.User_Creation_Notification_Recipients__c = 'test@metacube.com';
		upsert crmConfig;		
		Test.startTest();
        insert adminUser;
        Test.stopTest();
        List<Workflow_Email_Record__c> records = [Select Id from Workflow_Email_Record__c];
        System.assertEquals(true, records.size()>0);
    }
    
    @IsTest
    static void testUpdateServiceCloudUserValue(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User userRecord = New User(Alias = 'su', ProfileId = profileId,EmployeeNumber = '23445', Email = 'johndoe1@iqvia.com', IsActive =true, Username ='johndoe1@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        userRecord.UserPermissionsSupportUser = true;
        
        Test.startTest();
            insert userRecord;
        Test.stopTest();
        
        User updatedUser = [SELECT Service_Cloud_User__c FROM User WHERE Id =: userRecord.Id];
        System.assertEquals(true, updatedUser.Service_Cloud_User__c, 'Should update service cloud user field');
    }
    
    @IsTest
    static void testUpdatePRMSuperUser(){
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        
        Account ac = TST_PEP_TestDataFactory.createAccount('PRMTest');
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
    
        Contact con = new Contact(FirstName = 'TestFirstNamePRM', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com',Inactive__c = false);
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;
        
        User user = new User(alias = 'gdf', email='partneruser@iqvia.partner.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='test10101prm@xyz.com',
                             Change_Request_Description__c = 'test',
                             Change_Request_Ticket_Number__c ='test description',
                             EmployeeNumber = String.valueOf(System.currentTimeMillis())
                            );
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Test.startTest();
            insert user;
        Test.stopTest();
    }
    
}