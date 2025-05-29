@IsTest
private class TST_CNT_CSM_CommunityGroups {
    @testSetup
    static void setup() {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        String profilId2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User accOwner = New User(Alias = 'su', UserRoleId = portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com', IsActive = true,
                                 Username = 'john2.community@iqvia.com', LastName = 'testLastName', CommunityNickname = 'testSuNickname', 
                                 TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', EmployeeNumber = '43457');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        
        System.runAs (accOwner) {
            Community_topic__c topic = new Community_topic__c(Name = 'DDD');
            insert topic;
            
            Account account = UTL_TestData.createAccount();
            account.ownerId = accOwner.Id;
            insert account;
            
            Product2 p1 = UTL_TestData.createProduct();
            p1.Name = 'DDD';
            p1.SpecificToCSM__c = True;
            p1.Community_Topic__c = topic.Id;
            insert p1;
            
            Asset asset = new Asset(Name = 'DDD', AccountId = account.Id, Product2Id = p1.id);
            insert asset;
            
            CollaborationGroup chatterGroup = new CollaborationGroup(
                Name = 'Community Chatter Group', 
                Description = 'test chatter',
                CollaborationType = 'Public',
                CanHaveGuests = false,
                IsArchived = false,
                IsAutoArchiveDisabled = true
            );
            insert chatterGroup;
            
            Product_Group_Relationship__c productRelationship = new Product_Group_Relationship__c(Name = 'DDD-Community Chatter Group', Product__c = p1.Id, Collaboration_Group_Id__c = chatterGroup.Id,Group_Order__c=1 );
            insert productRelationship;
        }
    }
    
    @IsTest
    private static void testGetGroupDetails() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        
        Test.startTest();
            CollaborationGroup chatterGroup = CNT_CSM_CommunityGroups.getGroupDetails(groupId);
        Test.stopTest();
        
        System.assertEquals(true, chatterGroup.MemberCount > 0, 'Should get group details');
    }
    
    @IsTest
    private static void testGetGroupsRelatedToProduct() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        insert contact;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User communityUser = New User(Alias = 'com', Email = 'john@acme.com', IsActive = true, ContactId = contact.Id, 
                                      ProfileId = profilId, Username ='john.community12@acme.com', LastName = 'testLastName', 
                                      CommunityNickname = 'testCommunityNickname', TimeZoneSidKey = 'America/Los_Angeles', 
                                      LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',
                                      EmployeeNumber = '43457927');
        insert communityUser;
        
        String chatterGroupJSON;
        
        Test.startTest();
            System.runAs(communityUser) {
                chatterGroupJSON = CNT_CSM_CommunityGroups.getGroupsRelatedToProduct('DDD');
            } 
        Test.stopTest();
        System.assertEquals(true, chatterGroupJSON != null, 'Should get groups related to product');
    }
    
    @IsTest
    private static void testGetGroupsRelatedToUser() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname = 'Brian',
            Lastname = 'Dent',
            Phone = '(619)852-4569',
            Department = 'Mission Control',
            Title = 'Mission Specialist - Neptune',
            Email = 'john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c = 'HO User',
            AccountId = acc.Id);
        insert contact;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acc.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acc.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        String profilId = [SELECT Id FROM Profile WHERE Name = 'CSM Customer Community Plus Login User'].Id;
        User communityUser = New User(Alias = 'com', Email = 'john@acme.com', IsActive = true, ContactId = contact.Id, 
                                      ProfileId = profilId, Username ='john.community12@acme.com', LastName = 'testLastName', 
                                      CommunityNickname = 'testCommunityNickname', TimeZoneSidKey = 'America/Los_Angeles', 
                                      LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',
                                      EmployeeNumber = '43457927');
        insert communityUser;
        
        String chatterGroupJSON;
        
        Test.startTest();
            System.runAs(communityUser) {
                chatterGroupJSON = CNT_CSM_CommunityGroups.getGroupsRelatedToUser();
            } 
        Test.stopTest();
        System.assertEquals(true, chatterGroupJSON != null, 'Should get groups related to product');
    }
    @IsTest
    private static void testGetProductGroupList() {
        Test.startTest();
            CNT_CSM_CommunityGroups.getProductGroupList(); 
        Test.stopTest();
    }
}
