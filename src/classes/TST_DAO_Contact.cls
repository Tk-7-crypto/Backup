/**
 * This test class is used to test all methods in Contact Domain class.
 * version : 1.0
 */
@isTest
private class TST_DAO_Contact {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact testContact1 = UTL_TestData.createContact(newAccount.id);
        testContact1.Disposition__c = 'Test Disposition';
        insert testContact1;
        
        Contact testContact2 = UTL_TestData.createContact(newAccount.id);
        testContact2 .Disposition__c = 'Marketing to Nurture';
        testContact2 .Nurture_Detail__c = '3 months';
        insert testContact2 ;
        
        /*CSM Start*/
        Account acc = CSM_Util.createAccount();
          insert acc;
          Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
          insert cnt; 
        /*CSM End*/
        
    }
    
    /**
     * This test method used for insert Contact record
     */ 
    static testMethod void testInsertContact() {
        Account newAccount = [SELECT id FROM Account LIMIT 1];
        test.startTest();
            Contact newContact = UTL_TestData.createContact(newAccount.Id);
            insert newContact;
        test.stopTest();
        Contact existingContact = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Contact LIMIT 1];
        System.assertEquals(true, existingContact.Invalid_Email_Address__c);
        System.assertEquals(null, existingContact.Consented_to_Marketing_Emails__c);
    }
    
    /**
     * This test method used for update Contact record
     */ 
    static testMethod void testUpdateContact() {
        Account newAccount = [SELECT id FROM Account LIMIT 1];
        test.startTest();
            Contact newContact = UTL_TestData.createContact(newAccount.Id);
            newContact.Email = 'test123@iqvia.com';
            insert newContact;
            newContact.Email = null;
            update newContact;
        test.stopTest();
        Contact existingContact = [SELECT Id, Invalid_Email_Address__c, Consented_to_Marketing_Emails__c FROM Contact LIMIT 1];
        System.assertEquals(true, existingContact.Invalid_Email_Address__c);
        System.assertEquals(null, existingContact.Consented_to_Marketing_Emails__c);
    }
    
    /**
     * This test method used to create OutboundMessageDeletionQueue
     */ 
    static testMethod void testcreateOutboundMessageDeletionQueue() {
        Account newAccount = [SELECT id FROM Account LIMIT 1];
        Contact newContact = UTL_TestData.createContact(newAccount.Id);
        insert newContact;
        test.startTest();
            List<Contact> cntDeleteList = [SELECT Id FROM Contact];
            delete cntDeleteList;
            List<Outbound_Message_Deletion_queue__c> outboundList = [SELECT Id FROM Outbound_Message_Deletion_queue__c LIMIT 1];
        test.stopTest();
        System.assertEquals(1, outboundList.size());
    }
    
    /**
* This test method used for insert and update Case record for CSM Data Audit Log
*/ 
    static testMethod void testAuditforContact() {
     
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,Birthdate,FlashAlertMessage__c,PreferredChannel__c,JobRole__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(null,'CaseTestContact2');
        insert cnt2;
        cnt2.JobRole__c = 'Analyst';
        cnt2.PreferredChannel__c = 'Email';
        cnt2.FlashAlertMessage__c = 'Message Test';
        cnt2.AccountId = acc.Id;
        update cnt2;
        Test.startTest();
        cnt2.JobRole__c = 'Director';
        update cnt2;
        cnt2.JobRole__c = null;
        update cnt2;
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,JobRole__c,ReportsToId');
        cnt.ReportsToId = cnt2.Id;
        update cnt;
        Contact cnt3 = CSM_Util.createContact(null,'CaseTestContact3');
        insert cnt3;
        cnt.ReportsToId = cnt3.Id;
        update cnt;
        cnt.ReportsToId = null;
        update cnt;
        CNT_CSM_FieldHistoryTracking.saveFields('Contact','AccessToAllCasesOfTheAccou__c,AccountId,AssistantName,AssistantPhone,ReportsToId,MailingAddress');
        cnt.MailingCity = 'Bangalore';
        cnt.MailingCountry = 'India';
        cnt.MailingPostalCode = '560016';
        cnt.MailingState = 'Karnataka';
        cnt.MailingStreet = 'KB-11';
        update cnt;
        cnt.MailingCity = 'Paris';
        cnt.MailingCountry = 'France';
        cnt.MailingPostalCode = '500016';
        cnt.MailingState = 'Telangana';
        cnt.MailingStreet = 'TH-11';
        update cnt;
        cnt.MailingCity = null;
        cnt.MailingCountry = null;
        cnt.MailingPostalCode = null;
        cnt.MailingState = null;
        cnt.MailingStreet = null;
        update cnt;
        Test.stopTest();
    }
    
     /**
     * This test method used for insert contact records
     */ 
    static testMethod void testContactInsert() {   
        List<Contact> contacts = [SELECT Disposition__c, Disposition_Date__c, Nurture_Area__c, Nurture_Detail__c, Nurture_Detail_Other__c FROM Contact];
        
        for(Contact con : contacts) {
            if(con.Disposition__c == 'Test Disposition') {
                System.assertEquals(Date.today(), con.Disposition_Date__c);
            } else {
                System.assertEquals(null, con.Disposition__c);
                System.assertEquals(null, con.Disposition_Date__c);
                System.assertEquals(null, con.Nurture_Area__c);
                System.assertEquals(null, con.Nurture_Detail__c);
                System.assertEquals(null, con.Nurture_Detail_Other__c);
            }
        }
    }
    
    /**
     * This test method used for update lead records
     */ 
    static testMethod void testLeadUpdate() {   
        List<Contact> contacts = [SELECT Disposition__c, Disposition_Date__c, Nurture_Area__c, Nurture_Detail__c, Nurture_Detail_Other__c FROM Contact];
        
        Test.startTest();
            for(Contact con : contacts) {
                if(con.Disposition__c == 'Test Disposition') {
                    con.Disposition__c = 'Test Update';
                }
            } 
            update contacts;
        Test.stopTest();
        
        for(Contact con : contacts) {
            if(con.Disposition__c == 'Test Update') {
                System.assertEquals(Date.today(), con.Disposition_Date__c);
            } else {
                System.assertEquals(null, con.Disposition__c);
                System.assertEquals(null, con.Disposition_Date__c);
                System.assertEquals(null, con.Nurture_Area__c);
                System.assertEquals(null, con.Nurture_Detail__c);
                System.assertEquals(null, con.Nurture_Detail_Other__c);
            }
        }
    }
    
    /**
     * This test method used to Test resetLegacyAccountId
     */ 
    static testMethod void testResetLegacyAccountId() {   
        Contact cnt = [SELECT Id, AccountId FROM Contact LIMIT 1];
        cnt.AccountId = null;
        Test.startTest();
            update cnt;
        cnt = [SELECT Id, LI_Account_Id__c FROM Contact LIMIT 1];
        Test.stopTest();
        System.assertEquals(null, cnt.LI_Account_Id__c);
    }
    
    static testMethod void testCreateAssignPermissionSetToUser() {
        
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User' LIMIT 1];
        //User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
        User user_1;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
         
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User admin = New User(Alias = 'su',UserRoleId= portalRole.Id,EmployeeNumber ='999987', ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert admin;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE'  );
            insert account_1;
            
            Contact contact_1 = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='yourusername@gmail.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = account_1.Id);
            insert contact_1;
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
            insert qurPortal;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account_1.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account_1.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;            
            user_1 = new User( 
                Email = 'yourusername@iqvia.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                EmployeeNumber ='99994487',
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            ); 
            insert user_1;
            contact_1.AccessToAllCasesOfTheAccou__c = true;
            update contact_1;
            contact_1.AccessToAllCasesOfTheAccou__c = false;
            update contact_1;
        }
        
    }
    
    @isTest 
    static void testUpdateUserForContact() {
        User_Contact_Sync__c testUserContactSync = UTL_TestData.createUserContactSync();
        insert testUserContactSync;
        
        List<User> userList = UTL_TestData.createUser('System Administrator', 1);
        userList[0].EmployeeNumber ='9999844447';
        Test.startTest();
            insert userList;
        Test.stopTest();
        
        List<Contact> conList = [Select id,Phone,Salesforce_User__c,QI_User_Id__c from Contact where Salesforce_User__c != null];
        /*
        conList[0].Phone = '123456';
        conList[0].QI_User_Id__c = conList[0].Salesforce_User__c;
        update conList;
        
        userList = [Select Phone from User where Id = :conList[0].Salesforce_User__c];
        system.assertEquals('123456', userList[0].Phone);
		*/
    }
}