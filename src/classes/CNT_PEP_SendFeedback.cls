public class CNT_PEP_SendFeedback {
    
    @AuraEnabled
    public static void saveFeedback(String feedback, String docTitle, String aId, String itemType, String fileId, Boolean isPRMSalesArticle){
        Id userInfo = UserInfo.getUserId();
        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        List<User> users = new List<User>();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
        Community_User_feedback__c cuf = new Community_User_feedback__c();
        if(itemType == 'KB Article'){
            List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {aId}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title'});
            cuf = new Community_User_feedback__c(Subject__c = 'New feedback related to the ' + itemType + ': ' + docTitle, Body__c = feedback, File__c = domainURL + '/lightning/r/Knowledge__kav/' + kl[0].KnowledgeArticleId + '/view' , File_Title__c = docTitle, Type__c = 'KB Article', PRM_Sales_Collateral__c = isPRMSalesArticle, Contact__c = users[0].Contact.Id, Source__c = CON_PEP.S_PEP_SOURCE, ArticleNumber__c = kl[0].ArticleNumber, PRM_User__c = users[0].Id);
        }
        else{
            cuf = new Community_User_feedback__c(Subject__c = 'New feedback related to the ' + itemType + ': ' + docTitle, Body__c = feedback, File__c = domainURL + '/lightning/r/ContentDocument/' + fileId + '/view', File_Title__c = docTitle, Type__c = 'File', Contact__c = users[0].Contact.Id, Source__c = CON_PEP.S_PEP_SOURCE, PRM_User__c = users[0].Id);
        }
        insert cuf;
    }
    
    @AuraEnabled
    public static void saveLikeDislike(String likeOrDislike, String kid){
        system.debug('save like dislike call : 	');
        Community_User_feedback__c cuf;
        List<Community_User_feedback__c> cufl = new List<Community_User_feedback__c>();
        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        List<User> users = new List<User>();
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title'});
                if(kl.size() > 0 ) {
                    cufl = new SLT_CommunityUserFeedback().getFeedback(users[0].Id, kl[0].ArticleNumber, CON_PEP.S_PEP_SOURCE);
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
                        cuf.Contact__c = users[0].Contact.Id;
                        cuf.PRM_User__c = users[0].Id;
                        cuf.ArticleNumber__c = kl[0].ArticleNumber;
                        cuf.Source__c = CON_PEP.S_PEP_SOURCE;
                        cuf.File_Title__c=kl[0].Title;
                        cuf.File__c = domainURL + '/lightning/r/Knowledge__kav/' + kl[0].KnowledgeArticleId +'/view';
                        insert cuf;
                    }
                }
            }        
    }

    @AuraEnabled
    public static Community_User_feedback__c getLikeDislike(String kid){
        Community_User_feedback__c cuf = new Community_User_feedback__c();
        List<Community_User_feedback__c> cufl = new List<Community_User_feedback__c>();
        List<User> users = new List<User>();
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId', 'Contact.Remove_KB_Access__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {kid}, new Set<String> {'ArticleNumber'});
                if(kl.size() > 0 ) {                    
                    cufl = new SLT_CommunityUserFeedback().getFeedback(users[0].Id, kl[0].ArticleNumber, CON_PEP.S_PEP_SOURCE);
                    if (cufl.size() > 0)
                        cuf = cufl[0];
                }
            }
        return cuf;
    }
}
