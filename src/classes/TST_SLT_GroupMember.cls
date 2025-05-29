/*
* Version       : 1.0
* Description   : This test class is used for Select GroupMember
*/
@isTest
private class TST_SLT_GroupMember {
    
    @testSetup
    static void dataSetup() {
        Group grp = new Group(name='test@1', developername = 'test1');
        insert grp;
        GroupMember grpMember = new GroupMember(GroupId = grp.Id, UserOrGroupId =UserInfo.getUserId());
        insert grpMember;
    }
    
    @isTest
    static void testGetGroupMemberByGroupId() {
        List<Group> grpList = [SELECT id, Name FROM Group WHERE name = 'test@1'];
        Test.startTest();
        List<GroupMember> grpMemberList = new SLT_GroupMember().getGroupMemberByGroupId(new Set<Id> { grpList[0].Id });
        Test.stopTest();
        System.assertEquals(grpList[0].Id, grpMemberList[0].GroupId); 
    }
	
    @isTest
    static void testGetGroupMembersByUserAndGroupId() {
        List<Group> grpList = [SELECT id, Name FROM Group WHERE name = 'test@1'];
        Test.startTest();
        List<GroupMember> grpMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupId(UserInfo.getUserId(), new Set<Id> { grpList[0].Id });
        GroupMember grpMember = SLT_GroupMember.getGroupMemberByUserIdAndGroupId(grpList[0].Id ,UserInfo.getUserId());
        List<GroupMember> newGrpMemberList = SLT_GroupMember.getGroupMembersByGroupId(grpList[0].Id);
        Test.stopTest();
        System.assertEquals(grpList[0].Id, grpMemberList[0].GroupId); 
    }
    
    @isTest
    static void testGetGroupMembersByUserAndGroupNameSet() {
        List<Group> grpList = [SELECT id, Name FROM Group WHERE name = 'test@1' LIMIT 1];
        Test.startTest();
        List<GroupMember> grpMemberList = new SLT_GroupMember().getGroupMembersByUserAndGroupNameSet(UserInfo.getUserId(), new Set<String> { grpList[0].Name });
        Test.stopTest();
        System.assertEquals(grpList[0].Id, grpMemberList[0].GroupId); 
    }
    
    @isTest
    static void testGetGroupMemberByUserAndGroupDeveloperName() {
        List<Group> groupList = [SELECT id, Name, developername FROM Group WHERE developername = 'test1' LIMIT 1];
        Test.startTest();
        List<GroupMember> groupMemberList = new SLT_GroupMember().getGroupMemberByUserAndGroupDeveloperName(UserInfo.getUserId(), groupList[0].developername);
        Test.stopTest();
        System.assertEquals(groupList[0].Id, groupMemberList[0].GroupId); 
    }
}