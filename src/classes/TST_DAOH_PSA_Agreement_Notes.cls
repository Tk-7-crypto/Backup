/**
 * This test class is used to test DAOH_PSA_Agreement_Notes.cls. It is copied over from TST_DAO_Agreement_Notes.cls
 * 
 */
@isTest
private class TST_DAOH_PSA_Agreement_Notes 
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
    static void testInsertOnAgreementNotes () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Notes__c an = new Agreement_Notes__c();
        an.PV_Agreement__c = target.id;
        an.Notes__c='Test Note INSERT';
        insert an;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: an.Id AND Field__c = 'notes__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('notes__c', auditLogAfterInsert.Field__c);
    }
    
    @IsTest
    static void testUpdateOnAgreementNotes () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Notes__c an = new Agreement_Notes__c();
        an.PV_Agreement__c = target.id; 
        an.Notes__c='Test Note UPDATE';
        insert an;
        an.Notes__c='Test Note Updated';
        update an;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: an.Id AND Operation__c = 'UPDATE' AND Field__c = 'notes__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('notes__c', auditLogAfterUpdate.Field__c);    
    }
    
    @IsTest
    static void testDeleteOnAgreementNotes () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Notes__c an = new Agreement_Notes__c();
        an.PV_Agreement__c = target.id;
        an.Notes__c='Test Note DELETE';
        insert an;
        delete an;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: an.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnAgreementNotes () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Notes__c an = new Agreement_Notes__c();
        an.PV_Agreement__c = target.id;
        an.Notes__c='Test Note UNDELETE';
        insert an;
        delete an;
        undelete an;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: an.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }
    
    /*
    static Target__c target;
    static Program__c program;
    static Agreement_Notes__c an;
    static void setupTestData () {
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
        insert target;
        an = new Agreement_Notes__c();
        an.PV_Agreement__c = target.id;
    }
	*/
}