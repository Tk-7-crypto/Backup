/**
 * This test class is used to test RA Request Trigger.
 * This is the main Test class for RA Request Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_RA_Request.cls as well as TST_DAOH_RA_Request.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_RA_Request {

    @IsTest
    static void testInsertOnRARequest () {
    
        Test.startTest();
        setupTestData();
        rar.Section__c='Test Section INSERT';
        // rar to Insert
        insert rar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rar.Id AND Field__c = 'section__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('section__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnRARequest () {
        Test.startTest();
        setupTestData();
        rar.Section__c='Test Section UPDATE';
        insert rar;
        rar.Section__c='Test Section Updated';
    
        // rar to Insert
        update rar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rar.Id AND Operation__c = 'UPDATE' AND Field__c = 'section__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('section__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnRARequest () {
    
        Test.startTest();
        setupTestData();
        rar.Section__c='Test DELETE';
        insert rar;
        delete rar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rar.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnRARequest () {
    
        Test.startTest();
        setupTestData();
        rar.Section__c='Test UNDELETE';
        insert rar;
        
        delete rar;
        undelete rar;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rar.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static RA_Request__c rar; 
    
    static void setupTestData () {
    
        rar = new RA_Request__c();
        
    }
}