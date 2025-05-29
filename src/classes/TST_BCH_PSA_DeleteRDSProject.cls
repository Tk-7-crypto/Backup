@isTest
public with sharing class TST_BCH_PSA_DeleteRDSProject
{
	@testSetup
    static void setupTestData(){

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

        UTL_PSA_TestData.createPermissionControls();

        Contact contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
        
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

        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = servicelineproject.Id;
        insert resourceRequest;

        pse__Project_Task__c projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task');
        projecttask.pse__Project__c = parentproject.id;
        insert projecttask;
        
        pse__Project_Task__c deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            //pse__Milestone__c = milestone.Id,
            pse__Project__c = servicelineproject.Id
            );
        insert deliverable;
    }
    
    @isTest
    static void testExecuteBatch(){
        //setupTestData();
        Program__c program =[Select Id from Program__c limit 1];
        Set<Id> programIds = new Set<Id>{program.Id};
        test.startTest();
        Database.executeBatch(new BCH_PSA_DeleteRDSProject(programIds), 1);
        test.stopTest();
    }

    /*
    static Program__c program;
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Contact contact;
    static Contact anothercontact;
    static pse__Milestone__c milestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c anotherdeliverable;
    static pse__Resource_Request__c resourcerequest;
    static pse__Project_Task__c projecttask;

    static void setupTestData () {

        //Insert Program
        program = new Program__c(Name = 'TestProgram');
        insert program;

        // parent project
        parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentproject.Program__c = program.id;
        insert parentProject;

        // Service line project
        servicelineproject = UTL_PSA_TestData.createProjects(2, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.Name = 'Test ServiceLine Project';
        insert servicelineproject;

        UTL_PSA_TestData.createPermissionControls();

        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
        
        anothercontact = UTL_PSA_TestData.resources[1];

        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
            );
        insert serviceLine;

        // service
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
            );
        insert service;

        //resoruce request
        resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = servicelineproject.Id;
        insert resourceRequest;


        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task');
        projecttask.pse__Project__c = parentproject.id;
        insert projecttask;

        /*milestones
        milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        //milestone.pse__Project__c = servicelineproject.Id;
        //milestone.Service_Line__c = serviceLine.Id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        insert milestone;

        //Deliverable for milestone

        deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            //pse__Milestone__c = milestone.Id,
            pse__Project__c = servicelineproject.Id
            );
        insert deliverable;
    }
	*/
}