public without sharing class CNT_CSM_Feedback {
    @AuraEnabled
    public static void saveFeedback(String feedback, String kid, String source){
        Community_User_feedback__c cuf = new Community_User_feedback__c();
        List<User> users = new List<User>();
        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
        if (users.size() > 0) {
            String contactId = null;
            if(users[0].Contact != null)
                contactId = users[0].Contact.Id;
            List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title','CreatedById', 'Test__c', 'ProductName__c', 'Pillar__c'});
            if(kl.size() > 0 ) {
                cuf = new Community_User_feedback__c(Body__c = feedback, PRM_User__c = users[0].Id, Contact__c = contactId, ArticleNumber__c = kl[0].ArticleNumber, Source__c = source, File_Title__c=kl[0].Title,  File__c = domainURL + '/lightning/r/Knowledge__kav/' + kl[0].KnowledgeArticleId +'/view', Article_Creator__c =  kl[0].CreatedById, Article_Reviewer__c = kl[0].Test__c, ProductName__c = kl[0].ProductName__c, Pillar__c = kl[0].Pillar__c );
                insert cuf;
            }
        }
    }

    @AuraEnabled
    public static void saveLikeDislike(String likeOrDislike, String kid, String source){
        Community_User_feedback__c cuf;
        List<Community_User_feedback__c> cufl = new List<Community_User_feedback__c>();
        List<User> users = new List<User>();
        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
        if (users.size() > 0) {
            List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title','CreatedById', 'Test__c', 'ProductName__c', 'Pillar__c'});
            if(kl.size() > 0 ) {
                cufl = [SELECT Id, Like_or_Dislike__c FROM Community_User_feedback__c WHERE Like_or_Dislike__c != '' AND PRM_User__c = :users[0].Id AND ArticleNumber__c =:kl[0].ArticleNumber AND Source__c = :source ];
                if (cufl.size() > 0) {
                    cuf = cufl[0];
                    if (cuf.Like_or_Dislike__c == likeOrDislike) {
                        delete cuf;
                    }else{
                        cuf.Like_or_Dislike__c = likeOrDislike;
                        update cuf;
                    }
                } else {
                    cuf =  new Community_User_feedback__c();
                    cuf.Like_or_Dislike__c = likeOrDislike;
                    if(users[0].Contact != null)
                        cuf.Contact__c = users[0].Contact.Id;
                    cuf.PRM_User__c = users[0].Id;
                    cuf.ArticleNumber__c = kl[0].ArticleNumber;
                    cuf.Source__c = source;
                    cuf.File_Title__c=kl[0].Title;
                    cuf.File__c = domainURL + '/lightning/r/Knowledge__kav/' + kl[0].KnowledgeArticleId +'/view';
                    cuf.Article_Creator__c = kl[0].CreatedById;
                    cuf.Article_Reviewer__c = kl[0].Test__c;
                    cuf.ProductName__c = kl[0].ProductName__c;
                    cuf.Pillar__c = kl[0].Pillar__c;
                    insert cuf;
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static Community_User_feedback__c getLikeDislike(String kid, String source){
        Community_User_feedback__c cuf = new Community_User_feedback__c();
        List<Community_User_feedback__c> cufl = new List<Community_User_feedback__c>();
        List<User> users = new List<User>();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
        if (users.size() > 0 ) {
            List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title'});
            if(kl.size() > 0 ) {
                cufl = [SELECT Id, Like_or_Dislike__c FROM Community_User_feedback__c WHERE Like_or_Dislike__c != '' AND PRM_User__c = :users[0].Id AND ArticleNumber__c =:kl[0].ArticleNumber AND Source__c = :source];
                if (cufl.size() > 0)
                    cuf = cufl[0];
            }
        }
        return cuf;
    }

    @AuraEnabled
    public static List<Community_User_feedback__c> getFeedback(String kid){
        List<Community_User_feedback__c> cufl = new List<Community_User_feedback__c>();
        List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title'});
        if(kl.size() > 0 ) {
            cufl = [SELECT Id, Like_or_Dislike__c, Body__c, PRM_User__c, PRM_User__r.Name, Contact__c, Contact__r.Name, LastModifiedDate, Source__c FROM Community_User_feedback__c WHERE ArticleNumber__c =:kl[0].ArticleNumber AND Source__c in (:CON_CSM.S_CSH,:CON_CSM.S_INTERNAL,:CON_PEP.S_PEP_SOURCE) ORDER BY LastModifiedDate DESC ];
        }
        return cufl;
    }
}