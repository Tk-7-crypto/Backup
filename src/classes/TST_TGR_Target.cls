/**
 * This test class is used to test Target Trigger.
 * This is the main Test class for Target Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Target.cls as well as TST_DAOH_Target.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_Target {
 
    @IsTest
    static void testInsertOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title INSERT';
        // target to Insert
        insert target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: target.Id AND Field__c = 'title__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('title__c', auditLogAfterInsert.Field__c);
    }
    
    @IsTest
    static void testUpdateOnTarget () {
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title UPDATE';
        insert target;
        target.Title__c='Test Title Updated';
    
        // target to Insert
        update target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'UPDATE' AND Field__c = 'title__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('title__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title DELETE';
        insert target;
        delete target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title UNDELETE';
        insert target;
        
        delete target;
        undelete target;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }
    
    static Target__c target;
    static Program__c program;
    
    static void setupTestData () {
    
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
    }
}