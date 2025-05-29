/**
 * @description : Container class for User which interacts with service class.
 */
public without sharing class CNT_lwcSearchComponent {
    
    /**
     * method to retrive the list of users by the searched username
     * @params : String userName
     * @returns : returns the list of related users records.
     */
    @AuraEnabled
    public static list<User> retriveUsersByName(String userName) {
        return SRV_CRM_User.getUsers(userName);
    } 

    /**
     * method to add users to groups.
     * @params : List<ID> usersIds
     * @params : List<ID> groupIds
     * @returns : String
     */
    @AuraEnabled
    public static String addUserToGroup(List<ID> usersIdsList, List<ID> groupIdsList) {
        return SRV_CRM_User.addMemberToGroup(usersIdsList, groupIdsList);
    }

    /**
     * method to retrive the the list of users which are group member of a particular group.
     * @params : Group group
     * @returns : returns the list of related users records.
     */
    @AuraEnabled
    public static list<User> retriveGroupMemberByGroup(Group groupRecord) {
        return SRV_CRM_User.getUsersAsGroupMemberByGroup(groupRecord);
    }

    /**
     * method to delete users from groups
     * @params : Id groupId
     * @params :  Id userId
     * @returns : Boolean 
     */
    @AuraEnabled
    public static Boolean deleteGroupMemberByGroupIdAndUserId(Id groupId, Id userId) {
        return SRV_CRM_User.deleteMemberFromGroup(groupId, userId);
    }

}