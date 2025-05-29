/*
 * Version       : 1.0
 * Description   : Apex Controller for CNT_LXC_CSATInternal Lightning component 
 */ 
public class CNT_CSM_CSATInternal {
    /*
     * Return List of CSM_QI_CSATInternal__c for a caseId
     */
    @AuraEnabled
    public static List<CSM_QI_CSATInternal__c> getCommentRatingByCaseId(String caseId){
        List<CSM_QI_CSATInternal__c> csatList  = [select Id,CommentParentId__c,CommentId__c,CommentCreatedById__c,CommentCreatedById__r.Name,CommentCreatedById__r.SmallPhotoUrl,CommentBody__c,CommentCreatedDate__c,CommentIsPublished__c,Rate__c,RaterUser__c,RaterUser__r.Name,RaterUser__r.SmallPhotoUrl,RateCreatedDate__c from CSM_QI_CSATInternal__c where CommentParentId__c =: caseId order by CommentCreatedDate__c desc];
        return csatList;
    }
    
    @AuraEnabled
    public static void saveCommentRating (String id, String rate, String caseCurrentQueue) {
        CSM_QI_CSATInternal__c csat = new CSM_QI_CSATInternal__c();
        csat.Id = id;
        csat.Rate__c = rate;
        csat.RaterUser__c = userInfo.getUserId();
        csat.RateCreatedDate__c = DateTime.now();
        csat.Rater_Current_Queue__c = caseCurrentQueue;
        update csat;
    }

    @AuraEnabled
    public static Profile getUserProfile () {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        return profiles[0];
    }

    @AuraEnabled
    public static List<PermissionSetAssignment> getUserPermissionSet () {
        List<PermissionSetAssignment> psa = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() ];
        return psa;
    }

    @AuraEnabled
    public static List<Case> getCase (String caseId) {
        List<Case> cases = new SLT_Case().selectByCaseIdList(new Set<Id> {caseId}, new Set<String> {'Id','CurrentQueue__c'});
        return cases;
    }
}