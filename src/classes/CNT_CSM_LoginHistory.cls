public  without sharing class CNT_CSM_LoginHistory {

    @AuraEnabled
    public static UserLoginHistory getLoginHistory(Id recordIDD){
        List<LoginHistory> lHistory = new List<LoginHistory>() ;
        UserLoginHistory loginHostoryWrapper = new UserLoginHistory(); 
        loginHostoryWrapper.loginHistory = lHistory;
        loginHostoryWrapper.isCommunityUser = false;
        List<User> u = [SELECT Id, Name, IsActive FROM User WHERE ContactId =:recordIDD];
        if(u.size() > 0 && u != null) {
            lHistory = [SELECT Id, LoginTime, UserId, LoginUrl, Status FROM LoginHistory WHERE userId =:u[0].Id ORDER BY LoginTime DESC LIMIT 10];
            loginHostoryWrapper.loginHistory = lHistory;
            loginHostoryWrapper.isCommunityUser = true;
            loginHostoryWrapper.isActive = u[0].IsActive;
        } 
        return loginHostoryWrapper;
    }
    
    @AuraEnabled
    public static void resetPasswordOrUnlockUser(Id contactId, Boolean reset, Boolean unlock){
        List<User> users = [SELECT Id, Name FROM User WHERE ContactId =: contactId];
        if(users != null && users.size() > 0) {
            Id communityUserId = users[0].Id;
            if(unlock) {
                UserLogin communityUserLogin = [SELECT IsPasswordLocked FROM UserLogin WHERE UserId =: communityUserId];
                communityUserLogin.IsPasswordLocked = false;
                Update communityUserLogin;
                System.resetPassword(communityUserId, true);
            } 
            else if(reset) {
                System.resetPassword(communityUserId, true);
            }
        }
    }
    @AuraEnabled
    public static void activeUser(Id contactId){
        List<User> users = [SELECT Id, Name, IsActive FROM User WHERE ContactId =: contactId];
        if(users != null && users.size() > 0) {
                users[0].IsActive = true;
                Update users[0];
        }
    }
    
    public class UserLoginHistory {
        @AuraEnabled
        public List<LoginHistory> loginHistory;
        @AuraEnabled
        public Boolean isCommunityUser;
        @AuraEnabled
        public Boolean isActive;
    }
}
