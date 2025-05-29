/**
* This test class is used to test TST_DAO_Project_Task.cls. It is copied over from TST_TGR_Project_Task.cls
*
*/

@isTest
private class TST_DAO_Project_Task {
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Contact
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;
        Contact contact = testResource;        
        //anothercontact = UTL_PSA_TestData.resources[1];        
        
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
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
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        /*assignment
assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {contact},project,false)[0];
assignment.pse__Bill_Rate__c = 200;
insert assignment;*/
        
        pse__Proj__c templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
        recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
        templateProject.recordTypeId = recTypeId;
        templateProject.pse__Project_Status__c = 'Start-up';
        templateProject.pse__Is_Template__c = true;
        insert templateProject;
        
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Task_Template_ID__c = templateProject.id;
        insert rdsSettings;
        
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
        milestone.Include_Tasks_on_Deliverables__c = true;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceline.id;
        insert milestone;
        
        //target
        Target__c target = new Target__c();
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.id;
        target.Inactivated_Date__c = system.today();
        target.Date_Activated__c = system.today();
        insert target;
        
        
        //Pricing Task
        Pricing_Task__c pricingtask = new Pricing_Task__c(Name = 'PricingTask Test');
        pricingtask.Project__c = parentproject.id;
        pricingtask.Service__c = service.id;
        pricingtask.Service_Milestone__c = milestone.id;
        pricingtask.Budget_Hours__c = 20;
        pricingtask.Task_Id__c = '123456789';
        insert pricingtask;
        
        //top project task
        //topprojecttask = new pse__Project_Task__c(Name = 'TopPT');
        //topprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        //topprojecttask.pse__Project__c = project.id;
        
        //Parent Project Task
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        parentprojecttask.pse__Project__c = project.id;
        parentprojecttask.pse__Milestone__c = milestone.id;
        parentprojecttask.Target__c = target.id;
        //parentprojecttask.Resource__c = contact.id;
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        //	parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        //	parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Include_in_Financials__c = true;
        test.startTest();
        //insert parentprojecttask;
        
        pse__Project_Task__c projecttask = new pse__Project_Task__c();
        projecttask.Name = pricingtask.Name;
        projecttask.pse__Project__c = parentprojecttask.pse__Project__c;
        projecttask.Parent_Project__c = pricingtask.Project__c;
        projecttask.pse__Milestone__c = parentprojecttask.pse__Milestone__c;
        projecttask.Target__c = target.id;
        projecttask.Budgeted_Hours__c = pricingtask.Budget_Hours__c;
        projecttask.pse__Status__c = 'In Progress';
        projecttask.Role__c = pricingtask.Role__c;  
        projecttask.pse__Start_Date_Time__c = parentprojecttask.pse__Start_Date_Time__c;
        projecttask.pse__End_Date_Time__c = parentprojecttask.pse__End_Date_Time__c;
        projecttask.Start_Date_Planned__c = parentprojecttask.Start_Date_Planned__c;
        projecttask.End_Date_Planned__c = parentprojecttask.End_Date_Planned__c;
        projecttask.Pricing_Task_ID__c = pricingtask.Task_Id__c;
        projecttask.Service__c = service.id;
        projecttask.Service_Line__c = parentprojecttask.Service_Line__c;
        projecttask.Reason_for_Deletion__c = 'Delete pt';
        projecttask.pse__Parent_Task__c = parentprojecttask.id;
        projecttask.Program__c = program.id;
        projecttask.Resource__c = contact.Id;
        insert projecttask;
        
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;
        
        test.stopTest();
    }
    
    @IsTest
    static void testFieldUpdates () {
        //setupTestData();
        Test.startTest();
        pse__Project_Task__c parentprojecttask = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //pse__Project_Task__c parentprojecttask = createTask('RDS Deliverable', true);
        parentprojecttask.pse__Status__c = 'Complete';
        parentprojecttask.pse__Actual_Start_Date_Time__c = System.Date.Today();
        update parentprojecttask;
        
        //parentprojecttask.pse__Status__c = 'Planned';
        //update parentprojecttask;
        
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testStatusUpdates () {
        //setupTestData();
        Test.startTest();
        pse__Project_Task__c parentprojecttask = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //pse__Project_Task__c parentprojecttask = createTask('RDS Deliverable', true);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.pse__Actual_Start_Date_Time__c = System.Date.Today();
        update parentprojecttask;
        
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    /*
@IsTest
static void testAddPricingTask1 () {
//setupTestData();
pse__Proj__c templateProject = [Select Id from pse__Proj__c where pse__Is_Template__c = True limit 1];

list<pse__Project_Task__c> insertTaskList = new List<pse__Project_Task__c>();
pse__Project_Task__c templateTask1 = new pse__Project_Task__c();
templateTask1.Name = 'Template Task 1';
templateTask1.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Template Task');
templateTask1.pse__Parent_Task__c = null;
templateTask1.Parent_Project__c = null;
templateTask1.pse__Project__c = templateProject.id;
templateTask1.Pricing_Task_ID__c = '123456789';
templateTask1.Service_Line__c = null;
templateTask1.Service__c = null;
templateTask1.pse__Milestone__c = null;
templateTask1.Target__c = null;
Test.startTest();
insert templateTask1;
Test.stopTest();
system.assertEquals(templateTask1.Name, 'Template Task 1');
}
*/
    
    static void testAddPricingTask2 () {
        pse__Proj__c templateProject = [Select Id from pse__Proj__c where pse__Is_Template__c = True limit 1];
        Service__c service = [Select Id, Name from Service__c where Name = 'Test Service' limit 1]; 
        
        pse__Project_Task__c templateTask2 = new pse__Project_Task__c();
        templateTask2.Name = 'Template Task 2';
        templateTask2.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Template Task');
        templateTask2.pse__Parent_Task__c = null;
        templateTask2.Parent_Project__c = null;
        templateTask2.pse__Project__c = templateProject.id;
        templateTask2.service__c = service.id;
        templateTask2.Service_Line__c = null;
        templateTask2.Pricing_Task_ID__c = null;
        templateTask2.pse__Milestone__c = null;
        templateTask2.Target__c = null;
        Test.startTest();
        insert templateTask2;
        Test.stopTest();
        system.assertEquals(templateTask2.Name, 'Template Task 2');
    }
    
    static void testAddPricingTask3 () {
        pse__Proj__c templateProject = [Select Id from pse__Proj__c where pse__Is_Template__c = True limit 1];
        Service_Line__c serviceline = [Select Id, Name from Service_Line__c where Name='Aggregate Reporting' limit 1];
        
        pse__Project_Task__c templateTask3 = new pse__Project_Task__c();
        templateTask3.Name = 'Template Task 3';
        templateTask3.pse__Parent_Task__c = null;
        templateTask3.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Template Task');
        templateTask3.Parent_Project__c = null;
        templateTask3.pse__Project__c = templateProject.id;
        templateTask3.Service_Line__c = serviceline.id;
        templateTask3.Pricing_Task_ID__c = null;
        templateTask3.service__c = null;
        templateTask3.pse__Milestone__c = null;
        templateTask3.Target__c = null;
        Test.startTest();
        insert templateTask3;
        Test.stopTest();
        system.assertEquals(templateTask3.Name, 'Template Task 3');
    }
    
    
    
    @IsTest
    static void testDeleteTask () {
        //setupTestData();
        Test.startTest();
        pse__Project_Task__c parentprojecttask = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //pse__Project_Task__c parentprojecttask = createTask('RDS Deliverable Task', true);
        //pse__Project_Task__c subTask = createTask('RDS Deliverable Task', true);
        delete parentprojecttask;
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    
    @IsTest
    static void testcreateTaskFromPricingTask () {
        //setupTestData();
        Test.startTest();
        
        pse__Project_Task__c parentprojecttask = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //update parentprojecttask;
        Test.stopTest();
        List<pse__Project_Task__c>  testcreateTaskFromPricingTask = [SELECT Name,Reason_for_Deletion__c, pse__Top_level_Parent_Task__c, pse__Milestone__c, pse__Completed__c,pse__Started__c, pse__Actual_End_Date_Time__c, pse__Status__c, pse__Actual_Start_Date_Time__c from pse__Project_Task__c where Id=: parentprojecttask.Id];
    }
    
    
    @IsTest
    static void testcreateTask () {
        //setupTestData();
        Test.startTest();
        pse__Project_Task__c parentprojecttask = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //	parentprojecttask.pse__Parent_Task__c = topprojecttask.id;
        //	parentprojecttask.Template_Task_ID__c = String.valueOf(topprojecttask.id);
        update parentprojecttask;
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    
    @IsTest
    static void testSetDefaultProjectTaskDates () {
        //setupTestData();
        Program__c program = [Select Id from Program__c where Name='TestProgram' limit 1];
        Service_Line__c serviceline = [Select Id from Service_Line__c where Name='Aggregate Reporting' limit 1]; 
        Service__c service = [Select Id from Service__c where Name = 'Test Service' limit 1];
        
        PSA_Date_Offset__c o1 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
                                                                  'Draft_Due_Date__c', true);
        PSA_Date_Offset__c o2 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
                                                                  'End_Date_Planned__c', true);
        
        
        Test.startTest();
        pse__Project_Task__c pt = [Select Id,Name from pse__Project_Task__c where pse__Status__c ='In Progress' limit 1];
        //pse__Project_Task__c pt = createTask('RDS Deliverable Task', false);
        pt.Draft_Due_Date__c = null;
        pt.End_Date_Planned__c = null;
        pt.Client_Notification_Date__c = System.today();
        update pt;
        Test.stopTest();
    }
    
    /*
@IsTest
static void testCrossReferenceAggregateReports(){
//setupTestData();
RecordType recordId = [SELECT Id from RecordType where Name='General Report'];

milestone.Validate_Product_Line__c = false;
update milestone;

Test.startTest();
Aggregate_Report__c ar = new Aggregate_Report__c();
ar.Project__c = project.Id; 
ar.RecordTypeId = recordId.Id;
ar.Status__c = 'Completed';
ar.Service_Milestone__c = milestone.Id;
ar.Project_Files_SMP__c = 'http://salesforce.com';
ar.Client_Final_Report__c = 'http://salesforce.com';
DAOH_Aggregate_Report.makeReportValid(ar);
insert ar;
Test.stopTest();
List<pse__Project_Task__c> deliverables = [SELECT Id, Aggregate_Report__c FROM pse__Project_Task__c WHERE Aggregate_Report__c = :ar.Id];
//System.assertEquals(1, deliverables.size());
Id deliverableId = deliverables.get(0).Id;
List<Aggregate_Report__c> agReports = [SELECT Id, Deliverable__c FROM Aggregate_Report__c WHERE Deliverable__c = :deliverableId];
//System.assertEquals(1, agReports.size());
}
*/
    
    /*
static Program__c program;
static pse__Proj__c parentproject;
static pse__Proj__c project;
static pse__Proj__c templateProject;
static pse__Project_Task__c parentprojecttask;
//static pse__Project_Task__c topprojecttask;
static pse__Project_Task_Assignment__c PTA;
static pse__Milestone__c milestone;
static Contact contact;
//static Contact anothercontact;
static Drug__c drug;
static Target__c target;
static Service__c service;
static Pricing_Task__c pricingtask;
static Service_Line__c serviceline;
static pse__Assignment__c assignment;

static void setupTestData () {

UTL_PSA_TestData.createPermissionControls();


program = new Program__c(Name = 'TestProgram');
insert program;

//Contact
RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
testResource.RecordTypeId = contactRT.Id;
testResource.pse__Salesforce_User__c = UserInfo.getUserId();
insert testResource;
contact = testResource;

//anothercontact = UTL_PSA_TestData.resources[1];

list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
// Parent Project
parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
parentproject.recordTypeId = parentrecTypeId;
parentproject.pse__Project_Status__c = 'Start-up';
parentproject.Program__c = program.id;
insert parentproject;

//service line
serviceline = new Service_Line__c(
Name = 'Aggregate Reporting',
Active__c=true,
Service_Line_Code__c = 'AR');
insert serviceline;

//service
service = new Service__c(Name = 'Test Service');
service.Service_Code__c = '12345678';
service.Service_Line__c = serviceline.Id;
insert service;

// project
project = UTL_PSA_TestData.createProjects(1, false)[0];
Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
project.recordTypeId = recTypeId;
project.pse__Project_Status__c = 'Start-up';
project.pse__Parent_Project__c = parentproject.Id;
project.Service_Line__c = serviceline.Id;
projInsertList.add(project);

/*assignment
assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {contact},project,false)[0];
assignment.pse__Bill_Rate__c = 200;
insert assignment;

templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
templateProject.recordTypeId = recTypeId;
templateProject.pse__Project_Status__c = 'Start-up';
templateProject.pse__Is_Template__c = true;
projInsertList.add(templateProject);
insert projInsertList;

PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
rdsSettings.Task_Template_ID__c = templateProject.id;
insert rdsSettings;

//milestone
milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
milestone.RecordTypeId = milestonerecTypeId;
milestone.Actual_Quantity__c = 10;
milestone.Billed_Quantity__c = 15;
milestone.pse__Project__c = project.Id;
milestone.pse__Target_Date__c = system.today();
milestone.Actual_Amount__c = 20;
milestone.pse__Milestone_Amount__c = 100;
milestone.Billed_Amount__c = 30;
milestone.Include_Tasks_on_Deliverables__c = true;
milestone.Service__c = service.id;
milestone.Service_Line__c = serviceline.id;
milestone.Validate_Product_Line__c = true;
insert milestone;

//drug
drug = new Drug__c();
drug.program__c = program.id;
drug.name = 'Test Drug';
insert drug;

insert new pse__Task_Management_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), pse__Track_Points_History_Disabled__c=true);

//target
target = new Target__c();
target.recordtypeid = CON_PSA.TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE;
target.drug__c = drug.id;
target.Single_Country__c = 'US';
target.Strength__c = '50';
target.Dosage_Form__c = '100';
target.Program__c = program.id;
target.Active__c = true;
insert target;

//Pricing Task
pricingtask = new Pricing_Task__c(Name = 'PricingTask Test');
pricingtask.Project__c = parentproject.id;
pricingtask.Service__c = service.id;
pricingtask.Service_Milestone__c = milestone.id;
pricingtask.Budget_Hours__c = 20;
pricingtask.Task_Id__c = '123456789';
insert pricingtask;

//top project task
//topprojecttask = new pse__Project_Task__c(Name = 'TopPT');
//topprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
//topprojecttask.pse__Project__c = project.id;

//Parent Project Task
parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
parentprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
parentprojecttask.pse__Project__c = project.id;
parentprojecttask.pse__Milestone__c = milestone.id;
parentprojecttask.Target__c = target.id;
parentprojecttask.Countries__c = 'US;';
//parentprojecttask.Resource__c = contact.id;
parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
parentprojecttask.Service_Line__c = serviceline.id;
parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
parentprojecttask.pse__Status__c = 'Planned';
parentprojecttask.Unit_Price__c = 200;
//	parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
parentprojecttask.Budgeted_Hours__c = 10;
parentprojecttask.Role__c = 'Coordinator';
//	parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
parentprojecttask.Include_in_Financials__c = true;
parentprojecttask.Drug__c = drug.id;
}

static pse__Project_Task__c createTask(String recordType, boolean isInsert){
pse__Project_Task__c projecttask = new pse__Project_Task__c();
projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', RecordType);
projecttask.Name = pricingtask.Name;
projecttask.pse__Project__c = parentprojecttask.pse__Project__c;
projecttask.Parent_Project__c = pricingtask.Project__c;
projecttask.pse__Milestone__c = parentprojecttask.pse__Milestone__c;
projecttask.Target__c = target.id;
//projecttask.Resource__c = contact.id;
projecttask.Budgeted_Hours__c = pricingtask.Budget_Hours__c;
projecttask.pse__Status__c = 'In Progress';
projecttask.Role__c = pricingtask.Role__c;
projecttask.pse__Start_Date_Time__c = parentprojecttask.pse__Start_Date_Time__c;
projecttask.pse__End_Date_Time__c = parentprojecttask.pse__End_Date_Time__c;
projecttask.Start_Date_Planned__c = parentprojecttask.Start_Date_Planned__c;
projecttask.End_Date_Planned__c = parentprojecttask.End_Date_Planned__c;
projecttask.Pricing_Task_ID__c = pricingtask.Task_Id__c;
projecttask.Service__c = service.id;
projecttask.Drug__c = drug.id;
projecttask.Countries__c = 'US;';
projecttask.Service_Line__c = parentprojecttask.Service_Line__c;
projecttask.Reason_for_Deletion__c = 'Delete pt';
projecttask.pse__Parent_Task__c = parentprojecttask.id;
projecttask.Program__c = program.id;
if (isInsert) {
insert projecttask;
}

return projecttask;
}
*/
}
