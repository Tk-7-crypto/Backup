/*
 * Version       : 1.0
 * Description   : Apex Controller for CNT_LXC_PortalWelcomeTitle Lightning component 
 */ 
public without sharing class CNT_CSM_PortalWelcomeTitle {
    
    /*
    * Return List of ContentFolder  for current user
    */
    @AuraEnabled
    public static List<User> getCurrentUser(){
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        return users;
    }

    @AuraEnabled
    public static void getLastLogin() {
        DateTime lastLogin ;
        User userRecord = new SLT_User().selectUserByUserId(new Set<Id> {userInfo.getUserId()});
        lastLogin = userRecord.LastLoginDate;
        Contact contactRecord = new SLT_Contact().selectContactBasedOnId(new Set<Id>{userRecord.ContactId})[0];
        if(lastLogin != userRecord.LastLoginValue__c){
            userRecord.LastLoginValue__c = userRecord.LastLoginDate;
            update userRecord;
            contactRecord.CSH_User_Last_connection_date__c = lastLogin;
            update contactRecord;
        }
    }
}