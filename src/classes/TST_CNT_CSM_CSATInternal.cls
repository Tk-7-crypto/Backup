/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CSM_CSATInternal
 */
@isTest
private class TST_CNT_CSM_CSATInternal {
    /**
     * This method used to set up testdata
     */ 
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
    }
    
    /**
     * This method used to get a List of CSM_QI_CSATInternal__c for a caseId
     */    
    @IsTest
    static void testGetCommentRatingByCaseId() {
        List<Case> c = new  List<Case>();
        List<CSM_QI_CSATInternal__c> csatList = new List<CSM_QI_CSATInternal__c>();
        c = [SELECT id FROM Case WHERE Subject = 'TestCase'];
        Test.startTest();
        csatList = CNT_CSM_CSATInternal.getCommentRatingByCaseId(c[0].Id);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = csatList.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testSaveCommentRating() {
        List<Case> c = new  List<Case>();
        List<CSM_QI_CSATInternal__c> csatList = new List<CSM_QI_CSATInternal__c>();
        c = [SELECT id, CurrentQueue__c FROM Case WHERE Subject = 'TestCase'];
        csatList = CNT_CSM_CSATInternal.getCommentRatingByCaseId(c[0].Id);
        CNT_CSM_CSATInternal.saveCommentRating (csatList[0].id, 'Satisfied', c[0].CurrentQueue__c);
        csatList = CNT_CSM_CSATInternal.getCommentRatingByCaseId(c[0].Id);
        System.assertEquals('Satisfied', csatList[0].Rate__c);
    }

    @IsTest
    static void testGetUserProfile() {
        Profile p = new Profile();
        Test.startTest();
        p = CNT_CSM_CSATInternal.getUserProfile();
        Test.stopTest();
        System.assertEquals('System Administrator', p.Name);
    }

    @IsTest
    static void testGetUserPermissionSet() {
        List<PermissionSetAssignment> psa  = new List<PermissionSetAssignment>();
        Test.startTest();
        psa = CNT_CSM_CSATInternal.getUserPermissionSet();
        Test.stopTest();
    }
}