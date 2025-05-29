@isTest
private class TST_SCH_CSM_CSHUserLoginCheck {
    
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su1',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='07070707', Email = 'john112@iqvia.com',IsActive =true,Username ='john112@iqvia.com', LastName= 'testLast11Name', CommunityNickname ='testSu1Nickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', UserPermissionsKnowledgeUser = true);
        insert accOwner;
        System.runAs (accOwner) {
            Account account = UTL_TestData.createAccount();
            account.ownerId=accOwner.Id;
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
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            
            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
            insert asset;
            
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify',CSHSubType__c='Please Specify',CSH_Visible__c = true);
            categorization.Pillar__c = 'Technology Solutions';
            insert categorization;
            
                      
            CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
            custsettObj2.Name = 'Org Wide No-Reply';
            custsettObj2.Setting_Type__c = 'Org Wide';
            custsettObj2.Other_Details__c = 'Customer Portal';
            custsettObj2.Origin__c = 'Customer Portal';
            
            CSM_Case_Details_Global_Setting__c custsettObj = new CSM_Case_Details_Global_Setting__c();
            custsettObj.Name = 'CAS_ET_CSM_AttachmentUpload';
            custsettObj.Setting_Type__c = 'Email Template';
            custsettObj.Other_Details__c = 'CAS_ET_CSM_AttachmentUploadNotification';
            custsettObj.Origin__c = 'Customer Portal';
            custsettObj.Component_Id__c = '0D26A000000L1W5';
            custsettObj.Country__c = CON_CSM.S_DEFAULT;
            insert new List<CSM_Case_Details_Global_Setting__c>{custsettObj2, custsettObj};
                }
    }
    
    @IsTest
    static void testCreateCSHUser() {
        List<Asset> assets = new List<Asset>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact(Firstname='Brian1',Lastname='Dent1',Phone='(619)852-4569',Department='Mission Control',Title='Mission Specialist - Neptune',Email='john12@acme.com',Portal_Case_Type__c = 'Technology Solutions',Contact_User_Type__c='HO User',AccountId = acc.Id);
        insert contact;
        Date d = System.today();
        d = d.addDays(18);
        Contact contact1 = new Contact(Firstname='Brian2',Lastname='Dent2',Phone='(619)852-4569',Department='Mission Control',Title='Mission Specialist - Neptune',Email='john123@acme.com',Portal_Case_Type__c = 'Technology Solutions',Contact_User_Type__c='HO User',AccountId = acc.Id,CSHAccessControl1stNotification__c = d);
        insert contact1;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        List<User> usList = new List<User>();
        User user = New User(Alias = 'com1', Email = 'john12@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john12@acme.com', LastName= 'testLast12Name', CommunityNickname ='testCommunity1Nickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        usList.add(user);
        User user2 = New User(Alias = 'com2', Email = 'john123@acme.com',IsActive =true, ContactId = contact1.Id, ProfileId = profilId,Username =' john123@acme.com', LastName= 'testLast123Name', CommunityNickname ='testCommunity2Nickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        usList.add(user2);
        insert usList;
        
        Test.startTest();
        String CRON_EXP = '0 0 2 * * ?'; 
        SCH_CSM_CSHUserLoginCheck.scheduleJob('CSHUserLoginCheck',CRON_EXP);
        Test.stopTest();
        
        
    }
}