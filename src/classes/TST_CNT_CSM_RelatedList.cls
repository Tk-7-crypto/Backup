/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_RelatedList
 */
@isTest
private class TST_CNT_CSM_RelatedList {
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        acc.Website='http://www.iqvia.com';
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        Account account = UTL_TestData.createAccount();
        account.Website='http://www.iqvia.com';
        insert account;
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
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
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,Current_Queue__c = 'Q1');
        insert c;
        CaseComment cc = new CaseComment(ParentId = c.Id, IsPublished=true,CommentBody='TestComment');
        insert cc;
        CaseHistory ch = new CaseHistory();
        ch.CaseId = c.Id;
        ch.Field = 'Status';
        insert ch;
        EmailMessage em = new EmailMessage();
        em.status = '3';
        em.relatedToId = c.Id;
        em.fromAddress = 'sender@example.com';
        em.fromName = 'Jean Test'; // from name
        em.subject = 'This is the Subject!'; // email subject
        em.htmlBody = '<html><body><b><p>Hello abc@mailinator.com</b></body></html>';
        String[] toIds = new String[]{UserInfo.getUserId()}; 
        em.toIds = toIds;
        insert em; 
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', Pillar__c = 'Technology Solutions');
        insert knowledge;
        knowledge = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledge.Id];
        CaseArticle caseArticle = new CaseArticle(CaseId = c.Id, KnowledgeArticleId=knowledge.KnowledgeArticleId);
        insert caseArticle;
    }

    @IsTest
    static void testGetContentDocumentLinks() {
        List<Case> c = new  List<Case>();
        List<CNT_CSM_RelatedList.CSM_Attachment> attachments = new List<CNT_CSM_RelatedList.CSM_Attachment>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        attachments = CNT_CSM_RelatedList.getContentDocumentLinks(c[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = attachments.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetEmailMessages() {
        List<Case> c = new  List<Case>();
        List<EmailMessage> em = new List<EmailMessage>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        em = CNT_CSM_RelatedList.getEmailMessages(c[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = em.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testGetCaseArticles() {
        List<Case> c = new  List<Case>();
        List<CaseArticle> cal = new List<CaseArticle>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        cal = CNT_CSM_RelatedList.getCaseArticles(c[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = cal.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testDeleteContentDocumentById() {
        List<Case> c = new  List<Case>();
        List<ContentDocument> cd = new List<ContentDocument>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        cd = [SELECT id FROM ContentDocument WHERE Title = 'Penguins'];
        Test.startTest();
        CNT_CSM_RelatedList.deleteContentDocumentById(cd[0].Id, c[0].Id);
        Test.stopTest();
    }

}