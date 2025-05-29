@isTest
public class TST_SLT_CollaborationGroupMember {
    
    @testSetup
    static void dataSetup() {
        CollaborationGroup cg = new CollaborationGroup(Name='test', CollaborationType='Public', ownerId = UserInfo.getUserId());
        insert cg;
    }
    
    @isTest
    static void testSelectCollaborationGroupMemberByWhereCondtion(){
        Test.startTest();
            List<CollaborationGroupMember> CollaborationGroupMemberList = 
                new SLT_CollaborationGroupMember().selectCollaborationGroupMemberByWhereCondtion
                ('CollaborationGroup.Name = \'test\'', new Set<String> {'Id','Member.Email','CollaborationGroup.Name'});
        Test.stopTest();

        System.assertEquals(1, CollaborationGroupMemberList.size(), 'Should Return Collaboration GroupMember by Collaboration Group Name');
    }

}