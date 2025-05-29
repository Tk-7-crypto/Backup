/**
 * Class to test the methods of CNT_User class.
 */
@isTest
public class TST_CNT_lwcSearchComponent {
    
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
     * method to test retriveUsersByName() method.
     */
    @isTest
    public static void testRetriveUsersByName() {
        List<User> userList = new List<User>();
        String userName = 'last';
        userList = [Select Id,Name from User where Name Like '%last%'];
        Test.startTest();
        List<User> expectedUserList = CNT_lwcSearchComponent.retriveUsersByName(userName);
        Test.stopTest();
        System.assertEquals(expectedUserList.size(), 5);
    }

    /**
     * method to test addUserToGroup() method.
     */
    @isTest public static void testAddUserToGroup() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name ='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        Test.startTest();
        String expected = CNT_lwcSearchComponent.addUserToGroup(userList, groupList);
        Test.stopTest();
        System.assertEquals(expected, 'Insert Successfully!!.');
    }

    /**
     * method to test retriveGroupMemberByGroup() method.
     */
    @isTest public static void testRetriveGroupMemberByGroup() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        String result = CNT_lwcSearchComponent.addUserToGroup(userList, groupList); 
        List<User> expectedUserList = new List<User>();
        Test.startTest();
        expectedUserList = CNT_lwcSearchComponent.retriveGroupMemberByGroup(groupRecord);
        Test.stopTest();
        //System.assertEquals(expectedUserList.size(), userList.size());
    }

    /**
     * method to test deleteGroupMemberByGroupIdAndUserId() method.
     */
    @isTest public static void testDeleteGroupMemberByGroupIdAndUserId() {
        List<Id> userList = new List<Id>();
        List<Id> groupList = new List<Id>();
        User userRecord = [Select Id,Name from User where Name Like '%last%' limit 1];
        Group groupRecord = [Select Id,Name from Group where Name='Test Group' limit 1];
        userList.add(userRecord.Id);
        groupList.add(groupRecord.Id);
        String result = CNT_lwcSearchComponent.addUserToGroup(userList, groupList);
        Test.startTest();
        Boolean expected = CNT_lwcSearchComponent.deleteGroupMemberByGroupIdAndUserId(groupRecord.Id, userRecord.Id);
        Test.stopTest();
        System.assertEquals(expected, false);
    }
}