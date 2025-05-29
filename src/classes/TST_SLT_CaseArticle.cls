/*
 * Version       : 1.0
 * Description   : Test Class for SLT_CaseArticle
 */
@isTest
private class TST_SLT_CaseArticle {
    
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
        Knowledge__kav knowledge = New Knowledge__kav(Title = 'TestTitle', language = 'en_US',UrlName='TestUrlName', Pillar__c = 'Technology Solutions');
        insert knowledge;
        knowledge = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledge.Id];
        CaseArticle caseArticle = new CaseArticle(CaseId = c.Id, KnowledgeArticleId=knowledge.KnowledgeArticleId);
        insert caseArticle;
    }
    
     /**
     * This method used to get CaseArticle by ID
     */    
    @IsTest
    static void testSelectById() {
        List<CaseArticle> caseArticles = new  List<CaseArticle>();
        Case c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        CaseArticle caseArticle = [SELECT Id FROM CaseArticle WHERE caseId =: c.Id];
        Test.startTest();
        caseArticles = new SLT_CaseArticle().selectById(new Set<Id> {caseArticle.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = caseArticles.size();
        System.assertEquals(expected, actual);
    }
    
     /**
     * This method used to get CaseArticle by caseId
     */    
    @IsTest
    static void testSelectByCaseId() {
        List<CaseArticle> caseArticles = new  List<CaseArticle>();
        Case c = [SELECT id FROM Case WHERE Subject = 'TestCase'];    
        Test.startTest();
        caseArticles = new SLT_CaseArticle().selectByCaseId(new Set<Id> {c.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = caseArticles.size();
        System.assertEquals(expected, actual);
    }
    
    
    
}