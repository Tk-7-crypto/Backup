@isTest
public class TST_CNT_CSM_CommunityDocumentationMenu {
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
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            Asset ast = TST_PEP_TestDataFactory.createAsset('Asset 1',account,product,true);
            insert ast;
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Product__c= product.Id, Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner');
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id =: knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
        }
    }
    
    @IsTest
    static void testGetProductDetails() {
        List<Product2> prod = new List<Product2>();
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
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' prmjohn@acme.com', LastName= 'testPRMLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        Test.startTest();
        system.runAs(user){
           prod = CNT_CSM_CommunityDocumentationMenu.getProductDetails('TestProduct');
        }
        Test.stopTest();
    }

}