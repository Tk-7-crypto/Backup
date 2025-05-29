public class UTL_CSM_ArticleTranslation {
    public static List<Group> kbTranslationQueue {
        get {
            if(kbTranslationQueue == null) {
                kbTranslationQueue = new SLT_Groups().getGroupByDevelopernameSet(new Set<String>{'Id'}, new Set<String>{CON_CSM.S_CSM_KB_ARTICLE_TRANSLATION});
            }
            return kbTranslationQueue;
        }
        private set;
    }
    
    public static Map<String, String> disclaimerByLanguage {
        get {
            if(disclaimerByLanguage == null) {
                disclaimerByLanguage = new SLT_KBTranslationSetting().getDisclaimerByLanguage();
            }
            return disclaimerByLanguage;
        } 
        private set;
    }
    
    public static Set<String> availableLanguagesForTranslation {
        get {
            if(availableLanguagesForTranslation == null && translateAPISetting != null && translateAPISetting.LanguagesForTranslation__c != null) {
                availableLanguagesForTranslation = new Set<String>(translateAPISetting.LanguagesForTranslation__c.split(';'));
            }
            return availableLanguagesForTranslation; 
        }
        private set;
    }
    
    public static CSM_Translate_API_Connection__c translateAPISetting {
        get {
            if (translateAPISetting == null)
            {
                translateAPISetting = CSM_Translate_API_Connection__c.getOrgDefaults();
            }
            return translateAPISetting;
        }
        private set;
    }
    
    public static Set<String> getAllCustomFields(Schema.SObjectType objectType) {
        List<String> sObjectFields = new List<String>{};
        Map<String, SObjectField> fieldsByName;
        if(objectType != null) {
            sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
            fieldsByName = objectType.getDescribe().fields.getMap();
        }  
        Set<String> customFields = new Set<String>();
        if(fieldsByName != null && fieldsByName.size() > 0) {
            for (SObjectField field : fieldsByName.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.isCustom() && !fieldDescribe.isCalculated()) {
                    customFields.add(fieldDescribe.getName());
                }
            }
        }
        return customFields;
    }  
    
    public static Map<String, String> getAllAvailableLanguages() {
        Map<String, String> languageMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Language.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple: picklistValues) {
            if(ple.isActive()) {
                languageMap.put(ple.getValue(), ple.getLabel());
            }
        }
        return languageMap;
    }
    
    public static void translateRecords(List<ArticleWrapper> articleWrapperList, Set<String> allFields, Boolean updateTranslation) {
        Map<String, Knowledge__kav> translationByLanguage = WSC_CSM_TranslateCallout.getTranslatedData(articleWrapperList);
        if(translationByLanguage != null && translationByLanguage.size() > 0) {
            updateTranslationRecords(articleWrapperList, translationByLanguage, allFields, updateTranslation);
        }
    }
    
    private static void updateTranslationRecords(List<ArticleWrapper> articleWrapperList, Map<String, Knowledge__kav> translationByLanguage, Set<String> allFields, Boolean updateTranslation) {
        Map<Id, Set<String>> languagesForTranslation = new Map<Id, Set<String>>();
        Map<Id, Knowledge__kav> masterArticleMap = new Map<Id, Knowledge__kav>();
        for(ArticleWrapper articleWrapper: articleWrapperList) {
            languagesForTranslation.put(articleWrapper.knowledgeArticleId, articleWrapper.languagesForTranslation);
            masterArticleMap.put(articleWrapper.knowledgeArticleId, articleWrapper.masterArticle);
        }
        if(!languagesForTranslation.isEmpty() && !masterArticleMap.isEmpty()) {
            Map<String, Id> translationIdByLanguage = getTranslationIdByLanguage(languagesForTranslation, updateTranslation);
            if(translationIdByLanguage != null && !translationIdByLanguage.isEmpty()) {
                Map<Id, Knowledge__kav> translatedArticleMap = copyTranslatedValues(masterArticleMap, translationByLanguage, allFields, new Set<Id>(translationIdByLanguage.values()));
                if(translatedArticleMap != null && !translatedArticleMap.isEmpty() && translatedArticleMap.values().size() > 0) {
                    try {
                        update translatedArticleMap.values();
                        for(Id articleVersionId: translationIdByLanguage.values()) {
                            KbManagement.PublishingService.completeTranslation(articleVersionId);
                        }
                    } catch(Exception ex) {
                        System.debug('Failed to update translation due to: '+ex.getMessage());
                        throw new TranslationException('Failed to update translation due to: '+ex.getMessage());
                    }
                }
            }
        }
    }
    
    private static Map<String, Id> getTranslationIdByLanguage(Map<Id, Set<String>> languagesForTranslation, Boolean updateTranslation) {
        Map<Id, Set<String>> translatedLanguages = new Map<Id, Set<String>>();
        Map<String, TranslationMethodWrapper> knowledgeIdAndTranslation = new Map<String, TranslationMethodWrapper>();
        if(updateTranslation) {
            List<Knowledge__kav> translationRecords = new SLT_Knowledge().getTranslationsByKnowledgeId(languagesForTranslation.keySet(), new Set<String>{'Id', 'KnowledgeArticleId', 'PublishStatus', 'Language', 'isLatestVersion'});
            for(Knowledge__kav translation: translationRecords) {
                TranslationMethodWrapper translationWrapper = new TranslationMethodWrapper();
                translationWrapper.translation = translation;
                if(knowledgeIdAndTranslation.containskey(translation.Language + '~' + translation.KnowledgeArticleId)) {
                    Knowledge__kav existingTranslation = knowledgeIdAndTranslation.get(translation.Language + '~' + translation.KnowledgeArticleId).translation;
                    if(translation.PublishStatus == CON_CSM.S_KB_ARTICL_PUBLISH_STATUS && translation.isLatestVersion && existingTranslation.PublishStatus == CON_CSM.S_KB_ARTICLE_ONLINE_STATUS) {
                        translationWrapper.updateAndPublish = true;
                        knowledgeIdAndTranslation.put(translation.Language + '~' + translation.KnowledgeArticleId, translationWrapper);
                    }
                }
                else {
                    if(translation.PublishStatus == CON_CSM.S_KB_ARTICLE_ONLINE_STATUS) {
                        translationWrapper.editPublishedVersion = true;
                        knowledgeIdAndTranslation.put(translation.Language + '~' + translation.KnowledgeArticleId, translationWrapper);
                    }
                    else if(translation.PublishStatus == CON_CSM.S_KB_ARTICL_PUBLISH_STATUS) {
                        translationWrapper.onlyUpdate = true;
                        knowledgeIdAndTranslation.put(translation.Language + '~' + translation.KnowledgeArticleId, translationWrapper);
                    }
                }
                if(translatedLanguages.containsKey(translation.KnowledgeArticleId)) {
                    translatedLanguages.get(translation.KnowledgeArticleId).add(translation.Language);
                }
                else {
                    translatedLanguages.put(translation.KnowledgeArticleId, new Set<String>{translation.Language});
                }
            }
        }
        for(Id knowledgeId: languagesForTranslation.keySet()) {
            Set<String> nonTranslatedLanguages = new Set<String>();
            nonTranslatedLanguages.addAll(languagesForTranslation.get(knowledgeId));
            if(!translatedLanguages.isEmpty() && translatedLanguages.containsKey(knowledgeId)) {
                nonTranslatedLanguages.removeAll(translatedLanguages.get(knowledgeId));
                languagesForTranslation.put(knowledgeId, nonTranslatedLanguages);
            }
            else {
                languagesForTranslation.put(knowledgeId, nonTranslatedLanguages);
            }
        }
        for(Id knowledgeId: languagesForTranslation.keySet()) {
            for(String languageCode: languagesForTranslation.get(knowledgeId)) {
                TranslationMethodWrapper translationWrapper = new TranslationMethodWrapper();
                translationWrapper.language = languageCode;
                translationWrapper.submitForTranslation = true;
                translationWrapper.knowledgeArticleId = knowledgeId;
                knowledgeIdAndTranslation.put(languageCode + '~' + knowledgeId, translationWrapper);
            }
        }
        Map<String, Id> translationIdByLanguage;
        if(!knowledgeIdAndTranslation.isEmpty()) {
            translationIdByLanguage = applyPublishingServiceMethods(knowledgeIdAndTranslation);
        }
        return translationIdByLanguage;
    }
    
    private static Map<String, Id> applyPublishingServiceMethods(Map<String, TranslationMethodWrapper> knowledgeIdAndTranslation) {
        Map<String, Id> translationIdByLanguage = new Map<String, Id>();
        for(String languageAndKnowledgeId: knowledgeIdAndTranslation.keySet()) {
            Id draftTranslationId;
            TranslationMethodWrapper translationWrapper = knowledgeIdAndTranslation.get(languageAndKnowledgeId);
            Knowledge__kav translation = translationWrapper.translation;
            try {
                if(translationWrapper.updateAndPublish || translationWrapper.onlyUpdate) {
                    draftTranslationId = translation.Id;
                }
                else if(translationWrapper.editPublishedVersion) {
                    draftTranslationId = KbManagement.PublishingService.editPublishedTranslation(translation.KnowledgeArticleId, translation.Language, true);
                }
                else if(translationWrapper.submitForTranslation) {
                    if(kbTranslationQueue != null && kbTranslationQueue.size() > 0) {
                        String language = languageAndKnowledgeId.substringBefore('~');
                        draftTranslationId = KbManagement.PublishingService.submitForTranslation(translationWrapper.knowledgeArticleId, language, kbTranslationQueue[0].Id, System.now());
                    }
                }
            } catch(Exception ex) {
                System.debug('Knowledge Publishing Service method failed due to: '+ex.getMessage());
                throw new TranslationException('Publishing Service method failed : '+ ex.getMessage());
            }
            translationIdByLanguage.put(languageAndKnowledgeId, draftTranslationId);
        }
        return translationIdByLanguage;
    }
    
    private static Map<Id, Knowledge__kav> copyTranslatedValues(Map<Id, Knowledge__kav> masterArticleMap, Map<String, Knowledge__kav> translationByLanguage, Set<String> allFields, Set<Id> translationArticleIds) {
        Map<Id, Knowledge__kav> translatedArticles = new Map<Id, Knowledge__kav>();
        Set<String> fieldsToByPass = new Set<String>{'Summary', 'Title', 'Question__c', 'Answer__c', 'Content__c', 'L1Answer__c', 'L1Content__c'};
        Set<String> fieldsToBeCopied = new Set<String>();
        fieldsToBeCopied.addAll(allFields);
        fieldsToBeCopied.removeAll(fieldsToByPass);
        fieldsToBeCopied.removeAll(new Set<String>{'KnowledgeArticleId', 'MasterVersionId', 'Language', 'ArticleMasterLanguage'});
        allFields.add('Language');
        List<Knowledge__kav> draftArticlesToBeTranslated = new SLT_Knowledge().getArticlesById(translationArticleIds, allFields);
        if(masterArticleMap != null && !masterArticleMap.isEmpty() && draftArticlesToBeTranslated != null && draftArticlesToBeTranslated.size() > 0 && disclaimerByLanguage != null && !disclaimerByLanguage.isEmpty()) {
            for(Knowledge__kav article: draftArticlesToBeTranslated) {
                if(masterArticleMap.containsKey(article.KnowledgeArticleId)) {
                    Knowledge__kav masterArticle = masterArticleMap.get(article.KnowledgeArticleId);
                    String languageAndKnowledgeId = article.Language + '~' + article.KnowledgeArticleId;
                    for(String fieldName: fieldsToBeCopied) {
                        article.put(fieldName, masterArticle.get(fieldName)); 
                        article.ArticleTranslatedFrom__c = masterArticle.Id;
                    }
                    if(translationByLanguage.containsKey(languageAndKnowledgeId) && translationByLanguage.get(languageAndKnowledgeId) != null) {
                        Knowledge__kav translation = translationByLanguage.get(languageAndKnowledgeId);
                        String disclaimer = disclaimerByLanguage.containsKey(translation.Language) && disclaimerByLanguage.get(translation.Language) != null ? disclaimerByLanguage.get(translation.Language): '';
                        article.Answer__c = (translation.Answer__c != null && translation.Answer__c != '') ? disclaimer + translation.Answer__c : '';
                        article.Content__c = (translation.Content__c != null && translation.Content__c != '') ? disclaimer + translation.Content__c : '';
                        article.L1Answer__c = (translation.L1Answer__c != null && translation.L1Answer__c != '') ? disclaimer + translation.L1Answer__c : '';
                        article.L1Content__c = (translation.L1Content__c != null && translation.L1Content__c != '') ? disclaimer + translation.L1Content__c : '';
                        article.Question__c = translation.Question__c;
                        article.Title = translation.Title;
                        article.Summary = translation.Summary;
                    }
                    article.IsOutOfdate = false;
                    translatedArticles.put(article.Id, article);
                }
            }
        }
        return translatedArticles;
    } 
    
    public class TranslationException extends Exception {
        
    }  
    
    class TranslationMethodWrapper {
        Knowledge__kav translation;
        Boolean updateAndPublish;
        Boolean onlyUpdate;
        Boolean editPublishedVersion;
        Boolean submitForTranslation;
        Id knowledgeArticleId;
        String language;
        TranslationMethodWrapper() {
            this.updateAndPublish = false;
            this.onlyUpdate = false;
            this.editPublishedVersion = false;
            this.submitForTranslation = false;
        }
    }
    
    public class ArticleWrapper {
        public Id knowledgeArticleId;
        public Knowledge__kav masterArticle;
        public Set<String> languagesForTranslation;
    }
}