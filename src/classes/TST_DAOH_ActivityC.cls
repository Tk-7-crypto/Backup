@isTest
private class TST_DAOH_ActivityC {

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
        CSM_LOS_Based_Distribution__c losBasedDistribution = new CSM_LOS_Based_Distribution__c();
        losBasedDistribution.Name = 'RandD_Account_Management';
        losBasedDistribution.LOS__c = 'Account Management';
        losBasedDistribution.Distribution_List__c = 'test.mail@iqvia.com';
        insert losBasedDistribution;
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforActivity() {
        CNT_CSM_FieldHistoryTracking.saveFields('Activity__c','ActivityOrigin__c,ActivityOwner__c,AppointmentType__c,Case__c,CloseDate__c,Comments__c,Contact__c,CreatedById,CurrencyIsoCode,Description__c,Duration__c,EndDate__c,EscalationType__c,FirstName__c,Language__c,LastModifiedById,LastName__c,LOS__c,PassFail__c,RecordTypeId,ResponseSyntellectId__c,Site__c,StartDate__c,Status__c,Study__c,SystemModstamp,Team__c,TeamLocation__c,Type__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study= CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2= CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        insert product;
        Asset aset = CSM_Util.createAsset('CaseTestProduct',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        insert service2;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R_D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2; 
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        List<Case> csList=new List<Case>();
        Case cse = null,cseParent = null;
        cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
        csList.add(cse);
        cseParent = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        csList.add(cseParent);
        insert csList;
        List<Activity__c> actList = new List<Activity__c>();
        Activity__c act = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cseParent.Id,Status__c='Open' );
        actList.add(act);
        Activity__c act1 = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cseParent.Id,Status__c='Done' );
        actList.add(act1);
        Test.startTest();
        insert actList;
        act.Status__c = 'Done';
        act.Contact__c = cnt.Id;
        act.FirstName__c = 'Act First';
        update act;
        act.Site__c = null;
        act.Status__c = 'Done';
        act.FirstName__c = 'Act First One';
        act.Contact__c = cnt.Id;
        update act;
        act.Site__c = acc.Id;
        act.Status__c = 'Done';
        act.FirstName__c = '';
        act.Contact__c = cnt2.Id;
        update act;
        act.Contact__c = null;
        act.ActivityOwner__c = null;
        act.Description__c = 'Test Activity Description';
        act.Study__c = study2.Id;
        update act;
        Test.stopTest();
    }
    
    @IsTest
    private static void testSendOutlookMeetingRequest() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id, 'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Q1';
        queues.QueueName__c = 'Q1';
        queues.Type__c = 'Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Case caseRecord = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues.Id,
            Origin = 'Phone',
            Status = 'New',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = RecordTypeId
        );
        insert caseRecord;
        List<Activity__c> actList = new List<Activity__c>();
        Activity__c activity = new Activity__c(ActivityOwner__c = UserInfo.getUserId(), Site__c = acc.Id, Study__c = study.Id, Case__c = caseRecord.Id,
                                          Status__c = 'Open', LOS__c = 'Account Management', Type__c = 'Appointment', EscalationType__c = 'Call',
                                          Appointment_Date_And_Time__c = System.now() + 2);
        actList.add(activity);
        Activity__c activity1 = new Activity__c(ActivityOwner__c = UserInfo.getUserId(), Site__c = acc.Id, Study__c = study.Id, Case__c = caseRecord.Id,
                                          Status__c = 'Open', LOS__c = 'Account Management', Type__c = 'Email - Outbound', EscalationType__c = 'Quality Check');
        actList.add(activity1);
        Activity__c activity2 = new Activity__c(ActivityOwner__c = UserInfo.getUserId(), Site__c = acc.Id, Study__c = study.Id, Case__c = caseRecord.Id,
                                          Status__c = 'Open', LOS__c = 'Account Management', Type__c = 'Call - Outbound', EscalationType__c = 'Left VM');
        actList.add(activity2);
        Test.startTest();
            insert actList;
        Test.stopTest();
    }
    
    @isTest
    static void testCheckForAttachmentOnRDCaseActivities(){
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        List<Account> actlist = new List<Account>();
        Account sponsorAccount = new Account(RecordTypeId = mdmValidAccount, AccountCountry__c = 'US', Name = 'Techno Sponsor Portal', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        actlist.add(sponsorAccount);
        Account siteAccount = new Account(RecordTypeId = mdmValidAccount, AccountCountry__c = 'US', Name = 'Techno Site Portal', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        actlist.add(siteAccount);
        insert actlist;
        
        Contact contactRecord = new Contact(AccountId = sponsorAccount.Id, FirstName = 'Sponsor', LastName = 'Contact', Email = 'noreply@dummy.com', PreferredLanguage__c = 'en_US');
        insert contactRecord;
        
        Queue_User_Relationship__c queueRecord = new Queue_User_Relationship__c();
        queueRecord.Name ='Q1';
        queueRecord.QueueName__c ='Q1';
        queueRecord.Type__c ='Queue'; 
        insert queueRecord;
        Queue_User_Relationship__c queueUserRecord = new Queue_User_Relationship__c();
        queueUserRecord.Name ='Q1';
        queueUserRecord.QueueName__c ='Q1';
        queueUserRecord.Type__c ='User';
        queueUserRecord.User__c = UserInfo.getUserId();
        insert queueUserRecord;
        
        Study__c studyRecord = new Study__c(Name = 'Sponsor Study', Sponsor__c = sponsorAccount.Id);
        insert studyRecord;
        StudySiteContactRelationship__c sscRecord = new StudySiteContactRelationship__c(Study__c = studyRecord.Id, Site_Name__c = siteAccount.Id, SiteNumber__c = 'SITE01');
        insert sscRecord;
        
        Id RD_RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Case caseRecord = new Case(AccountId = sponsorAccount.Id, ContactId = contactRecord.Id, Study__c = studyRecord.Id,
                                   Site_Related_to_the_Study__c = sscRecord.Id, CurrentQueue__c = queueUserRecord.Id, Origin = 'Email', AssignCaseToCurrentUser__c = false,
                                   Status = 'New', Subject = 'Parent Case', RandD_Location__c = 'Dalian', OwnerId = UserInfo.getUserId(), RecordTypeId = RD_RecordTypeId);
        insert caseRecord;
        
        List<Activity__c> activityList = new List<Activity__c>();
        Activity__c actRecord1 = new Activity__c(Case__c = caseRecord.Id, Site__c = siteAccount.Id, Study__c = studyRecord.Id, PassFail__c = 'Pass', 
                                               LOS__c = 'Account Management', Type__c = 'Quality Check', EscalationType__c = 'Compliant');
        activityList.add(actRecord1);
        Activity__c actRecord2 = new Activity__c(Case__c = caseRecord.Id, Site__c = siteAccount.Id, Study__c = studyRecord.Id, PassFail__c = 'Pass', 
                                               LOS__c = 'Account Management', Type__c = 'Quality Check', EscalationType__c = 'Pass');
        activityList.add(actRecord2);
        insert activityList;
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = 'Penguins';
        contentVersionRecord.PathOnClient ='Penguins.jpg';
        contentVersionRecord.IsMajorVersion = True;
        contentVersionRecord.VersionData =beforeblob;
        insert contentVersionRecord;
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title= 'Penguins'];
        
        ContentDocumentLink linkRecord = new ContentDocumentLink(LinkedEntityId = actRecord1.Id, ContentDocumentId = contDocs[0].Id);
        insert linkRecord;
        
        Test.startTest();
        try{
            activityList[0].Status__c = 'Done';
            activityList[1].Status__c = 'Done';
            update activityList;
        }
        catch(Exception ex){
            Boolean flag = ex.getMessage().contains('Activity should contain an attachment') ? true : false;
            System.assertEquals(True, flag);
        }
        Test.stopTest();
    }
}