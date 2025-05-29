/**
 * This test class is used to test Project Contact Trigger.
 * This is the main Test class for Project Contact Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Project_Contact.cls as well as TST_DAOH_PSA_Project_Contact.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
private class TST_TGR_Project_Contact 
{
    @testSetup
    static void dataSetup() 
	{
		RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        Target__c target = new Target__c();
        target.RecordTypeId = recordId.Id;
        Program__c program = new Program__c();
        insert program;
        target.Program__c = program.id;
        insert target;
    }
    
    @IsTest
    static void testInsertOnProjectContact () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Project_Contact__c pc = new Project_Contact__c();
        pc.Target__c = target.id;
        pc.Comments__c='Test Comment INSERT';
        insert pc;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: pc.Id AND Field__c = 'comments__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('comments__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnProjectContact () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Project_Contact__c pc = new Project_Contact__c();
        pc.Target__c = target.id;
        pc.Comments__c='Test Comment UPDATE';
        insert pc;
        pc.Comments__c='Test Comment Updated';
        update pc;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'UPDATE' AND Field__c = 'comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c);
    }
    
    @IsTest
    static void testDeleteOnProjectContact () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Project_Contact__c pc = new Project_Contact__c();
        pc.Target__c = target.id;
        pc.Comments__c='Test Comment DELETE';
        insert pc;
        delete pc;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnProjectContact () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Project_Contact__c pc = new Project_Contact__c();
        pc.Target__c = target.id;
        pc.Comments__c='Test Comment UNDELETE';
        insert pc;
        delete pc;
        undelete pc;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: pc.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    }
    
    /*
    static Target__c target;
    static Program__c program;
    static Project_Contact__c pc;
    static void setupTestData () {
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
        insert target;
        pc = new Project_Contact__c();
        pc.Target__c = target.id;
    }
	*/
}