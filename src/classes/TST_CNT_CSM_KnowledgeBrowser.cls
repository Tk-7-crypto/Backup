/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_KnowledgeBrowser
 */
@isTest
public class TST_CNT_CSM_KnowledgeBrowser {
    /**
    * This method used to set up testdata
    */
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='070707078', Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true);
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Community_topic__c ct = new Community_topic__c(Name='topicName');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = new Asset(Name='TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            Contact contact = UTL_TestData.createContact(account.Id);
            insert contact;
            Knowledge__kav knowledge = new Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, ProductName__c='TestProduct', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            Knowledge_Account_RelationShip__c kar = new Knowledge_Account_RelationShip__c(Knowledge__c = knowledge.Id, Account__c = account.Id);
            insert kar;
            Knowledge__kav knowledge2 = new Knowledge__kav(Title = 'TestTitle2', language = 'en_US',UrlName='TestUrlName2', IsVisibleInCsp= true, Product__c= product.Id, ProductName__c='TestProduct', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert knowledge2;
            Knowledge__kav k2 = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge2.Id];
            KbManagement.PublishingService.publishArticle(k2.KnowledgeArticleId, true);
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert categorization;
        }
    }

    /**
    * This method used to get a List of Knowledge__kav by productName
    */
    @IsTest
    static void testGetArticlesByProductName() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        Test.startTest();
        articles = CNT_CSM_KnowledgeBrowser.getArticlesByProductName('TestProduct');
        Test.stopTest();
        Integer expected = 2;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetArticlesByProductName2() {
        List<Knowledge__kav> articles = new  List<Knowledge__kav>();
        Account acc = [SELECT Id FROM Account Where Name='TestAccount'];
        Test.startTest();
        articles = CNT_CSM_KnowledgeBrowser.getArticlesByProductName2('TestProduct',acc.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = articles.size();
        System.assertEquals(expected, actual);
    }

    /**
    * This method used to get a List of products with Community_Topics__c not null and and present in CaseCategorization Object
    */
    @IsTest
    static void testGetProducts() {
        List<AggregateResult> products = new List<AggregateResult>();
        Test.startTest();
        products = CNT_CSM_KnowledgeBrowser.getProducts();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = products.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetAccountsArticlesByProductName() {
        Map<Id, Account>  accounts = new Map<Id, Account>();
        Test.startTest();
        accounts = CNT_CSM_KnowledgeBrowser.getAccountsArticlesByProductName('TestProduct');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = accounts.size();
        System.assertEquals(expected, actual);
    }
}