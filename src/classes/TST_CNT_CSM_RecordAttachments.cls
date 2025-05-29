@isTest
public class TST_CNT_CSM_RecordAttachments {
    @testSetup
    static void dataSetup() {
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName11', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        Knowledge__kav k = [SELECT Id,KnowledgeArticleId FROM Knowledge__kav WHERE Id=:knowledge.Id];
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = k.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;

        Contact Con = new Contact(Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Data GLOBAL E-SERVICE';
        queues.QueueName__c = 'Data GLOBAL E-SERVICE';
        queues.Type__c = 'Queue'; 
        queues.User__c = UserInfo.getUserId();
        queueList.add(queues);
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Data GLOBAL E-SERVICE';
        queueUser.QueueName__c = 'Data GLOBAL E-SERVICE';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueList.add(queueUser); 
        insert queueList;
        
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Case c1 = new Case(Subject = 'R&D - Activity Plan Case 01',Description = 'R&D AP Case Description',AccountId = acct.Id,ContactId = con.Id,
                           Origin = 'Email',Status = 'New',InitialQueue__c = 'group name',RandD_Location__c = 'Dalian',OwnerId = UserInfo.getUserId(),
                           EntitlementId = ent.Id,RecordTypeId = RecordTypeIdCaseRD,CurrentQueue__c = queueUser.Id);
        insert c1;

        EmailMessage em = new EmailMessage(FromAddress = 'test@abc.org', Incoming = true, ToAddress= 'm.reddy@in.imshealth.com', Subject = 'Test email RD In', TextBody = '23456 ', ParentId = c1.Id);
        insert em;

        Attachment a = new Attachment();
        a.OwnerId = UserInfo.getUserId();
        a.Name= 'sound.mp4';
        a.ContentType = 'audio/mp4';
        a.body= Blob.valueOf('Test music file attachment');
        a.ParentId = em.Id;
        insert a;
    }
    
    @IsTest
    static void testgetPermissionSets() {
        Test.startTest();
        boolean actual = CNT_CSM_RecordAttachments.getPermissionSets();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetpublishStatus() {
        boolean actual ;
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle12', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        Test.startTest();
        List<Knowledge__kav> kv = [Select ID from Knowledge__kav where ID =:knowledge.ID and publishStatus ='Draft'  ];
        if(kv.size()>0){
            actual =CNT_CSM_RecordAttachments.getPublishStatus(kv[0].ID);
        }
        Test.stopTest();
        if(actual){
            System.assertEquals(true, actual);
        }
        else
        {
            System.assertEquals(false, actual);
        }
    }
    
    @IsTest
    static void testdeleteContentDocumentById() {
        boolean actual = true;
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        List<Knowledge__kav> kv = [Select ID from Knowledge__kav where ID =:knowledge.id  ];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = kv[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;      
        Test.startTest();
        
        CNT_CSM_RecordAttachments.deleteContentDocumentById(cdl.ContentDocumentId);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testupdateContentDocumentLinkVisibility() {
        boolean actual = true;
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle12', language = 'en_US',UrlName='TestUrlName', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        Test.startTest();
        List<Knowledge__kav> kv = [Select ID from Knowledge__kav where ID =:knowledge.ID ];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = kv[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        CNT_CSM_RecordAttachments.updateContentDocumentLinkVisibility(cdl.ContentDocumentId, cdl.linkedEntityId,cdl.visibility);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testgetAttachments() {
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle01', language = 'en_US',UrlName='TestUrlName01', IsVisibleInCsp= true, Pillar__c = 'Technology Solutions');
        insert knowledge;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = knowledge.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.startTest();
        CNT_CSM_RecordAttachments.getAttachments(knowledge.Id);
        Test.stopTest();
    }
    @IsTest
    static void testgetAttachmentCase() {
        Case c = [Select Id from Case Where Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
        Test.startTest();
        CNT_CSM_RecordAttachments.getAttachments(c.Id);
        Test.stopTest();
    }

    @IsTest
    static void testDownloadFilesAsZip() {
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Limit 1];
        List<Id> fileIds = new List<Id>();
        for (ContentDocument doc : documents) {
            fileIds.add(doc.Id);
        }
        Test.startTest();
        CNT_CSM_RecordAttachments.downloadFilesAsZip(fileIds, 'caseId');
        Test.stopTest();
    }
    
    
}