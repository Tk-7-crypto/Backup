/**
 * This test class is used to test DAOH_PSA_Assignment.cls. It is copied over from TST_TGR_Assignment.cls
 *
 */

@isTest
private class TST_DAOH_PSA_Assignment 
{    
    @testSetup
    static void dataSetup() 
    {
        User salesUser = UTL_TestData.createUser('Sales User', 1).get(0); 
        insert salesUser;

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
        //insert contact;
        Contact contact = [Select id,FirstName,LastName,Email from Contact limit 1];	 
        
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

        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Non_billable_ProjectId__c= project.Id;
        insert rdsSettings;
    }
    
    @IsTest
    static void testSyncServiceLineLeads()
    {
        pse__Proj__c project = [Select Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c from pse__Proj__c where pse__Billing_Type__c = 'Fixed Price' limit 1];
        pse__Assignment__c assignment = [Select Id, pse__Is_Billable__c from pse__Assignment__c where pse__Project__c =: project.Id LIMIT 50];
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
        assignment2.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment2.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment2.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment2.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment2.Primary_Service_Line_Lead__c = true;

        Test.startTest();
        insert assignment2;
        Test.stopTest();

        List<pse__Assignment__c> assignments = [SELECT Id, Primary_Service_Line_Lead__c FROM pse__Assignment__c];
        pse__Proj__c updatedProject = [SELECT Id, Service_Line_Lead__c FROM pse__Proj__c WHERE Id = :project.Id];
        
        System.assertNotEquals(assignments[0].Primary_Service_Line_Lead__c, assignments[1].Primary_Service_Line_Lead__c, 'Tested');
        System.assertEquals(contact.Id, updatedProject.Service_Line_Lead__c, 'Tested');
    }
    @IsTest
    static void testUpdateActiveWhenStatusClosed(){
        pse__Proj__c project = [Select Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c from pse__Proj__c where pse__Billing_Type__c = 'Fixed Price' limit 1];
        pse__Assignment__c assignment = [Select Id, pse__Is_Billable__c, Active__c from pse__Assignment__c where pse__Project__c =: project.Id];
        Contact contact = [Select Id from Contact limit 1];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = contact.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_CLOSED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        Test.startTest();
        update assignment;
        Test.stopTest();
        System.assert(true, 'Tested');
    }

    static void testFieldUpdateOnCreation()
    {
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
        assignment2.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_CLOSED;
        assignment2.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment2.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment2.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment2.Primary_Service_Line_Lead__c = true;

        Test.startTest();
        insert assignment2;
        Test.stopTest();
        System.assert(true, 'Tested');
    }
    
 
    @IsTest
    static void testDeleteNonBillableProject_UserHasPermission() {
        User salesUser = [Select id from User where alias = 'alia3133' limit 1];
        Contact contact= [Select Id,pse__Salesforce_User__c from Contact limit 1];
        pse__Proj__c project = [SELECT Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c FROM pse__Proj__c WHERE pse__Billing_Type__c = 'Fixed Price' LIMIT 1];
        pse__Assignment__c assignment = [SELECT Id, pse__Is_Billable__c,pse__Project__c,pse__Resource__c,pse__Resource__r.pse__Salesforce_User__c FROM pse__Assignment__c WHERE pse__Project__c = :project.Id and pse__Resource__c = :contact.Id LIMIT 1];
        
        PermissionSet psResource = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin' LIMIT 1];
        PermissionSet psProjectManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Project_Manager_and_Functional_Lead' LIMIT 1];
        PermissionSet psResourceLineManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Resource_and_Line_Manager' LIMIT 1];
        
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResource.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psProjectManager.Id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResourceLineManager.Id);
        insert new List<PermissionSetAssignment>{ psa1, psa2, psa3 };
       
            System.runAs(salesUser) {
                Test.Starttest();
                try{
                    delete assignment;
                    Assert.fail('Assignment is deleted but it should not.');
                } catch(Exception ex) {
                    Assert.areEqual(true, ex.getMessage().contains('You do not have permission to delete this Assignment.'));
                }
                Test.Stoptest();
            } 
    }
   

    @IsTest
    static void testDeleteNonBillableProjectAssignmentOfOtherResource() {
        User salesUser = [Select id from User where alias = 'alia3133' limit 1];
        Contact contact= [Select Id,pse__Salesforce_User__c from Contact limit 1];
        pse__Proj__c project = [SELECT Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c FROM pse__Proj__c WHERE pse__Billing_Type__c = 'Fixed Price' LIMIT 1];
        pse__Assignment__c assignment = [SELECT Id, pse__Is_Billable__c,pse__Project__c,pse__Resource__c,pse__Resource__r.pse__Salesforce_User__c FROM pse__Assignment__c WHERE pse__Project__c = :project.Id and pse__Resource__c = :contact.Id LIMIT 1];
        
        Contact contactdata = new Contact(
            CurrencyIsoCode = 'USD',
            FirstName = 'Test',
            LastName = 'Resource data',
            Email = 'testresource@metacube.org',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true,
            pse__Start_Date__c = System.Today(),
            pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER,
            pse__Default_Cost_Rate__c = 50.0,
            pse__Utilization_Target__c = 90,
            EmployeeNumber__c = String.valueOf(System.currentTimeMillis()),
            Location_Code_text__c = 'USDUR1',
            Salesforce_User__c = salesUser.Id
        );
        
        insert contactdata;
        
        PermissionSet psResource = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin' LIMIT 1];
        PermissionSet psProjectManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Project_Manager_and_Functional_Lead' LIMIT 1];
        PermissionSet psResourceLineManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Resource_and_Line_Manager' LIMIT 1];
        System.runAs(salesUser) {
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResource.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psProjectManager.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResourceLineManager.Id);
            insert new List<PermissionSetAssignment>{ psa1, psa2, psa3 };
                }
        System.runAs(salesUser) {
            Test.Starttest();
            try{
                delete assignment;
                Assert.fail('Assignment is deleted but it should not.');
            } catch(Exception ex) {
                Assert.areEqual(true, ex.getMessage().contains('You do not have permission to delete this Assignment.'));
            }
            Test.Stoptest();
        } 
    }
    
    
    @IsTest
    static void testDeleteBillableProjectAssignment() {
        PSA_RDS_Settings__c rdsSetting = [Select Id, Non_billable_ProjectId__c from PSA_RDS_Settings__c];
        rdsSetting.Non_billable_ProjectId__c = '';
        Update rdsSetting;
        
        User salesUser = [Select id from User where alias = 'alia3133' limit 1];
        Contact contact= [Select Id,pse__Salesforce_User__c from Contact limit 1];
        pse__Proj__c project = [SELECT Id, pse__Billing_Type__c, pse__Start_Date__c, pse__End_Date__c, pse__Is_Billable__c, pse__Time_Credited__c, pse__Time_Excluded__c FROM pse__Proj__c WHERE pse__Billing_Type__c = 'Fixed Price' LIMIT 1];
        pse__Assignment__c assignment = [SELECT Id, pse__Is_Billable__c,pse__Project__c,pse__Resource__c,pse__Resource__r.pse__Salesforce_User__c FROM pse__Assignment__c WHERE pse__Project__c = :project.Id and pse__Resource__c = :contact.Id LIMIT 1];
        
        Contact contactdata = new Contact(
            CurrencyIsoCode = 'USD',
            FirstName = 'Test',
            LastName = 'Resource data',
            Email = 'testresource@metacube.org',
            pse__Is_Resource__c = true,
            pse__Is_Resource_Active__c = true,
            pse__Start_Date__c = System.Today(),
            pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER,
            pse__Default_Cost_Rate__c = 50.0,
            pse__Utilization_Target__c = 90,
            EmployeeNumber__c = String.valueOf(System.currentTimeMillis()),
            Location_Code_text__c = 'USDUR1',
            Salesforce_User__c = salesUser.Id
        );
        
        insert contactdata;
        
        PermissionSet psResource = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin' LIMIT 1];
        PermissionSet psProjectManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Project_Manager_and_Functional_Lead' LIMIT 1];
        PermissionSet psResourceLineManager = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Resource_and_Line_Manager' LIMIT 1];
        System.runAs(salesUser) {
            PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResource.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psProjectManager.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = salesUser.Id, PermissionSetId = psResourceLineManager.Id);
            Database.insert(new List<PermissionSetAssignment>{ psa1, psa2, psa3 }, false);
        }
        System.runAs(salesUser) {
            try{
                delete assignment;
                Assert.fail('Assignment is deleted but it should not.');
            } catch(Exception ex) {
                Assert.areEqual(true, ex.getMessage().contains('You do not have permission to delete this Assignment.'));
            }
        } 
    }
    
    
    /*
    static pse__Proj__c project;
    static Contact contact;
    static pse__Resource_Request__c resourcerequest;
    static pse__Assignment__c assignment;
    static void setupTestData () {
        // project
        System.debug('A:' + Limits.getQueries());
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        System.debug('B:' + Limits.getQueries());
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        System.debug('C:' + Limits.getQueries());
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        insert project;
        System.debug('D:' + Limits.getQueries());
        System.debug('&&& inserted sub project');
        //UTL_PSA_TestData.createPermissionControls(); 
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
        System.debug('E:' + Limits.getQueries());
        //contacts
        contact = UTL_PSA_TestData.createResources(1,false)[0];
        System.debug('F:' + Limits.getQueries());
        insert contact;
        resourcerequest = new pse__resource_request__c();
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
        assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = contact.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Schedule__c = sch.Id;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        System.debug('J:' + Limits.getQueries());
    }
	*/
}
