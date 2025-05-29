@isTest
private class TST_DAOH_CSM_ContentDocument {
    @testSetup
    static void setup(){
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
    }
    
    @isTest
    static void test(){
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
        Activity__c activity = new Activity__c(ActivityOwner__c = UserInfo.getUserId(), Site__c = acc.Id, Case__c = caseRecord.Id,
                                          Status__c = 'Open', LOS__c = 'Account Management', Type__c = 'Appointment', EscalationType__c = 'Call',
                                          Appointment_Date_And_Time__c = System.now() + 2);
        insert activity;
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Test Content'];
        ContentDocumentLink contentDocLink=new ContentDocumentLink();
        contentDocLink.LinkedEntityId = activity.Id; 
        contentDocLink.ContentDocumentId = contDocs[0].Id; 
        insert contentDocLink;  
        Test.startTest();
            DAOH_CSM_ContentDocument.updateCountForAttachmentOnRDCaseActivities(contDocs);
        Test.stopTest();
        
    }
}