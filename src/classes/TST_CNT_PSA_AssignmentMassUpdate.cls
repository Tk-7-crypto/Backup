/*
 * TST_CNT_PSA_AssignmentMassUpdate
 *
 * Providing proofs for the CNT PSA AssignmentMassUpdate page
 *
 *
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_AssignmentMassUpdate -c -r json
 */
@isTest(isParallel=false)
private class TST_CNT_PSA_AssignmentMassUpdate 
{

    @testSetup
    static void dataSetup() 
    {
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
    
        pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentproject.Program__c = program.id;
        insert parentProject;
    	
        pse__Proj__c servicelineproject = UTL_PSA_TestData.createProjects(2, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.Name = 'Test ServiceLine Project';
        insert servicelineproject;
    
        pse__Proj__c anotherservicelineproject = UTL_PSA_TestData.createProjects(2, false)[1];
        anotherservicelineproject.recordTypeId = recTypeId;
        anotherservicelineproject.pse__Parent_Project__c = parentProject.id;
        anotherservicelineproject.Name = 'Test Another ServiceLine Project';
        insert anotherservicelineproject;
            
        UTL_PSA_TestData.createPermissionControls();
    
        Contact contact = UTL_PSA_TestData.resources[0];
        Contact anothercontact = UTL_PSA_TestData.resources[1];
    
        Service_Line__c serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
            );
        insert serviceLine;
    
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
            );
        insert service;
    
        Service_Line__c anotherserviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'pv',
            Name = 'pv'
            );
        insert anotherserviceLine;
    
        Service__c anotherservice = new Service__c(
            Active__c = true,
            Service_Line__c = anotherserviceLine.id,
            Service_Code__c = 'pv'
    
            );
        insert anotherservice;
    
        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = system.today();
        schedule.pse__End_Date__c = schedule.pse__Start_Date__c.addDays(30);
        insert schedule;
    
        UTL_PSA_TestData.key = 'MS1';
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        insert milestone;
    
        UTL_PSA_TestData.key = 'MS2';
        pse__Milestone__c anothermilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        anothermilestone.RecordTypeId = milestonerecTypeId;
        anothermilestone.pse__Project__c = anotherservicelineproject.Id;
        anothermilestone.Service_Line__c = anotherserviceLine.Id;
        anothermilestone.Service__c = anotherservice.id;
        anothermilestone.Start_Date__c = system.today();
        anothermilestone.End_Date__c =  anothermilestone.Start_Date__c.addDays(30);
        insert anothermilestone;
    }
    
    /**
     * This method used to update assignment schedules.
     */
    @IsTest
    static void testUpdateAssignmentSchedules() {
        //setupTestData();
        pse__Schedule__c schedule = [Select Id, pse__Start_Date__c,pse__End_Date__c from pse__Schedule__c limit 1];
        Test.startTest();
        String startDateString = string.valueof(schedule.pse__Start_Date__c);
        String endDateString = string.valueof(schedule.pse__End_Date__c);
        String assignmentSchedules = CNT_PSA_AssignmentMassUpdate.updateAssignmentSchedules(new List<Id> {schedule.id}, startDateString, endDateString );
        Test.stopTest();
        String expected = 'success';
        String actual = assignmentSchedules;
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Assignments by Program.
     */
    @IsTest
    static void testgetAssignmentsByProgram() {
        //setupTestData();
        Program__c program = [Select Id from Program__c limit 1];
        Test.startTest();
        String programId = program.id;
        List<String> fieldList = new List<String> {'Name'};
        List<pse__Assignment__c> assignmentsByProgram = CNT_PSA_AssignmentMassUpdate.getAssignmentsByProgram(programId, fieldList );
        Test.stopTest();
    }

    /**
     * This method used to get a Projects by Program.
     */
    @IsTest
    static void testgetProjectsByProgram() {
        //setupTestData();
        Program__c program = [Select Id from Program__c limit 1];
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c where Name='Test Parent Project' limit 1];
        Test.startTest();
        String programId = program.id;
        List<String> fieldList = new List<String> {'Program__c'};
        List<pse__Proj__c> projectsByProgram = CNT_PSA_AssignmentMassUpdate.getProjectsByProgram(programId, fieldList );
        Test.stopTest();
        String expected = parentproject.id;
        String actual = projectsByProgram[0].id;
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Service Line by Project.
     */
    @IsTest
    static void testgetServiceLinesByProject() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c where Name='Test Parent Project' limit 1];
        Test.startTest();
        List<String> fieldList = new List<String> {'Service_Line__c'};
        List<pse__Proj__c> serviceLineByProject = CNT_PSA_AssignmentMassUpdate.getServiceLinesByProject(new List<Id> {parentproject.id}, fieldList );
        Test.stopTest();
    }

	/*
    static Program__c program;
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static pse__Proj__c anotherservicelineproject;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Service_Line__c anotherserviceLine;
    static Contact contact;
    static Contact anothercontact;
    static pse__Milestone__c milestone;
    static pse__Milestone__c anothermilestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c anotherdeliverable;
    static pse__Resource_Request__c resourcerequest;
    static pse__Schedule__c schedule;
    
    static void setupTestData () {
    
        //Insert Program
        system.debug('AMU Creating program');
        program = new Program__c(Name = 'TestProgram');
        insert program;
    
    
        // parent project
        system.debug('AMU Creating parent project');
        parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentproject.Program__c = program.id;
    
        insert parentProject;
    
        // Service line project
        system.debug('AMU Creating service line project');
        servicelineproject = UTL_PSA_TestData.createProjects(2, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.Name = 'Test ServiceLine Project';
    
        insert servicelineproject;
    
        // Another Service line project
        system.debug('AMU Creating another service line project');
        anotherservicelineproject = UTL_PSA_TestData.createProjects(2, false)[1];
        anotherservicelineproject.recordTypeId = recTypeId;
        anotherservicelineproject.pse__Parent_Project__c = parentProject.id;
        anotherservicelineproject.Name = 'Test Another ServiceLine Project';
    
        insert anotherservicelineproject;
        UTL_PSA_TestData.createPermissionControls();
    
        //contacts
        system.debug('AMU Creating contact');
        contact = UTL_PSA_TestData.resources[0];
        system.debug('AMU Creating another contact');
        anothercontact = UTL_PSA_TestData.resources[1];
    
        // service line
        system.debug('AMU Creating service line');
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
            );
        insert serviceLine;
    
        // service
        system.debug('AMU Creating service');
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
            );
        insert service;
    
        // service line
        system.debug('AMU Creating another service line');
        anotherserviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'pv',
            Name = 'pv'
            );
        insert anotherserviceLine;
    
        // service
        system.debug('AMU Creating another service');
        Service__c anotherservice = new Service__c(
            Active__c = true,
            Service_Line__c = anotherserviceLine.id,
            Service_Code__c = 'pv'
    
            );
        insert anotherservice;
    
        //Schedule
        system.debug('AMU Creating schedule');
        schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = system.today();
        schedule.pse__End_Date__c = schedule.pse__Start_Date__c.addDays(30);
        insert schedule;
    
        //milestones
        system.debug('AMU Creating milestone');
        UTL_PSA_TestData.key = 'MS1';
        milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        insert milestone;
    
        //anothermilestone
        system.debug('AMU Creating another milestone');
        UTL_PSA_TestData.key = 'MS2';
        anothermilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        anothermilestone.RecordTypeId = milestonerecTypeId;
        anothermilestone.pse__Project__c = anotherservicelineproject.Id;
        anothermilestone.Service_Line__c = anotherserviceLine.Id;
        anothermilestone.Service__c = anotherservice.id;
        anothermilestone.Start_Date__c = system.today();
        anothermilestone.End_Date__c =  anothermilestone.Start_Date__c.addDays(30);
        insert anothermilestone;
    
        //Deliverable for milestone
    
        /*deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            pse__Milestone__c = milestone.Id,
            pse__Project__c = servicelineproject.Id
            );
        insert deliverable;
    }
	*/
}