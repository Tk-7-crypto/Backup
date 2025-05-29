@isTest
private class TST_SLT_PermissionSet {
    @isTest
    private static void testGetSObjectFieldListShouldReturnList(){
        Test.startTest();
            List<Schema.SObjectField> sObjectList = new SLT_PermissionSet().getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(true,sObjectList.isEmpty(), 'Returned list is empty when not expected');
    }

    @isTest
    private static void testGetSObjectTypeShouldReturnSObjectType(){
        Test.startTest();
            Schema.SObjectType permissionSetType = new SLT_PermissionSet().getSObjectType();
        Test.stopTest();

        System.assertNotEquals(null,permissionSetType, 'Type is null when not expected');
    }
}