@isTest
public class TST_CNT_PEP_PartnerPortalSearch {
    
    @testSetup
    static void dataSetup() { 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, EmployeeNumber ='08080808');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
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
            Case c = New Case(Subject = 'TestCase',RecordTypeId=technoCaseRecordTypeId, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=qurPortal.Id,InitialQueue__c = 'Q1');
            insert c;
            
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,IsVisibleInPrm=true, Partner_Type__c = 'Integrator Partner');
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Knowledge_Account_RelationShip__c kar = new Knowledge_Account_RelationShip__c(Knowledge__c = knowledge.Id, Account__c = account.Id);
            insert kar;
            
            Knowledge__kav knowledge2 = New Knowledge__kav(Title = 'TestTitle2', language = 'en_US',UrlName='TestUrlName2', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,IsVisibleInPrm=true, Partner_Type__c = 'Integrator Partner');
            insert knowledge2;
            Knowledge__kav k2 = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge2.Id];
            KbManagement.PublishingService.publishArticle(k2.KnowledgeArticleId, true);
            
        }
    }
    
    @IsTest
    static void testSearchForIds() {
        List<CNT_PEP_PartnerPortalSearch.PEP_SearchResult> r = new  List<CNT_PEP_PartnerPortalSearch.PEP_SearchResult>();
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
            Partner_Type__c = 'Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Id [] fixedSearchResults= new Id[3];
        fixedSearchResults[0] = c[0].Id;
        fixedSearchResults[1] = k[0].Id;
        fixedSearchResults[2] = k[1].Id;
        system.runAs(user){
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            r = CNT_PEP_PartnerPortalSearch.searchForIds('Test','',10,0);
            Test.stopTest();
        }
    }
    
    
}
