/*
* Version       : 1.0
* Description   : This test class is used for DAO_CSAT_Respone
*/
@isTest
private class TST_DAO_CSAT_Response {

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
        
        
    }

    @IsTest
    static void testShouldUpdateAnswer() {
        List<CSAT_Responses__c> listOfCSATResponse = new List<CSAT_Responses__c>();
        Case c = [SELECT Id from Case where Subject = 'TestCase' limit 1];
        CSAT_Responses__c newCSATResponse = new CSAT_Responses__c(Question__c = 'Test', Case__c = c.Id);
        newCSATResponse.Answer__c = '2';
        listOfCSATResponse.add(newCSATResponse);
        
        Test.startTest();
            insert listOfCSATResponse;
        Test.stopTest();
        
        listOfCSATResponse = listOfCSATResponse();
        System.assertEquals(2, listOfCSATResponse[0].Answer_Numeric__c, 'Should update value in answer in numeric');
    }
    
    @IsTest
    static void testShouldNotUpdateAnswer() {
        List<CSAT_Responses__c> listOfCSATResponse = new List<CSAT_Responses__c>();
        Case c = [SELECT Id from Case where Subject = 'TestCase' limit 1];
        CSAT_Responses__c newCSATResponse = new CSAT_Responses__c(Question__c = 'Test', Case__c = c.Id);
        newCSATResponse.Answer__c = '23';
        listOfCSATResponse.add(newCSATResponse);
        
        Test.startTest();
            insert listOfCSATResponse;
        Test.stopTest();
        
        listOfCSATResponse = listOfCSATResponse();
        System.assertEquals(null, listOfCSATResponse[0].Answer_Numeric__c, 'Should not update value in answer in numeric');
    }
    
    private static List<CSAT_Responses__c> listOfCSATResponse() {
        return [SELECT Id, Answer_Numeric__c FROM CSAT_Responses__c];
    }
}