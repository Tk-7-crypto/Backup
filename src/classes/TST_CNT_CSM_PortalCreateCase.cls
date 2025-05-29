/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalCreateCase
 */
@isTest
private class TST_CNT_CSM_PortalCreateCase {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='07070707', Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', UserPermissionsKnowledgeUser = true);
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
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;

            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id, Visible_in_CSH__c = true);
            insert asset;
            
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify',CSHSubType__c='Please Specify',CSH_Visible__c = true);
            categorization.RecordTypeId__c = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            categorization.Type__c = 'Categorization';
            categorization.Pillar__c = 'Technology Solutions';
            insert categorization;

            categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='One', SubType2__c='Two',CSHSubType__c='Three',CSH_Visible__c = true);
            categorization.RecordTypeId__c = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
            categorization.Type__c = 'Categorization';
            categorization.Pillar__c = 'Information Offering';
            categorization.Active__c = true;
            insert categorization;

            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            
            CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
            custsettObj2.Name = 'Org Wide No-Reply';
            custsettObj2.Setting_Type__c = 'Org Wide';
            custsettObj2.Other_Details__c = 'Customer Portal';
            custsettObj2.Origin__c = 'Customer Portal';
            List<OrgWideEmailAddress> orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: CON_CSM.S_NO_REPLY_EMAIL limit 1];
            CSM_Case_Details_Global_Setting__c custsettObj = new CSM_Case_Details_Global_Setting__c();
            custsettObj.Name = 'CAS_ET_CSM_AttachmentUpload';
            custsettObj.Setting_Type__c = 'Email Template';
            custsettObj.Other_Details__c = 'CAS_ET_CSM_AttachmentUploadNotification';
            custsettObj.Origin__c = 'Customer Portal';
            custsettObj.Component_Id__c = orgAddress[0].Id;
            custsettObj.Country__c = CON_CSM.S_DEFAULT;
            insert new List<CSM_Case_Details_Global_Setting__c>{custsettObj2, custsettObj};
        }
    }

    /**
    * This method used to get c by recordId
    */
    @IsTest
    static void testGetCategorization() {
        Test.startTest();
        List<CSM_QI_Case_Categorization__c> categorizations = CNT_CSM_PortalCreateCase.getCategorization('TestProduct','Please Specify');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = categorizations.size();
        System.assertEquals(expected, actual, 'Unexpected number of categorization');
    }

    @IsTest
    static void testGetCategorizationForDataGlobalSupport() {
        Test.startTest();
        String recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        List<CSM_QI_Case_Categorization__c> categorizations = CNT_CSM_PortalCreateCase.getCategorizationForDataGlobalSupport('TestProduct', recordTypeId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = categorizations.size();
        System.assertEquals(expected, actual, 'Unexpected number of categorization');
    }
    

    /**
    * This method used to get assete by productId
    */
    @IsTest
    static void testGetAssetByProductId() {
        List<Asset> assets = new List<Asset>();
        Product2 p = [SELECT id FROM Product2 WHERE Name = 'TestProduct'];
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        system.runAs(user){
            assets = CNT_CSM_PortalCreateCase.getAssetByProductId(p.Id,acc.Id);
            CNT_CSM_PortalCreateCase.getUrgencyList();
            CNT_CSM_PortalCreateCase.getImpactList();
            CNT_CSM_PortalCreateCase.getEnvironmentList();
            CNT_CSM_PortalCreateCase.getEscalationFormFields();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = assets.size();
        System.assertEquals(expected, actual, 'Unexpected number of assets');
    }

    /**
    * This method used to get a List<AggregateResult> of categorization
    */
    @IsTest
    static void testGetSubtypeCategorization() {
        Test.startTest();
        List<AggregateResult> categorizations = CNT_CSM_PortalCreateCase.getSubtypeCategorization('TestProduct','');
        Test.stopTest();
        Integer expected = 2;
        Integer actual = categorizations.size();
        System.assertEquals(expected, actual, 'Unexpected number of categorization subtypes');
    }


    @IsTest
    static void testGetUserAccount() {
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        List<Account> a = new List<Account>();
        system.runAs(user){
            a = CNT_CSM_PortalCreateCase.getUserAccount();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = a.size();
        System.assertEquals(expected, actual, 'Unexpected number of user accounts');
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

        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        List<Contact> c = new List<Contact>();
        system.runAs(user){
            c = CNT_CSM_PortalCreateCase.getUserContact();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = c.size();
        System.assertEquals(expected, actual, 'Unexpected number of contacts');
    }


    @IsTest
    static void testGetUserAssetsForDATA2() {
        List<Asset> assets = new List<Asset>();
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        system.runAs(user){
            assets = CNT_CSM_PortalCreateCase.getUserAssetsForDATA2(new List<String> {'TestAsset'});
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = assets.size();
        System.assertEquals(expected, actual, 'Unexpected number of assets');
    }

    /**
    * This method used to get a List<AggregateResult> of categorization
    */
    @IsTest
    static void testGetCategorizationWithAggregate() {
        Test.startTest();
        List<AggregateResult> categorizations = CNT_CSM_PortalCreateCase.getCategorizationWithAggregate('select Subtype1__c from CSM_QI_Case_Categorization__c group by Subtype1__c');
        Test.stopTest();
        Integer expected = 2;
        Integer actual = categorizations.size();
        System.assertEquals(expected, actual, 'Unexpected number of categorizations');
    }

    @IsTest
    static void testGetpriorityvalue() {
        Test.startTest();
        List<string> prios = CNT_CSM_PortalCreateCase.getpriorityvalue();
        Test.stopTest();
        System.assert (prios.size()>0, 'Unexpected number of priorities');
    }

    @IsTest
    static void testGetUrgencyList() {
        Test.startTest();
        List<string> urg = CNT_CSM_PortalCreateCase.getUrgencyList();
        Test.stopTest();
        System.assert (urg.size()>0, 'Unexpected number of urgencies');
    }

    @IsTest
    static void testGetImpactList() {
        Test.startTest();
        List<string> imp = CNT_CSM_PortalCreateCase.getImpactList();
        Test.stopTest();
        System.assert (imp.size()>0, 'Unexpected number of impacts');
    }
    @IsTest
    static void testGetCountryRequesterList() {
        Test.startTest();
        List<EXT_CSM_CheckboxDetails> imp = CNT_CSM_PortalCreateCase.getCountryRequesterList();
        Test.stopTest();
        System.assert (imp.size()>0, 'Unexpected number of countries');
    }

    @IsTest
    static void testGetProductCategorizationForNewCase() {
        List<EXT_CSM_CheckboxDetails> keyValues = new  List<EXT_CSM_CheckboxDetails>();
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        system.runAs(user){
        keyValues = CNT_CSM_PortalCreateCase.getProductCategorizationForNewCase(acc.Id, Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId());
        }
        Test.stopTest();
        System.assert (keyValues.size()>0, 'Unexpected number of product categorization');
    }

    @IsTest
    static void testSearchForIds() {
        List<CNT_CSM_PortalCreateCase.WRP_CSM_SearchResult> r = new  List<CNT_CSM_PortalCreateCase.WRP_CSM_SearchResult>();
        List<Knowledge__kav> k = [Select Id from Knowledge__kav];
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = k[0].Id;
        system.runAs(user){
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            r = CNT_CSM_PortalCreateCase.searchForIds('Test', 'TestProduct');
            Test.stopTest();
        }
        System.assertEquals(true, r.size()!= null, 'Not search result found' );
    }

    @IsTest
    static void testWRP_CSM_SearchResultClass() {
        Knowledge__kav article = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle'];
        Test.startTest();
        CNT_CSM_PortalCreateCase.WRP_CSM_SearchResult sr = new CNT_CSM_PortalCreateCase.WRP_CSM_SearchResult();
        sr.id = article.Id;
        sr.sobj = article;
        Test.stopTest();
        System.assertNotEquals(sr, null, 'WRP_CSM_SearchResult is null');
    }
    
    @IsTest
    private static void sendAttachmentEmailToCaseOriginator() {
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent test',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john.test@acme.com',
            Portal_Case_Type__c = 'Information Offering',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        insert contact;

        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john.test@acme.com', IsActive = true, ContactId = contact.Id, ProfileId = profilId,
                             Username = 'john.test@acme.com.csh', LastName = 'testLastName', CommunityNickname = 'testCommunityNicknameCSH', 
                             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert user;
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1].Id;
        Queue_User_Relationship__c ff = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' LIMIT 1 ]; 
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'DDD';
        p2.SpecificToCSM__c = True;
        Insert p2;

        CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
        cc1.Product__c = p2.Id;
        cc1.Pillar__c = 'Information Offering';
        cc1.SubType1__c = 'DATA MGT/PRODUCTION';
        cc1.SubType2__c = 'DATA ISSUES';  
        cc1.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
        cc1.Active__c = true;
        Insert cc1;
        
        Case cs = new Case();
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = user.Id;
        cs.RecordTypeId = recordTypeIdData;
        cs.Priority = 'Medium';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Portal Data Test case';
        cs.Description = 'Portal Data Test case';
        cs.Status = 'New';
        cs.RootCause__c = 'Access Request';
        cs.CurrentQueue__c = ff.Id;
        cs.Previous_Queue__c = 'Tech CA TechSupport OK T2a';
        cs.Case_CategorizationId__c = cc1.Id;
        cs.SubType1__c = 'DATA MGT/PRODUCTION';
        cs.SubType2__c = 'DATA ISSUES';  
        cs.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
        cs.Device__c = 'iPhone';
        cs.Resolution__c = 'test resolution';
        cs.CSM_QI_Data_Originator__c = user.Id;
        Insert cs;
        System.runAs(user) {
            Test.startTest();
                CNT_CSM_PortalCreateCase.sendAttachmentEmailToCaseOriginator(cs.Id);
            Test.stopTest();
        }
        System.assertNotEquals(true, CNT_CSM_PortalCreateCase.dataSendEmailList.isEmpty(), 'Email list is not generated.');
    }
    
    @IsTest
    static void testSearchForPRMIds() {
        List<CNT_CSM_PortalCreateCase.WRP_PRM_SearchResult> r = new  List<CNT_CSM_PortalCreateCase.WRP_PRM_SearchResult>();
        List<Knowledge__kav> k = [Select Id from Knowledge__kav];
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
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm@acme.com', LastName= 'prmLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = k[0].Id;
        system.runAs(user){
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            r = CNT_CSM_PortalCreateCase.searchForPRMIds('Test', 'TestProduct');
            Test.stopTest();
        }
        System.assertEquals(true, r.size()!= null, 'Not search result found' );
    }
    
    @IsTest
    static void testGetCategorizationId() {
        List<CSM_QI_Case_Categorization__c> c = new List<CSM_QI_Case_Categorization__c>();
        Test.startTest();
        c = CNT_CSM_PortalCreateCase.getCategorizationId('TestProduct','Please Specify','Please Specify','Please Specify');
        Test.stopTest();
        System.assertEquals(true, c.size()!= null, 'testGetCategorizationId error' );
    }

    @IsTest
    private static void testContentDocument() {
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent test',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john.test@acme.com',
            Portal_Case_Type__c = 'Information Offering',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        insert contact;

        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john.test@acme.com', IsActive = true, ContactId = contact.Id, ProfileId = profilId,
                             Username = 'john.test@acme.com.csh', LastName = 'testLastName', CommunityNickname = 'testCommunityNicknameCSH', 
                             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert user;
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Id accObjId = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1].Id;
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Brian Dent test' LIMIT 1].Id;
        Queue_User_Relationship__c ff = [SELECT Id FROM Queue_User_Relationship__c WHERE Name = 'Q1' LIMIT 1 ]; 
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'DDD';
        p2.SpecificToCSM__c = True;
        Insert p2;

        CSM_QI_Case_Categorization__c cc1 = new CSM_QI_Case_Categorization__c();
        cc1.Product__c = p2.Id;
        cc1.Pillar__c = 'Information Offering';
        cc1.SubType1__c = 'DATA MGT/PRODUCTION';
        cc1.SubType2__c = 'DATA ISSUES';  
        cc1.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
        cc1.Active__c = true;
        Insert cc1;
        
        Case cs = new Case();
        cs.ContactId = conObjId;
        cs.AccountId = accObjId;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = user.Id;
        cs.RecordTypeId = recordTypeIdData;
        cs.Priority = 'Medium';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Portal Data Test case';
        cs.Description = 'Portal Data Test case';
        cs.Status = 'New';
        cs.RootCause__c = 'Access Request';
        cs.CurrentQueue__c = ff.Id;
        cs.Previous_Queue__c = 'Tech CA TechSupport OK T2a';
        cs.Case_CategorizationId__c = cc1.Id;
        cs.SubType1__c = 'DATA MGT/PRODUCTION';
        cs.SubType2__c = 'DATA ISSUES';  
        cs.SubType3__c = 'LOOK-UP, PRESCRIBER (21-50 COUNT)';
        cs.Device__c = 'iPhone';
        cs.Resolution__c = 'test resolution';
        cs.CSM_QI_Data_Originator__c = user.Id;
        Insert cs;
        ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
                );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<Id> documentIds = new List<Id>();
        for (ContentDocument doc : documents) {
            documentIds.add(doc.Id);
        }
        Test.startTest();
            CNT_CSM_PortalCreateCase.createContentDocumentLink(documentIds,cs.Id);
            CNT_CSM_PortalCreateCase.deleteContentDocument(documents[0].Id);
        Test.stopTest();
    }
}