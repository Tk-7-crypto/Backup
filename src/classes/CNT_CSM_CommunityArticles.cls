public without sharing class CNT_CSM_CommunityArticles {

    public class articleWrapper {
        @AuraEnabled
        public Knowledge__kav contentArticle {get; set;}
        @AuraEnabled
        public Boolean forThisAcc {get; set;}
        @AuraEnabled
        public Integer versionNumber {get; set;}
        @AuraEnabled
        public Date visibilityDate {get; set;}
        @AuraEnabled
        public Decimal chapterOrder {get; set;}
        @AuraEnabled
        public Decimal articleOrder {get; set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<articleWrapper> getArticlesByCategoryForCurrentUser(String category, String language){
        List<articleWrapper> articles = new List<articleWrapper>();
        List<User> users = new List<User>();
        List<Knowledge__kav> articleList1=new List<Knowledge__kav>();
        List<Knowledge__kav> articleList2=new List<Knowledge__kav>();
        List<articleWrapper> articleWrapperList1=new List<articleWrapper>();
        List<articleWrapper> articleWrapperList2=new List<articleWrapper>();
        String fields = 'Id, KnowledgeArticleId, Article_Chapter__c, Title, UrlName, Summary, ArticleNumber, RecordTypeId, ArticleTotalViewCount, End_date_of_display_as_new_or_updated__c, VersionNumber, Language, IsMasterLanguage, ProductName__c , Product__r.Community_Topic__r.Name';
        String category_conditions = '';
        String prodIds = '',removeProd = '';
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.Remove_KB_Access__c','LanguageLocaleKey','Contact.KB_Location__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                String userType = users[0].Contact.Contact_User_Type__c;
                String contact_role_conditions = '';
                if (userType == 'Rep User') {
                    contact_role_conditions =' (Contact_Role__c = \'\' or Contact_Role__c = \'Rep User\') and ';
                }
                String KB_Location = users[0].Contact.KB_Location__c;
                String location_condition = '';
                if (KB_Location != null) {
                    KB_Location = '\'' + KB_Location.replace(';','\',\'') +'\'';
                    location_condition = ' OR Location__r.Location__c  in ('+ KB_Location +')';
                }
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()) {
                    for (Integer i=0; i<dataList.size(); i++) {
                        prodIds += '\''+ dataList[i].ProductId__c+'\'';
                        if(i < dataList.size()-1){
                            prodIds += ',';
                        }
                    }

                }else{
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for (Integer i=0; i<prodDataList.size(); i++) {
                        removeProd += '\''+ prodDataList[i].Product__c+'\'';
                        if(i < prodDataList.size()-1){
                            removeProd += ',';
                        }
                    }
                }
                String ids ='';
                List<asset> assets = new List<asset>();
                if(category != '') {
                    if(dataList != null && !dataList.isEmpty()){
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+ prodIds +')  AND Product2.Community_Topic__r.Name  =\'' + category +'\'');
                    }else if(removeProd.length()>1){
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id not in ('+ removeProd +') AND Product2Id !=\'\' AND Product2.Community_Topic__r.Name  =\'' + category +'\'');
                    }else{
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\' AND Product2.Community_Topic__r.Name  =\'' + category +'\'');
                    }
                }else{
                    if(dataList != null && !dataList.isEmpty()){
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+ prodIds +') AND Product2.Community_Topic__c !=\'\'');
                    }else if(removeProd.length()>1){
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id not in ('+ removeProd +') AND Product2Id !=\'\' AND Product2.Community_Topic__c !=\'\'');
                    }else{
                        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\' AND Product2.Community_Topic__c !=\'\'');
                    }
                }

                for (Integer i=0; i<assets.size(); i++) {
                    ids += '\''+ assets[i].Product2Id+'\'';
                    if(i < assets.size()-1){
                        ids += ',';
                    }
                }
                if (ids !='') {
                    if(pillar.indexOf('R&D') != -1) {
                        ids += ',\'\'';
                    }
                    category_conditions = 'Product__c in ('+ ids +') and ';
                }

                articleList1 = Database.query('select ' + fields + ' from Knowledge__kav where ' + category_conditions + contact_role_conditions + ' Pillar__c in (' + pillar + ') and PublishStatus =\'Online\' and IsVisibleInCsp = true and Id in  (select Knowledge__c  from Knowledge_Account_RelationShip__c where Account__c =\'' + users[0].AccountId +'\' AND (Location__c = \'\' ' + location_condition + ' ))  order By Article_Chapter__c, ArticleTotalViewCount desc');
                articleList2 = Database.query('select ' + fields + ' from Knowledge__kav where ' + category_conditions + contact_role_conditions + ' Pillar__c in (' + pillar + ') and PublishStatus =\'Online\' and IsVisibleInCsp = true and Id NOT in  (select Knowledge__c  from Knowledge_Account_RelationShip__c)  order By Article_Chapter__c , ArticleTotalViewCount desc');

                Map<String, Decimal> articleChapterOrderMap = new Map<String, Decimal>();
                for (CSM_QI_Case_Categorization__c cat : [SELECT Article_Chapter_Order__c, Article_Chapter__c FROM CSM_QI_Case_Categorization__c WHERE Product__r.Community_Topic__r.Name =:category AND Type__c = 'Knowledge' AND Article_Chapter_Order__c !=null]) {
                    articleChapterOrderMap.put(cat.Article_Chapter__c, cat.Article_Chapter_Order__c);
                }

                Set<String> ArticleNumbers = new Set<String>();
                for (Knowledge__kav article : articleList1) {
                    ArticleNumbers.add(article.ArticleNumber);
                }
                for (Knowledge__kav article : articleList2) {
                    ArticleNumbers.add(article.ArticleNumber);
                }

                Map<String, Decimal> articleOrderMap = new Map<String, Decimal>();
                for (CSM_QI_Knowledge_Article_Order__c order : [SELECT ArticleNumber__c, Order__c FROM CSM_QI_Knowledge_Article_Order__c WHERE ArticleNumber__c IN :ArticleNumbers]) {
                    articleOrderMap.put(order.ArticleNumber__c, order.Order__c);
                }

                Map<Id,Id> userKnowledgeId = new Map<Id,Id>();
                for (Knowledge__kav k : articleList1) {
                    articleWrapper sr = new articleWrapper();
                    sr.contentArticle = k;
                    sr.forThisAcc = true;
                    sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                    sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                    if(users[0].LanguageLocaleKey == k.Language)
                    {
                        if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                            userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                        }
                        articleWrapperList1.add(sr);
                    }
                }

                for(Knowledge__kav k : articleList1)
                {
                    articleWrapper sr = new articleWrapper();
                    sr.forThisAcc = true;
                    sr.contentArticle = k;
                    sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                    sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                    if(k.IsMasterLanguage)
                    {
                        if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                            userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                            articleWrapperList1.add(sr);
                        }
                    }
                }

                for (Knowledge__kav k : articleList2) {
                    articleWrapper sr = new articleWrapper();
                    sr.contentArticle = k;
                    sr.forThisAcc = false;
                    sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                    sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                    if(users[0].LanguageLocaleKey == k.Language)
                    {
                        if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                            userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                        }
                        articleWrapperList2.add(sr);
                    }
                }

                for(Knowledge__kav k : articleList2)
                {
                    articleWrapper sr = new articleWrapper();
                    sr.forThisAcc = false;
                    sr.contentArticle = k;
                    sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                    sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                    if(k.IsMasterLanguage)
                    {
                        if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                            userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                            articleWrapperList2.add(sr);
                        }
                    }
                }



                articles.addall(articleWrapperList1);
                articles.addall(articleWrapperList2);


            }
        }else{
            List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
            for (Integer i=0; i<prodDataList.size(); i++) {
                removeProd += '\''+ prodDataList[i].Product__c+'\'';
                if(i < prodDataList.size()-1){
                    removeProd += ',';
                }
            }
            if(category != '') {
                if(removeProd.length()>1){
                    category_conditions = 'Product__r.Available_to_the_Guest_User__c=true and Product__r.Community_Topic__r.Name  =\'' + category +'\' and Product__c not in ('+ removeProd +') and';
                }else{
                    category_conditions = 'Product__r.Available_to_the_Guest_User__c=true and Product__r.Community_Topic__r.Name  =\'' + category +'\' and ';
                }
            }else{
                if(removeProd.length()>1){
                    category_conditions = 'Product__r.Available_to_the_Guest_User__c=true and Product__c not in ('+ removeProd +') and ';
                }else{
                    category_conditions = 'Product__r.Available_to_the_Guest_User__c=true and';
                }
            }
            Map<String, Decimal> articleChapterOrderMap = new Map<String, Decimal>();
            for (CSM_QI_Case_Categorization__c cat : [SELECT Article_Chapter_Order__c, Article_Chapter__c FROM CSM_QI_Case_Categorization__c WHERE Product__r.Community_Topic__r.Name =:category AND Type__c = 'Knowledge']) {
                articleChapterOrderMap.put(cat.Article_Chapter__c, cat.Article_Chapter_Order__c);
            }
            articleList1 = Database.query('select ' + fields + ' from Knowledge__kav where ' + category_conditions + ' PublishStatus =\'Online\' and IsVisibleInCsp = true and Id NOT in  (select Knowledge__c  from Knowledge_Account_RelationShip__c)  order By Article_Chapter__c , ArticleTotalViewCount desc');
      
            Set<String> ArticleNumbers = new Set<String>();
            for (Knowledge__kav article : articleList1) {
                ArticleNumbers.add(article.ArticleNumber);
            }

            Map<String, Decimal> articleOrderMap = new Map<String, Decimal>();
            for (CSM_QI_Knowledge_Article_Order__c order : [SELECT ArticleNumber__c, Order__c FROM CSM_QI_Knowledge_Article_Order__c WHERE ArticleNumber__c IN :ArticleNumbers]) {
                articleOrderMap.put(order.ArticleNumber__c, order.Order__c);
            }

            Map<Id,String> userKnowledgeId = new Map<Id,String>();
            for (Knowledge__kav k : articleList1) {
                articleWrapper sr = new articleWrapper();
                sr.contentArticle = k;
                sr.forThisAcc = false;
                sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                if(language == k.Language)
                {
                    if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                        userKnowledgeId.put(k.KnowledgeArticleId, 'guest');
                    }
                    articleWrapperList1.add(sr);
                }
            }

            for(Knowledge__kav k : articleList1) {
                articleWrapper sr = new articleWrapper();
                sr.forThisAcc = false;
                sr.contentArticle = k;
                sr.chapterOrder = articleChapterOrderMap.containsKey(k.Article_Chapter__c) ? articleChapterOrderMap.get(k.Article_Chapter__c) : 9999;
                sr.articleOrder = articleOrderMap.containsKey(k.ArticleNumber) ? articleOrderMap.get(k.ArticleNumber) : 9999;
                if(k.IsMasterLanguage)
                {
                    if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                        userKnowledgeId.put(k.KnowledgeArticleId, 'guest');
                        articleWrapperList1.add(sr);
                    }
                }
            }
            articles.addall(articleWrapperList1);
    
        }
        articles = getTranslatedChapterArticle(articles, language);
        return articles;
    }

    public static List<articleWrapper> getTranslatedChapterArticle(List<articleWrapper> articles, String targetLanguage) {
        StaticResource resource = getLabelsResource();
        Map<String, String> translationCache = new Map<String, String>();
        for (articleWrapper article : articles) {
            String chapterToTranslate = article.contentArticle.Article_Chapter__c;
            if (String.isBlank(chapterToTranslate) || chapterToTranslate == 'Please Specify') {
                chapterToTranslate = 'Others';
            }
            if (translationCache.containsKey(chapterToTranslate)) {
                article.contentArticle.Article_Chapter__c = translationCache.get(chapterToTranslate);
                continue;
            }
            String translatedText = getChapterLabel(resource, chapterToTranslate, targetLanguage);
            if (translatedText == null) {
                HttpResponse response = WSC_CSM_TranslateCallout.translateText(chapterToTranslate, targetLanguage);
                if (response != null && response.getStatusCode() == 200) {
                    try {
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        if (responseMap.containsKey('data')) {
                            Map<String, Object> data = (Map<String, Object>) responseMap.get('data');
                            if (data.containsKey('translations')) {
                                List<Object> translations = (List<Object>) data.get('translations');
                                if (!translations.isEmpty()) {
                                    Map<String, Object> translation = (Map<String, Object>) translations[0];
                                    if (translation.containsKey('translatedText')) {
                                        translatedText = (String) translation.get('translatedText');
                                    }
                                }
                            }
                        }
                    } catch (Exception e) {
                        throw new AuraHandledException('Exception parsing translation response: ' + e.getMessage());
                    }
                }
                translationCache.put(chapterToTranslate, translatedText != null ? translatedText : chapterToTranslate);
            }
            article.contentArticle.Article_Chapter__c = translatedText != null ? translatedText : chapterToTranslate;
        }
        return articles;
    }  

    public static String getChapterLabel(StaticResource resource, String chapterKey, String language) {
        if (resource != null && resource.Body != null) {
            String jsonContent = resource.Body.toString();
            Map<String, Object> labelsData = (Map<String, Object>) JSON.deserializeUntyped(jsonContent);
            if (labelsData != null && labelsData.containsKey(chapterKey)) {
                Map<String, Object> translationsObject = (Map<String, Object>) labelsData.get(chapterKey);
                if (translationsObject != null && translationsObject.containsKey(language)) {
                    return (String) translationsObject.get(language);
                }
            }
        }
        return null;
    }

    public static StaticResource getLabelsResource() {
        List<StaticResource> resources = [SELECT Body FROM StaticResource WHERE Name = 'ArticleChapterLabels' LIMIT 1];
        if (!resources.isEmpty()) {
            return resources[0];
        }
        return null;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<articleWrapper> getArticlesByCategoryForCurrentPRMUser(String category,Boolean salesCollateral)
    {
        List<User> users = new List<User>();
        List<Knowledge__kav> article1=new List<Knowledge__kav>();
        List<Knowledge__kav> article2=new List<Knowledge__kav>();
        List<articleWrapper> articles1=new List<articleWrapper>();
        List<articleWrapper> articles2=new List<articleWrapper>();
        List<articleWrapper> articles3=new List<articleWrapper>();
        String partnerType = '';
        String pillar = '';
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Partner_Type__c','Contact.Portal_Case_Type__c','LanguageLocaleKey'});
        partnerType = users[0].Contact.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        pillar = users[0].Contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';

        article1=new SLT_Knowledge().selectByCategory(category,partnerType,pillar,users[0].AccountId,true);
        article2=new SLT_Knowledge().selectByCategoryAndAccount(category,partnerType,pillar,users[0].AccountId,true);
        Map<Id,Id> userKnowledgeId = new Map<Id,Id>();
        if(article1.size()>0) {
            for (Knowledge__kav k : article1) {
                articleWrapper sr = new articleWrapper();
                sr.contentArticle = k;
                sr.versionNumber = k.VersionNumber;
                sr.visibilityDate = k.End_date_of_display_as_new_or_updated__c;
                if(users[0].LanguageLocaleKey == k.Language)
                {
                    if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                        userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                    }
                    articles1.add(sr);
                }
            }
        }
        /*
        for(Knowledge__kav k : article1)
        {
            articleWrapper sr = new articleWrapper();
            sr.contentArticle = k;
            sr.versionNumber = k.VersionNumber;
            sr.visibilityDate = k.End_date_of_display_as_new_or_updated__c;
            if(k.IsMasterLanguage)
            {
                if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                    userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                    articles1.add(sr);
                }
            }
        }*/
        if(article2.size()>0) {
            for (Knowledge__kav k : article2) {
                articleWrapper sr = new articleWrapper();
                sr.contentArticle = k;
                sr.versionNumber = k.VersionNumber;
                sr.visibilityDate = k.End_date_of_display_as_new_or_updated__c;
                if(users[0].LanguageLocaleKey == k.Language)
                {
                    if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                        userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                    }
                    articles2.add(sr);
                }
            }
            /*
            for(Knowledge__kav k : article2)
            {
                articleWrapper sr = new articleWrapper();
                sr.contentArticle = k;
                sr.versionNumber = k.VersionNumber;
                sr.visibilityDate = k.End_date_of_display_as_new_or_updated__c;
                if(k.IsMasterLanguage)
                {
                    if(!userKnowledgeId.containsKey(k.KnowledgeArticleId)) {
                        userKnowledgeId.put(k.KnowledgeArticleId,users[0].Id);
                        articles2.add(sr);
                    }
                }
            }*/
        }
        articles3.addall(articles1);
        articles3.addall(articles2);
        return articles3;
    }

    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_Favorite_Record__c> getFavoriteArticles()
    {
        List<CSM_QI_Favorite_Record__c> favRecordList = [SELECT EntityId__c, EntityName__c FROM CSM_QI_Favorite_Record__c WHERE User__c =: UserInfo.getUserId() AND EntityName__c = 'Knowledge__kav'];
        return favRecordList;
    }

    @AuraEnabled(cacheable=true)
    public static String getArticleProductByUrlName(String urlName, String language) {
        List<Knowledge__kav> articles = [
        SELECT ProductName__c, Product__r.Community_Topic__r.Name, IsMasterLanguage, Language
        FROM Knowledge__kav 
        WHERE UrlName = :urlName 
        AND PublishStatus = 'Online'
        ];
        
        if (articles.isEmpty()) {
            return null;
        }
        for (Knowledge__kav article : articles) {
            if (article.Language == language) {
                return article.Product__r.Community_Topic__r.Name;
            }
        }
        for (Knowledge__kav article : articles) {
            if (article.IsMasterLanguage) {
                return article.Product__r.Community_Topic__r.Name;
            }
        }
        return null;
    }
}