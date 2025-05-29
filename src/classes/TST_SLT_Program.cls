/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Program
 */
@isTest
private class TST_SLT_Program {

     /**
     * This method used to get a Program by Program Id.
     */    
    @IsTest
    static void testSelectProgramById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Account__c','Start_Date__c','End_Date__c'};
        Program__c idToProgram = new SLT_Program().selectByProgramId(new Set<Id> {program.id}, fieldSet );
        Test.stopTest();
        String expected = 'SLTTestProgram';
        String actual = idToProgram.Name;
        System.assertEquals(expected, actual);
    }

     /**
     * This method used to get a List of Program by Program Id.
     */    
    @IsTest
    static void testSelectProgramListById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Account__c','Start_Date__c','End_Date__c'};
        List<Program__c> idToProgramMap = new SLT_Program().selectByProgramIdList(new Set<Id> {program.id}, fieldSet );
        Test.stopTest();
        Integer expected = 1;
        Integer actual = idToProgramMap.size();
        System.assertEquals(expected, actual);
    }
    
     /**
     * This method used to get a Map<Id, Program__c> by Program Id.
     */    
    @IsTest
    static void testSelectProgramMapById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Account__c','Start_Date__c','End_Date__c'};
        Map<Id, Program__c> idToProgramMap = new SLT_Program().getProjectById(new Set<Id> {program.id}, fieldSet );
        Test.stopTest();
        String expected = 'SLTTestProgram';
        String actual = idToProgramMap.get(program.id).Name;
        System.assertEquals(expected, actual);
    }

   @IsTest
    static void testSelectProgramMapAccountId() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Account__c','Start_Date__c','End_Date__c'};
        List<Program__c> idToProgramList = new SLT_Program().selectByAccount(new Set<Id> {account.id}, fieldSet );
        Test.stopTest();
        String expected = 'SLTTestProgram';
        String actual = idToProgramList[0].Name;
        System.assertEquals(expected, actual);
    }



    static Program__c program;
    static Account account;
    static void setupTestData () {
    account = UTL_PSA_TestData.accounts[0];

    program = new Program__c(Name = 'SLTTestProgram');
    program.Account__c = account.id;
    insert program;       
    }
}