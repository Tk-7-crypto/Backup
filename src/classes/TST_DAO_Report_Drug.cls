/**
 * This test class is used to test Report Drug Trigger.
 * This is the main Test class for Report Drug Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Report_Drug.cls as well as TST_DAOH_Report_Drug.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
@isTest
public class TST_DAO_Report_Drug {
    @IsTest
    static void testInsertOnReportDrug () {
    
        Test.startTest();
        setupTestData();
        // report drug to Insert
        insert reportDrug;
        Test.stopTest();
        
        // Validate that agg report field was updated
        Report_Drug__c reportDrug = [SELECT Id, Name, Drug__r.Name, Aggregate_Report__c from Report_Drug__c LIMIT 1];
        Id relatedAggReport = reportDrug.Aggregate_Report__c;
        List<Aggregate_Report__c> arsAfterInsert = [SELECT Id, Sanofi_Products__c from Aggregate_Report__c where Id=: relatedAggReport];
        System.assertEquals(reportDrug.Drug__r.Name, arsAfterInsert[0].Sanofi_Products__c);
    }
    
    @IsTest
    static void testUpdateOnReportDrug () {
        Test.startTest();
        setupTestData();
        
        // update agg report on reportDrug
        insert reportDrug;
        Program__c programRecord = [SELECT Id, Name from Program__c LIMIT 1];
        Drug__c newDrug = new Drug__c(Name='Updated Drug');
        newDrug.Program__c = programRecord.Id;
        newDrug.Service_Lines__c = 'Aggregate Reporting';
        insert newDrug;
        reportDrug.Drug__c = newDrug.id;
        update reportDrug;
        Test.stopTest();
        
        // Validate that agg report field was updated
        Id relatedAggReport = reportDrug.Aggregate_Report__c;
        Report_Drug__c reportDrug = [SELECT Id, Drug__r.Name, Aggregate_Report__c from Report_Drug__c LIMIT 1];
        List<Aggregate_Report__c> arsAfterUpdate = [SELECT Id, Sanofi_Products__c from Aggregate_Report__c where Id =: relatedAggReport ];
        System.assertEquals(reportDrug.Drug__r.Name, arsAfterUpdate[0].Sanofi_Products__c);
    }
    
    @IsTest
    static void testDeleteOnReportDrug () {
    
        Test.startTest();
        setupTestData();
        insert reportDrug;
        Report_Drug__c reportDrug = [SELECT Id, Drug__r.Name, Aggregate_Report__c from Report_Drug__c LIMIT 1];
        String rdName = reportDrug.Drug__r.Name;
        delete reportDrug;
        Test.stopTest();
        // Validate that agg report field was deleted
        Id relatedAggReport = reportDrug.Aggregate_Report__c;
        List<Aggregate_Report__c> arsAfterUpdate = [SELECT Id, Sanofi_Products__c from Aggregate_Report__c where Id =: relatedAggReport];
        System.assertNotEquals(rdName, arsAfterUpdate[0].Sanofi_Products__c);
    }

    //static Aggregate_Report__c ar; 
    static Report_Drug__c reportDrug; 

    static void setupTestData () {
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Aggregate Reporting',
            Active__c=true,
            Service_Line_Code__c = 'AR');
        insert serviceline;

        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;

        //Contact
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;

        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false);
        assignments[0].pse__Bill_Rate__c = 200;
        assignments[0].Sub_role__c = 'IQVIA TAH';
        system.debug('Assignments: ');
        system.debug(assignments);
        insert assignments;
        
        RecordType recordId = [SELECT Id from RecordType where Name='Sanofi GSO Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.IQVIA_TAH__c = testResource.Id;
        ar.RecordTypeId = recordId.Id;
        insert ar;
        
        Drug__c drug = new Drug__c(Name = 'Test');
        drug.Program__c = program.Id;
        drug.Service_Lines__c = 'Aggregate Reporting';
        insert drug;
        
        reportDrug = new Report_Drug__c(Aggregate_Report__c = ar.id, Drug__c = drug.id);
        reportDrug.Program__c = program.Id;
    }
}
