/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_User
 */
@isTest
private class TST_SRV_CRM_User {

    @testSetup
    static void dataSetup() {
        List<User> userList = new List<User>();
        userList = UTL_TestData.createUser('System Administrator',5);
        insert userList;
        
        Group groupRecord = UTL_TestData.createGroup('Test Group','Regular');
        insert groupRecord;   
        
        Credit_Control_Groups__c creditControlGroups = new Credit_Control_Groups__c();         
        creditControlGroups.Name = 'Number_of_Users__c';        
        creditControlGroups.Number_of_Users__c = 5;        
        insert creditControlGroups;
    }
    
    /**
     * test method to get user record details
     */      
    static testmethod void testGetUserDetail() {
        Test.startTest();
            List<User> userList = SRV_CRM_User.getUserDetail(new Set<Id> {UserInfo.getUserId()});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = userList.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method to get field Details of Product Object with Exception
     */      
    static testmethod void testGetUserDetailException() {
        Test.startTest();
            try {
                List<User> userList = SRV_CRM_User.getUserDetail(null);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_User.UserServiceException', ex.getTypeName());
            }    
        Test.stopTest();
    }

    /**
     * method to test deleteMemberFromGroup() method.
     */
    @isTest public static void testDeleteMemberFromGroup() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        String result = SRV_CRM_User.addMemberToGroup(userList, groupList);
        Test.startTest();
        Boolean expected = SRV_CRM_User.deleteMemberFromGroup(groupRecord.Id, userRecord.Id);
        Test.stopTest();
        System.assertEquals(expected, false);
    }

    /**
     * method to test addMemberToGroup() method.
     */
    @isTest public static void testAddMemberToGroup() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name ='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        Test.startTest();
        String expected = SRV_CRM_User.addMemberToGroup(userList, groupList);
        Test.stopTest();
        System.assertEquals(expected, 'Insert Successfully!!.');
    }

    /**
     * method to test getUsersAsGroupMemberByGroup() method.
     */
    @isTest public static void testGetUsersAsGroupMemberByGroup() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        String result = SRV_CRM_User.addMemberToGroup(userList, groupList); 
        List<User> expectedUserList = new List<User>();
        Test.startTest();
        expectedUserList = SRV_CRM_User.getUsersAsGroupMemberByGroup(groupRecord);
        Test.stopTest();
        //System.assertEquals(expectedUserList.size(), userList.size());
    }

    /**
     * method to test getUsers() method.
     */
    @isTest
    public static void testGetUsers() {
        List<User> userList = new List<User>();
        String userName = 'last';
        userList = [Select Id,Name from User where Name Like '%last%'];
        Test.startTest();
        List<User> expectedUserList = SRV_CRM_User.getUsers(userName);
        Test.stopTest();
        System.assertEquals(expectedUserList.size(), 5);
    }
}