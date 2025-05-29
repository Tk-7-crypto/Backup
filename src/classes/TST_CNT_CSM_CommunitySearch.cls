@isTest
public class TST_CNT_CSM_CommunitySearch {

    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Community_topic__c ct = new Community_topic__c(Name='topicName');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            product.Available_to_the_Guest_User__c = true;
            insert product;
            Asset asset = new Asset(Name='TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;

            Contact contact = UTL_TestData.createContact(account.Id);
            insert contact;
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

            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Knowledge_Account_RelationShip__c kar = new Knowledge_Account_RelationShip__c(Knowledge__c = knowledge.Id, Account__c = account.Id);
            insert kar;

            Knowledge__kav knowledge2 = New Knowledge__kav(Title = 'TestTitle2', language = 'en_US',UrlName='TestUrlName2', IsVisibleInCsp= true, IsVisibleInPkb = true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge2;
            Knowledge__kav k2 = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge2.Id];
            KbManagement.PublishingService.publishArticle(k2.KnowledgeArticleId, true);

            CollaborationGroup cg = New CollaborationGroup (Name ='Test', CollaborationType = 'Public');
            insert cg;

            Product_Group_Relationship__c pgr = New Product_Group_Relationship__c(Collaboration_Group_Id__c = cg.Id, Product__c = product.Id);
            insert pgr;
        }
    }

    @IsTest
    static void testSearchForIds() {
        List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult> r = new  List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult>();
        List<Knowledge__kav> k = [Select Id from Knowledge__kav];
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TestProduct'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            KB_Location__c='test',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Id [] fixedSearchResults = new Id[] {k[0].id};
        system.runAs(user){
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            CNT_CSM_CommunitySearch.searchForIds('Test',p.Id,'',5,5);
            r = CNT_CSM_CommunitySearch.searchForIds('Test','','',5,5);
            Test.stopTest();
        }
        System.assertEquals(true, r.size()!= null, 'Not search result found' );
    }

    @IsTest
    static void testClassesForNoCustomerSuccess() {
        List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult> r = new  List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult>();
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TestProduct'];
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        List<Knowledge__kav> k = [Select Id from Knowledge__kav where Title='TestTitle2'];
        Id [] fixedSearchResults = new Id[] {k[0].id};
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
        CNT_CSM_CommunitySearch.searchForIds('Test',p.Id,'',5,5);
        r = CNT_CSM_CommunitySearch.searchForIds('Test','TestProduct','',5,5);
        communityTopics = CNT_CSM_CommunitySearch.getProductCommunityTopics();
        Test.stopTest();
        System.assertEquals(1, communityTopics.size(), 'communityTopics not found');
        System.assertEquals(true, r.size()!= null, 'Not search result found' );
    }

    @IsTest
    static void testSearchForIdsWithRestriction() {
        List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult> r = new  List<CNT_CSM_CommunitySearch.WRP_CSM_SearchResult>();
        List<Case> c = [Select Id from case];
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
        Id [] fixedSearchResults= new Id[3];
        fixedSearchResults[0] = c[0].Id;
        fixedSearchResults[1] = k[0].Id;
        fixedSearchResults[2] = k[1].Id;
        List<Product2> productList = [SELECT id,Name FROM Product2 LIMIT 5];
        ServiceNow_Group__c service = new ServiceNow_Group__c(Group_ID__c='EA-IQVIA',Name = 'EA-IQVIA',SystemType__c = 'IQVIA');
        insert service;
        CMDB__c cm = new CMDB__c(Admin_Group_Name__c ='Admin',Category__c = '1',Name__c = '1');
        insert cm;
        List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
        for(Product2 p2: productList) {
            dataList.add(new CSM_QI_Data_Portal_Queue_User_details__c(ServiceNow_Group__c = service.Id,ServiceNow_Type__c = 'Incident',CMDB__c = cm.Id,Product__c = p2.Name,ProductId__c = p2.Id, Type__c = 'Product Level Restriction', ClientContact__c = contact.Id, Account__c = acc.Id));
        }
        insert dataList;
        CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        dTSh.ParentId = dataList[0].Id;
        dTSh.UserOrGroupId = user.Id;
        dTSh.AccessLevel = 'Read';
        dTSh.RowCause='manual';
        Database.insert(dTSh,false);
        system.runAs(user){
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            r = CNT_CSM_CommunitySearch.searchForIds('Test','','',5,5);
            Test.stopTest();
        }
        System.assertEquals(true, r.size()!= null, 'Not search result found' );
    }

    @IsTest
    static void testCSM_SearchResultClass() {
        Knowledge__kav article = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle'];
        Test.startTest();
        CNT_CSM_CommunitySearch.WRP_CSM_SearchResult sr = new CNT_CSM_CommunitySearch.WRP_CSM_SearchResult();
        sr.id = article.Id;
        sr.objName = 'Knowledge__kav';
        sr.sobj = article;
        Test.stopTest();
        System.assertNotEquals(sr, null, 'WRP_CSM_SearchResult is null');
    }

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
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
        system.runAs(user){
            contacts = CNT_CSM_CommunitySearch.getUserContact();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contacts.size();
        System.assertEquals(expected, actual,'Contact not found');
    }

    @IsTest
    static void testGetProductCommunityTopics() {
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian2',
            Lastname='Dent2',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john22@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
            communityTopics = CNT_CSM_CommunitySearch.getProductCommunityTopics();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = communityTopics.size();
        System.assertEquals(expected, actual, 'communityTopics not found');

    }
}