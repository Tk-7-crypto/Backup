@isTest
public class TST_CNT_CSM_CommunityTopics {
    @testSetup
    static void dataSetup() { 
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2, Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', employeeNumber= '080808081');
        accOwner.Change_Request_Description__c = 'Change Request Descritpion';
        insert accOwner;
        List<Product2> lstProducts = new List<Product2>();
        List<Asset> lstAssets = new List<Asset>();
        List<Topic> lstTopics = new List<Topic>();
        System.runAs (accOwner) {
            Community_topic__c ct = new Community_topic__c(Name='topicName');
            insert ct;
            Community_topic__c ct2 = new Community_topic__c(Name='topicName2');
            insert ct2;

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
            product.Community_Topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            product.Available_to_the_Guest_User__c= true;
            product.Name = 'TestAsset';
            //lstProducts.add(product);
            insert product;
            Product2 productSC = UTL_TestData.createProduct();
            productSC.Name = 'TestAsset2';
            productSC.Community_Topic__c = ct2.Id;
            productSC.SpecificToCSM__c = True;
            //lstProducts.add(productSC);
            insert productSC;
            
            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
            lstAssets.add(asset);

            Asset asset2 = new Asset(Name = 'TestAsset2', AccountId = account.Id, Product2Id = productSC.id);
            lstAssets.add(asset2);
            insert lstAssets;

            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify', Pillar__c=CON_CSM.S_TECHNOLOGY_SOLUTIONS);
            insert categorization;
        }
    }

    @IsTest
    static void testGetProductCommunityTopicsWithRestriction() {
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        List<Product2> productList = [SELECT id,Name FROM Product2 LIMIT 5];
        Contact contact = new Contact(
            Firstname='Brian1',
            Lastname='Dent1',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john1@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
        ServiceNow_Group__c service = new ServiceNow_Group__c(Group_ID__c='EA-IQVIA',Name = 'EA-IQVIA',SystemType__c = 'IQVIA');
        insert service;
        CMDB__c cm = new CMDB__c(Admin_Group_Name__c ='Admin',Category__c = '1',Name__c = '1');
        insert cm;
        List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
        for(Product2 p2 : productList){
            System.debug('Product2 : '+p2.Name);
            dataList.add(new CSM_QI_Data_Portal_Queue_User_details__c(ServiceNow_Group__c = service.Id,ServiceNow_Type__c = 'Incident',CMDB__c = cm.Id,Product__c = p2.Name,ProductId__c = p2.Id, Type__c = 'Product Level Restriction', ClientContact__c = contact.Id, Account__c = acc.Id));
        }
        insert dataList;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        CSM_QI_Data_Portal_Queue_User_details__Share dTSh = new CSM_QI_Data_Portal_Queue_User_details__Share();
        dTSh.ParentId = dataList[0].Id;
        dTSh.UserOrGroupId = user.Id;
        dTSh.AccessLevel = 'Read';
        dTSh.RowCause='manual';
        Database.insert(dTSh,false);
        Test.startTest();
        system.runAs(user){
            communityTopics = CNT_CSM_CommunityTopics.getProductCommunityTopics();
        }
        Test.stopTest();
        Integer expected = 1;
        Integer actual = communityTopics.size();
        System.assertEquals(expected, actual);

    }
    
    @IsTest
    static void testGetProductCommunityTopics() {
        List<AggregateResult> communityTopics = new List<AggregateResult>();
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        List<Product2> productList = [SELECT id FROM Product2 LIMIT 5];
        Contact contact = new Contact(
            Firstname='Brian2',
            Lastname='Dent2',
            Phone='(619)852-4569',
            Department='Mission Control',
            Title='Mission Specialist - Neptune',
            Email='john22@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'john@acme.com',IsActive =true, ContactId = contact.Id, ProfileId = profilId,Username =' john@acme.com', LastName= 'testLastName', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;
        Test.startTest();
        system.runAs(user){
            communityTopics = CNT_CSM_CommunityTopics.getProductCommunityTopics();
        }
        Test.stopTest();
        Integer expected = 2;
        Integer actual = communityTopics.size();
        System.assertEquals(expected, actual);

    }

    @IsTest
    static void testClassesForNoCustomerSuccess() {
        Test.startTest();
        CNT_CSM_CommunityTopics.getProductCommunityTopics();
        Test.stopTest();
    }
}