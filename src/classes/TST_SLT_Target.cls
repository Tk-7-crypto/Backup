/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Target
 */
@isTest
public class TST_SLT_Target {    

    /**
     * This method used to get Targets by Program Id.
     */    
    @IsTest
    static void testGetTargetByProgram() {
        setupTestData();
        Id recordtypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', 'RDS Product Line');
        Set<String> fieldset = new Set<String>{'Id'};

        Test.startTest();
        List<Target__c> targets = new SLT_Target().getTargetByProgram(program.Id);
        targets = new SLT_Target().getTargetByProgram(program.Id, fieldset);
        targets = new SLT_Target().getTargetByProgram(program.Id, recordtypeId, fieldset);
        Map<Id, List<Target__c>> mapTargets = new SLT_Target().getTargetByProgram(new Set<Id>{program.id}, recordtypeId,fieldset);
        Test.stopTest();

        Target__c tar = targets.get(0);
        System.assertNotEquals(null, tar);
        System.assertEquals(tar.API__c,'Test API');
    }

    /**
     * This method used to get sObjectFieldlist
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        setupTestData();
        Test.startTest();
        List<Schema.SObjectField> fieldNames = new SLT_Target().getSObjectFieldList();
        Test.stopTest();
    }

    /**
     * This method used to get sObjectFieldset
     */    
    @IsTest
    static void testGetSObjectFieldSet() {
        setupTestData();
        Test.startTest();
        Set<String> fieldNames = new SLT_Target().getSObjectFieldSet();
        Test.stopTest();
    }

    /**
     * This method used to get sObject Type
     */    
    @IsTest
    static void testGetSObjectType() {
        setupTestData();
        Test.startTest();
        Schema.SObjectType sObjectType = new SLT_Target().getSObjectType();
        Test.stopTest();
        System.assertEquals(Target__c.sObjectType,sObjectType);
    }



    static Program__c program;
    static Target__c target;

    static void setupTestData () {
        program = UTL_PSA_TestData.programs[0];
        target = new Target__C(
            Active__c=true,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Date_Activated__c = system.today(),
            Countries_NA__c = true
        );
        insert target;


    }

}
