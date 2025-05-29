public class SLT_CommunityUserFeedback {
    
    public List<Community_User_Feedback__c> getFeedback(Id userId,String articleNumber,String source){
        return  Database.query('SELECT Id, Like_or_Dislike__c FROM Community_User_Feedback__c WHERE Like_or_Dislike__c != \'\' AND PRM_User__c = :userId AND ArticleNumber__c =:articlenumber AND Source__c =:source');
    }   
}
