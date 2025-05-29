@IsTest
private class TST_CNT_CSM_ArticleTranslation {
    @testSetup
    static void setup() {
        Group kbTranslationQueue = new Group(Name = CON_CSM.S_CSM_KB_ARTICLE_TRANSLATION, Type = 'Queue');
        insert kbTranslationQueue;
        User userToRunAs = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        System.runAs (userToRunAs) {
            QueueSobject qs = new QueueSobject();
            qs.QueueId = kbTranslationQueue.Id;
            qs.SobjectType = 'KnowledgeArticleVersion';
            insert qs;
        }
        
        CSM_Translate_API_Connection__c translateAPI = new CSM_Translate_API_Connection__c();
        translateAPI.Translate_API_Key__c = 'testKey';
        translateAPI.Translate_API_Request_2__c = '&target={0}&source={1}&format={2}';
        translateAPI.API_Referer__c = 'https://iqvia.my.salesforce.com';
        translateAPI.Translate_API_URL__c = 'https://www.googleapis.com/language/translate/v2?key=';
        translateAPI.LanguagesForTranslation__c = 'fr;es';
        insert translateAPI;
        
        Knowledge__kav article = New Knowledge__kav(Title = 'TestTitle1', language = 'en_US', UrlName = 'TestUrlName1', 
                                                    IsVisibleInCsp = true, Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,
                                                    Partner_Type__c = 'Integrator Partner', IsVisibleInPrm = true);
        article.Content__c = 'Test Content';
        insert article;
        
        Knowledge__kav knowledge = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: article.Id];
        KbManagement.PublishingService.publishArticle(knowledge.KnowledgeArticleId, true);
        
        Knowledge__kav kbArticle = New Knowledge__kav(Title = 'TestTitle2', language = 'en_US', UrlName = 'TestUrlName2', 
                                                    IsVisibleInCsp = true, Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS,
                                                    Partner_Type__c = 'Integrator Partner', IsVisibleInPrm = true);
        kbArticle.Content__c = 'Test Content 2';
        insert kbArticle;
        
        Knowledge__kav knowledgeArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: kbArticle.Id];
        KbManagement.PublishingService.publishArticle(knowledgeArticle.KnowledgeArticleId, true);
        Id draftTranslationId = KbManagement.PublishingService.submitForTranslation(knowledgeArticle.knowledgeArticleId, 'fr', kbTranslationQueue.Id, System.now());
        Knowledge__kav translatedArticle = [SELECT Id, KnowledgeArticleId, ArticleTranslatedFrom__c, Content__c, Partner_Type__c, Pillar__c FROM Knowledge__kav WHERE Id =: draftTranslationId];
        translatedArticle.Content__c = 'Translated Content FR';
        translatedArticle.ArticleTranslatedFrom__c = kbArticle.Id;
        translatedArticle.Partner_Type__c = 'Integrator Partner';
        translatedArticle.Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS;
        update translatedArticle;
        KbManagement.PublishingService.completeTranslation(translatedArticle.Id);
        
        Id draftTranslationIdDE = KbManagement.PublishingService.submitForTranslation(knowledgeArticle.knowledgeArticleId, 'de', kbTranslationQueue.Id, System.now());
        Knowledge__kav translatedArticleDE = [SELECT Id, KnowledgeArticleId, ArticleTranslatedFrom__c, Content__c, Language, Partner_Type__c, Pillar__c FROM Knowledge__kav WHERE Id =: draftTranslationIdDE];
        translatedArticleDE.Content__c = 'Translated Content DE';
        translatedArticleDE.ArticleTranslatedFrom__c = kbArticle.Id;
        translatedArticleDE.Partner_Type__c = 'Integrator Partner';
        translatedArticleDE.Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS;
        update translatedArticleDE;
        KbManagement.PublishingService.completeTranslation(translatedArticleDE.Id);
        KbManagement.PublishingService.editPublishedTranslation(translatedArticleDE.KnowledgeArticleId, translatedArticleDE.Language, false);
    }
    
    @IsTest
    private static void testTranslateRecords() {
        String query = 'SELECT Id FROM Knowledge__kav WHERE Title = \'TestTitle1\' LIMIT 1';
        Knowledge__kav article = (Knowledge__kav)Database.query(query);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
            CNT_CSM_ArticleTranslation.translateArticles(article.Id, new List<String>{'fr'});
        Test.stopTest();
    }
    
    @IsTest
    private static void testUpdateTranslations() {
        String query = 'SELECT Id FROM Knowledge__kav WHERE Title = \'TestTitle2\' LIMIT 1';
        Knowledge__kav article = (Knowledge__kav)Database.query(query);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
            CNT_CSM_ArticleTranslation.updateTranslations(article.Id);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCheckTranslations() {
        String query = 'SELECT Id FROM Knowledge__kav WHERE Title = \'TestTitle1\' LIMIT 1';
        Knowledge__kav article = (Knowledge__kav)Database.query(query);

        Test.startTest();
            CNT_CSM_ArticleTranslation.ArticleTranslationWrapper articleTranslationWrapper = CNT_CSM_ArticleTranslation.checkTranslations(article.Id);
        Test.stopTest();
    }
    
    @IsTest
    private static void testCheckTranslationsShouldGiveTranslations() {
        String query = 'SELECT Id FROM Knowledge__kav WHERE Title = \'TestTitle2\' LIMIT 1';
        Knowledge__kav article = (Knowledge__kav)Database.query(query);

        Test.startTest();
            CNT_CSM_ArticleTranslation.ArticleTranslationWrapper articleTranslationWrapper = CNT_CSM_ArticleTranslation.checkTranslations(article.Id);
        Test.stopTest();
    }
}