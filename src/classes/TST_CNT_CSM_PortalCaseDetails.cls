@isTest
private class TST_CNT_CSM_PortalCaseDetails {

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
            
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
            Contact contact = new Contact(
                Firstname = 'Brian', 
                Lastname = 'Dent test', 
                Phone = '(619)852-4569', 
                Department = 'Mission Control', 
                Title = 'Mission Specialist - Neptune', 
                Email = 'john@acme.com.test',
                Portal_Case_Type__c = 'Technology Solutions',
                Contact_User_Type__c = 'HO User',
                AccountId = acc.Id);
            Insert contact;
        }  
      
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        Contact contact = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1];
        User communityUser = New User(Alias = 'com', Email = 'john@acme.com.test', IsActive = true , ContactId = contact.Id, ProfileId = profilId,
                             Username = 'john@acme.com.test', LastName = 'testLastNameSetup', CommunityNickname = 'testCommunityNicknameSetup', 
                             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
                             LanguageLocaleKey = 'en_US', LastLoginValue__c = System.now());
        Insert communityUser;
        System.runAs(communityUser) {
            Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
            
            Account accCase = new Account();
            accCase.RecordTypeId = mdmValidAccount;
            accCase.Name = 'Techno Portal';
            //accCase.RDCategorization__c = 'Sponsor';
            accCase.AccountCountry__c ='FR';
            accCase.CustomerSegment__c = 'GOVERNMENT';
            accCase.Sub_Industry__c = 'STATE';
            insert accCase;
            
            Contact conCase = new Contact();
            conCase.AccountId = accCase.Id;
            conCase.FirstName = 'test';
            conCase.LastName = 'portalUser';
            conCase.Salutation = 'Eng';
            conCase.Email = 'noreply@dummy.com';
            conCase.MailingCity = 'Bangalore';
            conCase.MailingCountry = 'India';
            conCase.MailingPostalCode = '560016';
            conCase.MailingState = 'Karnataka';
            conCase.MailingStreet = 'KB-11';
            Insert conCase;
            
            Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1].Id;
            Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1].Id;
            
            Queue_User_Relationship__c ff = [SELECT Id FROM Queue_User_Relationship__c WHERE Name ='Q1' LIMIT 1 ]; 
            Product2 p2 = UTL_TestData.createProduct();
            p2.Name = 'Nexxus MI';
            p2.SpecificToCSM__c = True;
            Insert p2;
            
            CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
            cc1.Product__c = p2.Id;
            cc1.Pillar__c = 'Technology Solutions';
            cc1.SubType1__c = 'Incident-Module';
            cc1.SubType2__c = 'Formularies';  
            cc1.SubType3__c = '--none--';
            cc1.Active__c = true;
            Insert cc1;
            
            Case cs = new Case();
            cs.ContactId = conObjId;
            cs.AccountId = accObjId;
            cs.AssignCaseToCurrentUser__c = false;
            cs.OwnerId = UserInfo.getUserId();
            cs.RecordTypeId = recordTypeIdTechno;
            cs.Priority = 'Medium';
            cs.Origin = 'Customer Portal';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Portal Techno Test case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.RootCause__c = 'Access Request';
            cs.CurrentQueue__c = ff.Id;
            cs.Previous_Queue__c = 'Tech CA TechSupport OK T2a';
            cs.Case_CategorizationId__c = cc1.Id;
            cs.SubType1__c = 'Incident-Module';
            cs.SubType2__c = 'Formularies';  
            cs.SubType3__c = '--none--';
            cs.Device__c = 'iPhone';
            cs.Resolution__c = 'test resolution';
            Insert cs;
        }
        System.runAs (accOwner) {
            Case caseRecord = [SELECT Id, Status FROM Case WHERE Subject = 'Portal Techno Test case'];
            caseRecord.Status = 'Closed';
            Update caseRecord;
        }
    }
    
    @isTest
    static void testUpdateLastLogin(){
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', LastLoginValue__c = System.now());
        insert user;
        Test.startTest();
        system.runAs(user){
            CNT_CSM_PortalCaseDetails.updateLastLogin();
        }
        Test.stopTest();
    }
    @isTest
    static void testUpdateMailCCList(){
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', LastLoginValue__c = System.now());
        insert user;
        Test.startTest();
        system.runAs(user){
            Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
            Account accCase = new Account();
            accCase.RecordTypeId = mdmValidAccount;
            accCase.Name = 'Site Portal';
            //accCase.RDCategorization__c = 'Site';
            accCase.AccountCountry__c ='BR';
            accCase.CustomerSegment__c = 'GOVERNMENT';
            accCase.Sub_Industry__c = 'STATE';
            insert accCase;
            Contact conCase = new Contact();
            conCase.AccountId = accCase.Id;
            conCase.FirstName = 'Saurabh';
            conCase.LastName = 'Sharma';
            conCase.Salutation = 'Eng';
            conCase.Email = 'noreply@dummy.com';
            conCase.MailingCity = 'Bangalore';
            conCase.MailingCountry = 'India';
            conCase.MailingPostalCode = '560016';
            conCase.MailingState = 'Karnataka';
            conCase.MailingStreet = 'KB-11';
            insert conCase;
            Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1].Id;
            Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent' LIMIT 1].Id;
            Queue_User_Relationship__c ff = [Select id from Queue_User_Relationship__c where name ='Q1'limit 1 ]; 
            Product2 p2 = UTL_TestData.createProduct();
            p2.Name = 'Nexxus';
            p2.SpecificToCSM__c = True;
            insert p2;
            CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
            cc1.Product__c= p2.Id;
            cc1.Pillar__c  ='Technology Solutions';
            cc1.SubType1__c = 'Incident-Module';
            cc1.SubType2__c = 'Formularies';  
            cc1.SubType3__c = '--none--';
            cc1.Active__c = true;
            insert cc1;
            Case cs = new Case();
            cs.ContactId = conObjId;
            cs.AccountId = accObjId;
            cs.AssignCaseToCurrentUser__c = false;
            cs.OwnerId = UserInfo.getUserId();
            cs.RecordTypeId = recordTypeIdTechno;
            cs.Priority = 'Medium';
            cs.Origin = 'Customer Portal';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno Test case';
            cs.Description = 'Test class to check case creation ';
            cs.Status = 'New';
            cs.CurrentQueue__c = ff.Id;
            cs.Previous_Queue__c ='Tech CA TechSupport OK T2a';
            insert cs;
            Case cc = [Select id,Mail_CC_List__c from case where Origin ='Customer Portal'];
            CNT_CSM_PortalCaseDetails.updateMailCCList(cc.Id,'Akash@metacube.com');
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetCloneCaseAsParentForFollowUpShouldRetrieve() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Portal Techno Test case'];
        
        Test.startTest();
            Case resultCase = CNT_CSM_PortalCaseDetails.getCloneCaseAsParentForFollowUp(caseRecord.Id, '', true);
        Test.stopTest();
        
        System.assertEquals(true, resultCase != null, 'Should get Case record');
    }
    
    
    @IsTest
    private static void testGetCloneCaseAsParentForFollowUp() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'Portal Techno Test case'];
        User communityUser = [SELECT Id FROM User WHERE LastName = 'testLastNameSetup'];
        System.runAs(communityUser) {
            Test.startTest();
            Case resultCase = CNT_CSM_PortalCaseDetails.getCloneCaseAsParentForFollowUp(caseRecord.Id, 'test description', false);
            Test.stopTest();
        }
        Case clonedCase = [SELECT Id FROM Case WHERE Subject = 'Portal Techno Test case' AND Status = 'New'];
        System.assertEquals(true, clonedCase != null, 'Should clone Case record');
    }

}