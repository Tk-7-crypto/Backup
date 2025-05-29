/**
 * This test class is used to test Responsibilities and Maintenance Trigger.
 * This is the main Test class for Responsibilities and Maintenance Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Responsibilities_and_Maintenance.cls as well as TST_DAOH_Responsibilities_and_Maintenance.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_Responsibilities_and_Maint {
 
    @IsTest
    static void testInsertOnResponsibilitiesandMaintenance () {
    
        Test.startTest();
        setupTestData();
        rm.Comment__c='Test Comment INSERT';
        // rm to Insert
        insert rm;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rm.Id AND Field__c = 'comment__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('comment__c', auditLogAfterInsert.Field__c);
    }
    
    @IsTest
    static void testUpdateOnResponsibilitiesandMaintenance () {
        Test.startTest();
        setupTestData();
        rm.Comment__c='Test Comment UPDATE';
        insert rm;
        rm.Comment__c='Test Comment Updated';
    
        // pc to Insert
        update rm;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rm.Id AND Operation__c = 'UPDATE' AND Field__c = 'comment__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('comment__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnResponsibilitiesandMaintenance () {
    
        Test.startTest();
        setupTestData();
        rm.Comment__c='Test Comment DELETE';
        insert rm;
        delete rm;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rm.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnResponsibilitiesandMaintenance () {
    
        Test.startTest();
        setupTestData();
        rm.Comment__c='Test Comment UNDELETE';
        insert rm;
        
        delete rm;
        undelete rm;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rm.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }
    
    static Target__c target;
    static Program__c program;
    static Responsibilities_and_Maintenance__c rm;
    
    static void setupTestData () {
    
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
        insert target;
        
        rm = new Responsibilities_and_Maintenance__c();
        rm.PV_Agreement__c = target.id;
    }
}