/**
 * This test class is used to test BCH_PSA_InsertTaskTemplates
 */
@isTest
private class TST_BCH_PSA_InsertTaskTemplates {
    @isTest 
    static void testBatchTaskInsert() {
        setupTestData();

        Test.startTest();
        Id jobId = BCH_PSA_InsertTaskTemplates.batchRun(new List<pse__Proj__c>{project});
        Test.stopTest();

        List<pse__Project_Task__c> newList = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :project.id];
        System.assertEquals(2, newList.size());
    }
    
    @isTest 
    static void testBatchTaskInsertForCeva() {
        setupTestData();

        Test.startTest();
        Id jobId = BCH_PSA_InsertTaskTemplates.batchRun(new List<pse__Proj__c>{projectCeva});
        Test.stopTest();

        List<pse__Project_Task__c> newList = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :projectCeva.id];
    }


  static pse__Proj__c parentproject;
  static pse__Proj__c project;
  static pse__Proj__c projectCeva;
  static pse__Proj__c templateProject;
  static List<pse__Project_Task__c> tasks;
  static Service__c service;
  static Service_Line__c servicelineCeva;
  static Service_Line__c serviceline;
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
    
    servicelineCeva = new Service_Line__c(Name = 'CEVA');
    servicelineCeva.Service_Line_Code__c = '05678';
    insert servicelineCeva;

    //Group
    groupobj = new pse__Grp__c(Name = 'Test Group');
    insert groupobj;

    //Program
    program = new Program__c(Name = 'Test Program');
    insert program;

    UTL_PSA_TestData.createPermissionControls();

    // Parent Project
    parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
    parentproject.recordTypeId = parentrecTypeId;
    parentproject.pse__Project_Status__c = 'Start-up';
    parentproject.pse__Start_Date__c = Date.today();
    parentproject.Go_Live_Date__c = Date.today().addDays(599);
    parentproject.Go_Live_Date__c = Date.today().addDays(600);
    parentProject.Program__c = program.Id;
    insert parentproject;

    // project
    List<pse__Proj__c> projectList = new List<pse__Proj__c>();
    project = UTL_PSA_TestData.createProjects(1, false)[0];
    Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
    project.recordTypeId = recTypeId;
    project.pse__Project_Status__c = 'Active';
    project.Service_Line__c = serviceline.id;
    project.pse__Parent_Project__c = parentproject.id;
    projectList.add(project);
    
    projectCeva = UTL_PSA_TestData.createProjects(1, false)[0];     
    projectCeva.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
    projectCeva.pse__Project_Status__c = 'Active';
    projectCeva.Service_Line__c = servicelineCeva.id;
    projectCeva.pse__Parent_Project__c = parentproject.id;
    projectCeva.Service_Line_Scope__c = 'DMC;EAC';
    projectList.add(projectCeva);
    insert projectList;


    //Template Project
    templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id templateRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
    templateProject.recordTypeId = templateRecTypeId;
    insert templateProject;

    //RDS Settings
    PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
    rdsSettings.Task_Template_ID__c = templateProject.id;
    rdsSettings.CEVA_Service_Line_Id__c = servicelineCeva.id;
    insert rdsSettings;
    
    List<pse__Project_Task__c> taskList = new List<pse__Project_Task__c>();
    createTask('RDS Template Task', templateProject, true);
    pse__Project_Task__c otherType = createTask('RDS Template Task', templateProject, false);
    otherType.Type__c = 'Start-up';
    otherType.Name = 'Test Name 2';
    taskList.add(otherType);
    
    pse__Project_Task__c cevaType = createTask('RDS Template Task', templateProject, false);
    cevaType.Type__c = 'Start-up';
    cevaType.Name = 'CEVA Task';
    cevaType.Service_Line__c = servicelineCeva.id;
    cevaType.Service_Line_Scope__c = 'EAC';
    taskList.add(cevaType);
    
    pse__Project_Task__c cevaType2 = createTask('RDS Template Task', templateProject, false);
    cevaType2.Type__c = 'Start-up';
    cevaType2.Name = 'CEVA Task 2';
    cevaType2.Service_Line__c = servicelineCeva.id;
    cevaType2.Service_Line_Scope__c = 'DMC';
    taskList.add(cevaType2);
    
    pse__Project_Task__c cevaType3 = createTask('RDS Template Task', templateProject, false);
    cevaType3.Type__c = 'Start-up';
    cevaType3.Name = 'CEVA Task';
    cevaType3.Service_Line__c = servicelineCeva.id;
    taskList.add(cevaType3);
    insert taskList;

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
}
