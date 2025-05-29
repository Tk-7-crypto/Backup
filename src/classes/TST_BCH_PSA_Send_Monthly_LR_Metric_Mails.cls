/**
* Test class for BCH_PSA_Send_Monthly_LR_Metric_Mails
*/
@IsTest
public class TST_BCH_PSA_Send_Monthly_LR_Metric_Mails {
    @testSetup
    static void setupTestData(){
        
        test.startTest();
        
        //contact
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        insert contact;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Project_Code__c ='12345';
        insert parentproject;
        
        //Service Line
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line__c = serviceline.Id;
        project.Service_Line_Lead__c = contact.id;
        insert project;
        
        Service_Line__c pvsServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST2',
            Name = 'PV Solutions'
        );
        insert pvsServiceLine;
        
        pse__Proj__c pvsProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'PV Solutions Project', false);
        pvsProject.Service_Line__c = pvsServiceLine.Id;
        pvsProject.pse__Parent_Project__c = parentproject.id;
        Id recTypeId1 = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        pvsProject.recordTypeId = recTypeId1;
        pvsProject.pse__Project_Status__c = 'Start-up';
        pvsProject.pse__Project_Manager__c = contact.id;
        pvsProject.Service_Line_Lead__c = contact.id;
        insert pvsProject;
        
        Program__c program = UTL_PSA_TestData.programs[0];
        
        Account account = UTL_PSA_TestData.accounts[0]; 
        
        Drug__c prod = new Drug__c(
            Name = 'testProduct', 
            Program__c = program.id,
            Active__c = true,
            Service_Lines__c = 'Literature');
        insert prod;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = account.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert eventJournal;
        
        LR_Project_Overview__c lrRec2 = UTL_PSA_TestData.createLRProjectOverview();
        lrRec2.Program__c = program.id;
        lrRec2.Account__c = account.id;
        lrRec2.Project__c = project.id;
        lrRec2.Product__c = prod.id;
        lrRec2.Status__c = CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED;
        lrRec2.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        lrRec2.Date_this_LR_Project_Completed__c = Date.today().addMonths(-1).toStartOfMonth();
        insert lrRec2;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Object__c = 'LR_Project_Overview__c';
        psaEvent.Planned_Date_Field__c = 'LR_LBI_Period_Stop_Date__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'DLP 30 days approaching email trigger';
        psaEvent.Send_Missed_Due_Date_Noti_Offset__c = 1;
        insert psaEvent;
        
        Project_Event__c pje = new Project_Event__c();
        pje.Project__c = project.id;
        pje.PSA_Event__c = psaEvent.id;
        pje.LR_Project_Overview__c = lrRec2.id;
        pje.Notification_Date__c = DATE.today();
        pje.Event_Due_Date__c = Date.today().addDays(-1);
        insert pje;
        
        List<Id> userIds = new List<Id>();
        userIds.add(UserInfo.getUserId());
        pse__region__c rgn = [SELECT Id, Name from pse__region__c WHERE Id = :project.pse__region__c LIMIT 1];
        
        pse__Permission_Control__c pc = UTL_PSA_TestData.createPermissionControls(userIds, rgn, false)[0]; 
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
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
        
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
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
       
        
        //Assignment
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, project, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Role__c = CON_PSA.SPECIALIST_JUNIOR_ROLE;
        assignment.Sub_role__c = CON_PSA.LIT_SARA_SUB_ROLE;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.pse__Project__c = project.id;
        insert assignment;
        test.stopTest();
        
        List<Contact> resList1 = new List<Contact>();
        resList1.add(contact);
        pse__Assignment__c assignment1 = UTL_PSA_TestData.createAssignments(resList1, pvsProject, false)[0];
        assignment1.pse__Is_Billable__c = pvsProject.pse__Is_Billable__c;
        assignment1.pse__Bill_Rate__c = (assignment1.pse__Is_Billable__c && pvsProject.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment1.pse__Planned_Hours__c = 100;
        assignment1.pse__Role__c = CON_PSA.SRVC_LINE_LEAD_ROLE;
        assignment1.Sub_role__c = CON_PSA.LIT_SARA_LEAD_SUB_ROLE;
        assignment1.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment1.pse__Time_Credited__c = pvsProject.pse__Time_Credited__c;
        assignment1.pse__Time_Excluded__c = pvsProject.pse__Time_Excluded__c;
        assignment1.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment1.Primary_Service_Line_Lead__c = true;
        assignment1.pse__Project__c = pvsProject.id;
        insert assignment1;
        
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.LR_failed_batches_email_ids__c = 'ronak.kumpawat@iqvia.com';
        insert rdsSettings;
    }
    
    @isTest
    static void testExecuteBatch(){
        test.startTest();
        Database.executeBatch(new BCH_PSA_Send_Monthly_LR_Metric_Mails());
        test.stopTest();
        System.assertEquals(2, [select count() from pse__Assignment__c where pse__Planned_Hours__c = 100], 'Assignment Inserted');
    }
    
}
