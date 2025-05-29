/**
 * This test class is used to test DAO_Partner_Contact class.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0 
 */
@isTest
private class TST_DAO_Partner_Contact {

    @IsTest
    static void testInsertOnPartnerContact () {
    
        Test.startTest();
        setupTestData();
        pc.PV_Agreement__c =target.id;
        // pc to Insert
        insert pc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: pc.Id AND Field__c = 'PV_Agreement__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('pv_agreement__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnRAFeedback () {
        Test.startTest();
        setupTestData();
        pc.Comments__c='Test Insert';
        insert pc;
        pc.Comments__c='Test Updated';
    
        // raf to Insert
        update pc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'UPDATE' AND Field__c = 'Comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnRAFeedback () {
    
        Test.startTest();
        setupTestData();
        pc.PV_Agreement__c=target.id;
        insert pc;
        delete pc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnRAFeedback () {
    
        Test.startTest();
        setupTestData();
        pc.PV_Agreement__c=target.id;
        insert pc;
        
        delete pc;
        undelete pc;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static Partner_Contact__c pc; 
    static Target__c target;
    static Program__c program;
        
    static void setupTestData () {
    
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
        target.Title__c='Test Title INSERT';
        insert target;
        pc = new Partner_Contact__c();

    }
}