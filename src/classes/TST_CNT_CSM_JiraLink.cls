/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_JiraLink
 */
@isTest
private class TST_CNT_CSM_JiraLink {
    
     /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
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
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
        insert c;
        CSM_QI_JiraLink__c jiraLink = New CSM_QI_JiraLink__c(jira_key__c='TestJiraKey', case_recordId__c = c.Id);
        insert jiraLink;
        CSM_QI_JiraLinkComment__c jlc = New CSM_QI_JiraLinkComment__c(JiraLink__c=jiraLink.Id, Body__c='a Jira comment',JiraCommentId__c='1');
        insert jlc;
    }
    
    /**
     * This method used to get Case by recordId
     */    
    @IsTest
    static void testGetCase() {
        List<Case> cases = new List<Case>();  
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        cases = CNT_CSM_JiraLink.getCase(caseId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = cases.size();
        System.assertEquals(expected, actual);
    }
    
    
    /**
     * This method used to get JiraLink by caseId
     */    
    @IsTest
    static void testGetJiraLink() {
        List<CSM_QI_JiraLink__c> jiraLinks = new List<CSM_QI_JiraLink__c>();  
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        jiraLinks = CNT_CSM_JiraLink.getJiraLink(caseId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = jiraLinks.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get JiraLinkComment by jiraLink Id
     */    
    @IsTest
    static void testGetJiraLinkComments() {
        List<CSM_QI_JiraLinkComment__c> jlc = new List<CSM_QI_JiraLinkComment__c>();  
        CSM_QI_JiraLink__c jl = [SELECT id FROM CSM_QI_JiraLink__c WHERE jira_key__c='TestJiraKey'];
        String jlId = jl.Id;
        Test.startTest();
        jlc = CNT_CSM_JiraLink.getJiraLinkComments(jlId);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = jlc.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testUpsertJiraLinkComments() {
        List<CSM_QI_JiraLinkComment__c> jlc = new List<CSM_QI_JiraLinkComment__c>();  
        CSM_QI_JiraLink__c jl = [SELECT id FROM CSM_QI_JiraLink__c WHERE jira_key__c='TestJiraKey'];
        String jlId = jl.Id;
        List<CNT_CSM_JiraLink.JiraComment> jcl = new List<CNT_CSM_JiraLink.JiraComment>();
        CNT_CSM_JiraLink.JiraComment jc = new CNT_CSM_JiraLink.JiraComment();
        jc.body = 'test Jira Commment';
        jc.id = '1';
        jc.jiraLinkId = jl.Id;
        jcl.add(jc);
        Test.startTest();
        CNT_CSM_JiraLink.upsertJiraLinkComments(JSON.serialize(jcl));
        Test.stopTest();
    }

    @IsTest
    static void testSaveJiraCommentFromCSM() {
        List<CSM_QI_JiraLinkComment__c> jlc = new List<CSM_QI_JiraLinkComment__c>();  
        CSM_QI_JiraLink__c jl = [SELECT id FROM CSM_QI_JiraLink__c WHERE jira_key__c='TestJiraKey'];
        String jlId = jl.Id;
        Test.startTest();
        CNT_CSM_JiraLink.saveJiraCommentFromCSM('2', jlId);
        Test.stopTest();
    }

    @IsTest
    static void testGetJiraBaseUrls() {
        Test.startTest();
        List<String> jiraBaseUrls = CNT_CSM_JiraLink.getJiraBaseUrls();
        Test.stopTest();
    }

    @IsTest
    static void testGetCountryLabelByCode() {
        Test.startTest();
        String label = CNT_CSM_JiraLink.getCountryLabelByCode('US');
        Test.stopTest();
    }

    @IsTest
    static void testInsertCaseComments() { 
        List<FeedItem> caseComments = new List<FeedItem>(); 
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        FeedItem cc = new FeedItem();
        cc.ParentId=caseId;
        cc.Body='new comment';
        caseComments.add(cc);
        Test.startTest();
        CNT_CSM_JiraLink.insertCaseComments(caseComments);
        Test.stopTest();
    }

    @IsTest
    static void testUpdateCaseJiraIssue() { 
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        CNT_CSM_JiraLink.updateCaseJiraIssue(caseId,'NewJiraKey');
        Test.stopTest();
    }

        @IsTest
    static void testDeleteContentDocumentById() { 
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.startTest();
        CNT_CSM_JiraLink.deleteContentDocumentById(documents[0].Id);
        Test.stopTest();
    }

    @isTest
    static void testSearcUser(){
        Test.startTest();
        List<UTL_LookupSearchResult> result = CNT_CSM_JiraLink.searchUsers(UserInfo.getName());
        Test.stopTest();
    }

    @isTest
    private static void testCallout() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpResponseGenerator());
        CNT_CSM_JiraLink.getCalloutResponseContents('http://example.com/rest/api/');
        CNT_CSM_JiraLink.postCalloutResponseContents('http://example.com/rest/api/','{"example":"test"}');
        CNT_CSM_JiraLink.postAttachmentCalloutResponseContents('http://example.com/rest/api/',documents[0].Id);
        Test.stopTest();
    }
    
    public class TST_MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }

}