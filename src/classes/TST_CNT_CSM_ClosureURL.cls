@isTest
private class TST_CNT_CSM_ClosureURL {

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

        CSM_Case_Details_Global_Setting__c gs = new CSM_Case_Details_Global_Setting__c(Name='CSM_qualtrics_closure_case', Component_Id__c='00000');
        insert gs;

    }

    @IsTest
    private static void testGetURL() {
        Case c = [SELECT Id, caseNumber FROM case where Subject = 'TestCase' limit 1];
        Test.startTest();
            CNT_CSM_ClosureURL cntClosureURL= new CNT_CSM_ClosureURL();
            cntClosureURL.caseId = c.Id;
            String result = cntClosureURL.url;
        Test.stopTest();
    }
}