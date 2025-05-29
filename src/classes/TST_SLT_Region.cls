/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Region
 */
@isTest
private class TST_SLT_Region {
    
   
   
    // This method used to get Single Region by Name
        
    @IsTest
    static void testGetSingleRegionByName() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'Name','pse__Region_Name_Chain__c', 'pse__Region_ID_Chain__c', 'pse__Parent_Region__c'};
        pse__Region__c singleRegionByName = new SLT_Region().selectSingleRegionByName(region.Name, fieldSet );
        Test.stopTest();
        String expected = 'NAMR';
        String actual = singleRegionByName.Name;
        System.debug('actual '+ actual);
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get Region by Name
     */    
    @IsTest
    static void testGetRegionByName() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'Name','pse__Region_Name_Chain__c', 'pse__Region_ID_Chain__c', 'pse__Parent_Region__c'};
        Map<String, pse__Region__c> regionByName = new SLT_Region().selectRegionByName(new Set<String> {region.Name}, fieldSet );
        Test.stopTest();
        String expected = 'NAMR';
        String actual = regionByName.get(region.Name).Name;
        System.debug('actual'+ actual);
        System.assertEquals(expected, actual);
    }

     /**
     * This method used to get Regions by country code
     */    
    @IsTest
    static void testGetRegionsByCountryCode() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'Name','pse__Region_Name_Chain__c', 'pse__Region_ID_Chain__c', 'pse__Parent_Region__c'};
        Set<String> contryCodeSet = new Set<String>{'US'};
        Map<String, pse__Region__c> regionByCode = new SLT_Region().selectRegionByCountryCode(contryCodeSet);
        
        Test.stopTest();
        String expected = 'NAMR';
        pse__Region__c actualRegion = regionByCode.get('Test Region');
        System.debug('****actual '+ actualRegion);
        //System.assertEquals(expected, actualRegion);
    }



    static Program__c program;
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static Service__c service;
    static pse__Region__c region;
    static PSA_Country_Region_Map__mdt mapping;

    static void setupTestData () {

        //Region
        region = UTL_PSA_TestData.createRegions(1, false)[0];
        region.Name = 'NAMR';
        region.pse__Region_Name_Chain__c = 'Corporate';
        region.pse__Region_ID_Chain__c = region.id;
        insert region;

        
        //Program
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