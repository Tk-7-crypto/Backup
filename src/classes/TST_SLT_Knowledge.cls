/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Knowledge
 */
@isTest
public class TST_SLT_Knowledge {
    	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id,EmployeeNumber = '07070445756', ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true);
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
            Knowledge__kav knowledge1 = New Knowledge__kav(Title = 'TestTitle1', language = 'en_US',UrlName='TestUrlName1', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner',IsVisibleInPrm=true);
            insert knowledge1;
            Knowledge__kav k1 = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge1.Id];
            KbManagement.PublishingService.publishArticle(k1.KnowledgeArticleId, true);
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c= CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner', PRM_Sales_Collateral__c = true);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id=:knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Topic topic = New Topic(Name = 'TopicsName');
            insert topic;
            TopicAssignment ta = New TopicAssignment(EntityId=knowledge.Id,TopicId=topic.Id);
            insert ta;
        }
        
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            
            Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
            Account ac = new Account(name ='Acme',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
            ac.AccountCountry__c = 'BM' ;
            insert ac;
            
            Contact con = new Contact(FirstName = 'TestFirstName2', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
            con.Partner_Type__c = 'Integrator Partner';
            con.Portal_Case_Type__c = 'Technology Solutions';
            insert con;
            
            User partnerUser = new User(alias = 'test123', email='partneruser@iqvia.partner.com',
                                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                        localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                                        ContactId = con.Id,PortalRole='Manager',
                                        timezonesidkey='America/Los_Angeles', username='xyz123490@iqviaTestPartner.com');
            insert partnerUser;
        }
    }

    testmethod static void selectKnowledge(){
        SLT_Knowledge slt = new SLT_Knowledge();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        Topic topic = [SELECT Id FROM Topic WHERE Name = 'TopicsName'];
        slt.selectByTopicId2(topic.Id);
        slt.selectByProductName('ProductName');
    }
        
     /**
     * This method used to get List<Knowledge__kav> by ID
     */    
    @IsTest
    static void testSelectById() {
    	List<Knowledge__kav> knowledges = new  List<Knowledge__kav>();
    	Knowledge__kav k = [SELECT Id FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus='Online' and language='en_US'];	
        Test.startTest();
        knowledges = new SLT_Knowledge().selectById(new Set<Id> {k.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = knowledges.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get a List<Knowledge__kav> by topics
     */    
    @IsTest
    static void testSelectByTopicId() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        List<Topic> topics =[SELECT Id FROM Topic WHERE Name='TopicsName'];
        Test.startTest();
        articles = new SLT_Knowledge().selectByTopicId(topics[0].Id);  
        Test.stopTest();
        Integer expected = 1;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testSelectByCategory() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        User us=[SELECT Id,AccountId FROM User WHERE Username ='john2@iqvia.com'];
        Knowledge__kav k = [SELECT Id,Pillar__c,Partner_Type__c,Product__r.Community_Topics__c FROM Knowledge__kav WHERE Title = 'TestTitle1' and PublishStatus='Online' and language='en_US'];
        String partnerType=k.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar=k.Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        articles = new SLT_Knowledge().selectByCategory(k.Product__r.Community_Topics__c,partnerType,pillar,us.Id,true);  
        Test.stopTest();
        Integer expected = 0;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testSelectByCategoryAndAccount() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        User us=[SELECT Id,AccountId FROM User WHERE Username ='john2@iqvia.com'];
        Knowledge__kav k = [SELECT Id,Pillar__c,Partner_Type__c,Product__r.Community_Topics__c FROM Knowledge__kav WHERE Title = 'TestTitle1' and PublishStatus='Online' and language='en_US'];
        String partnerType=k.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar=k.Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        Test.startTest();
        articles = new SLT_Knowledge().selectByCategoryAndAccount(k.Product__r.Community_Topics__c,partnerType,pillar,us.Id,true);  
        Test.stopTest();
        Integer expected = 0;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testSelectByArticleId() {
        List<Knowledge__kav> knowledges = new  List<Knowledge__kav>();
        Knowledge__kav k = [SELECT Id FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus='Online' and language='en_US'];	
        Test.startTest();
        knowledges = new SLT_Knowledge().selectByArticleId(k.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = knowledges.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetArticlesByKnowledgeArticleIds() {
    	List<Knowledge__kav> knowledges = new  List<Knowledge__kav>();
    	Knowledge__kav k = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus='Online' and language='en_US'];	
        Test.startTest();
        knowledges = new SLT_Knowledge().getArticlesByKnowledgeArticleIds(new Set<String> {k.KnowledgeArticleId});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = knowledges.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetSearchResults() {
        List<List<SObject>> articles = new List<List<SObject>>();
        User us = [SELECT Id,AccountId FROM User WHERE Username ='john2@iqvia.com'];
        String accountId = us.AccountId;
        Set<String> ids = new Set<String>();
        Knowledge__kav k = [SELECT Id,Pillar__c,Partner_Type__c,Product__r.Community_Topics__c FROM Knowledge__kav WHERE Title = 'TestTitle1' and PublishStatus='Online' and language='en_US'];
        Set<String> pillar = new Set<String>{k.Pillar__c};
        Test.startTest();
        articles = new SLT_Knowledge().getSearchResults('Test', pillar, accountId, ids, 'test');
        Test.stopTest();    
    }
    
    @IsTest
    static void testGetArticlesById() {
    	List<Knowledge__kav> knowledges = new  List<Knowledge__kav>();
    	Knowledge__kav k = [SELECT Id FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus = 'Online' and language = 'en_US'];	
        Test.startTest();
            knowledges = new SLT_Knowledge().getArticlesById(new Set<Id>{k.Id}, new Set<String>{'Title', 'PublishStatus'});
        Test.stopTest();
    }

    @IsTest
    static void testGetArticlesToUpdate() {
    	List<Knowledge__kav> knowledges = new  List<Knowledge__kav>();
    	Knowledge__kav k = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle'];	
        Test.startTest();
        knowledges = new SLT_Knowledge().getArticlesByKnowledgeArticleIds(new Set<String> {k.KnowledgeArticleId});
        Test.stopTest();
    }

    

    @IsTest
    private static void testGetTranslationsByKnowledgeId() {
        Group kbTranslationQueue = new Group(Name = CON_CSM.S_CSM_KB_ARTICLE_TRANSLATION, Type = 'Queue');
        insert kbTranslationQueue;
        User userToRunAs = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        System.runAs (userToRunAs) {
            QueueSobject qs = new QueueSobject();
            qs.QueueId = kbTranslationQueue.Id;
            qs.SobjectType = 'KnowledgeArticleVersion';
            insert qs;
        }
        Knowledge__kav kbArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Title = 'TestTitle' and PublishStatus = 'Online' and language = 'en_US' LIMIT 1];	
        Id draftTranslationId = KbManagement.PublishingService.submitForTranslation(kbArticle.KnowledgeArticleId, 'fr', kbTranslationQueue.Id, System.now());
        Knowledge__kav translatedArticle = [SELECT Id, KnowledgeArticleId, ArticleTranslatedFrom__c, Content__c, Partner_Type__c, Pillar__c FROM Knowledge__kav WHERE Id =: draftTranslationId];
        translatedArticle.Content__c = 'Translated Content FR';
        translatedArticle.ArticleTranslatedFrom__c = kbArticle.Id;
        translatedArticle.Partner_Type__c = 'Integrator Partner';
        translatedArticle.Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS;
        update translatedArticle;
        KbManagement.PublishingService.completeTranslation(translatedArticle.Id);
        
        Test.startTest();
            List<Knowledge__kav> translations = new SLT_Knowledge().getTranslationsByKnowledgeId(new Set<Id>{kbArticle.KnowledgeArticleId}, new Set<String>{'Title', 'Language'});
        Test.stopTest();
        
        System.assertEquals(true, translations != null, 'Should get attached translations');
    }

    @IsTest
    static void testGetSearchResultsPRM1() {
        User partnerUser = [SELECT Id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Contact con = [SELECT Id, Portal_Case_Type__c, Partner_Type__c FROM Contact Where FirstName = 'TestFirstName2'];
        String partnerType = con.Partner_Type__c;
        partnerType = partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String searchText='TestCase';
        Set<String> pillar = new Set<String>(con.Portal_Case_Type__c.split(';'));
        Set<String> ids = new Set<String>();
        System.runAs(partnerUser){
        Test.startTest();
        List<List<SObject>> results = new SLT_Knowledge().getSearchResultsPRM1(searchText, pillar, '',ids, partnerType,10,0);
        Test.stopTest();
        }
    }
    
    @IsTest
    static void testGetSearchResultsPRM2() {
        User partnerUser = [SELECT Id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Contact con = [SELECT Id, Portal_Case_Type__c, Partner_Type__c FROM Contact Where FirstName = 'TestFirstName2'];
        String partnerType = con.Partner_Type__c;
        partnerType = partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String searchText='TestCase';
        Set<String> pillar = new Set<String>(con.Portal_Case_Type__c.split(';'));
        Set<String> ids = new Set<String>();
        System.runAs(partnerUser){
        Test.startTest();
        List<List<SObject>> results = new SLT_Knowledge().getSearchResultsPRM2(searchText, pillar, '',ids, partnerType,10,0);
        Test.stopTest();
        }
    }
}
