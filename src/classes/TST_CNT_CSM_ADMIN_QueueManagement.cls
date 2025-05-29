@isTest
private class TST_CNT_CSM_ADMIN_QueueManagement {

    public static testmethod void testQueueUserManagement(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        List<User> userList = new List<User>();
        List<GroupMember> groupList = new List<GroupMember>(); 
        String profilId1 = [select id from Profile where Name='System Administrator'].Id;
        String profilId2 = [select id from Profile where Name='Service User'].Id;
        User accOwner = New User(Alias = 'su00',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john00@iqvia.com',IsActive =true ,Username ='john00@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        userList.add(accOwner);
        User user1 = New User(Alias = 'su100',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john100@iqvia.com',IsActive =true ,Username ='john100@iqvia.com', LastName= 'testLastName1', CommunityNickname ='testSuNickname1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        userList.add(user1);
        User user2 = New User(Alias = 'su200',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john200@iqvia.com',IsActive =true ,Username ='john200@iqvia.com', LastName= 'testLastName2', CommunityNickname ='testSuNickname2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        userList.add(user2);
        User user3 = New User(Alias = 'su300',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john300@iqvia.com',IsActive =true ,Username ='john300@iqvia.com', LastName= 'testLastName3', CommunityNickname ='testSuNickname3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        userList.add(user3);
        insert userList;
        system.runAs(accOwner) {
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser1 = new GroupMember (UserOrGroupId = user1.Id,GroupId = g1.Id);
            insert grpUser1;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = user2.Id,GroupId = g1.Id);
            insert grpUser2;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = g1.Name,
                User__c = grpUser1.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = g1.Id);
            
            insert qur;
            
            Queue_User_Relationship__c qur1 = new Queue_User_Relationship__c(
                Name = g1.Name,
                User__c = grpUser2.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = g1.Id);
            
            insert qur1;
            CNT_CSM_ADMIN_QueueManagement.fetchLookUpValues('A');
            CNT_CSM_ADMIN_QueueManagement.getLocalAdmin();
            CNT_CSM_ADMIN_QueueManagement.getSearchUsers(g1.Id, 'A');
            CNT_CSM_ADMIN_QueueManagement.getSelectedQueueUsers(g1.Id);
            CNT_CSM_ADMIN_QueueManagement.getAddedDeletedList(g1.Id);
            CNT_CSM_ADMIN_QueueManagement.saveSelectedUsersinGroupMember(g1.Id, new List<String>{user1.Id,user2.Id}, new List<String>{user2.Id,user3.Id});
        }
        
        
    }
}