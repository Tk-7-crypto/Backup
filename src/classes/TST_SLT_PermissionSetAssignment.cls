@isTest
private class TST_SLT_PermissionSetAssignment {
    
    @isTest
    private static void testGetSObjectFieldListShouldReturnList(){
        Test.startTest();
            List<Schema.SObjectField> sObjectList = new SLT_PermissionSetAssignment().getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(true,sObjectList.isEmpty(), 'Returned list is empty when not expected');
    }

    @isTest
    private static void testGetSObjectTypeShouldReturnSObjectType(){
        Test.startTest();
            Schema.SObjectType permissionSetAssgType = new SLT_PermissionSetAssignment().getSObjectType();
        Test.stopTest();

        System.assertNotEquals(null,permissionSetAssgType, 'Type is null when not expected');
    }

    @isTest
    private static void testSelectByUserIdsShouldReturnRecords(){
        List<PermissionSet> permissionSetList = [SELECT Id, Name,Label FROM PermissionSet
                                                WHERE Label = : CON_CLM.CLM_PERMISSION_AUTHOR];
        User adminUser = UTL_TestData.createUser('System Administrator',1).get(0);
        insert adminUser;
        if(!permissionSetList.isEmpty()) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = adminUser.Id, 
                PermissionSetId = permissionSetList[0].Id);
            insert permissionSetAssignment;
        }

        Test.startTest();
            List<PermissionSetAssignment> lstPermissionSetAssg = new SLT_PermissionSetAssignment().selectByUserIds(
                new Set<String>{'Id'}, new Set<Id>{adminUser.Id});
        Test.stopTest();

        System.assertNotEquals(true,lstPermissionSetAssg.isEmpty(), 'No Permission set assignment records returned');
        
    }
    
     @isTest
    private static void testSelectByPermissionSetForUserId(){
        String permissionSetName = 'Sales_with_Bid_History';
        List<PermissionSet> permissionSetList = [SELECT Id, Name,Label FROM PermissionSet
                                                WHERE Name = : permissionSetName];
        User adminUser = UTL_TestData.createUser('System Administrator',1).get(0);
        insert adminUser;
        if(!permissionSetList.isEmpty()) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = adminUser.Id, 
                PermissionSetId = permissionSetList[0].Id);
            insert permissionSetAssignment;
        }

        Test.startTest();
            List<PermissionSetAssignment> lstPermissionSetAssg = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(
                new Set<String>{'Id'}, new Set<Id>{adminUser.Id}, permissionSetName);
        Test.stopTest();

        System.assertNotEquals(true,lstPermissionSetAssg.isEmpty(), 'No Permission set assignment records returned');
        
    }
    
    @isTest
    private static void testSelectByPermissionSetsForUserId(){
        String permissionSetName = 'Sales_with_Bid_History';
        List<PermissionSet> permissionSetList = [SELECT Id, Name,Label FROM PermissionSet
                                                WHERE Name = : permissionSetName];
        User adminUser = UTL_TestData.createUser('System Administrator',1).get(0);
        insert adminUser;
        if(!permissionSetList.isEmpty()) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = adminUser.Id, 
                PermissionSetId = permissionSetList[0].Id);
            insert permissionSetAssignment;
        }

        Test.startTest();
            List<PermissionSetAssignment> lstPermissionSetAssg = new SLT_PermissionSetAssignment().selectByPermissionSetsForUserId(
                new Set<String>{'Id'}, new Set<Id>{adminUser.Id}, new Set<String>{permissionSetName});
        Test.stopTest();

        System.assertNotEquals(true,lstPermissionSetAssg.isEmpty(), 'No Permission set assignment records returned');
        
    }
}