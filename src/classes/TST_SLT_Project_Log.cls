/*
* TST_SLT_Project_Log
*
* Providing proofs for the SLT_Project_Log
*/
@isTest
private class TST_SLT_Project_Log {
    /**
     * This method used to get sObjectFieldset
     */    
    @IsTest
    static void testGetSObjectFieldSet() {
        setupTestData();
        Set<String> fieldNames = new SLT_Project_Log().getSObjectFieldSet();
        Test.startTest();
        System.assertNotEquals(0,fieldNames.size());
    }

    @isTest
    static void testFindBy(){
        setupTestData();
        Test.startTest();
        List<Project_Log__c> logs = new SLT_Project_Log().findBy(new Set<String>{'Title__c'}, 'Title__c = \'Test Log\'');
        Test.stopTest();
        System.assertEquals(1,logs.size());
    }

    static Service_Line__c serviceLine;
    static Service__c service;
    static void setupTestData(){

        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Project_Log__c', 'Risk - RADDS');
        insert new Project_Log__c(Title__c='Test Log',RecordTypeId=recordTypeId);

    }

}