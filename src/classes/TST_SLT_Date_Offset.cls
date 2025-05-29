/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Date_Offset
 */
@isTest
private class TST_SLT_Date_Offset {
    
    @isTest
    static void testGetDateOffsetByObject(){

        setupTestData();

        PSA_Date_Offset__c o2 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
        'End_Date_Planned__c', true);

        Test.startTest();
        SLT_Date_Offset os = new SLT_Date_Offset();
        List<PSA_Date_Offset__c> osList = os.getDateOffsetByObject(new Set<String>{'pse__Project_Task__c'}, new Set<String>{'Id'});
        os.getSObjectFieldList();
        os.getSObjectType();
        Test.stopTest();
        System.assert(osList.size() == 1);

    }

    static Program__c program;
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c templateProject;
    static pse__Project_Task__c parentprojecttask;
    static pse__Project_Task__c topprojecttask;
    static pse__Project_Task_Assignment__c PTA;
    static pse__Milestone__c milestone;
    static Contact contact;
    //static Contact anothercontact;
    static Target__c target;
    static Service__c service;
    static Pricing_Task__c pricingtask;
    static Service_Line__c serviceline;
    static pse__Assignment__c assignment;

    static void setupTestData () {

        UTL_PSA_TestData.createPermissionControls();


        program = new Program__c(Name = 'TestProgram');
        insert program;

        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;

        //anothercontact = UTL_PSA_TestData.resources[1];

        list<pse__Proj__c> projInsertList = new list<pse__Proj__c>();
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        projInsertList.add(project);

        /*assignment
        assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {contact},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;*/

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
        insert milestone;
        
        //target
        target = new Target__c();
        target.Single_Country__c = 'US';
        target.Strength__c = '50';
        target.Dosage_Form__c = '100';
        target.Program__c = program.id;
        target.Inactivated_Date__c = system.today();
        target.Date_Activated__c = System.today();
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

        //Parent Project Task
        parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
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
        parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Include_in_Financials__c = true;
    }
}
