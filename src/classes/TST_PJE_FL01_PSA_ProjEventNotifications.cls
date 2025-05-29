/**
 * This test class is used to test PJE_FL01_PSA_Project_Event_Notifications.flow.
 *
 */
@isTest
private class TST_PJE_FL01_PSA_ProjEventNotifications{
    static Aggregate_Report__c ar;
    static Aggregate_Report__c sandozAggReport;
    static Aggregate_Report__c raAgReport;
    static Report_Country__c reportCountry;

    static void setupTestData () {
        UTL_PSA_TestData.createPermissionControls();

        //program
        Program__c program = new Program__c(Name = 'TestProgram');
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

        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        ar = new Aggregate_Report__c();
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.Report_Countries_Required__c = 'Yes';
        ar.RecordTypeId = recordId.Id;
        ar.Service_Milestone__c = milestone.Id;
        ar.Report_Writing__c = null;
        DAOH_Aggregate_Report.makeReportValid(ar);
        ar.Report_Writing__c = 'IQVIA';
        ar.Primary_QC_Reviewer__c = testResource.Id;
        ar.Secondary_QC_Reviewer__c = testResource.Id;
        ar.Primary_BRM_Analyst__c = testResource.Id;
        ar.Secondary_BRM_Analyst__c = testResource.Id;
        ar.Primary_Medical_Reviewer__c = testResource.Id;
        ar.Secondary_Medical_Reviewer__c = testResource.Id;
        ar.Coordinator__c = testResource.Id;
        ar.Line_Listing_Reviewer__c = testResource.Id;
        ar.Line_Listing_QCer__c = testResource.Id;
        ar.Secondary_Author__c = testResource.Id;
        
        //sandoz report
        Id sandozRecordId = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosByName().get('Sandoz Report').getRecordTypeId();
        sandozAggReport = new Aggregate_Report__c();
        sandozAggReport.Status__c = 'Assigned';
        sandozAggReport.Project__c = project.Id;
        sandozAggReport.Client_First_Draft_Due__c = Date.today().addDays(7);
        sandozAggReport.Primary_Author__c = testResource.Id;
        sandozAggReport.RecordTypeId = sandozRecordId;
        sandozAggReport.Service_Milestone__c = milestone.Id;
        sandozAggReport.Report_Writing__c = null;
        sandozAggReport.Planned_date_CFI_prestrat_Mtg_agenda__c = Date.today();
        sandozAggReport.Planned_date_CFI_prestrat_Mtg_agendaNA__c = 'Yes';
        sandozAggReport.Pre_strat_minutes_sent_actual_date__c = null;
        sandozAggReport.Pre_strat_minutes_sent_actual_date_NA__c = 'No';
        sandozAggReport.Planned_Date_for_QC_Completion__c = Date.today();
        sandozAggReport.Planned_Date_for_QC_Completion_NA__c = 'Yes';
        sandozAggReport.Planned_Date_for_QC_Sent__c = null;
        sandozAggReport.Planned_Date_for_QC_Sent_NA__c = 'No';
        sandozAggReport.Planned_Date_for_Medical_Review_Sent__c = Date.today();
        sandozAggReport.Plnnd_Date_for_Medical_Review_Cmpltn__c = Date.today();
        sandozAggReport.Report_Due_to_IQVIA_or_Client_Reg__c = Date.today();
        sandozAggReport.Date_Submitted_to_IQVIA_or_Client_Reg__c = Date.today();
        sandozAggReport.Report_Due_to_Reg_Agency__c = Date.today(); 
        sandozAggReport.Report_Type__c ='PAER';
        
        insert sandozAggReport;
        //drug
        Drug__c drug = new Drug__c(Name = 'Test Drug');
        drug.Program__c = program.Id;
        drug.Name = '12345678';
        drug.Service_Lines__c = 'Aggregate Reporting';
        insert drug;
        
        raAgReport = new Aggregate_Report__c();
        raAgReport.Project__c = project.Id;
        raAgReport.Client_First_Draft_Due__c = Date.today().addDays(7);
        raAgReport.Product_Name_Active_Ingredient__c = drug.Id;
        raAgReport.RecordTypeId = recordId.Id;
        raAgReport.Primary_Report__c = ar.Id;
        raAgReport.Service_Milestone__c = milestone.Id;
        DAOH_Aggregate_Report.makeReportValid(raAgReport);
    }
    @IsTest
    static void testSendEmailNotification(){
        Test.startTest();
        setupTestData();    
        insert ar;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event';
        insert psaEvent;
        try{
            Aggregate_Report__c aggRep = [SELECT id,Client_First_Draft_Due__c from Aggregate_Report__c limit 1];
            Project_Event__c pje = new Project_Event__c();
            pje.Report__c = aggRep.id;
            pje.Event_Due_Date__c = aggRep.Client_First_Draft_Due__c;
            pje.Primary_Resource__c = aggRep.Primary_Author__c;
            pje.PSA_Event__c = psaEvent.id;
            pje.Event_Actual_Date__c = null;
            pje.Event_Due_Date__c = system.today();
            insert pje;
            
            aggRep.Client_First_Draft_Due__c = Date.newInstance(2021, 8, 4);
            update aggRep;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }

}