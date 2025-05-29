@isTest
private class TST_BCH_CSM_UpdateJiraLink {
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
        CSM_QI_JiraLink__c jiraLink = New CSM_QI_JiraLink__c(jira_key__c='TestJiraKey', jira_base_url__c = 'https://jiraims.rm.imshealth.com', case_recordId__c = c.Id);
        insert jiraLink;
        CSM_QI_JiraLinkComment__c jlc = New CSM_QI_JiraLinkComment__c(JiraLink__c=jiraLink.Id, Body__c='a Jira comment',JiraCommentId__c='1');
        insert jlc;
    }
    
    static testMethod void testBCH_CSM_UpdateJiraLink() {
        Test.setMock(HttpCalloutMock.class, new CSM_JiraCalloutsHttpResponseMock());
        Test.startTest();
        SCH_CSM_UpdateJiraLink sch = new SCH_CSM_UpdateJiraLink();
        SchedulableContext ctx = null;
        sch.execute(ctx);
        BCH_CSM_UpdateJiraLink obj = new BCH_CSM_UpdateJiraLink();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }

}