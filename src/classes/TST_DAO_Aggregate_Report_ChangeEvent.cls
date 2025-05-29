/**
 * Test class for the Aggregate Report Change Event
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 28 May 2020               CLD                 		 Initial Version
 */
@isTest
private class TST_DAO_Aggregate_Report_ChangeEvent {

  @isTest
  static void tstUtilEventDomainHelper() {
    // initialize CDC!
    Test.enableChangeDataCapture();

    Test.startTest();

    // insert a project task object and trigger cdc event
    Aggregate_Report__c aggregateReport = createAggregateReport();
    insert aggregateReport;
    Test.getEventBus().deliver();

    // update and trigger cdc event
    aggregateReport.Comments__c='Test Comment UNDELETE';
    aggregateReport.Delete_Reason__c = 'Test';

    update aggregateReport;
    Test.getEventBus().deliver();

    // delete and trigger cdc event
    delete aggregateReport;
    Test.getEventBus().deliver();

    Test.stopTest();

    Audit_Log__c[] insertedLogs = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :aggregateReport.Id and operation__c in ('INSERT')];
    system.assertNotEquals(0, insertedLogs.size(), 'Expected to have an INSERT operation');
    system.assertEquals('INSERT', insertedLogs[0].Operation__c, 'expected an INSERT operation');

    Audit_Log__c[] updatedLogs  = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :aggregateReport.Id and operation__c in ('UPDATE') ];
    system.assertNotEquals(0, updatedLogs.size(), 'Expected to have an UPDATED operation');
    system.assertEquals('UPDATE', updatedLogs[0].Operation__c, 'expected an UPDATE operation');

    Audit_Log__c[] deleteddLogs  = [select id, name, operation__c, record_id__c from Audit_Log__c where record_id__c = :aggregateReport.Id and operation__c in ('DELETE') ];
    system.assertNotEquals(0, deleteddLogs.size(), 'Expected to have a DELETED operation');
    system.assertEquals('DELETE', deleteddLogs[0].Operation__c, 'expected a DELETE operation');
  }

  // initialize an aggregate report object for testing
  static Aggregate_Report__c createAggregateReport () {
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

    //contacts
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

    // initialize Aggregate_Report__c
    RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
    Aggregate_Report__c aggregateReport = new Aggregate_Report__c(
      Project__c = project.id,
      Client_First_Draft_Due__c = Date.today().addDays(7),
      Primary_Author__c = testResource.id,
      Project_Files_SMP__c = 'http://salesforce.com',
      Client_Final_Report__c = 'http://salesforce.com',
      RecordTypeId = recordId.Id
    );
    return aggregateReport;
  }

}