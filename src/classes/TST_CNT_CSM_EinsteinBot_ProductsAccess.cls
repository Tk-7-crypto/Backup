@isTest
private class TST_CNT_CSM_EinsteinBot_ProductsAccess {

    @isTest
    static void testGetProductListOfLoggedInUser(){
        Id mdmValidRecordId = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accountRecord = new Account();
        accountRecord.RecordTypeId = mdmValidRecordId;
        accountRecord.Name = 'Techno Portal';
        accountRecord.RDCategorization__c = 'Site';
        accountRecord.CustomerSegment__c = 'GOVERNMENT';
        accountRecord.Sub_Industry__c = 'STATE';
        insert accountRecord;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = accountRecord.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = accountRecord.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        Contact contactRecord = new Contact();
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.FirstName = 'Saurabh';
        contactRecord.LastName = 'Sharma';
        contactRecord.Salutation = 'Eng';
        contactRecord.Email = 'noreply@dummy.com';
        contactRecord.PreferredLanguage__c = 'en_US';
        contactRecord.Portal_Case_Type__c = 'Technology Solutions';
        contactRecord.Contact_User_Type__c = 'HO User';
        insert contactRecord;
        
        Community_Topic__c communityOne = new Community_Topic__c(Name = 'Nexxus MI');
        insert communityOne;
        Product2 productOne = UTL_TestData.createProduct();
        productOne.Name = 'Nexxus MI';
        productOne.SpecificToCSM__c = True;
        productOne.Community_Topic__c = communityOne.Id;
        insert productOne;
        Asset assetOne = new Asset(Name = 'Nexxus MI', AccountId = accountRecord.Id, Product2Id = productOne.id, 
                                   Status ='Installed', Topic_Visible_in_CSH_Homepage__c = true);
        insert assetOne;
        
        Community_Topic__c communityTwo = new Community_Topic__c(name = 'Nexxus OM');
        insert communityTwo;
        Product2 productTwo = UTL_TestData.createProduct();
        productTwo.Name = 'Nexxus OM';
        productTwo.SpecificToCSM__c = True;
        productTwo.Community_Topic__c = communityTwo.Id;
        insert productTwo;
        Asset assetTwo = new Asset(Name = 'Nexxus OM', AccountId = accountRecord.Id, Product2Id = productTwo.id, 
                                   Status ='Installed', Topic_Visible_in_CSH_Homepage__c = true);
        insert assetTwo;
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name='CSM Customer Community Plus Login User' LIMIT 1];
        User communityUser = new User(LastName = 'TestCommUser', Alias = 'testCU', Email = 'testCommUser@iqvia.com', 
                                  Username = 'testCommunityUser@iqvia.com', CommunityNickname = 'testUser1', 
                                  ProfileId = communityProfile.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', EmployeeNumber = '0909090993',
                                  Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', 
                                  ContactId = contactRecord.Id);
        insert communityUser;
        
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        
        LiveChatTranscript transChatRecord = new LiveChatTranscript(LiveChatVisitorId = chatVisitor.Id, ContactId = contactRecord.Id,
                                                                    Email__c = 'testuser@dummytest.com', FirstName__c = 'Saurabh', 
                                                                    LastName__c = 'Sharma', Body = 'Test chat content');
        insert transChatRecord;
        
        CSM_EinsteinBot_Products__c customProductOne = new CSM_EinsteinBot_Products__c();
        customProductOne.Name = 'Nexxus MI';
        customProductOne.ProductId__c = ProductOne.Id;
        customProductOne.ProductName__c = ProductOne.Name;
        insert customProductOne;
        
        Test.startTest();
        CNT_CSM_EinsteinBot_ProductsAccess.ChatScriptInput chatRecord = new CNT_CSM_EinsteinBot_ProductsAccess.ChatScriptInput();
        chatRecord.routableId = transChatRecord.Id;
        List<CNT_CSM_EinsteinBot_ProductsAccess.ChatScriptInput> chatList = new List<CNT_CSM_EinsteinBot_ProductsAccess.ChatScriptInput>();
        chatList.add(chatRecord);
        CNT_CSM_EinsteinBot_ProductsAccess.getProductListOfLoggedInUser(chatList);
        CNT_CSM_EinsteinBot_ProductsAccess.getContactProducts(contactRecord.Id);
        Test.stopTest();
    }
}