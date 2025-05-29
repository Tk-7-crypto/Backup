@isTest
public class TST_SLT_Announcements {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserPermissionsKnowledgeUser = true, employeeNumber= '080808085');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner; 
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
            insert account;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            Asset asset = New asset (Name='AssetTest', AccountId=account.Id, Product2Id = product.id);
            insert asset;
            CSM_QI_Announcement__c announcement = New CSM_QI_Announcement__c(Subject__c='test', Description__c='test',Expiry_Date__c= Date.newInstance(2030, 2, 17) , Partner_Type__c= 'Integrator Partner', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert announcement;
        }
    }
    
    @IsTest
    static void testSelectAnnouncements1() {
        List<CSM_QI_Announcement__c> announcements = new  List<CSM_QI_Announcement__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprmtest@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808081');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncements1(partnerType, pillar, '');
        }    
        
    }
    
    @IsTest
    static void testSelectAnnouncements2() {
        List<CSM_QI_Announcement__c> announcements = new  List<CSM_QI_Announcement__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        String accId = acc.Id;
        
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncements2(partnerType, pillar, '', accId);
        }
        
    }
    
    @IsTest
    static void testSelectAnnouncements3() {
        List<CSM_QI_Announcement__c> announcements = new  List<CSM_QI_Announcement__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808083');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        String accId = acc.Id;
        Product2 prod = [SELECT Id FROM Product2 WHERE Community_Topics__c = 'OneKey'];
        String productId = '\''+ prod.Id +'\'';
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncements3(partnerType, pillar, '',  productId);
        }    
        
    }
    
    @IsTest
    static void testSelectAnnouncements4() {
        List<CSM_QI_Announcement__c> announcements = new  List<CSM_QI_Announcement__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808084');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        String accId = acc.Id;
        Product2 prod = [SELECT Id FROM Product2 WHERE Community_Topics__c = 'OneKey'];
        String productId = '\''+ prod.Id +'\'';
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncements4(partnerType, pillar, '', productId, accId);
        }    
        
    }
    
    @IsTest
    static void testSelectAnnouncementById() {
        List<CSM_QI_Announcement__c> announcements = new  List<CSM_QI_Announcement__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        String accId = acc.Id;
        
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncementById(announcement[0].Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectAnnouncementByProduct() {
        List<CSM_QI_Announcement_Product_Relationship__c> announcements = new  List<CSM_QI_Announcement_Product_Relationship__c>();
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
            Partner_Type__c='Integrator Partner',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johnprm1@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808082');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        String accId = acc.Id;
        
        
        Test.startTest();
        System.runAs(user){
            announcements = new SLT_Announcements().selectAnnouncementByProduct(announcement[0].Id);
        }
        Test.stopTest();
    }
}
