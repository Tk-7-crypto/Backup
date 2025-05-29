@isTest
public class TST_BCH_KAV_UpdateKnowledgeArticles {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true);
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
         accOwner.EmployeeNumber = '0909090917';
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
            KBManagement.PublishingService.editOnLineArticle(k1.KnowledgeArticleId,false);            
            Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c= CON_CSM.S_TECHNOLOGY_SOLUTIONS,Partner_Type__c='Integrator Partner');
            insert knowledge;
            Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id=:knowledge.Id];
            KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            
            KB_Mass_Draft_Articles__c setting = new KB_Mass_Draft_Articles__c();
            setting.Name = k.KnowledgeArticleId;
            setting.To_Run__c = true;
            insert setting;
            
            KB_Mass_Draft_Articles__c setting1 = new KB_Mass_Draft_Articles__c();
            setting1.Name = k1.KnowledgeArticleId;
            setting1.To_Run__c = true;
            insert setting1;
        } 
    }
    
    @isTest
    public static void testUpdateKnowledgeArticles(){
        Test.startTest();
        BCH_KAV_UpdateKnowledgeArticles ka = new BCH_KAV_UpdateKnowledgeArticles();
        Database.executeBatch(ka);
        Test.stopTest();
    }
}