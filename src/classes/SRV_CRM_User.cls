/*
 * Version       : 1.0
 * Description   : Service Class for User Selector class
 */
global class SRV_CRM_User {

    public class GroupNotFoundException extends Exception {}

    /**
     * service method to delete users from groups
     * @params : Id groupId
     * @params :  Id userId
     * @returns : Boolean  
     */
    public static Boolean deleteMemberFromGroup(Id groupId, Id userId) {
        String result = 'Group Member Deleted';
        GroupMember groupMember = SLT_GroupMember.getGroupMemberByUserIdAndGroupId(groupId,userId);
        try {
            delete groupMember;
        } catch(Exception e) {
            return false;
        }
        if(userId == UserInfo.getUserId()) {
            return true;
        }
        return false;
    }

    /**
     * service method to add users to groups
     * @params : List<ID> usersIdsList
     * @params : List<ID> groupIdsList
     * @returns : String
     */
    public static String addMemberToGroup(List<ID> usersIdsList, List<ID> groupIdsList) {
        String result = 'Insert Successfully!!.';
        String isNotPermissionToInsert = 'You don\'t have permission to insert the record';
        List<GroupMember> groupMemberList = new List<GroupMember>();
        for(Id groupId : groupIdsList) {
            for(Id userId : usersIdsList) {
                GroupMember groupMember = new GroupMember();
                groupMember.GroupId = groupId;
                groupMember.UserOrGroupId = userId;
                groupMemberList.add(groupMember);
            }
        }
        if(!groupMemberList.isEmpty()) {
            try {
                insert groupMemberList;
            } catch(Exception e) {
                return e.getMessage();
            }
            return result;
        } else {
            return isNotPermissionToInsert;
        }
    }

    /**
     * service method to get the users records which are group member's of a group.
     * @params : Group group
     * @returns : returns the related users list. 
     */
    public static List<User> getUsersAsGroupMemberByGroup(Group groupRecord) {
        list<GroupMember> groupMembersList = SLT_GroupMember.getGroupMembersByGroupId(groupRecord.Id);
        list<Id> userIdsList = new list<Id>();
        for(GroupMember groupMember : groupMembersList)
        {
            userIdsList.add(groupMember.UserOrGroupId);
        }
        List<User> usersList = SLT_User.getUsersByUserIds(userIdsList);
        return usersList;
    }

    /**
     * service method to get the users records related to a searched username.
     * @params : String userName
     * @returns : returns the realted users list.
     */
    public static list<User> getUsers(String userName) {
        Credit_Control_Groups__c creditControlGroups = Credit_Control_Groups__c.getOrgDefaults();
        Integer numberOfUsers = (Integer)creditControlGroups.Number_of_Users__c;
        userName = '%' + userName + '%';
        String license = 'Salesforce' + '%';
        List<User> usersList = SLT_User.getUsersByNameWithLicense(userName, numberOfUsers, license);
        if(usersList.isEmpty()) {
            throw new GroupNotFoundException('No Record Found..');
        }
        return usersList; 
        
    }
    
    /**
     * service method to get user records
     * @params  Set<Id> userIdsSet
     * @return  List<User>
     */
    public static List<User> getUserDetail(Set<Id> userIds) {
        List<User> userList = new List<User>();
        try {
            userList = new SLT_User().selectById(userIds);
        } catch(Exception ex) {
            throw new UserServiceException(new List<String>{ex.getMessage()});
        }   
        return userList;
    }
    
    // Exception Class for Product Service
    public Class UserServiceException extends Exception {
        
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public UserServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }
}