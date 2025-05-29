@isTest
public class TST_CNT_CSM_CommunityFavorites {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.Website = 'www.test.com';
            account.ownerId=accOwner.Id;
            insert account;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = new Asset(Name='TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
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
            String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
            User user = new User(Alias = 'com', Email = 'johnCommunity@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            insert user;
            Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
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
            Case c = new Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
            insert c;
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            
            system.runAs(user) {
                CSM_QI_Favorite_Record__c fav1 = New CSM_QI_Favorite_Record__c (EntityName__c= 'Knowledge__kav' , EntityId__c = k.KnowledgeArticleId,  User__c = UserInfo.getUserId());
                insert fav1;
                CSM_QI_Favorite_Record__c fav2 = New CSM_QI_Favorite_Record__c (EntityName__c= 'Case' , EntityId__c = c.Id,  User__c = UserInfo.getUserId()); 
                insert fav2;
            }
        }
    }

    @IsTest
    static void testGetFavorites() {
        List<CNT_CSM_CommunityFavorites.CSM_Favorite> favList = new  List<CNT_CSM_CommunityFavorites.CSM_Favorite>();
        User u = [Select id from User where Email = 'johnCommunity@acme.com'][0];
        Test.startTest();
        system.runAs(u){
            favList = CNT_CSM_CommunityFavorites.getFavorites();
        }
        Test.stopTest();
    }

}