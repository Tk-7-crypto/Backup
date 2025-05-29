/**
 * This test class is used to test BCH_PSA_ApplyRDSProjectTaskTemplates.
 *
 * ----------------------------------------------------------------------------
 * Date Modified     Modified By        Description of the update
 * ----------------------------------------------------------------------------
 * 27 Jul 2020       CLD                Migrated from Queueable job
 */
@isTest
private class TST_BCH_PSA_ApplyRDSProjectTaskTemplates {
  @testSetup
    static void dataSetup() 
    {
    Contact contact = UTL_PSA_TestData.resources[0];
    contact.pse__Salesforce_User__c = UserInfo.getUserId();
    update contact;

    Service_Line__c serviceline = new Service_Line__c(Name = 'Test Group');
    serviceline.Service_Line_Code__c = '09876';
    insert serviceline;

    pse__Grp__c groupobj = new pse__Grp__c(Name = 'Test Group');
    insert groupobj;

    Program__c program = new Program__c(Name = 'Test Program');
    insert program;

    UTL_PSA_TestData.createPermissionControls();

    pse__Proj__c templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id templateRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
    templateProject.recordTypeId = templateRecTypeId;
    insert templateProject;

    PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
    rdsSettings.Task_Template_ID__c = templateProject.id;
    insert rdsSettings;

   
        
    pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
    parentproject.recordTypeId = parentrecTypeId;
    parentproject.pse__Project_Status__c = 'Start-up';
    parentproject.pse__Start_Date__c = Date.today();
    parentproject.Go_Live_Date__c = Date.today().addDays(599);
    parentproject.Go_Live_Date__c = Date.today().addDays(600);
    parentProject.Program__c = program.Id;
    insert parentproject;


    pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
    Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
    project.recordTypeId = recTypeId;
    project.pse__Project_Status__c = 'Active';
    project.Service_Line__c = serviceline.id;
    insert project;
        
      pse__Project_Task__c projecttask = new pse__Project_Task__c();
    projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Project Task');
    projecttask.Name = 'Test Name';
    projecttask.pse__Project__c = project.Id;
    projecttask.pse__Status__c = 'In Progress';
    projecttask.pse__Start_Date_Time__c = project.pse__Start_Date__c;
    projecttask.pse__End_Date_Time__c = project.pse__End_Date__c;
    projecttask.Service_Line__c = serviceline.id;
    projecttask.Type__c = 'Maintenance';
    projecttask.Frequency__c = 'Yearly';
    insert projecttask;
    }
    
    
  @IsTest
  static void testQueueTaskTemplates() {
    //setupTestData();

    Test.startTest();
    pse__Proj__c parentproject  = [Select Id, Name,Legacy_ID__c,pse__Group__c,project_category__c,project_scope__c,service_line__c,pse__Start_Date__c,pse__End_Date__c,Go_Live_Date__c,Program__c from pse__Proj__c where RecordType.Name ='RDS Project' limit 1];
   pse__Proj__c project =  [Select Id, Name,Legacy_ID__c,pse__Group__c,project_category__c,project_scope__c,service_line__c,pse__Start_Date__c,pse__End_Date__c,Go_Live_Date__c,Program__c from pse__Proj__c where RecordType.Name ='RDS Service Line' limit 1];
    
    project.pse__Parent_Project__c = parentproject.id;
    update project;

//      ID jobid = System.enqueueJob(new QUE_PSA_ApplyRDSProjectTaskTemplates(new List<pse__Proj__c>{project}));
    Id jobId = BCH_PSA_ApplyRDSProjectTaskTemplates.batchRun(new List<pse__Proj__c>{project});
    Test.stopTest();

    List<pse__Project_Task__c> newList = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.id];
    //system.assertEquals(1, newList.size());
  }

  @IsTest
  static void testExistingTasks() {
    //setupTestData();

    Test.startTest();

    pse__Proj__c parentproject  = [Select Id, Name,Legacy_ID__c,pse__Group__c,project_category__c,project_scope__c,service_line__c,pse__Start_Date__c,pse__End_Date__c,Go_Live_Date__c,Program__c from pse__Proj__c where RecordType.Name ='RDS Project' limit 1];
   pse__Proj__c project =  [Select Id, Name,Legacy_ID__c,pse__Group__c,project_category__c,project_scope__c,service_line__c,pse__Start_Date__c,pse__End_Date__c,Go_Live_Date__c,Program__c from pse__Proj__c where RecordType.Name ='RDS Service Line' limit 1];
    project.pse__Parent_Project__c = parentproject.id;
    update project;

    Id jobid = BCH_PSA_ApplyRDSProjectTaskTemplates.batchRun(new List<pse__Proj__c>{project});

     /* 
    pse__Project_Task__c anotherTask = createTask('RDS Project Task', project, false);
    anotherTask.Name = 'Another Task';
    anotherTask.pse__Project__c = project.Id;
    insert anotherTask;
	*/
    Id jobid2 = BCH_PSA_ApplyRDSProjectTaskTemplates.batchRun(new List<pse__Proj__c>{project});

    Test.stopTest();

    //List<pse__Project_Task__c> newList = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.id];
    //system.assertEquals(2, newList.size());
  }

    /*
  static pse__Proj__c parentproject;
  static pse__Proj__c project;
  static pse__Proj__c templateProject;
  static pse__Project_Task__c parentprojecttask;
  static pse__Project_Task__c topprojecttask;
  static pse__Project_Task_Assignment__c PTA;
  static pse__Milestone__c milestone;
  static Target__c target;
  static Service__c service;
  static Pricing_Task__c pricingtask;
  static Service_Line__c serviceline;
  static PSA_Metric__c psametric;
  static Project_Metric__c projectmetric;
  static pse__Grp__c groupobj;
  static Program__c program;

  static void setupTestData () {
    //contacts
    Contact contact = UTL_PSA_TestData.resources[0];
    contact.pse__Salesforce_User__c = UserInfo.getUserId();
    update contact;

    //service line
    serviceline = new Service_Line__c(Name = 'Test Group');
    serviceline.Service_Line_Code__c = '09876';
    insert serviceline;

    //Group
    groupobj = new pse__Grp__c(Name = 'Test Group');
    insert groupobj;

    //Program
    program = new Program__c(Name = 'Test Program');
    insert program;

    UTL_PSA_TestData.createPermissionControls();

    //Template Project
    templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id templateRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
    templateProject.recordTypeId = templateRecTypeId;
    insert templateProject;

    //RDS Settings
    PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
    rdsSettings.Task_Template_ID__c = templateProject.id;
    insert rdsSettings;

    System.debug('&&& inserted rds settings');

    createTask('RDS Template Task', templateProject, true);
    pse__Project_Task__c otherType = createTask('RDS Template Task', templateProject, false);
    otherType.Type__c = 'Start-up';
    insert otherType;
    System.debug('&&& inserted template task');

    // Parent Project
    parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
    parentproject.recordTypeId = parentrecTypeId;
    parentproject.pse__Project_Status__c = 'Start-up';
    parentproject.pse__Start_Date__c = Date.today();
    parentproject.Go_Live_Date__c = Date.today().addDays(599);
    parentproject.Go_Live_Date__c = Date.today().addDays(600);
    parentProject.Program__c = program.Id;
    //insert parentproject;

    // project
    project = UTL_PSA_TestData.createProjects(1, false)[0];
    Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
    project.recordTypeId = recTypeId;
    project.pse__Project_Status__c = 'Active';
    project.Service_Line__c = serviceline.id;
    //project.pse__Parent_Project__c = parentproject.id;
    //insert project;
  }

  static pse__Proj__c createTemplateProject () {
    pse__Proj__c proj = UTL_PSA_TestData.createProjects(1, false)[0];
    Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
    proj.recordTypeId = recTypeId;
    return proj;
  }

  static pse__Project_Task__c createTask (String recordType, pse__Proj__c project, boolean isInsert) {
    pse__Project_Task__c projecttask = new pse__Project_Task__c();
    projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', RecordType);
    projecttask.Name = 'Test Name';
    projecttask.pse__Project__c = project.Id;
    projecttask.pse__Status__c = 'In Progress';
    projecttask.pse__Start_Date_Time__c = project.pse__Start_Date__c;
    projecttask.pse__End_Date_Time__c = project.pse__End_Date__c;
    projecttask.Service_Line__c = serviceline.id;
    projecttask.Type__c = 'Maintenance';
    projecttask.Frequency__c = 'Yearly';

    if (isInsert){
      insert projecttask;
    }

    return projecttask;
  }
	*/
}