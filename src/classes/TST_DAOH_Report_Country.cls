/**
 * This test class is used to test DAOH_Report_Country.cls. It is copied over from TST_TGR_Report_Country.cls
 *
 */
@isTest
private class TST_DAOH_Report_Country {

    @IsTest
    static void testInsertOnReportCountry () {
    
        Test.startTest();
        try{
            setupTestData();
        }catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'expectedExceptionThrown');
        }
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: rc.Id AND Field__c = 'comments__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c,'expectedResult');
        System.assertEquals('comments__c', auditLogAfterInsert.Field__c,'expectedResult');
    } 
    
    @IsTest
    static void testUpdateOnReportCountry () {
        Test.startTest();
        try{
            setupTestData();
            rc.Comments__c='Test Section Updated';
            update rc;
        }catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'UPDATE' AND Field__c = 'comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c,'expectedResult');
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c,'expectedResult');
    
    
    }
    
    @IsTest
    static void testDeleteOnReportCountry () {
    
        Test.startTest();
        try{
            setupTestData();
            rc.Comments__c='Test DELETE';
            rc.License_partner_PVAs__c = null;
            update rc;
            delete rc;
        }catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'expectedExceptionThrown');
        }
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c,'expectedResult');
    
    }
    
    @IsTest
    static void testUnDeleteOnReportCountry () {
        
        Test.startTest();
        try{
            setupTestData();
            delete rc;
            undelete rc;
        }catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'expectedExceptionThrown');
        }
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: rc.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c,'expectedResult');
    
    }
    
    @IsTest
    static void testFieldValidations() {
        UTL_PSA_TestData.createARAndRC();
        Test.startTest();
        try{
            
            Report_Country__c rc = [Select Id, Name from Report_Country__c];
            rc.Actual_Submission_Date__c = Date.today() + 1;
            rc.Report_Due_to_Reg_Agency__c = Date.today() -1;
            rc.License_Partner__c = true;
            rc.License_partner_PVAs__c = 'PVA1';
            update rc;
            }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'expectedExceptionThrown');
        }
        Test.stopTest();
    }

    static Report_Country__c rc; 
    static Report_Country__c rc1; 
    static Aggregate_Report__c sandozAggReport;
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
        sandozAggReport.LL_Review_Due__c = Date.today();
        sandozAggReport.Actual_Date_for_BRM_Completion__c = Date.today();
        sandozAggReport.Actual_Date_for_BRM_Sent__c = Date.today();
        sandozAggReport.Actual_Date_for_Medical_Review_Sent__c = Date.today();
        sandozAggReport.Actual_Date_for_Medical_Review_Cmpltn__c = Date.today();
        sandozAggReport.Actual_Date_for_QC_Completion__c = Date.today();
        sandozAggReport.Actual_Date_for_QC_Sent__c = Date.today();
        sandozAggReport.Actual_Final_Draft_Comments_Due__c = Date.today();
        sandozAggReport.Actual_First_Draft_Comments_Due__c = Date.today();
        sandozAggReport.Date_Submitted_to_IQVIA_or_Client_Reg__c = Date.today();
        sandozAggReport.PreStrategy_Actual_Date__c = Date.today();
        sandozAggReport.Client_Final_Draft_Sent__c = Date.today();
        sandozAggReport.Client_First_Draft_Sent__c = Date.today();
        sandozAggReport.First_RTR_Actual_Date__c = Date.today();
        sandozAggReport.LL_QC_Due_Date__c = Date.today();
        sandozAggReport.Second_RTR_Actual_Date__c = Date.today();
        sandozAggReport.Strategy_Planning_Mtg_Actual_Date__c = Date.today();
        sandozAggReport.LL_Review_Completion_Date__c = Date.today();
        sandozAggReport.Planned_Date_for_Medical_Review_Sent__c = Date.today();
        sandozAggReport.Plnnd_Date_for_Medical_Review_Cmpltn__c = Date.today();
        sandozAggReport.Planned_Date_for_QC_Completion__c = Date.today();
        sandozAggReport.Planned_Date_for_QC_Sent__c = Date.today();
        sandozAggReport.Planned_Final_Draft_Comments_Due__c = Date.today();
        sandozAggReport.Planned_First_Draft_Comments_Due__c = Date.today();
        sandozAggReport.Report_Due_to_IQVIA_or_Client_Reg__c = Date.today();
        sandozAggReport.PreStrategy_Planned_Date__c = Date.today();
        sandozAggReport.Client_Final_Draft_Due__c = Date.today();
        sandozAggReport.Client_First_Draft_Due__c = Date.today();
        sandozAggReport.First_RTR_Planned_Date__c = Date.today();
        sandozAggReport.LL_QC_Completion_Date__c = Date.today();
        sandozAggReport.Second_RTR_Planned_Date__c = Date.today();
        sandozAggReport.Strategy_Planning_Mtg_Planned_Date__c = Date.today();
        sandozAggReport.Planned_Date_for_BRM_Completion__c = Date.today();
        sandozAggReport.Planned_Date_for_BRM_Sent__c = Date.today();
        sandozAggReport.Actual_Date_Final_LL_Requested_NA__c = 'No';
        sandozAggReport.Actl_Dte_Pblshng_Task_Cmpltn_Dte_NA__c = 'No';
        sandozAggReport.Actual_Date_for_BRM_Completion_NA__c = 'No';
        sandozAggReport.Actual_Date_for_BRM_Sent_NA__c = 'No';
        sandozAggReport.Actual_Date_for_Final_GSO_Review_NA__c = 'No';
        sandozAggReport.Actual_date_for_First_GSO_Rvw_Cmpltn_NA__c = 'No';
        sandozAggReport.Actual_date_for_Last_GSO_Rvw_Cmpltn_NA__c = 'No';
        sandozAggReport.Actual_Date_for_Medical_Review_Cmpltn_NA__c = 'No';
        sandozAggReport.Actual_Date_for_Medical_Review_Sent_NA__c = 'No';
        sandozAggReport.Actual_Date_for_QC_Completion_NA__c = 'No';
        sandozAggReport.Actual_Date_for_QC_Sent_NA__c = 'No';
        sandozAggReport.Actual_date_for_Second_GSO_Review_NA__c = 'No';
        sandozAggReport.Actual_date_for_Second_GSO_Rvw_Cmpltn_NA__c = 'No';
        sandozAggReport.Actual_Date_Sent_to_GSO_NA__c = 'No';
        sandozAggReport.Actual_Date_Sent_to_IQVIA_TAH_NA__c = 'No';
        sandozAggReport.Actual_Date_to_Request_Draft_LL_NA__c = 'No';
        sandozAggReport.Actual_Dt_Draft_LL_to_Author_ClientNA__c = 'No';
        sandozAggReport.Actual_Final_Draft_Comments_Due_NA__c = 'No';
        sandozAggReport.Actual_Date_Final_LL_Requested_NA__c = 'No';
        sandozAggReport.Actual_First_Draft_Comments_Due_NA__c = 'No';
        sandozAggReport.CFI_prestrat_Mtg_agenda_date_sentNA__c = 'No';
        sandozAggReport.Client_Final_Draft_Due_NA__c = 'No';
        sandozAggReport.Client_Final_Draft_Sent_NA__c = 'No';
        sandozAggReport.Client_First_Draft_Due_NA__c = 'No';
        sandozAggReport.Client_First_Draft_Sent_NA__c = 'No';
        sandozAggReport.Coordinator_NA__c = 'No';
        sandozAggReport.Data_Lock_Point_NA__c = 'No';
        sandozAggReport.Date_esignatures_obtained_NA__c = 'No';
        
        sandozAggReport.Date_final_report_published_NA__c = 'No';
        sandozAggReport.Date_for_fnl_rprt_pblshng_in_EDMS_due_NA__c = 'No';
        sandozAggReport.Date_for_IQVIA_to_obtain_esignatures_NA__c = 'No';
        insert sandozAggReport;
        
        rc = new Report_Country__c();
        rc.Aggregate_Report__c = sandozAggReport.Id;
        rc.Comments__c = 'Test Section INSERT';
        rc.License_Partner__c = false;
        rc.Report_Due_to_Reg_Agency__c = system.today();
        rc.Actual_Submission_Date__c = system.today()+1;
        rc.Submitted_to_Reg_Late_Reason__c = null;
        insert rc;
        
        rc1 = new Report_Country__c();
        rc1.Aggregate_Report__c = sandozAggReport.Id;
        rc1.Comments__c = 'Test Section INSERT';
        rc1.License_Partner__c = false;
        rc1.Report_Due_to_Reg_Agency__c = system.today();
        rc1.Actual_Submission_Date__c = system.today()+1;
        rc1.Submitted_to_Reg_Late_Reason__c = null;
        rc1.License_partner_PVAs__c = null;
        insert rc1;
    }
}
