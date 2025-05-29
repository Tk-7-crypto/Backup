public class CNT_CSM_CommunityPage {
    @AuraEnabled
    public static List<Contact> getUserContact(){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String> {'Name','Portal_Case_Type__c','AccountId','Contact_User_Type__c','MikadoServiceLevel__c'});
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUser(){
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'FirstName', 'Contact.Portal_Case_Type__c','Contact.MikadoServiceLevel__c', 'Contact.Contact_User_Type__c', 'Contact.Remove_KB_Access__c' ,'Contact.Account.AccountCountry__c','Contact.Remove_Data_Privacy_Section_Access__c'});
        } 
        else if(UserInfo.getUserType().contains(CON_CSM.S_STANDARD)) {
            List<User> standardUsers = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'FirstName', 'Profile.Name', 'Contact.Portal_Case_Type__c','Contact.MikadoServiceLevel__c', 'Contact.Contact_User_Type__c','Contact.Account.AccountCountry__c','Contact.Remove_Data_Privacy_Section_Access__c'});
            if(standardUsers != null && standardUsers.size() > 0 && (standardUsers[0].Profile.Name == 'Service User' || standardUsers[0].Profile.Name == 'System Administrator')) {
                users = standardUsers;
            }
        }
        return users;
    }
}
