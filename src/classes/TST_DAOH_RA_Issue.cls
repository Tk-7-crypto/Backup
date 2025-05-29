/**
 * This test class is used to test DAOH_RA_Issue.cls. It is copied over from TST_TGR_RA_Issue.cls
 *
 */
@isTest
private class TST_DAOH_RA_Issue {

    @IsTest
    static void testInsertOnRAIssue () {
    
        Test.startTest();
        setupTestData();
        rai.Section__c='Test Section INSERT';
        // rai to Insert
        insert rai;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rai.Id AND Field__c = 'section__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('section__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnRAIssue () {
        Test.startTest();
        setupTestData();
        rai.Section__c='Test Section UPDATE';
        insert rai;
        rai.Section__c='Test Section Updated';
    
        // rai to Insert
        update rai;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rai.Id AND Operation__c = 'UPDATE' AND Field__c = 'section__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('section__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnRAIssue () {
    
        Test.startTest();
        setupTestData();
        rai.Section__c='Test DELETE';
        insert rai;
        delete rai;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rai.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnRAIssue () {
    
        Test.startTest();
        setupTestData();
        rai.Section__c='Test UNDELETE';
        insert rai;
        
        delete rai;
        undelete rai;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rai.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static RA_Issue__c rai; 
    
    static void setupTestData () {
    
        rai = new RA_Issue__c();
        
    }
}