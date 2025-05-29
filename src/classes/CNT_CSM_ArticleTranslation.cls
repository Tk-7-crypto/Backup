public class CNT_CSM_ArticleTranslation {
    @AuraEnabled
    public static ArticleTranslationWrapper checkTranslations(String articleId) {
        ArticleTranslationWrapper translationWrapper = new ArticleTranslationWrapper(); 
        Knowledge__kav article;
        List<Knowledge__kav> articleList = new SLT_Knowledge().getArticlesById(new Set<Id>{articleId}, new Set<String>{'Id', 'KnowledgeArticleId', 'IsLatestVersion', 'PublishStatus', 'ArticleMasterLanguage', 'IsMasterLanguage'});
        if(articleList != null && articleList.size() > 0 && articleList[0] != null && articleList[0].IsMasterLanguage && articleList[0].PublishStatus != 'Archived') {
            article = articleList[0];
            List<Knowledge__kav> attachedTranslations = new SLT_Knowledge().getTranslationsByKnowledgeId(new Set<Id>{article.KnowledgeArticleId}, new Set<String>{'Id', 'KnowledgeArticleId', 'IsMasterLanguage', 'PublishStatus', 'Language', 'ArticleTranslatedFrom__c'});
            Set<String> translatedLanguageSet = new Set<String>();
            Id articleTranslatedFrom;
            for(Knowledge__kav articleVersion: attachedTranslations) {
                translatedLanguageSet.add(articleVersion.Language);
                articleTranslatedFrom = articleVersion.ArticleTranslatedFrom__c;
            }
            TranslationMessages messageWrapper = getUserMessageForTranslation(translatedLanguageSet, article, articleTranslatedFrom);
            translationWrapper.componentMessage = messageWrapper.componentMessage;
            translationWrapper.modalMessage = messageWrapper.modalMessage;
            Set<String> languagesForTranslation = messageWrapper.languagesForTranslation;
            translationWrapper.languagesForTranslation = new List<String>(languagesForTranslation);
            translationWrapper.showTranslateButton = false;
            translationWrapper.showUpdateTranslationButton = false;
            if(article.PublishStatus == CON_CSM.S_KB_ARTICLE_ONLINE_STATUS) {
                if((articleTranslatedFrom == null || articleTranslatedFrom == article.Id) && (translatedLanguageSet.isEmpty() || (languagesForTranslation != null && !languagesForTranslation.isEmpty() && languagesForTranslation.size() != translatedLanguageSet.size() && !languagesForTranslation.equals(translatedLanguageSet)))) {
                    translationWrapper.showTranslateButton = true;
                    translationWrapper.showUpdateTranslationButton = false;
                }
                else if(articleTranslatedFrom != null && articleTranslatedFrom != article.Id && !translatedLanguageSet.isEmpty()) {
                    translationWrapper.showUpdateTranslationButton = true;
                    translationWrapper.showTranslateButton = false;
                }
            }
            translationWrapper.showTranslationComponent = true;
        }
        else {
            translationWrapper.showTranslationComponent = false;
        }
        return translationWrapper;
    }
 
    private static TranslationMessages getUserMessageForTranslation(Set<String> translatedLanguageSet, Knowledge__kav article, Id articleTranslatedFrom) {
        TranslationMessages messageWrapper = new TranslationMessages();
        Set<String> languagesForTranslation = UTL_CSM_ArticleTranslation.availableLanguagesForTranslation;
        Map<String, String> languageMap = UTL_CSM_ArticleTranslation.getAllAvailableLanguages();
        if(languagesForTranslation != null && !languagesForTranslation.isEmpty()) {
            languagesForTranslation.remove(article.ArticleMasterLanguage);
            String languages = '';
            Integer lastIndex;
            for(String languageCode: languagesForTranslation) {
                languages += languageMap.containsKey(languageCode) ? languageMap.get(languageCode) + ', ' : '';
            }
            lastIndex = languages.lastIndexOf(', ');
            languages = languages.substring(0, lastIndex);
            String modalMessage;
            String componentMessage;
            if(translatedLanguageSet.isEmpty()) {
                componentMessage = 'No Translation Available.';
                modalMessage = 'Article will be translated in '+ languages + '.';
            } 
            else {
                languagesForTranslation.removeAll(translatedLanguageSet);
                String translationAvailableForLanguages = '';
                for(String languageCode: translatedLanguageSet) {
                    translationAvailableForLanguages += languageMap.containsKey(languageCode) ? languageMap.get(languageCode) + ', ' : '';
                }
                lastIndex = translationAvailableForLanguages.lastIndexOf(', ');
                translationAvailableForLanguages = translationAvailableForLanguages.substring(0, lastIndex);
                componentMessage = languagesForTranslation.isEmpty() ? 'Translation available for '+ translationAvailableForLanguages + '.' : 'Translation available for '+ translationAvailableForLanguages + ' and needs to be translated in ';
                modalMessage = 'Article will be translated in ';
                if(!languagesForTranslation.isEmpty()) {
                    for(String languageCode: languagesForTranslation) {
                        if(languageMap.containsKey(languageCode)) {
                            componentMessage += languageMap.get(languageCode) + ', ';
                            modalMessage += languageMap.get(languageCode) + ', ';
                        }
                    }
                    lastIndex = componentMessage.lastIndexOf(', ');
                    componentMessage = componentMessage.substring(0, lastIndex);
                    lastIndex = modalMessage.lastIndexOf(', ');
                    modalMessage = modalMessage.substring(0, lastIndex);
                    componentMessage += '.';
                    modalMessage += '.';
                }
                if(articleTranslatedFrom != null && articleTranslatedFrom != article.Id) {
                    componentMessage = 'Translation available for the previous published version';
                    modalMessage = languages + ' Translations will be updated';
                }
            }
            messageWrapper.componentMessage = componentMessage;
            messageWrapper.modalMessage = modalMessage;
            messageWrapper.languagesForTranslation = languagesForTranslation;
        }
        return messageWrapper;
    }
        
    @AuraEnabled
    public static void translateArticles(Id articleId, List<String> languagesForTranslationList) {
        Set<String> languagesForTranslation = new Set<String>(languagesForTranslationList);
        sendForTranslation(articleId, languagesForTranslation, false);
    }
    
    @AuraEnabled
    public static void updateTranslations(Id articleId) {
        Set<String> languagesForTranslation = UTL_CSM_ArticleTranslation.availableLanguagesForTranslation;
        sendForTranslation(articleId, languagesForTranslation, true);
    }
 
    private static void sendForTranslation(Id articleId, Set<String> languagesForTranslation, Boolean updateTranslation) {
        List<UTL_CSM_ArticleTranslation.ArticleWrapper> articleWrapperList = new List<UTL_CSM_ArticleTranslation.ArticleWrapper>();
        Set<String> allFields = UTL_CSM_ArticleTranslation.getAllCustomFields(Knowledge__kav.sObjectType);
        allFields.addAll(new Set<String>{'KnowledgeArticleId', 'Summary', 'Title', 'ArticleMasterLanguage'});
        List<Knowledge__kav> articles = new SLT_Knowledge().getArticlesById(new Set<Id>{articleId}, allFields);
        if(articles != null && articles.size() > 0 && articles[0] != null) {
            languagesForTranslation.remove(articles[0].ArticleMasterLanguage);
            UTL_CSM_ArticleTranslation.ArticleWrapper articleWrapper = new UTL_CSM_ArticleTranslation.ArticleWrapper();
            articleWrapper.masterArticle = articles[0];
            articleWrapper.knowledgeArticleId = articles[0].KnowledgeArticleId;
            articleWrapper.languagesForTranslation = languagesForTranslation;
            articleWrapperList.add(articleWrapper);            
            UTL_CSM_ArticleTranslation.translateRecords(articleWrapperList, allFields, updateTranslation);
        }
    }
    
    public class ArticleTranslationWrapper {
        @AuraEnabled
        public Boolean showTranslationComponent;
        @AuraEnabled
        public Boolean showTranslateButton;
        @AuraEnabled
        public Boolean showUpdateTranslationButton;
        @AuraEnabled
        public List<String> languagesForTranslation;
        @AuraEnabled
        public String componentMessage;
        @AuraEnabled
        public String modalMessage;
    }
    
    class TranslationMessages {
        public String componentMessage;
        public String modalMessage;
        public Set<String> languagesForTranslation;
    }
}