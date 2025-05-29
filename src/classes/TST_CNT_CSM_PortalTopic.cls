/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_PortalTopic
 */
@isTest
private class  TST_CNT_CSM_PortalTopic {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
         
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='072070707', Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert accOwner;
        List<Product2> lstProducts = new List<Product2>();
        List<Asset> lstAssets = new List<Asset>();
        List<Topic> lstTopics = new List<Topic>();
        
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
            Community_Topic__c ct = new Community_Topic__c(Name='OneKeyTwo');
            insert ct;
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topic__c = ct.Id;
            product.SpecificToCSM__c = True;
            lstProducts.add(product);

            Community_Topic__c ct2 = new Community_Topic__c(Name='Sales Collateral for OCE Sales');
            insert ct2;
            Product2 productSC = UTL_TestData.createProduct();
            productSC.Community_Topic__c = ct2.Id;
            productSC.Community_Doc_Category__c = 'Sales Collateral';
            productSC.SpecificToCSM__c = True;            
            lstProducts.add(productSC);
            
            insert lstProducts;
                                
            Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
            lstAssets.add(asset);

            Asset asset2 = new Asset(Name = 'TestAsset2', AccountId = account.Id, Product2Id = productSC.id);
            lstAssets.add(asset2);
            insert lstAssets;
           
            Topic topic = New Topic(Name = 'OneKeyTwo');
            lstTopics.add(topic);

            Topic topic2 = New Topic(Name = 'Sales Collateral for OCE Sales');
            lstTopics.add(topic2);            
            insert lstTopics;
        
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='Please Specify', SubType2__c='Please Specify');
            categorization.Pillar__c = 'Technology Solutions';
            insert categorization;
        }
    }
    
     /**
     * This method used to get List<Topic> by name
     */    
    @IsTest
    static void testGetTopicsName() {
        List<Topic> topics = new List<Topic>();
        List<String> topicsName = new List<String>();
        topicsName.add('OneKeyTwo');
        Test.startTest();
        topics = CNT_CSM_PortalTopic.getTopicsByName(topicsName);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = topics.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get List<Topic> fro current user
     */    
    @IsTest
    static void testGetTopics() {
        List<Topic> topics = new List<Topic>();  
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
        system.runAs(user){
            topics =  CNT_CSM_PortalTopic.getTopics();
        }
        Test.stopTest();
        Integer expected = 0;//
        Integer actual = topics.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get List<Topic> by category
     */    
    @IsTest
    static void testGetTopicsByCategory() {
        List<Topic> topics = new List<Topic>();  
        Account acc = [SELECT id FROM Account WHERE Name = 'TestAccount'];
        Contact contact = new Contact( 
            Firstname='Brian', 
            Lastname='PEP consultant', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Partner', 
            Email='pep@acme.com',
            Portal_Case_Type__c = 'Technology Solutions',
            Contact_User_Type__c='HO User',
            AccountId = acc.Id);
        insert contact;
         
        String profilId = [select id from Profile where Name=:CON_PEP.S_P_PEP_COMMUNITY].Id;
        User user = New User(Alias = 'com', Email = 'pep@acme.com',IsActive =true , ContactId = contact.Id, 
            ProfileId = profilId,Username ='pep@iqvia.partner.test', LastName= 'PEP consultant', 
            CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', 
            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert user;

        Test.startTest();
            system.runAs(user){
                topics =  CNT_CSM_PortalTopic.getTopicsByDocCategory('Sales Collateral');
                //in test class only, community user cannot see topics so topics list is empty here
                //but this works when testing from community
                System.assertEquals(false,topics.size()>0);
            }
        Test.stopTest();
        
    }
    
}