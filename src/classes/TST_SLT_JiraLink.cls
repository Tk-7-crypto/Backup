/*
 * Version       : 1.0
 * Description   : Test Class for SLT_JiraLink
 */
@isTest
private class   TST_SLT_JiraLink {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;
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
        
        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
        insert c;
        CSM_QI_JiraLink__c jiraLink = New CSM_QI_JiraLink__c(jira_key__c='TestJiraKey', case_recordId__c = c.Id);
        insert jiraLink;        
    }
    
     /**
     * This method used to get JiraLink by ID
     */    
    @IsTest
    static void testSelectById() {
        List<CSM_QI_JiraLink__c> jiraLinks = new  List<CSM_QI_JiraLink__c>();
        CSM_QI_JiraLink__c jiraLink = [SELECT id FROM CSM_QI_JiraLink__c WHERE jira_key__c = 'TestJiraKey'];    
        Test.startTest();
        jiraLinks = new SLT_JiraLink().selectById(new Set<Id> {jiraLink.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = jiraLinks.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get JiraLink by CaseId
     */    
    @IsTest
    static void testSelectByCaseId() {
        List<CSM_QI_JiraLink__c> jiraLinks = new  List<CSM_QI_JiraLink__c>();
        Case c = [SELECT id FROM case WHERE Subject = 'TestCase'];
        Test.startTest();
        jiraLinks = new SLT_JiraLink().selectByCaseId(new Set<Id> {c.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = jiraLinks.size();
        System.assertEquals(expected, actual);
    }
}