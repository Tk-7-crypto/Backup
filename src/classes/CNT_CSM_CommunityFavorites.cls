public class CNT_CSM_CommunityFavorites {
    public class CSM_Favorite {
        @AuraEnabled
        public String entityName {get; set;}
        @AuraEnabled
        public String entityId {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String urlName {get; set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<CSM_Favorite> getFavorites()
    {
        List<CSM_Favorite> favorites = new List<CSM_Favorite>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.Remove_KB_Access__c','LanguageLocaleKey'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                List<CSM_QI_Favorite_Record__c> favRecordList = [SELECT EntityId__c, EntityName__c FROM CSM_QI_Favorite_Record__c WHERE User__c =: users[0].Id];

                if (favRecordList != null && favRecordList.size() > 0) {
                    Set<String> knowledgeArticleIds = new Set<String>();
                    Set<Id> caseIds = new Set<Id>();
                    for(CSM_QI_Favorite_Record__c fav : favRecordList) {
                        if(fav.EntityName__c == 'Knowledge__kav') {
                            knowledgeArticleIds.add(fav.EntityId__c);
                        }
                        if(fav.EntityName__c == 'Case') {
                            caseIds.add(fav.EntityId__c);
                        }
                    }
                    List<Knowledge__kav> articles = new SLT_Knowledge().getArticlesByKnowledgeArticleIds(knowledgeArticleIds);
                    Map<Id,Id> userKnowledgeId = new Map<Id,Id>();
                    for (Knowledge__kav article : articles) {
                        if(users[0].LanguageLocaleKey == article.Language) {
                            if(!userKnowledgeId.containsKey(article.KnowledgeArticleId)){
                                userKnowledgeId.put(article.KnowledgeArticleId,users[0].Id);
                            }
                            CSM_Favorite f = new CSM_Favorite();
                            f.entityName = 'Knowledge__kav';
                            f.entityId = article.KnowledgeArticleId;
                            f.title = article.ProductName__c + ' - ' + article.Title  + ' (' + article.Article_Chapter__c + ')';
                            f.urlName = article.UrlName;
                            favorites.add(f);
                        }
                    }


                    for (Knowledge__kav article : articles) {
                        if(article.IsMasterLanguage) {
                            if(!userKnowledgeId.containsKey(article.KnowledgeArticleId)){
                                userKnowledgeId.put(article.KnowledgeArticleId,users[0].Id);
                                CSM_Favorite f = new CSM_Favorite();
                                f.entityName = 'Knowledge__kav';
                                f.entityId = article.KnowledgeArticleId;
                                f.title = article.ProductName__c + ' - ' + article.Title  + ' (' + article.Article_Chapter__c + ')';
                                f.urlName = article.UrlName;
                                favorites.add(f);
                            }
                           
                        }
                    }

                    List<Case> cases = new SLT_Case().selectByCaseIdList(caseIds, new Set<String> {'Id', 'Subject'});
                    for (Case c : cases) {
                        CSM_Favorite f = new CSM_Favorite();
                        f.entityName = 'Case';
                        f.entityId = c.Id;
                        f.title = c.CaseNumber + ' - ' + c.Subject + ' (' + c.Status + ')';
                        favorites.add(f);
                    }
                }
            }
        }
        return favorites;
    }
}