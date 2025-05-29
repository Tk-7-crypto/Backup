@isTest
public class TST_CNT_CSM_AttachArticle {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        Group g = new Group(Name='IQVIAGenAI01');
        insert g;
        System.runAs(new User(Id = UserInfo.getUserId())){
         
        GroupMember gm = new  GroupMember(GroupId = g.Id,UserOrGroupId = UserInfo.getUserId());
        insert gm;
        }
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Community_topic__c ct = new Community_topic__c(Name='topicName');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Name='OCE';
            product.Community_Topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = new Asset(Name='OCE', AccountId = account.Id, Product2Id = product.id);
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
            CSM_Case_Details_Global_Setting__c gd = new CSM_Case_Details_Global_Setting__c(Name = 'IQVIAKBCopilotDraftEmail',Component_Id__c = 'Draft Close Resolution',Setting_Type__c = 'Draft Close Resolution',Other_Details__c = 'Draft Close Resolution',Origin__c = g.Id);
            insert gd;
            CNT_CSM_AttachArticle.getDataCustomSetting();
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);

        }
    }

    @IsTest
    static void testCNT_CSM_AttachArticle() {
        List<Case> c = [Select Id from Case];
        List<Knowledge__kav> k = [Select Id, KnowledgeArticleId from Knowledge__kav];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = k[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
        CNT_CSM_AttachArticle.insertCaseArticle(c[0].id, k[0].KnowledgeArticleId);
        CNT_CSM_AttachArticle.getCaseArticle(c[0].id);
        CNT_CSM_AttachArticle.searchArticles('',c[0].id,5,5);
        CNT_CSM_AttachArticle.deleteCaseArticle(c[0].id, k[0].KnowledgeArticleId);
        Test.stopTest();
    }
    
    @IsTest
    private static void testSearchArticles() {
        Account acc = [SELECT Id, KBA_Visibility_Restriction__c FROM Account LIMIT 1];
        acc.KBA_Visibility_Restriction__c = true;
        update acc;
        List<Case> caseRecord = [SELECT Id FROM Case];
        List<Knowledge__kav> knowledge = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav];
        Knowledge_Account_RelationShip__c knowledgeAccount = new Knowledge_Account_RelationShip__c(Account__c = acc.Id, Knowledge__c = knowledge[0].Id);
        insert knowledgeAccount;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = knowledge[0].Id;
        
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            CNT_CSM_AttachArticle.searchArticles('', caseRecord[0].id, 5, 5);
        Test.stopTest();
    }
}