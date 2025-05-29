/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalFile
 */
@isTest
private class TST_CNT_CSM_PortalFile {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
                
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
         
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id,EmployeeNumber='070702707', ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert accOwner;
        
        System.runAs (accOwner) {
        
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            account.Shared_Folder_Type__c='Local Account';
            insert account;
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
            insert qurPortal;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = account.Id;
            dT.All_Current_Users__c = true;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = account.Id;
            dd.All_Current_Users__c = true;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;
            Community_Topic__c ct = new Community_Topic__c(Name='OneKey-Web');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            insert product;
            
                    
            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            
            ContentFolder cf = new ContentFolder(Name='TestContentFolder');
            insert cf;
            ContentFolder cf2 = new ContentFolder(Name='TestContentFolder2', ParentContentFolderId=cf.Id );
            insert cf2; 
            
            ContentVersion cv  = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg',  VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
            insert cv;  
            
            Topic topic = New Topic(Name = 'OneKey-Web');
            insert topic;

        }
    }
    
    @IsTest
    static void testGetUserAccount() {
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
            
        Test.startTest();
        List<Account> a = new List<Account>();
        system.runAs(user){
            a = CNT_CSM_PortalFile.getUserAccount();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = a.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetFolderByFolderNameForCurrentUser(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
            
        Test.startTest();
        List<ContentFolder> contentFolders = new List<ContentFolder>();
        system.runAs(user){
            contentFolders = CNT_CSM_PortalFile.getFolderByFolderNameForCurrentUser('TestContentFolder');
        }
        Test.stopTest();
    }

     @IsTest
    static void testGetSharedFolderByUserParentAccount(){
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='john@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
            
        Test.startTest();
        List<ContentFolder> contentFolders = new List<ContentFolder>();
        system.runAs(user){
            contentFolders = CNT_CSM_PortalFile.getSharedFolderByUserParentAccount();
        }

        acc.Shared_Folder_Type__c='';
        update acc;
        system.runAs(user){
            contentFolders = CNT_CSM_PortalFile.getSharedFolderByUserParentAccount();
        }
        Test.stopTest();
    }


    @IsTest
    static void testGetMikadoFoldersByContact() {
        List<CSM_QI_Folder__c> csmfolder = new List<CSM_QI_Folder__c>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='yourusername@iqvia.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'yourusername@iqvia.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
            csmfolder = CNT_CSM_PortalFile.getMikadoFoldersByContact();
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetMikadoContentFolderMember() {
        List<ContentFolderMember> contentFolderMembers = new List<ContentFolderMember>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='yourusername@iqvia.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'yourusername@iqvia.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
            contentFolderMembers = CNT_CSM_PortalFile.getMikadoContentFolderMember();
        }
        Test.stopTest();
    }

    /**
     * This method used to get List of ContentFolder  for current user
     */    
    @IsTest
    static void testGetFolders() {
        List<ContentFolder> contentFolders = new List<ContentFolder>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='yourusername@iqvia.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'yourusername@iqvia.com',IsActive =true , ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
                contentFolders = CNT_CSM_PortalFile.getFolders();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contentFolders.size();
        /** System.assertEquals(expected, actual); */
    }
    
    /**
     * This method used to get List<ContentFolder> by TopicId
     */    
    @IsTest
    static void testGetFolderByTopicId() {
        List<ContentFolder> contentFolders = new List<ContentFolder>();
        Topic topic = [SELECT id FROM Topic WHERE Name = 'OneKey-Web'];
        Test.startTest();
        String id = topic.Id;
        contentFolders = CNT_CSM_PortalFile.getFolderByTopicId(id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contentFolders.size();
        /** System.assertEquals(expected, actual); */
    }
    
    /**
     * This method used to get List of ContentFolder by parentContentFolderId
     */    
    @IsTest
    static void testGetFoldersByParentId() {
        List<ContentFolder> contentFolders = new List<ContentFolder>();
        ContentFolder f = [SELECT id FROM ContentFolder WHERE Name = 'TestContentFolder'];
        Test.startTest();
        contentFolders = CNT_CSM_PortalFile.getFoldersByParentId(f.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contentFolders.size();
       /** System.assertEquals(expected, actual); **/
    }
     
    @IsTest
    static void testGetFolderMemberByParentId() {
        List<ContentFolderMember> contentFolderMembers = new  List<ContentFolderMember>();
        ContentFolder f = [SELECT Id FROM ContentFolder WHERE Name='TestContentFolder'];
        Test.startTest();
        contentFolderMembers = CNT_CSM_PortalFile.getFolderMemberByParentId(f.Id);
        Test.stopTest();
    }
 
     @IsTest
    static void testInsertNewFolder() {
        List<ContentFolderMember> contentFolderMembers = new  List<ContentFolderMember>();
        ContentFolder f = [SELECT Id FROM ContentFolder WHERE Name='TestContentFolder'];
        Test.startTest();
        CNT_CSM_PortalFile.insertNewFolder('new folder', f.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetContentWorkspaceByRootContentFolderId() {
        ContentWorkspace cws = new ContentWorkspace(Name='TestContentWorkspaces');
        insert cws;
        ContentWorkspace cw = [SELECT RootContentFolderId FROM ContentWorkspace WHERE Name='TestContentWorkspaces'][0];
        Test.startTest();
        CNT_CSM_PortalFile.getContentWorkspaceByRootContentFolderId(cw.RootContentFolderId);
        Test.stopTest();
    }
     
}