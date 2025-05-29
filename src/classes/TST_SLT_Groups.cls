/*
* Version       : 1.0
* Description   : This test class is used for Select Groups
*/
@ISTest
private class TST_SLT_Groups {
    
    @testSetup
    static void dataSetup() {
        Group grp = new Group(name='test@1', developername = 'test1', Type = 'Regular');
        insert grp;
        
        list<Territory2Model> terModel = [Select Id From Territory2Model Where Name = 'Total Business Units'];
        Id terModelId = terModel[0].Id;
        
        list<Territory2Type> terType   = [SELECT id, DeveloperName from Territory2Type limit 1];
        Id terTypeId = terType[0].id;
        
        list<Territory2> insertTerList = new list<Territory2>();
        
        Territory2 ter1 = new Territory2(name ='test@1', DeveloperName ='test545', Territory2TypeId = terTypeId, 
		Territory2ModelId = terModelId, Legacy_Id__c ='A1', Included_in_Custom_Sharing__c = true);
        insert ter1;      
    }
    
    @isTest
    static void testGetGroupByDevelopername(){        
        LIst<Group> grpList = [SELECT id, Name FROM Group WHERE name = 'test@1'];
        Test.startTest();        
        Set<String> grpFieldSet = new Set<String>{'Id', 'Developername'};
        String variable1 =' Developername like \'test%\' ';
        List<Group> checkGroupList = new SLT_Groups().getGroupByDevelopername(grpFieldSet, variable1);        
        Test.stopTest();
    }
    
    @isTest
    static void testGetGroupByDevelopernameSet(){        
        LIst<Group> grpList = [SELECT id, Name, Developername FROM Group WHERE name = 'test@1'];
        Test.startTest();        
        Set<String> grpFieldSet2 = new Set<String>{'Id', 'developername', 'type'};
        List<Group> checkGroupList = new SLT_Groups().getGroupByDevelopernameSet(grpFieldSet2, new Set<String> { grpList[0].Developername });        
        Test.stopTest();
        //System.assertEquals(grpList[0].developername, checkGroupList[0].developername);
    }
    
    @isTest
    static void testGetGroupByTypeAndRelatedId(){        
        LIst<Group> grpList = [SELECT id, Name, Developername FROM Group WHERE Type = 'Territory'];
        LIst<Territory2> terList = [SELECT id, Name FROM Territory2 WHERE name = 'test@1'];
        Test.startTest();        
        Set<String> grpFieldSet = new Set<String>{'Id', 'Name', 'Developername'};
        List<Group> checkGroupList = new SLT_Groups().getGroupByTypeAndRelatedId(grpFieldSet, 'Territory', new Set<Id> { terList[0].Id });        
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetGroupsWithGroupMembersByGroupName() {
        Group grp = new Group();
		grp.name = 'Test Group1';
		grp.Type = 'Regular'; 
		Insert grp; 
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
        
        Test.startTest();
            List<Group> groups = new SLT_Groups().getGroupsWithGroupMembersByGroupName(new Set<String>{'Test Group1'});
            List<GroupMember> grpMembers = new SLT_Groups().getGroupMembersByGroupName(new Set<String>{'Test Group1'});
        Test.stopTest();
        
        System.assertEquals(2, groups.size() + grpMembers.size());
    }
    
    @isTest
    static void testGetGroupByNameSet() {
        Group gp = [SELECT Id,Name FROM Group WHERE Name = 'test@1' LIMIT 1];
        Set<String> groupNameSet = new Set<String>{gp.Name};
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        Test.startTest();
            List<Group> groups = new SLT_Groups().getGroupByNameSet(fieldSet,groupNameSet);
        Test.stopTest();
    }
    
    @isTest
    static void testSelectById(){
        List<Group> grpList = [SELECT Id FROM Group];
        Set<Id> groupIds = new Set<Id>();
        for(Group grp : grpList){
            groupIds.add(grp.Id);
        }
        Test.startTest();
        new SLT_Groups().selectById(groupIds);
        Test.stopTest();
    }

    @isTest
    static void testGetGroupWithGroupName(){
        Set<String> nameSet = new Set<String>{CON_CLM.AMA_CONTRACT_QUEUE};
        
        Test.startTest();
            List<Group> checkGroupList = new SLT_Groups().getGroupWithGroupName(nameSet,'Queue');
        Test.stopTest();

        system.assertNotEquals(null, checkGroupList, 'the list is null when not expected');
        
    }
}