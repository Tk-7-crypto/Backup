/**
 * This test class is used to test Report Country Trigger.
 * This is the main Test class for Report Country Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Report_Country.cls as well as TST_DAOH_Report_Country.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_Report_Country {

    @IsTest
    static void testInsertOnReportCountry () {
    
        Test.startTest();
        setupTestData();
        rc.Comments__c='Test Section INSERT';
        // rai to Insert
        insert rc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rc.Id AND Field__c = 'comments__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('comments__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnReportCountry () {
        Test.startTest();
        setupTestData();
        rc.Comments__c='Test Section UPDATE';
        insert rc;
        rc.Comments__c='Test Section Updated';
    
        // rc to Insert
        update rc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'UPDATE' AND Field__c = 'comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnReportCountry () {
    
        Test.startTest();
        setupTestData();
        rc.Comments__c='Test DELETE';
        insert rc;
        delete rc;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnReportCountry () {
    
        Test.startTest();
        setupTestData();
        rc.Comments__c='Test UNDELETE';
        insert rc;
        
        delete rc;
        undelete rc;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static Report_Country__c rc; 
    
    static void setupTestData () {
    
        rc = new Report_Country__c();
        
    }
}