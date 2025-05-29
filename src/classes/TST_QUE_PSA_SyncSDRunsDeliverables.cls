@isTest
private class TST_QUE_PSA_SyncSDRunsDeliverables {

    @testSetup static void setup() {
         UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Signal Management',
            Active__c=true,
            Service_Line_Code__c = 'SM');
        insert serviceline;
        
        //service
        Service__c service = new Service__c(Name = 'Signal Detection Run');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
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
        
        pse__Milestone__c serviceMilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id serviceMilestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        serviceMilestone.Name = 'Signal Detection Run';
        serviceMilestone.RecordTypeId = serviceMilestonerecTypeId;
        serviceMilestone.Actual_Quantity__c = 10;
        serviceMilestone.Billed_Quantity__c = 15;
        serviceMilestone.pse__Project__c = project.Id;
        serviceMilestone.pse__Target_Date__c = system.today();
        serviceMilestone.Actual_Amount__c = 20;
        serviceMilestone.pse__Milestone_Amount__c = 100;
        serviceMilestone.Billed_Amount__c = 30;
        serviceMilestone.Include_Tasks_on_Deliverables__c = true;
        serviceMilestone.Service__c = service.id;
        serviceMilestone.Service_Line__c = serviceline.id;
        insert serviceMilestone;
        
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Date_Activated__c = System.today(),
            Countries_NA__c = true
        );
        insert target;
        
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

        UTL_PSA_TestData.createResources(1,false);
        Contact contact = [Select id,FirstName,LastName,Email from Contact limit 1];
       
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
        
        pse__Assignment__c assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = testResource.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Schedule__c = sch.Id;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.Active__c = true;
        assignment.Training_Completed__c = true;
        insert assignment;
        
        
        SD_Runs__c sdrunRec = new SD_Runs__c();
        sdrunRec.Frequency__c = 'Weekly';
        sdrunRec.Project__c = project.id;
        sdrunRec.Product__c = target.id;
        sdrunRec.SD_Run_Unique_ID__c = 'IQVIA-SD-00105';
        sdrunRec.Service_Line_Lead__c = testResource.Id;
        sdrunRec.SM_Specialist__c = testResource.id;
        insert sdrunRec;
        //UTL_PSA_TestData.createSdRun();
    }

    testmethod static void testValidateSDRunFields(){
        Test.startTest(); 
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = true);
        SD_Runs__c sdRec = [SELECT id, SD_Run_Unique_ID__c, Project__c,Frequency__c,Service_Line_Lead__c, SM_Specialist__c from SD_Runs__c limit 1];
        Contact con = [SELECT id from Contact limit 1];
        pse__Assignment__c asg = [Select id, Active__c, pse__Resource__c from pse__Assignment__c limit 1];
        sdRec.Status__c = 'Completed';
        sdRec.SD_Run_Start_Date__c = System.today();
        sdRec.Date_Client_Meeting__c = System.today();
        sdRec.SM_Specialist__c = asg.pse__Resource__c;
        sdRec.Medical_Safety_Advisor__c = con.Id;
        sdRec.SM_QC_Reviewer__c = asg.pse__Resource__c;
        sdRec.BRM_Analyst__c = con.Id;
        sdRec.Date_BRM_Review_Completed__c = System.today();
        sdRec.Link_to_Reviewed_Source__c = 'test';
        sdRec.Name_Reviewed_Source__c = 'test';
        sdRec.Last_SD_Run_for_Product__c = true;
        sdRec.Discussed_in_SMT_Meeting__c = 'Yes (enter date)';
        sdRec.SD_Run_Outcome__c = 'No Action;Potential Signal;Potential Emerging Safety Issue;Other (specify)';
        sdRec.SD_Run_Date_Completed__c = System.today();
        sdRec.SD_Run_Complexity__c = null;
        sdRec.SD_Run_Start_Date__c = Date.newInstance(2030, 3, 4);
        sdRec.SD_Run_Date_Completed__c  = Date.newInstance(2021, 3, 4);
        sdRec.Data_Review_Period_Start_Date__c = Date.newInstance(2030, 3, 4);
        sdRec.Data_Review_Period_End_Date__c =Date.newInstance(2021, 3, 4);
        sdRec.Not_Discussed_in_SMT_Meeting_Reason__c = null;
        sdRec.Date_SMT_Meeting__c = null;
        sdRec.Date_Draft_Sent_for_QC__c = Date.today();
        sdRec.Date_QC_Completed__c = Date.today();
        sdRec.Date_Draft_sent_for_Medical_Review__c = Date.today();
        sdRec.Date_Medical_Review_Completed__c = Date.today();
        sdRec.Date_final_Draft_Ready_for_SMT_Review__c = Date.today();
        update sdRec;  
        System.enqueueJob(new QUE_PSA_SyncSDRunsDeliverables(new List<SD_Runs__c>{sdRec}));
        Test.stopTest();
    }
}
