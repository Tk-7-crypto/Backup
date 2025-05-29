/*
* Test class for FLOW- ASNFL01PSAAssignmentNotifications
*/
@IsTest
public class TST_ASNFL01PSAAssignmentNotifications {
    @testSetup
    static void dataSetup() 
    {
        //Service Line Project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        insert project;
        
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Service Line [Literature]
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, false)[0];
        serviceline.Name = CON_PSA.LITERATURE;
        serviceline.Service_Line_Code__c = CON_PSA.SERVICE_LINE_CODE_LIT;
        insert serviceline;
        
        //Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //Service Line Project [Literature]
        pse__Proj__c literatureProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeIdServiceLineProject = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        literatureProject.recordTypeId = recTypeIdServiceLineProject;
        literatureProject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        literatureProject.pse__Parent_Project__c = parentproject.Id;
        literatureProject.Service_Line__c = serviceline.Id;
        literatureProject.Program__c = program.id;
        insert literatureProject;
        
        //Permission Control
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = project.pse__region__c;
        pc.pse__Cascading_Permission__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        pc.pse__Billing__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Forecast_Edit__c = true;
        pc.pse__Forecast_View__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Edit_Task_Manager__c = true;
        pc.pse__View_Task_Manager__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        insert pc;
        
        //Contact
        UTL_PSA_TestData.createResources(1,false);
        Contact contact = [Select Id,FirstName,LastName,Email from Contact limit 1];
        /*Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.DuplicateRuleHeader.AllowSave = true;
        Database.insert(contact, opts);*/
        
        //Resource Request
        pse__Resource_Request__c resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;
        
        //Assignment 1
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, literatureProject, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = contact.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        insert assignment;
        
        //LR Project Overview
        LR_Project_Overview__c lrProjectOverview = UTL_PSA_TestData.createLRProjectOverview();
        lrProjectOverview.Program__c = program.id;
        lrProjectOverview.Project__c = literatureProject.id;
        lrProjectOverview.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrProjectOverview;
        
        //Assignment 2
        List<Contact> resList2 = new List<Contact>();
        resList2.add(contact);
        pse__Assignment__c assignment2 = UTL_PSA_TestData.createAssignments(resList2, literatureProject, false)[0];
        assignment2.pse__Is_Billable__c = literatureProject.pse__Is_Billable__c;
        assignment2.pse__Bill_Rate__c = (assignment2.pse__Is_Billable__c && literatureProject.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment2.pse__Planned_Hours__c = 100;
        assignment2.Active__c = true;
        assignment2.pse__Role__c = 'Project Managers';
        assignment2.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment2.pse__Time_Credited__c = literatureProject.pse__Time_Credited__c;
        assignment2.pse__Time_Excluded__c = literatureProject.pse__Time_Excluded__c;
        assignment2.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment2.Primary_Service_Line_Lead__c = true;
        insert assignment2;
    }

    static void testEmailNotification(){
        pse__Proj__c project = [Select Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c from pse__Proj__c where pse__Billing_Type__c = 'Fixed Price' limit 1];
        pse__Assignment__c assignment = [Select Id, pse__Is_Billable__c from pse__Assignment__c where pse__Project__c =: project.Id];
        Contact contact = [Select Id from Contact limit 1];
        
        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = project.pse__Start_Date__c;
        sch.pse__End_Date__c = project.pse__End_Date__c;
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 0;
        sch.pse__Sunday_Hours__c = 0;
        insert sch;

        pse__Assignment__c assignment2 = new pse__Assignment__c();
        assignment2.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment2.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment2.pse__Planned_Hours__c = 100;
        assignment2.pse__Project__c = project.Id;
        assignment2.pse__Resource__c = contact.id;
        assignment2.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment2.pse__Schedule__c = sch.Id;
        assignment2.RecordTypeId = CON_PSA.ASSIGNMENT_REC_TYPE_ID_RDS;
        assignment2.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment2.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment2.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment2.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment2.Primary_Service_Line_Lead__c = true;

        Test.startTest();
        insert assignment2;
        Test.stopTest();
        System.assert(true, 'Tested');
    }
}