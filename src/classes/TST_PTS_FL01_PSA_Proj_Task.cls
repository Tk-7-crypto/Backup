/*
* Test class for FLOW- PTS_FL01_PSA_Proj_Task
*/
@IsTest
public class TST_PTS_FL01_PSA_Proj_Task {
@testSetup
    static void dataSetup() 
    {
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Contact
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;
        
        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.name = 'Parent Project';
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
        projInsertList.add(project);
        
        
        
        pse__Proj__c templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
        recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_TEMPLATE);
        templateProject.recordTypeId = recTypeId;
        templateProject.pse__Project_Status__c = 'Start-up';
        templateProject.pse__Is_Template__c = true;
        projInsertList.add(templateProject);
        insert projInsertList;
        
         // Assignment 
         List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource, testResource, testResource},project,false);
        assignments[0].pse__Bill_Rate__c = 200;
        assignments[0].Sub_role__c = 'IQVIA Primary GSO';
        assignments[1].pse__Bill_Rate__c = 200;
        assignments[1].Sub_role__c = 'IQVIA GSO LM';
        assignments[2].pse__Bill_Rate__c = 200;
        assignments[2].Sub_role__c = 'IQVIA TAH';
        system.debug('Assignments: ');
        system.debug(assignments);
        insert assignments;
        
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
        milestone.Validate_Product_Line__c = true;
        insert milestone;
        
       
        
        //drug
        Drug__c drug = new Drug__c();
        drug.Service_Lines__c = 'Aggregate Reporting';
        drug.program__c = program.id;
        drug.name = 'Test Drug';
        insert drug;
        
        insert new pse__Task_Management_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), pse__Track_Points_History_Disabled__c=true);
        
        //target
        Target__c target = new Target__c();
        target.recordtypeid = CON_PSA.TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE;
        target.drug__c = drug.id;
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.id;
        target.Active__c = true;
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
        pse__Project_Task__c pt = createTask('RDS Project Task', false);
        insert pt;
    }
    static pse__Project_Task__c createTask(String recordType, boolean isInsert){
        
        Program__c program = [select id from Program__c limit 1];
        Contact Contact = [select id from contact limit 1];
        pse__Proj__c parentproject = [select id from pse__Proj__c where recordType.name =: 'RDS Project' and name = 'Parent Project'];
        Service__c service = [select id from Service__c limit 1];
        Service_Line__c serviceline = [select id from Service_Line__c limit 1];
        pse__Proj__c project = [select id from pse__Proj__c where pse__Parent_Project__c =: parentproject.id limit 1];
        pse__Proj__c templateProject = [select id from pse__Proj__c where recordType.name =: 'RDS Template' limit 1 ];
        pse__Milestone__c milestone = [select id from pse__Milestone__c limit 1 ];
        Drug__c     drug  = [select id from Drug__c limit 1];
        Target__c target = [select id from Target__c limit 1];
        Pricing_Task__c pricingtask = [select id,Name,Project__c,Budget_Hours__c,Role__c,Task_Id__c from Pricing_Task__c limit 1];
        
        //Parent Project Task
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable');
        parentprojecttask.pse__Project__c = project.id;
        parentprojecttask.pse__Milestone__c = milestone.id;
        parentprojecttask.Target__c = target.id;
        parentprojecttask.Countries__c = 'US;';
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.Include_in_Financials__c = true;
        parentprojecttask.Drug__c = drug.id;
        parentprojecttask.Resource__c = Contact.Id;
        
        pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c();
        PTA.pse__Project_Task__c = parentprojecttask.id;
        PTA.pse__Resource__c = contact.Id;
        PTA.Is_Primary__c = true;
        
        pse__Project_Task__c projecttask = new pse__Project_Task__c();
        projecttask.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', RecordType);
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
        projecttask.Drug__c = drug.id;
        projecttask.Countries__c = 'US;';
        projecttask.Service_Line__c = parentprojecttask.Service_Line__c;
        projecttask.Reason_for_Deletion__c = 'Delete pt';
        projecttask.pse__Parent_Task__c = parentprojecttask.id;
        projecttask.Program__c = program.id;
        projecttask.Resource__c = Contact.Id;
        if (isInsert) {
            insert projecttask;
        }
        return projecttask;
    }
    
    @isTest
    static void testRequestResourceEmailNotification(){
       
        Test.startTest();
        pse__Project_Task__c pt = [Select Id,Trigger_Past_Due_Workflow__c from pse__Project_Task__c where pse__Project__c != Null limit 1];
        Test.stopTest();
        System.assertEquals(pt.Trigger_Past_Due_Workflow__c, TRUE);      
    
    }
}