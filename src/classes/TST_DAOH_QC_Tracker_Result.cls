/**
 * This test class is used to test DAOH_QC_Tracker_Result.cls. It is copied over from TST_TGR_QC_Tracker_Result.cls
 *
 */
@isTest
private class TST_DAOH_QC_Tracker_Result {
    
    @testSetup static void setup() {
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

        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
	    //ar.Name = '12345';
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.RecordTypeId = recordId.Id;
	    ar.Comments__c='Test Comment INSERT';
        ar.Report_Type__c = '2 mo LL';
        insert ar;
        
        RecordType recordId2 = [SELECT Id from RecordType where Name='Sandoz Report'];
        Aggregate_Report__c ar2 = new Aggregate_Report__c();
        ar2.Project__c = project.Id;
        ar2.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar2.Primary_Author__c = testResource.Id;
        ar2.Project_Files_SMP__c = 'http://salesforce.com';
        ar2.Client_Final_Report__c = 'http://salesforce.com';
        ar2.RecordTypeId = recordId2.Id;
	ar2.Comments__c='Test Comment INSERT';
        ar2.Report_Type__c = 'RMP';
        insert ar2;

        QC_Tracker_Result__c qcTrackerResult;
        qcTrackerResult = new QC_Tracker_Result__c();
        qcTrackerResult.REP_QC_ID__c = 'QCID-1223';
        qcTrackerResult.Aggregate_Report__c = ar.id;
        qcTrackerResult.Name = '12345';
        qcTrackerResult.Date_Deleted__c = null;
        insert qcTrackerResult;
        
        QC_Tracker_Result__c qcTrackerResult2;
        qcTrackerResult2 = new QC_Tracker_Result__c();
        qcTrackerResult2.REP_QC_ID__c = 'QCID-1224';
        qcTrackerResult2.Aggregate_Report__c = ar2.id;
        qcTrackerResult2.Name = '12345';
        qcTrackerResult2.Date_Deleted__c = null;
        insert qcTrackerResult2;
    }
    
    @IsTest
    static void testInsertOnQCTrackerResult() {
        Test.startTest();
        // Validate if a record was inserted in QC Tracker Result 
        list<QC_Tracker_Result__c> qcTrackerResultAfterInsert = [SELECT id from QC_Tracker_Result__c];
        System.assertEquals(2, qcTrackerResultAfterInsert.size());
        Test.stopTest();
    }  
}
