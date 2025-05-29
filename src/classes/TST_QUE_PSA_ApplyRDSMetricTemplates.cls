/**
 * This test class is used to test QUE_PSA_ApplyRDSMetricTemplates.
 * 
 * version : 1.0
 */

@isTest
private class TST_QUE_PSA_ApplyRDSMetricTemplates {
 	@testSetup
    static void dataSetup() 
	{
        //Program
        Program__c program = new Program__c(Name = 'Test Program');
        insert program;

        //contacts
        Contact contact = UTL_PSA_TestData.resources[0];
        Contact anothercontact = UTL_PSA_TestData.resources[1];

        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentProject.Program__c = program.Id;
        insert parentproject;
      
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        projInsertList.add(project);
        
        pse__Proj__c templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
        recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');  
        templateProject.recordTypeId = recTypeId;
        templateProject.pse__Project_Status__c = 'Start-up';
        templateProject.pse__Is_Template__c = true;
        projInsertList.add(templateProject);

        insert projInsertList;

        UTL_PSA_TestData.createPermissionControls(); 

        //service line
        Service_Line__c serviceline = new Service_Line__c(Name = 'Test Service Line');
        serviceline.Service_Line_Code__c = '09876';
        insert serviceline;

        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.id;
        insert service;
		
        
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
        milestone.Action_Apply_Standard_Metrics__c = true;
        insert milestone;
    }

        @IsTest
        static void testProjectMetric () {
        //setupTestData();
         Service_Line__c serviceline =[Select Id, Name from Service_Line__c limit 1];
        Service__c service = [Select Id, Name from Service__c where Service_Line__c =: serviceline.id];
        pse__Milestone__c milestone = [Select Id, Name,Service_Line__c,Service__c,pse__Project__c from pse__Milestone__c where Service_Line__c =: serviceline.id];
        QUE_PSA_ApplyRDSMetricTemplates qObj = new QUE_PSA_ApplyRDSMetricTemplates(new List<pse__Milestone__c>{milestone});
        
        Test.startTest();
        PSA_Metric__c psaMetric1 = new PSA_Metric__c();
        psaMetric1.Service_Line__c = serviceline.id;
        psaMetric1.Service__c = service.id;
        psaMetric1.External_ID__c = '123456';
        psaMetric1.Active__c = true;
        psaMetric1.Non_Standard__c = false;

        insert psaMetric1;

        System.enqueueJob(qObj);

        Test.stopTest();

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
    static PSA_Metric__c psametric;
    static Project_Metric__c projectmetric;
    static Program__c program;
    
    
    static void setupTestData () {
      
        //Program
        program = new Program__c(Name = 'Test Program');
        insert program;

        //contacts
        contact = UTL_PSA_TestData.resources[0];
        anothercontact = UTL_PSA_TestData.resources[1];

        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentProject.Program__c = program.Id;
        insert parentproject;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
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
        milestone.Service_Line__c = serviceline.id;
        milestone.Action_Apply_Standard_Metrics__c = true;
        insert milestone;
        system.debug('&&& milestoneid '+milestone.id);


        //RDS Settings

        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Task_Template_ID__c = templateProject.id;
        insert rdsSettings;
        System.debug('&&& inserted sub project');
    
         //target
        target = new Target__c();
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.Id;
        target.Inactivated_Date__c = system.today();
        target.Date_Activated__c = system.today();
        insert target;
        System.debug('&&&& inserted TARGET');

        //Pricing Task
        pricingtask = new Pricing_Task__c(Name = 'PricingTask Test');
        pricingtask.Project__c = parentproject.id;
        pricingtask.Service__c = service.id;
        pricingtask.Service_Milestone__c = milestone.id;
        pricingtask.Budget_Hours__c = 20;
        pricingtask.Task_Id__c = '123456789';
        insert pricingtask;
        
        //top project task
        /*topprojecttask = new pse__Project_Task__c(Name = 'TopPT');
        topprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable'); 
        topprojecttask.pse__Project__c = project.id;
    
    }

    static PSA_Metric__c createMetric(boolean isInsert){
        PSA_Metric__c psametric = new PSA_Metric__c();
        psametric.Name = 'Test PSA Metric';
        psametric.External_ID__c = '678';
        //psametric.PSA_Metric_Unique_ID__c = 'UID678';
        psametric.Green_Threshold__c = 'psametric Green Threshold';
        psametric.Amber_Threshold__c = 'psametric Amber Threshold';
        psametric.Location__c = 'QART';
        psametric.Red_Threshold__c = 'psametric Red Threshold';
        psametric.Automated_Date__c = System.Date.Today();
        psametric.Source_System__c = 'PSA';
        
        if (isInsert){
            insert psametric;
        } 

        return psametric;
        }
		*/
    
    }