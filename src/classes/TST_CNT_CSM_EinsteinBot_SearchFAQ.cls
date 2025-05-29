@isTest
private class TST_CNT_CSM_EinsteinBot_SearchFAQ {

    @testSetup
    static void dataSetup(){
        Account acct = new Account(Name = 'TesttestliveAcc',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        /* Added End */
        Contact Con = new Contact(Firstname='Mallikarjuna', Lastname='ReddyliveChat',Phone='(619)852-4569', Department='Mission Control', Title='Mission Specialist - Neptune', Email='testlive@test.com',
                               AccountId = acct.Id,  PreferredLanguage__c = 'en_US', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');
        insert Con;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = 'Group1',
                User__c = usr.Id,
                Type__c = 'User', Tier__c ='Tier 1',
                Group_Id__c = usr.Id);
            
            insert qur;
            
            
            
            Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(
                Name = 'Group1',
                User__c = usr.Id,
                Type__c = 'Queue', Tier__c ='Tier 1',
                Group_Id__c = usr.Id);
            
            insert qurPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qurPortal.Id;
            dT.Account__c = acct.Id;
            dT.All_Current_Users__c = true;
            dT.AccountCountry__c = acct.AccountCountry__c;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 1;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
            dd.Queue_User_Relationship__c = qurPortal.Id;
            dd.Account__c = acct.Id;
            dd.All_Current_Users__c = true;
            dd.AccountCountry__c = acct.AccountCountry__c;
            dd.CaseRecordType__c = 'DATACase';
            dd.Type__c ='Queue Assignment';
            dd.Order__c = 1;
            insert dd;           
            CSM_QI_Data_Portal_Queue_User_details__c dataPortal = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataPortal.Case_Subtype_3__c = 'LOOK-UP, PRESCRIBER (1-20 COUNT)';
            dataPortal.Queue_User_Relationship__c =qurPortal.Id;
            dataPortal.CaseRecordType__c = 'DATACase';
            dataPortal.Type__c ='Queue Assignment';
            dataPortal.Order__c = 100;
            insert dataPortal;
            
            CSM_QI_Data_Portal_Queue_User_details__c dataTechno = new CSM_QI_Data_Portal_Queue_User_details__c();
            dataTechno.Queue_User_Relationship__c = qurPortal.Id;
            dataTechno.Account__c = acct.Id;
            dataTechno.All_Current_Users__c = true;
            dataTechno.AccountCountry__c = acct.AccountCountry__c;
            dataTechno.CaseRecordType__c = 'TechnologyCase';
            dataTechno.Type__c ='Queue Assignment';
            dataTechno.Order__c = 3;
            insert dataTechno;
        Community_Topic__c ct = new Community_Topic__c(Name = 'Nexxus MI');
        insert ct;
        Product2 pro2 = new Product2();
        pro2.Name = 'Nexxus MI';
        pro2.Community_Topic__c = ct.Id;
        insert pro2;
        Asset a = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = pro2.id, Status ='Installed',Topic_Visible_in_CSH_Homepage__c = true);
        insert a;
        CSM_EinsteinBot_Products__c ebp = new CSM_EinsteinBot_Products__c();
        ebp.Name = 'Nexxus MI';
        ebp.ProductId__c = pro2.Id;
        ebp.ProductName__c = 'Nexxus MI';
        insert ebp;
        Id KnowledgeInfoRecordId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Information').getRecordTypeId();
        Knowledge__kav knowledgeRecord = new Knowledge__kav();
        knowledgeRecord.RecordTypeId = KnowledgeInfoRecordId;
        knowledgeRecord.Title = 'Import data for Nexxus MI';
        knowledgeRecord.Content__c = 'Test Data...';
        knowledgeRecord.Pillar__c = 'Technology Solutions';
        knowledgeRecord.Partner_Type__c = 'Tech Partner';
        knowledgeRecord.ValidationStatus = 'Validated';
        knowledgeRecord.UrlName = 'Import-data-for-Nexxus-MI';
        knowledgeRecord.IsVisibleInCsp = true;
        insert knowledgeRecord;
        
        Knowledge__kav articleRecord = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledgeRecord.Id];
        String articleId = articleRecord.KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(articleId, true);
    }
    
    @isTest
    static void testSearchFAQ(){
        Test.startTest();
        Id conObjId = [SELECT Id, Name FROM Contact WHERE Name = 'Mallikarjuna ReddyliveChat' LIMIT 1].Id;
        String profilId = [select id from Profile where Name='CSM Customer Community Plus Login User'].Id;
        User user = New User(Alias = 'com', Email = 'testlive@test.com', IsActive =true , ContactId = conObjId, ProfileId = profilId,Username =' testlive@test.com', LastName= 'ReddyliveChat', CommunityNickname ='testCommunityNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', LastLoginValue__c = System.now());
        insert user;
        //create a Live Chat Visitor
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        //update visitor;
        //create a Live Chat Transcript
        LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id, Email__c = 'testlive@test.com',FirstName__c = 'Mallikarjuna',LastName__c = 'Reddy',Body = 'Some chat.  Blah Blah');
        insert trans;
        CNT_CSM_EinsteinBot_SearchFAQ.SearchInput searchInputRecord = new CNT_CSM_EinsteinBot_SearchFAQ.SearchInput();
        searchInputRecord.searchKeyword = 'Import data';
        searchInputRecord.routableId = trans.Id;
        List<CNT_CSM_EinsteinBot_SearchFAQ.SearchInput> searchList = new List<CNT_CSM_EinsteinBot_SearchFAQ.SearchInput>();
        searchList.add(searchInputRecord);
        CNT_CSM_EinsteinBot_SearchFAQ.searchFAQ(searchList);
        Knowledge__kav articleRecord = [SELECT Id, KnowledgeArticleId,UrlName,Title FROM Knowledge__kav LIMIT 1];
        CNT_CSM_EinsteinBot_SearchFAQ.summarizeArticleForChatbot(CNT_CSM_EinsteinBot_SearchFAQ.getCommunityBaseUrl(), articleRecord, 'Nexxus', 'Nexxus');
        Test.stopTest();
    }
}