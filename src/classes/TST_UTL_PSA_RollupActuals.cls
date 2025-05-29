/*
 * TST_UTL_PSA_RollupActuals
 *
 * Providing proofs for the UTL_PSA_RollupActuals implementation
 *
 * 2019-May  cld      Initial version
 */
@isTest
private with sharing class TST_UTL_PSA_RollupActuals 
{
    @testSetup
    static void setupTestData() {
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
    
        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
    
        //service line
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Test Service Line',
            Active__c=true,
            Service_Line_Code__c = '09876');
        insert serviceline;
        
        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        service.Active__c = true;
        insert service;        
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        // Assignment 
        List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {contact, contact, contact},project,false);
        assignments[0].pse__Bill_Rate__c = 200;
        assignments[0].Sub_role__c = 'IQVIA Primary GSO';
        assignments[1].pse__Bill_Rate__c = 200;
        assignments[1].Sub_role__c = 'IQVIA GSO LM';
        assignments[2].pse__Bill_Rate__c = 200;
        assignments[2].Sub_role__c = 'IQVIA TAH';
        insert assignments;
    
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
        milestone.Actual_Quantity__c = 200;
        milestone.Billed_Quantity__c = 15;
        milestone.pse__Project__c = project.Id;
        milestone.pse__Target_Date__c = system.today();
        milestone.Actual_Amount__c = 20;
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Billed_Amount__c = 30;
        milestone.Include_Tasks_on_Deliverables__c = true;
        milestone.Service_Line__c = serviceline.Id;
        milestone.Service__c = service.id;
        insert milestone;
    
        //target
        Target__c target = new Target__c();
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.Id;
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
    
        //Parent Project Task
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        parentprojecttask.pse__Project__c = project.id;
        parentprojecttask.pse__Milestone__c = milestone.id;
        parentprojecttask.Target__c = target.id;
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.Include_in_Financials__c = true;
        test.startTest();
        
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;
        
        pse__Project_Task__c projecttask = new pse__Project_Task__c();
        projecttask.Name = 'TopPT';
        projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
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
        test.stopTest();
    }
    
@IsTest
static void testRefreshMilestoneActuals() {
	//setupTestData();
	pse__Milestone__c milestone = [Select Id from pse__Milestone__c limit 1];
    Test.startTest();
	pse__Project_Task__c topprojecttask =  [Select Id, Name from pse__Project_Task__c where RecordType.Name ='RDS Deliverable' limit 1];
	Test.stopTest();
	pse__Milestone__c updatedMilestone = [SELECT Actual_Quantity__c,Billed_Quantity__c,Actual_Amount__c,Billed_Amount__c from pse__Milestone__c where Id=: milestone.id];
	Decimal expected = 200;
	Decimal actual = updatedMilestone.Actual_Quantity__c;
	System.assertEquals(expected, actual);

}

    /*
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c templateProject;
    static pse__Project_Task__c parentprojecttask;
    static pse__Project_Task__c topprojecttask;
    static pse__Project_Task_Assignment__c PTA;
    static pse__Milestone__c milestone;
    static Contact contact;
    static Contact anothercontact;
    static Target__c target;
    static Service__c service;
    static Pricing_Task__c pricingtask;
    static Service_Line__c serviceline;
    
    
    static void setupTestData () {
    
        Program__c program = new Program__c(Name='Test Program');
        insert program;
    
        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
    
        anothercontact = UTL_PSA_TestData.resources[1];
    
        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
    
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        projInsertList.add(project);
    
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
    
        UTL_PSA_TestData.createPermissionControls();
    
        //service line
        serviceline = new Service_Line__c(Name = 'Test Service Line');
        serviceline.Service_Line_Code__c = '09876';
        insert serviceline;
    
        //service
        service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.id;
        insert service;
    
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
        insert milestone;
    
        //target
        target = new Target__c();
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.Id;
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
        topprojecttask = new pse__Project_Task__c(Name = 'TopPT');
        topprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        topprojecttask.pse__Project__c = project.id;
    }
    
    static pse__Project_Task__c createTask(String recordType, boolean isInsert){
        pse__Project_Task__c projecttask = new pse__Project_Task__c();
        projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', RecordType);
        projecttask.Name = pricingtask.Name;
        projecttask.pse__Project__c = project.id;
        projecttask.Parent_Project__c = pricingtask.Project__c;
        projecttask.pse__Milestone__c = milestone.id;
        projecttask.Target__c = target.id;
        //projecttask.Resource__c = contact.id;
        projecttask.Budgeted_Hours__c = pricingtask.Budget_Hours__c;
        projecttask.pse__Status__c = 'Complete';
        projecttask.Role__c = pricingtask.Role__c;
        projecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        projecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        projecttask.Start_Date_Planned__c = date.today().addDays(-30);
        projecttask.End_Date_Planned__c = date.today().addDays(-3);
        projecttask.Pricing_Task_ID__c = pricingtask.id;
        projecttask.Service__c = service.id;
        projecttask.Service_Line__c = serviceline.id;
        projecttask.Reason_for_Deletion__c = 'I felt like it';
        projecttask.Quantity__c = 200;
        projecttask.Include_in_Financials__c = true;
        projecttask.Unit_Price__c = 200;
        if (isInsert) {
            insert projecttask;
        }
    
        return projecttask;
    }
	*/
}
