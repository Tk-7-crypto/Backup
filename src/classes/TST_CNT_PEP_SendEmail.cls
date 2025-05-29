@isTest
public class TST_CNT_PEP_SendEmail {
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
            Agency_Program__c agencyProgram = new Agency_Program__c(Name= 'AssetTest',Description__c='Testing partner program description');
            insert agencyProgram;
            Contract contract = New Contract(Status ='Not Started',Non_Standard_Contract__c= False,SOW_status__c= 'Signed', PRM_Contract_type__c = 'Agency Program SOW', AccountId= account.Id, ContractTerm = 12, StartDate = Date.newInstance(2030, 2, 17), OwnerExpirationNotice = '30',Agency_Program__c=agencyProgram.id);
            insert contract;
            contract.Status = 'Active';
            update contract;
            CSM_QI_Announcement__c announcement = New CSM_QI_Announcement__c(Subject__c='test', Description__c='test',Expiry_Date__c= Date.newInstance(2030, 2, 17) , Partner_Type__c= 'Integrator Partner', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS,PRM_Active_Contract_Only__c = true);
            insert announcement;
            CSM_QI_Announcement_Product_Relationship__c cpr = new CSM_QI_Announcement_Product_Relationship__c(CSM_Announcement__c = announcement.Id, Product__c = product.Id);
            insert cpr;
            CSM_QI_Announcement__c announcementCSM = New CSM_QI_Announcement__c(Subject__c='testCSM', Description__c='test',Expiry_Date__c= Date.newInstance(2030, 2, 17) , Contact_User_Type__c = 'HO User', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert announcementCSM;
            CSM_QI_Announcement_Product_Relationship__c cprCSM = new CSM_QI_Announcement_Product_Relationship__c(CSM_Announcement__c = announcementCSM.Id, Product__c = product.Id);
            insert cprCSM;
        }
    }
    
    @IsTest
    static void testSelectAnnouncement() {        
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(
            Firstname='Brian',
            Lastname='Dent',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john@acme.com',
            Portal_Case_Type__c =CON_CSM.S_TECHNOLOGY_SOLUTIONS,
            Contact_User_Type__c='HO User',
            Partner_Type__c='Integrator Partner',
            EmailOptOut__c = false,
            AccountId = acc.Id,
            PRM_User__c = 'Active');
        insert contact;
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username ='johnprmtest@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808081');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c,PRM_Active_Contract_Only__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        Boolean isActive = announcement[0].PRM_Active_Contract_Only__c;
        String partnerType = announcement[0].Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        
        Test.startTest();
            CNT_PEP_SendEmail.sendAnnouncementMail(announcement[0].Id);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetAnnouncementDetails() {
        List<CSM_QI_Announcement__c> ann = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcement = [SELECT Partner_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Partner_Type__c= 'Integrator Partner'];
        ann = CNT_PEP_SendEmail.getAnnouncementDetails(announcement[0].Id);
    }
    
    @IsTest
    static void testSelectAnnouncementforCSM() {        
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
            AccountId = acc.Id,
            PRM_User__c = 'Active');
        insert contact;
        String profilId = [SELECT id from Profile where Name='Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' johncsm@acme.com',FirstName = 'testFirstName', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080803081');
        insert user;
        List<CSM_QI_Announcement__c> announcement = [SELECT Contact_User_Type__c,Pillar__c FROM CSM_QI_Announcement__c WHERE Contact_User_Type__c= 'HO User'];
        String userType = announcement[0].Contact_User_Type__c;
        userType = '\'' + userType.replace(';','\',\'') +'\'';
        String pillar = announcement[0].Pillar__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\'';
        
        Test.startTest();
            CNT_PEP_SendEmail.sendAnnouncementMailForCSM(announcement[0].Id);
        Test.stopTest();
        
    }
    
}
