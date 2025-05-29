/*
 * Version     : 1.0
 * Description : Service Class for Groups.
*/
public without sharing class SRV_Group {
    public class GroupNotFoundException extends Exception {}
    
    /**
     * service method to get the groups records by using custom setting.
     * @returns : returns the list of groups by using that custom setting.
     */
    public static List<Group> getGroups() {
        Credit_Control_Groups__c creditControlGroups = Credit_Control_Groups__c.getOrgDefaults();
        String groupNames = creditControlGroups.Group_Names__c;
        List<String> groupNamesList = groupNames.split(',');
        list<Group> groupsList = SLT_Groups.getGroupsByNameList(groupNamesList);
        if(groupsList.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return groupsList;
    }
    
    /**
     * service method to show buttons as per the User.
     * @returns Boolean
     */
    public static Boolean showButtonsForUser() {
        String Name = UserInfo.getName();
        Set<User> userSet = new Set<User>();
        List<Group> groupList = new List<Group>();
        Group groupRecordForUser = new Group();
        groupList = getGroups();
        for(Group groupRecord : groupList) {
            if(groupRecord.Name == CON_CRM.SUPER_CREDIT_CONTROL_ADMIN_GROUP) {
                groupRecordForUser = groupRecord; 
            }
        }
        List<User> memberList = new List<User>();
        memberList = SRV_CRM_User.getUsersAsGroupMemberByGroup(groupRecordForUser);
        userSet.addAll(memberList);
        for(User userRecord : userSet) {
            if(userRecord.Name == Name) {
                return true;
            }
        }
        return false;
    }

    /**
     * service method to show lwcSearchComponent as per the User.
     * @returns Boolean
     */
    public static Boolean showLwcSearchComponent() {
        String Name = UserInfo.getName();
        Set<User> userSet = new Set<User>();
        List<Group> groupList = new List<Group>();
        Set<Group> groupSet = new Set<Group>();
        groupList = getGroups();
        groupSet.addAll(groupList);
        List<User> memberList = new List<User>();
        for(Group groupRecord : groupSet) {
            memberList = SRV_CRM_User.getUsersAsGroupMemberByGroup(groupRecord);
            userSet.addAll(memberList);   
        }
        for(User userRecord : userSet) {
            if(userRecord.Name == Name) {
                return true;
            }
        }
        return false;
    }
    
}