@IsTest
private class TST_SLT_CollaborationGroup {
    @testSetup
    static void setup() {
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Community Chatter Group', 
            Description = 'test chatter',
            CollaborationType = 'Public',
            CanHaveGuests = false,
            IsArchived = false,
            IsAutoArchiveDisabled = true
        );
        insert chatterGroup;
    }
    
    @IsTest
    private static void testGetChatterGroups() {
        String groupName = 'Community Chatter Group';
        String condition = 'Name = \''+ groupName + '\'';
        
        Test.startTest();
            List<CollaborationGroup> chatterGroups = new SLT_CollaborationGroup().getChatterGroups(new Set<String>{'Id', 'Name'}, condition);
        Test.stopTest();
        
        System.assertEquals(true, chatterGroups != null, 'Should get groups by condition');
    }
    
    @IsTest
    private static void testGetChatterGroupsById() {
        String groupName = 'Community Chatter Group';
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name =: groupName LIMIT 1].Id;
        
        Test.startTest();
        List<CollaborationGroup> chatterGroups = new SLT_CollaborationGroup().getChatterGroupsById(new Set<String>{'Id', 'Name'}, new Set<Id>{groupId});
        Test.stopTest();
        
        System.assertEquals(true, chatterGroups != null, 'Should get groups by id');
    }
}