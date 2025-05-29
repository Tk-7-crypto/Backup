public class CNT_CSM_KnowledgeReview {
    @AuraEnabled
    public static List<CSM_QI_Knowledge_Article_Review__c> getAllKnowledgeReviewList(String articleId){
        List<Knowledge__kav> articleIds = Database.query('SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =:articleId LIMIT 1');
        String kaId = null;
        List<CSM_QI_Knowledge_Article_Review__c> karList = new List<CSM_QI_Knowledge_Article_Review__c>();
        if(articleIds != null && !articleIds.isEmpty()){
            for(Knowledge__kav kv : articleIds){
                kaId = kv.KnowledgeArticleId;
            }
            karList = Database.query('SELECT Id,Comment__c,Review_Date__c,CreatedDate,LastModifiedById,LastModifiedBy.Name,LastModifiedBy.FullPhotoUrl,Knowledge__r.VersionNumber FROM CSM_QI_Knowledge_Article_Review__c WHERE Knowledge__r.KnowledgeArticleId = :kaId order by LastModifiedDate desc');
        }
        return karList;
    }
    @AuraEnabled
    public static List<CSM_QI_Knowledge_Article_Review__c> insertKnowledgeReview(String articleId,Date reviewDate,String reviewComment){
                CSM_QI_Knowledge_Article_Review__c kar = new CSM_QI_Knowledge_Article_Review__c(Knowledge__c = articleId, Review_Date__c = reviewDate, Comment__c = reviewComment);
        insert kar;
        return getAllKnowledgeReviewList(articleId);
    }
    
}
