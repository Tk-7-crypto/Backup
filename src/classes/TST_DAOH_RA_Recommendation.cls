/**
 * This test class is used to test DAOH_RA_Recommendation.cls. It is copied over from TST_TGR_RA_Recommendation.cls
 *
 */
@isTest
private class TST_DAOH_RA_Recommendation {

    @IsTest
    static void testInsertOnRARecommendation () {
    
        Test.startTest();
        setupTestData();
        rarec.Section__c='Test Section INSERT';
        // rarec to Insert
        insert rarec;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rarec.Id AND Field__c = 'section__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('section__c', auditLogAfterInsert.Field__c);
    } 
    
    @IsTest
    static void testUpdateOnRARecommendation () {
        Test.startTest();
        setupTestData();
        rarec.Section__c='Test Section UPDATE';
        insert rarec;
        rarec.Section__c='Test Section Updated';
    
        // rai to Insert
        update rarec;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rarec.Id AND Operation__c = 'UPDATE' AND Field__c = 'section__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('section__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testDeleteOnRARecommendation () {
    
        Test.startTest();
        setupTestData();
        rarec.Section__c='Test DELETE';
        insert rarec;
        delete rarec;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rarec.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnRARecommendation () {
    
        Test.startTest();
        setupTestData();
        rarec.Section__c='Test UNDELETE';
        insert rarec;
        
        delete rarec;
        undelete rarec;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rarec.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    static RA_Recommendation__c rarec; 
    
    static void setupTestData () {
    
        rarec = new RA_Recommendation__c();
        
    }
}