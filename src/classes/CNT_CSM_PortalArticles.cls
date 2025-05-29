/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalArticles component.
 */
public with sharing class CNT_CSM_PortalArticles {
    /*
     * Return List of Knowledge__kav for on topic ID
     */
    @AuraEnabled
    public static List<Knowledge__kav> getArticlesByTopic(String topicId){
        List<Knowledge__kav> articles =  new SLT_Knowledge().selectByTopicId(topicId);
        return articles;
    }
}