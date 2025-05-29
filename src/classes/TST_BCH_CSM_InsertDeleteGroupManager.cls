@isTest
private class TST_BCH_CSM_InsertDeleteGroupManager {

    static testmethod void insertBatch(){
        Test.startTest();
        SCH_CSM_InsertDeleteGroupManager sch = new SCH_CSM_InsertDeleteGroupManager();
        SchedulableContext ctx = null;
        sch.execute(ctx);
        Test.stopTest();  
    }
    static testmethod void insertDeleteBatch(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        List<User> userList = new List<User>();
        List<GroupMember> groupList = new List<GroupMember>(); 
        String profilId1 = [select id from Profile where Name='System Administrator'].Id;
        String profilId2 = [select id from Profile where Name='Service User'].Id;
        User accOwner = New User(Alias = 'su100',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john100@iqvia.com',IsActive =true ,Username ='john100@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090913');
        userList.add(accOwner);
        User user1 = New User(Alias = 'su120',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john120@iqvia.com',IsActive =true ,Username ='john120@iqvia.com', LastName= 'testLastName1', CommunityNickname ='testSuNickname1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090914');
        userList.add(user1);
        User user2 = New User(Alias = 'su230',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john230@iqvia.com',IsActive =true ,Username ='john230@iqvia.com', LastName= 'testLastName2', CommunityNickname ='testSuNickname2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090915');
        userList.add(user2);
        User user3 = New User(Alias = 'su340',UserRoleId= portalRole.Id, ProfileId = profilId1, Email = 'john340@iqvia.com',IsActive =true ,Username ='john340@iqvia.com', LastName= 'testLastName3', CommunityNickname ='testSuNickname3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', EmployeeNumber = '0909090916');
        userList.add(user3);
        insert userList;
        
        System.runAs (accOwner) {
            List<CSM_Admin_Management__c> adminMgmt = new List<CSM_Admin_Management__c>();    
            Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
        
            GroupMember grpUser1 = new GroupMember (UserOrGroupId = user1.Id,GroupId = g1.Id);
            insert grpUser1;
            /** GroupMember grpUser2 = new GroupMember (UserOrGroupId = user2.Id,GroupId = g1.Id);
            groupList.add(grpUser2);
            GroupMember grpUser3 = new GroupMember (UserOrGroupId = user3.Id,GroupId = g1.Id);
            groupList.add(grpUser3);
            insert groupList;*/
            CSM_Admin_Management__c am1 = new CSM_Admin_Management__c();
            am1.Action__c = 'Delete';
            am1.Status__c = 'New';
            am1.DeleteGroupMemberId__c = grpUser1.Id;
            am1.User__c = user1.Id;
            am1.Queue_Id__c = g1.Id;
            adminMgmt.add(am1);
            
            CSM_Admin_Management__c am2 = new CSM_Admin_Management__c();
            am2.Action__c = 'Add';
            am2.Status__c = 'New';
            am2.User__c = user2.Id;
            am2.Queue_Id__c = g1.Id;
            adminMgmt.add(am2);
            
            CSM_Admin_Management__c am3 = new CSM_Admin_Management__c();
            am3.Action__c = 'Add';
            am3.Status__c = 'New';
            am3.User__c = user3.Id;
            am3.Queue_Id__c = g1.Id;
            adminMgmt.add(am3);
            
            insert adminMgmt;
        }
        
        Test.startTest();
        BCH_CSM_InsertDeleteGroupManager uca = new BCH_CSM_InsertDeleteGroupManager();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();        
    }
}