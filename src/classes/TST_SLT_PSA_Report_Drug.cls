/*
* Version       : 1.0
* Description   : Test Class for SLT_PSA_Report_Drug
*/
@isTest
private class TST_SLT_PSA_Report_Drug {
    
    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_PSA_Report_Drug(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }
    
    @IsTest
    static void testGetAggregateReportsByParentProject(){
        
        setupTestData();
        Test.startTest();
        List<Report_Drug__c> reportDrugList  = new SLT_PSA_Report_Drug(true).getReportDrugsByAggregateReportId(new Set<Id>{sanofiPVSAggReport.Id},new Set<String>{'Drug__r.Name'} );
        Test.stopTest();
        System.assertEquals(1,reportDrugList.size());
    }
    
    
    static void setupTestData () {
        UTL_PSA_TestData.createPermissionControls();
        
        //program
        program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //service line
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
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        testResource.Email = 'test@email.com';
        insert testResource;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.Id;
        insert project;
        
        //milestone
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.Actual_Quantity__c = 10;
        milestone.Billed_Quantity__c = 15;
        milestone.pse__Project__c = project.Id;
        milestone.pse__Target_Date__c = system.today();
        milestone.Actual_Amount__c = 20;
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Billed_Amount__c = 30;
        milestone.Include_Tasks_on_Deliverables__c = false;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceline.id;
        insert milestone;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event';
        insert psaEvent;
        
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;
        
        reportCountry = new Report_Country__c();
        reportCountry.Country__c = 'US';
        
        
        
        //Id sanofiPVSAggRecordID = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosByName().get('Sanofi PVS Report').getRecordTypeId();
        RecordType sanofiPVSReportRecordTypeNameId = [SELECT Id from RecordType where Name='Sanofi PVS Report'];
        sanofiPVSAggReport = new Aggregate_Report__c();
        sanofiPVSAggReport.Project__c = project.Id;
        sanofiPVSAggReport.Client_First_Draft_Due__c = Date.today().addDays(7);
        sanofiPVSAggReport.Primary_Author__c = testResource.Id;
        sanofiPVSAggReport.RecordTypeId = sanofiPVSReportRecordTypeNameId.Id;
        sanofiPVSAggReport.Service_Milestone__c =null;
        sanofiPVSAggReport.Report_Writing__c = null;
        sanofiPVSAggReport.Report_Type__c ='PAER';
        sanofiPVSAggReport.Task_Type__c='Other Activities';
        sanofiPVSAggReport.Activity_DetailsEvent_Name__c='Deliverable';
        sanofiPVSAggReport.IQVIA_Secondary_GSO_NA__c ='NA';
        sanofiPVSAggReport.IQVIA_TAH_NA__c ='NA';
        sanofiPVSAggReport.PVS_GBU_Lead_NA__c ='Yes';
        sanofiPVSAggReport.IQVIA_GSO_LM_NA__c ='Yes';
        sanofiPVSAggReport.IQVIA_Primary_GSO_NA__c='NA';
        insert sanofiPVSAggReport;
        
        //drug
        drug = new Drug__c(Name = 'Test Drug');
        drug.Program__c = program.Id;
        drug.Name = '12345678';
        drug.Service_Lines__c = 'Aggregate Reporting';
        drug.Active__c = true;
        insert drug;
        
        Report_Drug__c rd = new Report_Drug__c();
        rd.Aggregate_Report__c = sanofiPVSAggReport.Id;
        rd.Drug__c = drug.Id;
        rd.Program__c = program.Id;
        insert rd;
        drugMap.put(rd.Name, rd.id);    
    }
    static Drug__c drug;
    static CNT_PSA_CreateDrugReport.WPR_PSA_DetailsWrapper wrapperob;
    static Report_Country__c reportCountry;
    static Aggregate_Report__c sanofiPVSAggReport;
    Static Map<String,String> drugMap = new Map<String,String>();
    Static Program__c program;
}
