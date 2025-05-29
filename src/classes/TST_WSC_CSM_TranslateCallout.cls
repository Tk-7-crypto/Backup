@IsTest
private class TST_WSC_CSM_TranslateCallout {
    @testSetup
    static void setup() {
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
    }
    
    @IsTest
    private static void testTranslateCallout() {
        Knowledge__kav article = [SELECT Id, Content__c FROM Knowledge__kav WHERE Title = 'TestTitle1' LIMIT 1];
        String articleDataToTranslate = '&q=' + article.Content__c;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
            Map<String, HTTPResponse> languageResponseMap = WSC_CSM_TranslateCallout.translateCallout(articleDataToTranslate, new Set<String>{'fr'}, 'en');
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetTranslatedData() {
        Knowledge__kav article = [SELECT Id, KnowledgeArticleId, Summary, Title, Question__c, Answer__c, Content__c, L1Answer__c, L1Content__c, ArticleMasterLanguage FROM Knowledge__kav WHERE Title = 'TestTitle1' LIMIT 1];
        UTL_CSM_ArticleTranslation.ArticleWrapper  articleWrapper = new UTL_CSM_ArticleTranslation.ArticleWrapper(); 
        articleWrapper.masterArticle = article;
        articleWrapper.languagesForTranslation = new Set<String>{'fr'};
        Map<String, Knowledge__kav> translationByLanguage;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
            translationByLanguage = WSC_CSM_TranslateCallout.getTranslatedData(new List<UTL_CSM_ArticleTranslation.ArticleWrapper>{articleWrapper});
        Test.stopTest(); 
        
        System.assertEquals(true, translationByLanguage != null, 'Should get translations');
    } 

    @IsTest
    private static void testTranslateText() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_CSM_MockTranslateCalloutResponse());
        WSC_CSM_TranslateCallout.translateText('test', 'fr');
        Test.stopTest();
    }
}