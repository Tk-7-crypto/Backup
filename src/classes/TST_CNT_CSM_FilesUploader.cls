@isTest
private class TST_CNT_CSM_FilesUploader {
@testSetup
    static void dataSetup() {
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
    static void testgetAttachmentCase() {
        Case c = [Select Id from Case Where Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.startTest();
        CNT_CSM_FilesUploader.updateContentDocumentLinkVisibility(documents[0].Id, c.Id, CON_CSM.S_ALL_USERS);
        CNT_CSM_FilesUploader.countAttachment(c.Id);
        Test.stopTest();
    }
}