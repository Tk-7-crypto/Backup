@isTest
public class TST_CNT_CSM_CaseAttachmentController {
    
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

        EmailMessage em = new EmailMessage(FromAddress = 'us.csmsupport@iqvia.com', Incoming = true,BccAddress='Akansha.gupta@metacube.com', ToAddress= 'm.reddy@in.imshealth.com', Subject = 'Test email RD In', HtmlBody = '23456 ', ParentId = c1.Id);
        insert em;
        
        EmailMessage em2 = new EmailMessage(FromAddress = 'us.csmsupport@iqvia.com', Incoming = true, ToAddress= 'm.reddy@in.imshealth.com', Subject = 'Test email RD In',Status ='5', HtmlBody = '23456 ', ParentId = c1.Id);
        insert em2;

        Attachment a = new Attachment();
        a.OwnerId = UserInfo.getUserId();
        a.Name= 'sound.mp4';
        a.ContentType = 'audio/mp4';
        a.body= Blob.valueOf('Test music file attachment');
        a.ParentId = em.Id;
        insert a;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c1.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
    }
    
    @IsTest
    static void testgetAttachmentCase() {
        Case c = [Select Id from Case Where Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
        Test.startTest();
        CNT_CSM_CaseAttachmentController.fetchAttachmentList(c.id);
        Test.stopTest();
    }
    
    @IsTest
    static void testsaveAttachmentToDraftEmail() { 
        Case c = [Select Id from Case Where Subject = 'R&D - Activity Plan Case 01' LIMIT 1];
        ContentDocumentLink atta = [Select id from ContentDocumentLink where LinkedEntityId =:c.id];
        Test.startTest();
        CNT_CSM_CaseAttachmentController.saveAttachmentToDraftEmail(atta.id,c.id);
        CNT_CSM_CaseAttachmentController.sendDraftEmail(c.id);
        Test.stopTest();
    }

}