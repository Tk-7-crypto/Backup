/**
 * This test class is used to test DAO_Agreement_Products.cls. It is copied over from TST_TGR_Agreement_Products.cls
 * 
 */
@isTest
private class TST_DAO_Agreement_Products 
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
    static void testInsertOnAgreementProducts () 
    { 
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Products__c ap = new Agreement_Products__c();
        ap.PV_Agreement__c = target.id;
        ap.Comments__c='Test Comment INSERT';
        insert ap;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: ap.Id AND Field__c = 'comments__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('comments__c', auditLogAfterInsert.Field__c);
    }
    
    @IsTest
    static void testUpdateOnAgreementProducts () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Products__c ap = new Agreement_Products__c();
        ap.PV_Agreement__c = target.id;
        ap.Comments__c='Test Comment UPDATE';
        insert ap;
        ap.Comments__c='Test Comment Updated';
        update ap;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: ap.Id AND Operation__c = 'UPDATE' AND Field__c = 'comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c);
    }
    
    @IsTest
    static void testDeleteOnAgreementProducts () 
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Products__c ap = new Agreement_Products__c();
        ap.PV_Agreement__c = target.id;
        ap.Comments__c='Test Comment DELETE';
        insert ap;
        delete ap;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: ap.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    }
    
    @IsTest
    static void testUnDeleteOnAgreementProducts ()
    {
        Test.startTest();
        //setupTestData();
        Target__c target = [Select id from Target__c limit 1]; 
        Agreement_Products__c ap = new Agreement_Products__c();
        ap.PV_Agreement__c = target.id;
        ap.Comments__c='Test Comment UNDELETE';
        insert ap;
        delete ap;
        undelete ap;
        Test.stopTest();
        
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: ap.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    }
    
    /*
    static Target__c target;
    static Program__c program;
    static Agreement_Products__c ap;
    static void setupTestData () {
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
        insert target;
        ap = new Agreement_Products__c();
        ap.PV_Agreement__c = target.id;
    }
	*/
}