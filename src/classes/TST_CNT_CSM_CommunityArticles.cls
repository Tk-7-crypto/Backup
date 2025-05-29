@isTest
public class TST_CNT_CSM_CommunityArticles {

    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            CSM_Translate_API_Connection__c translateAPI = new CSM_Translate_API_Connection__c();
            translateAPI.Translate_API_Key__c = 'testKey';
            translateAPI.Translate_API_Request_2__c = '&target={0}&source={1}&format={2}';
            translateAPI.API_Referer__c = 'https://iqvia.my.salesforce.com';
            translateAPI.Translate_API_URL__c = 'https://www.googleapis.com/language/translate/v2?key=';
            translateAPI.LanguagesForTranslation__c = 'fr;es';
            insert translateAPI;
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Community_topic__c ct = new Community_topic__c(Name='productTopic');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.Community_Topic__c = ct.Id;
            product.Available_to_the_Guest_User__c = true;
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            CSM_QI_Case_Categorization__c cat = New CSM_QI_Case_Categorization__c(Product__c= product.Id, Type__c = 'Knowledge',Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS, Article_Chapter_Order__c = 1, Article_Chapter__c='TestChapter');
            insert cat;
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner',IsVisibleInPrm = true, PRM_Sales_Collateral__c = true,Article_Chapter__c='TestChapter');
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId, ArticleNumber FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Knowledge_Account_RelationShip__c kar = New Knowledge_Account_RelationShip__c(Knowledge__c = k.Id, Account__c = account.Id);
            insert kar;
            CSM_QI_Knowledge_Article_Order__c article_Order =  New CSM_QI_Knowledge_Article_Order__c (ArticleNumber__c = k.ArticleNumber,Order__c=1);
            insert article_Order;
            Knowledge__kav knowledge1 = New Knowledge__kav(Title = 'TestTitle1', language = 'fr',UrlName='TestUrlName1', IsVisibleInCsp= true, IsVisibleInPkb=true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner',IsVisibleInPrm = true, PRM_Sales_Collateral__c = true, Article_Chapter__c='TestChapter');
            insert knowledge1;
            Knowledge__kav k1 = [SELECT Id,KnowledgeArticleId, ArticleNumber FROM Knowledge__kav WHERE Id =: knowledge1.Id];
            KbManagement.PublishingService.publishArticle(k1.KnowledgeArticleId, true);
            CSM_QI_Knowledge_Article_Order__c article_Order1 =  New CSM_QI_Knowledge_Article_Order__c (ArticleNumber__c = k1.ArticleNumber,Order__c=2);
            insert article_Order1;
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
        }
    }

    @IsTest
    static void testGetArticlesByCategoryForCurrentUser() {
        List<CNT_CSM_CommunityArticles.articleWrapper> articles = new  List<CNT_CSM_CommunityArticles.articleWrapper>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
            articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentUser('productTopic','en_US');
            articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentUser('','fr');
        }
        Test.stopTest();
    }
    @IsTest
    static void testClassesForNoCustomerSuccess() {
        Test.startTest();
        CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentUser('','fr');
        CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentUser('productTopic','en_US');
        Test.stopTest();
    }

    @IsTest
    static void testGetArticlesByCategoryForCurrentPRMUser() {
        List<CNT_CSM_CommunityArticles.articleWrapper> articles = new  List<CNT_CSM_CommunityArticles.articleWrapper>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john101@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username ='john101'+ String.valueOf(System.currentTimeMillis()) +'@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        Test.startTest();
        system.runAs(user){
            articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentPRMUser('productTopic', true);
            articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentPRMUser('', true);
            articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentPRMUser('productTopic', false);
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetFavoriteArticles() {
        List<CSM_QI_Favorite_Record__c> favList = new  List<CSM_QI_Favorite_Record__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        Test.startTest();
        system.runAs(user){
            favList = CNT_CSM_CommunityArticles.getFavoriteArticles();
        }
        Test.stopTest();
    }

    @IsTest
    private static void testGetTranslatedChapterArticle() {
        List<CNT_CSM_CommunityArticles.articleWrapper> articles = new  List<CNT_CSM_CommunityArticles.articleWrapper>();
        articles = CNT_CSM_CommunityArticles.getArticlesByCategoryForCurrentUser('','fr');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
        CNT_CSM_CommunityArticles.getTranslatedChapterArticle(articles, 'fr');
        Test.stopTest();
    }

    @isTest
    private static void testGetArticleProductByUrlName() {
        Test.startTest();
        String prd = CNT_CSM_CommunityArticles.getArticleProductByUrlName('TestUrlName','en_US');
        System.assertEquals('productTopic', prd,'invalid product');
        String prd1 = CNT_CSM_CommunityArticles.getArticleProductByUrlName('TestUrlName','ru');
        System.assertEquals('productTopic', prd1,'invalid product');
        Test.stopTest();
    }

}
