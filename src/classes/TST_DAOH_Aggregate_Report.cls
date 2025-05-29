/**
 * This test class is used to test DAOH_Aggregate_Report.cls. It is copied over from TST_TGR_Aggregate_Report.cls
 *
 */
@isTest
private class TST_DAOH_Aggregate_Report {

    @IsTest
    static void testInsertOnAggregateReport () {
        Test.startTest();
        setupTestData();
        ar.Comments__c='Test Comment INSERT';
        // ar to Insert
        insert ar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with INSERT Operation
        Audit_Log__c auditLogAfterInsert = [SELECT Object__c,Operation__c,Field__c from Audit_Log__c where Record_ID__c=: ar.Id AND Field__c = 'comments__c'];
        System.assertEquals('INSERT', auditLogAfterInsert.Operation__c,true);
        System.assertEquals('comments__c', auditLogAfterInsert.Field__c, true);
    } 
    
    @IsTest
    static void testUpdateOnAggregateReport () {
        Test.startTest();
        setupTestData();
        ar.Comments__c='Test Comment UPDATE';
        insert ar;
        ar.Comments__c='Test Comment Updated';
        
        // ar to Insert
        update ar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterUpdate = [SELECT Object__c,Operation__c,New_Value__c,Field__c from Audit_Log__c where Record_ID__c =: ar.Id AND Operation__c = 'UPDATE' AND Field__c = 'comments__c' ];
        System.assertEquals('UPDATE', auditLogAfterUpdate.Operation__c, true);
        System.assertEquals('comments__c', auditLogAfterUpdate.Field__c, true);
    }
    
    @IsTest
    static void testDeleteOnAggregateReport () {
    
        Test.startTest();
        setupTestData();
        ar.Comments__c='Test Comment DELETE';
        ar.Delete_Reason__c = 'Test';
        insert ar;
        delete ar;
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UPDATE Operation
        Audit_Log__c auditLogAfterDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: ar.Id AND Operation__c = 'DELETE'];
        System.assertEquals('DELETE', auditLogAfterDelete.Operation__c, true);
        }
    
    @IsTest
    static void testUnDeleteOnAggregateReport () {
    
        Test.startTest();
        setupTestData();
        ar.Comments__c='Test Comment UNDELETE';
        ar.Delete_Reason__c = 'Test';
        insert ar;
        
        delete ar;
        undelete ar;
    
        Test.stopTest();
        // Validate if a record was inserted in Audit log with UNDELETE Operation
        Audit_Log__c auditLogAfterUnDelete = [SELECT Object__c,Operation__c,New_Value__c from Audit_Log__c where Record_ID__c =: ar.Id AND Operation__c = 'UNDELETE'];
        System.assertEquals('UNDELETE', auditLogAfterUnDelete.Operation__c, true);
    
    }

    @IsTest
    static void testReportCompletionAndValidation(){
        setupTestData();
        insert ar;
        reportCountry.Aggregate_Report__c = ar.Id;
        insert reportCountry;
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Send_aggregate_report_validation_emails__c = true;
        insert rdsSettings;

        Test.startTest();
        ar.Status__c = 'Completed';
        ar.Client_Final_Report__c = 'test';
        ar.Report_Therapeutic_Area__c = 'Dermatology';
        ar.Report_Countries_Required__c ='Yes';
        ar.Product_Name_Active_Ingredient__c = null;
        ar.Customer_Requested_Resource_Location__c = 'ALL2';
        ar.Safety_Database_Location__c = 'IQVIA';
        ar.Report_Size__c = 'Small';
        ar.No_of_riskssignalsindication__c = 2 ;
        ar.Report_Due_to_IQVIA_or_Client_Reg__c = system.today();
        ar.Date_Submitted_to_IQVIA_or_Client_Reg__c = system.today();
        ar.Report_Due_to_Reg_Agency__c = system.today();
        ar.Formatting_Request__c = 'Yes';
        ar.Upload_to_eTMF_Wingspan_Client_Spec_Repo__c = 'Yes';
        ar.Project_Files_SMP__c = 'test';
        ar.Client_Final_Report__c = 'test';
        ar.eTMF_Wingspan_Client_Spec_Repo_File_Stat__c = 'Completed';
        
        ar.Planned_Date_to_Request_Draft_LL_NA__c = 'No';
        ar.Actual_Date_to_Request_Draft_LL_NA__c = 'No';
        ar.Draft_LL_Request_Ticket_Number_NA__c = 'No';
        ar.Plnnd_Dt_Draft_LL_to_Author_Client_NA__c = 'No';
        ar.Actual_Dt_Draft_LL_to_Author_ClientNA__c = 'No';
        ar.Final_Listings_Ticket_Number_NA__c = 'No';
        ar.Plnnd_Date_Final_LL_to_Author_ClientNA__c = 'No';
        
        QC_Tracker_Result__c qcTrackerResult;
        qcTrackerResult = new QC_Tracker_Result__c();
        qcTrackerResult.REP_QC_ID__c = 'QCID-1223';
        qcTrackerResult.Aggregate_Report__c = ar.id;
        qcTrackerResult.Name = '12345';
        qcTrackerResult.Date_Deleted__c = null;
        insert qcTrackerResult;
        
        try{
        update ar;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testReportNegativeCompletionAndValidation(){
        setupTestData();
        insert ar;
        reportCountry.Aggregate_Report__c = ar.Id;
        insert reportCountry;
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Send_aggregate_report_validation_emails__c = true;
        insert rdsSettings;

        Test.startTest();
        ar.Status__c = null;
        ar.Client_Final_Report__c = null;
        ar.Report_Therapeutic_Area__c = null;
        ar.Report_Countries_Required__c = null;
        ar.Product_Name_Active_Ingredient__c = null;
        ar.Customer_Requested_Resource_Location__c = null;
        ar.Safety_Database_Location__c = null;
        ar.Report_Size__c = null;
        ar.No_of_riskssignalsindication__c = null ;
        ar.Report_Due_to_IQVIA_or_Client_Reg__c = null;
        ar.Date_Submitted_to_IQVIA_or_Client_Reg__c = null;
        ar.Report_Due_to_Reg_Agency__c = null;
        ar.Formatting_Request__c = null;
        ar.Upload_to_eTMF_Wingspan_Client_Spec_Repo__c = null;
        ar.Project_Files_SMP__c = null;
        ar.Client_Final_Report__c = null;
        ar.eTMF_Wingspan_Client_Spec_Repo_File_Stat__c = null;
        ar.Planned_Date_to_Request_Draft_LL_NA__c = null;
        ar.Actual_Date_to_Request_Draft_LL_NA__c = null;
        ar.Draft_LL_Request_Ticket_Number_NA__c = null;
        ar.Plnnd_Dt_Draft_LL_to_Author_Client_NA__c = null;
        ar.Actual_Dt_Draft_LL_to_Author_ClientNA__c = null;
        ar.Final_Listings_Ticket_Number_NA__c = null;
        ar.Plnnd_Date_Final_LL_to_Author_ClientNA__c = null;
        try{
        update ar;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testFieldValidation(){
        setupTestData();
        insert ar;
        reportCountry.Aggregate_Report__c = ar.Id;
        insert reportCountry;
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Send_aggregate_report_validation_emails__c = true;
        insert rdsSettings;

        Test.startTest();
        try{
            ar.Date_Submitted_to_IQVIA_or_Client_Reg__c = System.today();
            ar.Report_Due_to_IQVIA_or_Client_Reg__c = System.today() - 1;
            update ar;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }

    static Aggregate_Report__c ar;
    static Aggregate_Report__c sandozAggReport;
    static Aggregate_Report__c raAgReport;
    static Report_Country__c reportCountry;
    static Aggregate_Report__c sanofiPVSAggReport;


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
        
        PSA_Default_Value_Set_Setting__c customsetting = new PSA_Default_Value_Set_Setting__c();
        customsetting.Name = 'Test';
        customsetting.Record_Type__c = 'Sandoz Report';
        customsetting.Report_Type__c ='PAER';
        customsetting.Planned_Date_Field__c ='Planned_Date_to_Request_Draft_LL_NA__c';
        customsetting.Actual_Date_Field__c ='Actual_Date_to_Request_Draft_LL_NA__c';
        customsetting.Planned_Date_Field_Value__c ='No';
        customsetting.Actual_Date_Field_Value__c ='No';
        insert customsetting;
        
    }
    
    @IsTest
    static void testupdtRltdPJEToUpdtReciepients(){
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
            insert pje;
            
            aggRep.Client_First_Draft_Due__c = Date.newInstance(2021, 8, 4);
            update aggRep;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }
        
    @IsTest
    static void testUpdateFieldsforEmailAlerts () {
        setupTestData();
        insert ar;
        
        RecordType contactRT = [SELECT Id from RecordType where Name ='IQVIA User Contact'];
        Contact con = UTL_PSA_TestData.createResources(1,false)[0];
        con.RecordTypeId = contactRT.Id;
        con.Email = 'test2@email.com';
        insert con;
        
        Test.startTest();
        ar.Primary_QC_Reviewer__c = con.Id;
        ar.Secondary_QC_Reviewer__c = con.Id;
        ar.Primary_BRM_Analyst__c = con.Id;
        ar.Secondary_BRM_Analyst__c = con.Id;
        ar.Primary_Medical_Reviewer__c = con.Id;
        ar.Secondary_Medical_Reviewer__c = con.Id;
        ar.Coordinator__c = con.Id;
        ar.Line_Listing_Reviewer__c = con.id;
        ar.Secondary_Author__c = con.id;
        ar.Plnnd_Date_for_Medical_Review_Cmpltn__c = Date.today().addDays(7);
        ar.Planned_Date_for_Medical_Review_Sent__c = Date.today().addDays(8);
        try{
            update ar;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }
           
    @IsTest
    static void testsetProductNameOnRAResponseReport () {
        setupTestData();
        insert ar;
        
        Test.startTest();
        try{
            insert raAgReport;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSandozRecordTypeFieldValidations(){
        setupTestData();
        Test.startTest();
        try{
        
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
	    try{
        sandozAggReport.Actual_Date_for_QC_Completion_NA__c = 'No';
        update sandozAggReport;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testsendMailForMedicalReviewDateChange(){
        setupTestData();
        
        
        RecordType contactRT = [SELECT Id from RecordType where Name ='IQVIA User Contact'];
        Contact con = UTL_PSA_TestData.createResources(1,false)[0];
        con.RecordTypeId = contactRT.Id;
        con.Email = 'test2@email.com';
        insert con;
        
        Test.startTest();
        sandozAggReport.Primary_QC_Reviewer__c = con.Id;
        sandozAggReport.Secondary_QC_Reviewer__c = con.Id;
        sandozAggReport.Primary_BRM_Analyst__c = con.Id;
        sandozAggReport.Secondary_BRM_Analyst__c = con.Id;
        sandozAggReport.Primary_Medical_Reviewer__c = con.Id;
        sandozAggReport.Secondary_Medical_Reviewer__c = con.Id;
        sandozAggReport.Coordinator__c = con.Id;
        sandozAggReport.Line_Listing_Reviewer__c = con.id;
        sandozAggReport.Secondary_Author__c = con.id;
        sandozAggReport.Plnnd_Date_for_Medical_Review_Cmpltn__c = Date.today().addDays(12);
        sandozAggReport.Planned_Date_for_Medical_Review_Sent__c = Date.today().addDays(4);
        try{
            update sandozAggReport;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        
        List<Workflow_Email_Record__c> workflowEmailRecordList = new List<Workflow_Email_Record__c>();
        workflowEmailRecordList = [SELECT Id FROM Workflow_Email_Record__c];
        System.assertEquals(2, workflowEmailRecordList.size(), 'Test Workflow_Email_Record__c insertion');
        Test.stopTest();
    }

     @IsTest
    static void testSanofiRecordTypeFieldValidations(){
        setupTestData();
        Test.startTest();
	    try{
        sanofiPVSAggReport.Actual_Date_for_QC_Completion_NA__c = 'No';
        sanofiPVSAggReport.Status__c = 'Completed';
        update sanofiPVSAggReport;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    public static void testPopulateSanofiProducts(){
        setupTestData();
        RecordType sanofiPVSReportRecordTypeNameId = [SELECT Id from RecordType where Name='Sanofi PVS Report'];
        ar.RecordTypeId=sanofiPVSReportRecordTypeNameId.Id;
        ar.IQVIA_Primary_GSO_NA__c='NA';
        ar.Sanofi_Products__c='Testdata';
        ar.IQVIA_Secondary_GSO_NA__c ='NA';
        ar.IQVIA_TAH_NA__c ='NA';
        ar.PVS_GBU_Lead_NA__c ='Yes';
        ar.IQVIA_GSO_LM_NA__c ='Yes';
        insert ar;

        List<Aggregate_Report__c> aggList = [SELECT Id, RecordTypeId, Sanofi_Products__c FROM Aggregate_Report__c where Id=:ar.Id limit 1 ];
        Map<Id, Aggregate_Report__c> aggMap = new Map<Id, Aggregate_Report__c>(aggList);
        List<Report_Drug__c> rdList = [SELECT Id, Name, Aggregate_Report__c FROM Report_Drug__c where Aggregate_Report__c =:ar.Id ];

        Test.startTest();
        DAOH_Aggregate_Report.populateSanofiProducts(aggList, aggMap);
        Test.stopTest();
        Aggregate_Report__c updatedAgg = [SELECT Id, Sanofi_Products__c FROM Aggregate_Report__c WHERE Id = :ar.Id];
        System.assert(updatedAgg.Sanofi_Products__c!= null);
    }
}
