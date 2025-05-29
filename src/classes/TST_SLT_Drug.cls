/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Drug
 */
@isTest
public class TST_SLT_Drug {    

    /**
     * This method used to get Drugs by Id***/    
    @IsTest
    static void testGetDrugs() {
        setupTestData();
        Test.startTest();
        Set<Id> idSet = new Set<Id>();
        idSet.add(drug.Id);
        Set<String> fieldset = new Set<String>{'Id','Name'};
        Map<Id,Drug__c> drugsMap = new SLT_Drug(false,false).getDrugById(idSet,fieldset);
        Test.stopTest();
    }

    /**
     * This method used to get sObjectFieldlist
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        setupTestData();
        Test.startTest();
        List<Schema.SObjectField> fieldNames = new SLT_Drug(false).getSObjectFieldList();
        Test.stopTest();
    }


    /**
     * This method used to get sObject Type
     */    
    @IsTest
    static void testGetSObjectType() {
        setupTestData();
        Test.startTest();
        Schema.SObjectType sObjectType = new SLT_Drug().getSObjectType();
        Test.stopTest();
        System.assertEquals(Drug__c.sObjectType,sObjectType);
    }



    static Program__c program;
    static Drug__c drug;

    static void setupTestData () {
        program = UTL_PSA_TestData.programs[0];
        drug = new Drug__c(
            Program__c=program.Id,
            Service_Lines__c = 'Aggregate Reporting'
        );
        insert drug;


    }

}