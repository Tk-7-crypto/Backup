global class BCH_CSM_ArticleTranslation implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    Set<String> allFields;
    List<String> exception_List;
    CSM_Translate_API_Connection__c translateAPI;
    public static OrgWideEmailAddress[] noReplyAddress = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByAdress(CON_CSM.S_NO_REPLY_EMAIL, new Set<String>{'Id'});
    public BCH_CSM_ArticleTranslation() {
        exception_List = new List<String>();
        this.allFields = UTL_CSM_ArticleTranslation.getAllCustomFields(Knowledge__kav.sObjectType);
        this.allFields.addAll(new Set<String>{'KnowledgeArticleId', 'Summary', 'Title', 'ArticleMasterLanguage'});
        this.translateAPI = UTL_CSM_ArticleTranslation.translateAPISetting;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String fields = String.join(new List<String>(allFields), ', ');
        String query = 'SELECT '+ fields +' FROM Knowledge__kav WHERE PublishStatus = \'Online\' AND IsMasterLanguage = TRUE';
        query = (translateAPI != null && translateAPI.TranslationBatchCriteria__c != null && translateAPI.TranslationBatchCriteria__c != '') ? query + ' ' +  translateAPI.TranslationBatchCriteria__c : query;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Knowledge__kav> masterArticleList) {
        Map<Id, Knowledge__kav> articleKnowledgeIdMap = new Map<Id, Knowledge__kav>(); 
        for(Knowledge__kav masterArticle: masterArticleList) {
            articleKnowledgeIdMap.put(masterArticle.KnowledgeArticleId, masterArticle);
        }
        if(!articleKnowledgeIdMap.isEmpty()) {
            List<UTL_CSM_ArticleTranslation.ArticleWrapper> articleWrapperList = getArticlesToBeTranslated(articleKnowledgeIdMap); 
            if(articleWrapperList != null && articleWrapperList.size() > 0) {
                try {
                    UTL_CSM_ArticleTranslation.translateRecords(articleWrapperList, allFields, false);
                } catch(UTL_CSM_ArticleTranslation.TranslationException ex) {
                    exception_List.add(ex.getmessage());
                } catch (Exception ex) {
                    exception_List.add(ex.getmessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        if(exception_List.size() > 0){
            AsyncApexJob apexJob = [SELECT Id, CreatedBy.Email FROM AsyncApexJob WHERE Id =: bc.getJobId()];
            sendMailOnException(exception_List, new List<String>{apexJob.CreatedBy.Email});
        }
    }
    
    private static List<UTL_CSM_ArticleTranslation.ArticleWrapper> getArticlesToBeTranslated(Map<Id, Knowledge__kav> articleKnowledgeIdMap) {
        List<UTL_CSM_ArticleTranslation.ArticleWrapper> articleWrapperList = new List<UTL_CSM_ArticleTranslation.ArticleWrapper>();
        Set<String> allLanguages = UTL_CSM_ArticleTranslation.availableLanguagesForTranslation;
        Map<Id, Set<String>> translatedLanguages = new Map<Id, Set<String>>();
        List<Knowledge__kav> attachedTranslations = new SLT_Knowledge().getTranslationsByKnowledgeId(articleKnowledgeIdMap.keySet(), new Set<String>{'Id', 'KnowledgeArticleId', 'PublishStatus', 'Language', 'isLatestVersion'});
        for(Knowledge__kav translation: attachedTranslations) {
            if(translatedLanguages.containsKey(translation.KnowledgeArticleId)) {
                translatedLanguages.get(translation.KnowledgeArticleId).add(translation.Language);
            }
            else {
                translatedLanguages.put(translation.KnowledgeArticleId, new Set<String>{translation.Language});
            }
        }
        for(Id knowledgeId: articleKnowledgeIdMap.keySet()) {
            Set<String> languagesForTranslation = new Set<String>();
            languagesForTranslation.addAll(allLanguages);
            languagesForTranslation.remove(articleKnowledgeIdMap.get(knowledgeId).ArticleMasterLanguage);
            if(translatedLanguages.containsKey(knowledgeId) && translatedLanguages.get(knowledgeId) != null && !translatedLanguages.get(knowledgeId).containsAll(allLanguages)) {
                languagesForTranslation.removeAll(translatedLanguages.get(knowledgeId)); 
                UTL_CSM_ArticleTranslation.ArticleWrapper articleWrapper = new UTL_CSM_ArticleTranslation.ArticleWrapper();
                articleWrapper.masterArticle = articleKnowledgeIdMap.get(knowledgeId);
                articleWrapper.knowledgeArticleId = knowledgeId;
                articleWrapper.languagesForTranslation = languagesForTranslation;
                articleWrapperList.add(articleWrapper);
            } 
            else if(!translatedLanguages.containsKey(knowledgeId)) {
                UTL_CSM_ArticleTranslation.ArticleWrapper articleWrapper = new UTL_CSM_ArticleTranslation.ArticleWrapper();
                articleWrapper.masterArticle = articleKnowledgeIdMap.get(knowledgeId);
                articleWrapper.knowledgeArticleId = knowledgeId;
                articleWrapper.languagesForTranslation = languagesForTranslation;
                articleWrapperList.add(articleWrapper);
            }
        }
        return articleWrapperList;
    }
    
    @TestVisible    
    private void sendMailOnException(List<String> exception_List, List<String> toAddresses) {
        String bodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if(noReplyAddress != null && noReplyAddress.size() > 0) {
            mail.setOrgWideEmailAddressId(noReplyAddress[0].Id);
        }
        mail.setUseSignature(false);       
        bodyText = '';
        mail.setSubject('\nExceptions were thrown in Batch Class BCH_CSM_ArticleTranslation');                       
        bodyText += '============== Exception ==============\n';
        for(String exp : exception_List){              
            bodyText += exp;      
        }               
        mail.setPlainTextBody(bodyText);   
        if(!Test.isRunningTest()) {  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }       
    }
}