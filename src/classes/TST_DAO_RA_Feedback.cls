/**
 * This test class is used to test DAO_RA_Feedback.cls. It is copied over from TST_TGR_RA_Feedback.cls
 *
 */
@isTest
private class TST_DAO_RA_Feedback {

    @IsTest
    static void testInsertOnRAFeedback () {
    
        Test.startTest();
        setupTestData();
        raf.Procedure_Number__c='Test Section INSERT';
        // raf to Insert
        insert raf;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: raf.Id AND Field__c = 'procedure_number__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('procedure_number__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnRAFeedback () {
        Test.startTest();
        setupTestData();
        raf.Procedure_Number__c='Test Section UPDATE';
        insert raf;
        raf.Procedure_Number__c='Test Section Updated';
    
        // icsr to Insert
        update raf;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: raf.Id AND Operation__c = 'UPDATE' AND Field__c = 'procedure_number__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('procedure_number__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnRAFeedback () {
    
        Test.startTest();
        setupTestData();
        raf.Procedure_Number__c='Test DELETE';
        insert raf;
        delete raf;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: raf.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnRAFeedback () {
    
        Test.startTest();
        setupTestData();
        raf.Procedure_Number__c='Test UNDELETE';
        insert raf;
        
        delete raf;
        undelete raf;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: raf.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static RA_Feedback__c raf; 
    
    static void setupTestData () {
    
        raf = new RA_Feedback__c();
        
    }
}