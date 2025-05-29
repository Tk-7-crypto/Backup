@isTest
private class TST_CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN {
    
    static testmethod void getAccountCountryList(){
        List<EXT_CSM_CheckboxDetails> checkDtls = new List<EXT_CSM_CheckboxDetails>();
        UserRole portalRole = [Select Id,DeveloperName,PortalType  From UserRole Where DeveloperName = 'IQVIA_Global' and PortalType='None'];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='075070707', Email = 'john2@iqvia.com',IsActive =true ,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert accOwner;
        System.runAs (accOwner) {
        Account acc = new Account(
            Name = 'TestAccount',
            AccountCountry__c = 'IN', 
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        //acct.IsCustomerPortal = true;
        insert acc;
        Group g1 = new Group(Name='Tech - Queue T1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            Product2 product = UTL_TestData.createProduct();
            product.Community_Topics__c='OneKey';
            product.SpecificToCSM__c = True;
            insert product;
            
                    
            Asset asset = new Asset(Name = 'TestAsset', AccountId = acc.Id, Product2Id = product.id);
            insert asset;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = accOwner.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
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
            checkDtls = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getAccountCountryList();
            List<Queue_User_Relationship__c> queueDtls = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getTechnoQueueList();
            List<Account> accList = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getAllCustomerPortalAccountList(acc.AccountCountry__c);
            List<AggregateResult> assetlist = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getAccountProductList(accList[0].Id);
            EXT_CSM_DataTableResponse Response = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getPortalDataList();
            CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.addtoCSMDataPortal(acc.AccountCountry__c, acc.Id, null, null, qurPortal.Id, null);
            CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.addtoCSMDataPortal(acc.AccountCountry__c, acc.Id, null, null, qurPortal.Id, null);
            Integer count = CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.getTotalNoOfRows();
            CSM_QI_Data_Portal_Queue_User_details__c portalUser = [Select Id,Name From CSM_QI_Data_Portal_Queue_User_details__c LIMIT 1];
            CNT_CSM_TECHNO_CSH_QUEUE_ASSIGN.deleteRecord(portalUser.id);
        Test.stopTest();
        }
    }
    
}