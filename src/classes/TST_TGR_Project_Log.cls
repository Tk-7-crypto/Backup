/**
 * This test class is used to test Project Log Trigger.
 * This is the main Test class for Project Log Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Project_Log.cls as well as TST_DAOH_PSA_Project_Log.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_Project_Log 
{
	@testSetup
    static void dataSetup() {
	    //Program
	    Program__c program = new Program__c(Name = 'Test Program');
	    insert program;
        
        Account account = UTL_PSA_TestData.accounts[0];
        account.Name = 'Test Account';
        Project_Log__c projectLog = new Project_Log__c();
        projectLog.Account__c = account.id;
        projectLog.Title__c='Test';
        projectLog.Program__c = program.id;
        insert projectLog;
    }
    
    @IsTest
    static void testInsertOnProjectLog () 
    {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id from Project_Log__c limit 1];
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with INSERT Opertion
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: projectLog.Id AND Field__c = 'title__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('title__c', auditLogAfterInsert.Field__c);
    }

    @IsTest
    static void testUpdateOnProjectLog () 
    {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id from Project_Log__c limit 1];
        projectLog.Title__c='Test Title Updated';
        update projectLog;
        Test.stopTest();
        
        // Validate if a record was insererted in Audit log with UPDATE Opertion
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: projectLog.Id AND Operation__c = 'UPDATE' AND Field__c = 'title__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('title__c', auditLogAfterUpdate.Field__c);
    }

    @IsTest
    static void testDeleteOnProjectLog () 
    {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id from Project_Log__c limit 1];
        projectLog.Reason_for_Deletion__c='Test Title needs to be deleted';
        update projectLog;
        delete projectLog;
        Test.stopTest();
        
        // Validate if a record was insererted in Audit log with UPDATE Opertion
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: projectLog.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    }

    @IsTest
    static void testUnDeleteOnProjectLog ()
    {
        Test.startTest();
        //setupTestData();
        Project_Log__c projectLog = [Select Id from Project_Log__c limit 1];
        projectLog.Reason_for_Deletion__c='Test Title UNDELETE needs to be deleted';
        update projectLog;
        delete projectLog;
        undelete projectLog;
    
        Test.stopTest();
        // Validate if a record was insererted in Audit log with UNDELETE Opertion
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: projectLog.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    }

    /*
    static Project_Log__c projectLog;
    static Account account;
    static void setupTestData () {
        account = UTL_PSA_TestData.accounts[0];
        account.Name = 'Test Account';
        projectLog = new Project_Log__c();
        projectLog.Account__c = account.id;
        
    }
    */
}
