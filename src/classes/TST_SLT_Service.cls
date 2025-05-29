/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Service
 */
@isTest
private class TST_SLT_Service {
    
    /**
     * This method used to get Service by Id.
     */    
    @IsTest
    static void testSelectById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Service_Code__c'};
        Map<Id, Service__c> idToService = new SLT_Service().getServiceById(new Set<Id> {service.id}, fieldSet );
        Test.stopTest();
        String expected = 'Test Service';
        String actual = idToService.get(service.Id).Name;
        System.debug('actual'+ actual);
        System.assertEquals(expected, actual);
    }


/**
     * This method used to get Service by Service Code.
     */    
    @IsTest
    static void testActiveServiceByServiceCode() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Service_Code__c'};
        Map<String, Service__c> serviceByServiceCode = new SLT_Service().getActiveServiceByServiceCode(new Set<String> {service.Service_Code__c}, fieldSet );
        Test.stopTest();
        Integer expected = 1;
        Integer actual = serviceByServiceCode.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get sObjectFieldset
     */    
    @IsTest
    static void testGetSObjectFieldSet() {
        setupTestData();
        Set<String> fieldNames = new SLT_Service().getSObjectFieldSet();
        Test.startTest();

         for(String name : fieldNames){
                        System.debug(name);
                    }
               // System.assertEquals(expected, actual);
    }

    /**
     * This method used to get sObject Type
     */    
    @IsTest
    static void testGetSObjectType() {
        setupTestData();
        Schema.SObjectType sObjectType = new SLT_Service().getSObjectType();
        Test.startTest();
        System.debug(sObjectType);

        
               // System.assertEquals(expected, actual);
    }



    static Program__c program;
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static Service__c service;

    static void setupTestData () {

        program = new Program__c(Name = 'SLTTestProgram');
        insert program;  

        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Name = 'SLTTestParentProject';
        parentproject.Program__c = program.id;
        insert parentproject;
      
        //service
        service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';

        insert service;

        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.Name = 'SLTTestServiceLineProject';
        project.pse__Parent_Project__c = parentproject.id;
        project.Project_Code__c ='12345';
        
        insert project;    

        

    }

}