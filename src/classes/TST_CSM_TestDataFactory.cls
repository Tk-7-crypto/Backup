@isTest
public class TST_CSM_TestDataFactory {

    @isTest
    static void testCreateAccount(){
        Test.startTest();
        Account accountRecord1 = CSM_TestDataFactory.createAccount();
        Account accountRecord2 = CSM_TestDataFactory.createAccount('Sponsor');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateContact(){
        Account accountRecord = CSM_TestDataFactory.createAccount();
        
        Test.startTest();
        Contact contactRecord = CSM_TestDataFactory.createContact(accountRecord.Id,'SUser013','rUser013','noreply013@dummy.com');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateCase(){
        Account accountRecord = CSM_TestDataFactory.createAccount();
        Contact contactRecord = CSM_TestDataFactory.createContact(accountRecord.Id,'SUser011','rUser011','noreply011@dummy.com');
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id userId = UserInfo.getUserId();
        
        
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Tech Queue Test';
        queues.QueueName__c = 'Tech Queue Test';
        queues.Type__c = 'Queue';
        insert queues;
        
        Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
            Name = 'Tech Queue Test',
            User__c = UserInfo.getUserId(),
            Type__c = 'User',
            IsDefaultQueue__c = true,
            TECH_QueueUser__c = queues.Id);
        
        insert qur;
        
        Test.startTest();
        Case caseRecord = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, recordTypeIdTechno, null, 'Email', 
                                                         null, 'Test subject', 'Test description', qur.Id);
        Case newCase = CSM_TestDataFactory.createClosedCase(accountRecord.Id, recordTypeIdTechno, contactRecord.Id, 
                                                            FALSE, 'Customer Portal', 'Test subject', 'Test description', 
                                                            userId, 'New', 'test', 'dummy', null, TRUE, qur.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateMajorIncident(){
        Test.startTest();
        Major_Incident__c majorRecord = CSM_TestDataFactory.createMajorIncident();
        Test.stopTest();
    }
}