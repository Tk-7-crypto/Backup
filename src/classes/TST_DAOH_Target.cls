/**
 * This test class is used to test DAO_Target.cls. It is copied over from TST_DAO_Target.cls
 * 
 */
@isTest
private class TST_DAOH_Target {

    @IsTest
    static void testInsertOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title INSERT';
        // target to Insert
        insert target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: target.Id AND Field__c = 'title__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c);
        System.assertEquals('title__c', auditLogAfterInsert.Field__c);
    }
     
    @IsTest
    static void testUpdateOnTarget () {
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title UPDATE';
        insert target;
        target.Title__c='Test Title Updated';
    
        // target to Insert
        update target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'UPDATE' AND Field__c = 'title__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c);
        System.assertEquals('title__c', auditLogAfterUpdate.Field__c);
    
    
    }
    
    @IsTest
    static void testCountryUpdateOnTarget () {
        Test.startTest();
        setupTestData();
        target.Countries__c='AD';
        insert target;
        HA_Websites_Review__c hr = new HA_Websites_Review__c();
        hr.Product__c = target.id;
        hr.Client_marketing_author_in_the_country__c = 'Yes';
        insert hr;
        target.Countries__c='AF';
    
        // target to Insert
        update target;
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title DELETE';
        insert target;
        delete target;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c);
    
    }
    
    @IsTest
    static void testUnDeleteOnTarget () {
    
        Test.startTest();
        setupTestData();
        target.Title__c='Test Title UNDELETE';
        insert target;
        
        delete target;
        undelete target;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: target.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c);
    
    }

    @IsTest
    static void testFieldUpdates () {
        List<Target__c> insertList = new List<Target__c>();

        RecordType recordId = [SELECT Id from RecordType where Name='RDS Product Line'];
        Target__c target1 = new Target__c();
        target1.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target1.Program__c = program.id;
        target1.api__c = 'test api';
        target1.Countries_NA__c = true;
        target1.Date_Activated__c = System.today();
        target1.Inactivated_Date__c = System.today();

        Target__c target2 = new Target__c();
        target2.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target2.Program__c = program.id;
        target2.api__c = 'test api';
        target2.Countries_NA__c = true;
        target2.Date_Activated__c = System.today();
        target2.Inactivated_Date__c = System.today();

        Target__c target3 = new Target__c();
        target3.RecordTypeId = recordId.Id;
        program = new Program__c();
        insert program;
        target3.Program__c = program.id;
        Drug__c drug = new Drug__c();
        drug.Service_Lines__c = 'Aggregate Reporting';
        drug.Program__c = program.id;
        insert drug;
        target3.drug__c = drug.id;
        target3.Countries_NA__c = true;
        target3.Date_Activated__c = System.today();
        target3.Inactivated_Date__c = System.today();

        insertList.add(target1);
        insertList.add(target2);
        insertList.add(target3);
        insert insertList;
        // 
    }
    
    @isTest
    static void manageDatesOnActiveToggleTest() {
        RecordType recordId = [SELECT Id from RecordType where Name='RDS Product Line'];
        Target__c target1 = new Target__c();
        target1.RecordTypeId = recordId.Id;
        target1.Name = 'Test target';
        target1.Active__c = true;
        target1.Date_Activated__c = System.today();
        target1.Inactivated_Date__c = System.today();
        target1.Countries_NA__c = true;
        program = new Program__c();
        program.Name = 'New Prog';
        insert program;
        target1.Program__c = program.id;
        insert target1;
    }
    
    static Target__c target;
    static Program__c program;
    
    static void setupTestData () {
    
        RecordType recordId = [SELECT Id from RecordType where Name='PV Agreement'];
        target = new Target__c();
        target.RecordTypeId = recordId.Id;
        target.name = 'Testing';
        program = new Program__c();
        insert program;
        target.Program__c = program.id;
    }
    @isTest
    static void deleteValidationTest() {
        setupTestData();
        Test.startTest();
        target.Title__c='Test';
        target.Date_Activated__c = System.today();
        target.Inactivated_Date__c = System.today();
        target.Countries__c = 'US';
        insert target;
        Id recordId = [SELECT Id from RecordType where DeveloperName='RDS_Product_Line'].Id;
        target.RecordTypeId = recordId;
        update target;
        delete target;
        Test.stopTest();
    }
    
}
