/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_WorkNote
 */
@isTest
private class TST_CNT_CSM_WorkNote {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        
        Account acc = CSM_Util.createAccount();
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        /*Audit trail Log Added Start */
        Account acct2 = CSM_Util.createRDAccount();
        insert acct2;
        
        /*Audit trail Log Added End */
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
        Case c = New Case(Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,Current_Queue__c = 'Q1');
        insert c;
        CaseComment cc = new CaseComment(ParentId = c.Id, IsPublished=true,CommentBody='TestComment');
        insert cc;
        
        
    }
    
    
    /**
     * This method used to get caseComment by ParentId
     */    
    @IsTest
    static void testGetCaseCommentByParentId() {
        List<CaseComment> caseComments = new  List<CaseComment>();
        Case c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        caseComments = CNT_CSM_WorkNote.getCaseCommentByParentId(c.Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = caseComments.size();
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testInsertCaseComment(){
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        CaseComment ccRecord = new CaseComment(ParentId = caseList[0].Id, IsPublished = true, CommentBody = 'Test Comment');
        
        Test.startTest();
        CNT_CSM_WorkNote.insertCaseComment(ccRecord);
        Case caseRecord = caseList[0];
        caseRecord.Subject = 'Updated case subject';
        caseRecord.Origin = 'Customer Portal';
        Case newRecord = new Case();
        newRecord = CNT_CSM_WorkNote.updateCase(caseRecord);
        Test.stopTest();
    }
}