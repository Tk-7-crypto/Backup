/*
* Version       : 1.0
* Description   : This Apex class is selector layer for GroupMember
*/
public class SLT_GroupMember{
    
    /**
* This method is used to get Group Member by User Id and Group Id
* @params String userId
* @params Set<Id> groupIdSet
* @return List<GroupMember>
*/
    public List<GroupMember> getGroupMembersByUserAndGroupId(String userId, Set<Id> groupIdSet) {
    	return [SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId = :userId and GroupId In :groupIdSet];
    } 
    
    /**
* This method is used to get Group Member by Group Id
* @params Set<Id> idSet
* @return List<GroupMember>
*/
    public List<GroupMember> getGroupMemberByGroupId(Set<Id> idSet) {
        return [SELECT Id, GroupId, UserOrGroupId
                FROM GroupMember  
                WHERE GroupId in :idSet
               ];
    }
    
    /**
     * This method is used to get the group member by userId and groupId.
     * @params : Id userId
     * @params : Id groupId
     * @returns : returns the related group member record.
     */
    public static GroupMember getGroupMemberByUserIdAndGroupId( Id groupId, Id userId) {
        return (GroupMember) Database.query('Select Id from GroupMember where UserOrGroupID=:userId and GroupId=:groupId');
    }
    
    /**
     * This method is used to get the group member by groupId.
     * @params : Id groupId
     * @returns : returns the related group member record.
     */
    public static List<GroupMember> getGroupMembersByGroupId(Id groupId) {
        return (List<GroupMember>) Database.query('Select Id, UserOrGroupId from GroupMember where GroupId=:groupId');
    }    
    
    /**
     * This method is used to get the group member by User Id Group Name.
     * @params : groupNameSet Set<String>
     * @returns : List<GroupMember>
     */
    public List<GroupMember> getGroupMembersByUserAndGroupNameSet(String userId, Set<String> groupNameSet) {
        return [SELECT Id, UserOrGroupId, Group.Name FROM GroupMember WHERE UserOrGroupId = :userId and Group.Name IN :groupNameSet];
    }
    /**
     * This method is used to get the group member by User Id and Group Developer Name.
     * @params : groupDeveloperName String
     * @returns : List<GroupMember>
     */
    public List<GroupMember> getGroupMemberByUserAndGroupDeveloperName(String userId, String groupDeveloperName) {
        return  [SELECT Id, UserOrGroupId, Group.Name, GroupId FROM GroupMember WHERE UserOrGroupId = :userId AND Group.DeveloperName = :groupDeveloperName];
    }
}