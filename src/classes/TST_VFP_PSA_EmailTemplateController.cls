/**
 * This test class is used to test the VFP_PSA_EmailTemplateController
 */
@isTest
public class TST_VFP_PSA_EmailTemplateController {
    @isTest
    static void testGetProjectEventsByReport(){
        Test.startTest();
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
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Sent__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event'; 
        psaEvent.Actual_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Send_Missed_Due_Date_Notification__c = true;
        insert psaEvent;

        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;


        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Sent__c = Date.today().addDays(-3);
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
        insert ar;
        
        Aggregate_Report__c ar1 = new Aggregate_Report__c();
        ar1.Project__c = project.Id;
        ar1.Client_First_Draft_Sent__c = Date.today().addDays(-5);
        ar1.Primary_Author__c = testResource.Id;
        ar1.Project_Files_SMP__c = 'http://salesforce.com';
        ar1.Client_Final_Report__c = 'http://salesforce.com';
        ar1.Report_Countries_Required__c = 'Yes';
        ar1.RecordTypeId = recordId.Id;
        ar1.Service_Milestone__c = milestone.Id;
        ar1.Report_Writing__c = null;
        DAOH_Aggregate_Report.makeReportValid(ar1);
        ar1.Report_Writing__c = 'IQVIA';
        ar1.Primary_QC_Reviewer__c = testResource.Id;
        ar1.Secondary_QC_Reviewer__c = testResource.Id;
        ar1.Primary_BRM_Analyst__c = testResource.Id;
        ar1.Secondary_BRM_Analyst__c = testResource.Id;
        ar1.Primary_Medical_Reviewer__c = testResource.Id;
        ar1.Secondary_Medical_Reviewer__c = testResource.Id;
        ar1.Coordinator__c = testResource.Id;
        ar1.Line_Listing_Reviewer__c = testResource.Id;
        ar1.Line_Listing_QCer__c = testResource.Id;
        ar1.Secondary_Author__c = testResource.Id;
        ar1.Prior_Primary_Medical_Reviewer_Email__c = testResource.email;
        ar1.Prior_Secondary_Medical_Reviewer_Email__c = testResource.email;
        insert ar1;
        
        Test.stopTest();
        VFP_PSA_EmailTemplateController ob = new VFP_PSA_EmailTemplateController();
        ob.recordId = ar1.Id;
        ob.fieldName = 'Primary_Medical_Reviewer__c';
		ob.getEmailBody();
        
        VFP_PSA_EmailTemplateController ob1 = new VFP_PSA_EmailTemplateController();
        ob1.recordId = ar1.Id;
        ob1.fieldName = 'Secondary_Medical_Reviewer__c';
	ob1.getEmailBody();
        
        List<Project_Event__c> ProjectEventList = [Select id From Project_Event__c];
        VFP_PSA_EmailTemplateController ob2 = new VFP_PSA_EmailTemplateController();
        ob2.recordId = ProjectEventList[0].Id;
        ob2.fieldName = 'Late SARA Report';
		ob2.getEmailBody();
        
        VFP_PSA_EmailTemplateController ob3 = new VFP_PSA_EmailTemplateController();
        ob3.recordId = ProjectEventList[0].Id;
        ob3.fieldName = 'DUE DATE ALERT';
		ob3.getEmailBody();
        System.assertNOTEquals(0, ProjectEventList.Size());
    }
}
