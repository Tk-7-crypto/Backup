public class CNT_CSM_FollowUnFollowController {
    @AuraEnabled
    public static Boolean recordIsFollowed(String recordId) {
        Boolean isFollowed = false;
        list<User> users = new SLT_User().selectAccountCountryByUser(UserInfo.getUserId());
        if (!users.isEmpty()) {
            List <CSM_QI_Case_Follower__c> usersf = [SELECT id FROM CSM_QI_Case_Follower__c WHERE Contact__c=:users[0].ContactId AND Case__c=:recordId LIMIT 1];
            if (!usersf.isEmpty()) {
                isFollowed = true;
            }
        }
        return isFollowed;
    }

    @AuraEnabled
    public static Boolean followRecord(String recordId,Boolean isFollowed) {
        list<User> users = new SLT_User().selectAccountCountryByUser(UserInfo.getUserId());
        if (!users.isEmpty()) {
            if(!isFollowed) {
                CSM_QI_Case_Follower__c cf;
                if(users[0].AccountId != null) {
                    String accCountry = [Select AccountCountry__c from Account where Id =: users[0].AccountId].AccountCountry__c;
                    cf = new CSM_QI_Case_Follower__c(Contact__c=users[0].ContactId, Case__c=recordId, Account_Country__c = accCountry);
                }
                else {
                    cf = new CSM_QI_Case_Follower__c(Contact__c=users[0].ContactId, Case__c=recordId);
                }
                insert cf;
            }
            if(isFollowed) {
                CSM_QI_Case_Follower__c cf = [SELECT Id FROM CSM_QI_Case_Follower__c WHERE Contact__c=: users[0].ContactId AND Case__c=:recordId LIMIT 1];
                delete cf;
            }
        }
        return !isFollowed;
    }
}