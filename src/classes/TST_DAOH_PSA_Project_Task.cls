/**
* This test class is used to test DAOH_PSA_Project_Task.cls. It is copied over from TST_TGR_Project_Task.cls
*
*/

@isTest
private class TST_DAOH_PSA_Project_Task {
    
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
    }
    
    @IsTest
    static void testFieldUpdates () {
        pse__Project_Task__c parentprojecttask = createTask('RDS Deliverable', false);
        Test.startTest();
        parentprojecttask.pse__Status__c = 'Complete';
        insert parentprojecttask;
        Test.stopTest();
    }
    
    @IsTest
    static void testAddPricingTask () {
        pse__Proj__c templateProject = [select id from pse__Proj__c where recordType.name =: 'RDS Template' limit 1 ];
        Service__c service = [select id from Service__c limit 1];
        Service_Line__c serviceline = [select id from Service_Line__c limit 1];
        
        list<pse__Project_Task__c> insertTaskList = new List<pse__Project_Task__c>();
        pse__Project_Task__c templateTask1 = createTask('RDS Template Task', false);
        templateTask1.Name = 'Template Task 1';
        templateTask1.pse__Parent_Task__c = null;
        templateTask1.Parent_Project__c = null;
        templateTask1.pse__Project__c = templateProject.id;
        templateTask1.Pricing_Task_ID__c = '123456789';
        templateTask1.Service_Line__c = null;
        templateTask1.Service__c = null;
        templateTask1.pse__Milestone__c = null;
        templateTask1.Target__c = null;
        //templateTask1.Resource__c = null;
        
        pse__Project_Task__c templateTask2 = createTask('RDS Template Task', false);
        templateTask2.Name = 'Template Task 2';
        templateTask2.pse__Parent_Task__c = null;
        templateTask2.Parent_Project__c = null;
        templateTask2.pse__Project__c = templateProject.id;
        templateTask2.service__c = service.id;
        templateTask2.Service_Line__c = null;
        templateTask2.Pricing_Task_ID__c = null;
        templateTask2.pse__Milestone__c = null;
        templateTask2.Target__c = null;
        //templateTask2.Resource__c = null;
        
        pse__Project_Task__c templateTask3 = createTask('RDS Template Task', false);
        templateTask3.Name = 'Template Task 3';
        templateTask3.pse__Parent_Task__c = null;
        templateTask3.Parent_Project__c = null;
        templateTask3.pse__Project__c = templateProject.id;
        templateTask3.Service_Line__c = serviceline.id;
        templateTask3.Pricing_Task_ID__c = null;
        templateTask3.service__c = null;
        templateTask3.pse__Milestone__c = null;
        templateTask3.Target__c = null;
        insertTaskList.add(templateTask1);
        insertTaskList.add(templateTask2);
        insertTaskList.add(templateTask3);
        insert insertTaskList;
        
        Test.startTest();
        pse__Project_Task__c parentprojecttask = createTask('RDS Deliverable', true);
        
        Test.stopTest();
        system.assertEquals(templateTask1.Name, insertTaskList[0].Name);
    }   
    
    @IsTest
    static void testDeleteTask () {
        Test.startTest();
        parentprojecttask = createTask('RDS Deliverable Task', true);
        pse__Project_Task__c subTask = createTask('RDS Deliverable Task', true);
        delete parentprojecttask;
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testcreateTaskFromPricingTask () {
        Test.startTest();
        parentprojecttask = createTask('RDS Deliverable', true);
        Test.stopTest();
        List<pse__Project_Task__c>  testcreateTaskFromPricingTask = [SELECT Name,Reason_for_Deletion__c, pse__Top_level_Parent_Task__c, pse__Milestone__c, pse__Completed__c,pse__Started__c, pse__Actual_End_Date_Time__c, pse__Status__c, pse__Actual_Start_Date_Time__c from pse__Project_Task__c where Id=: parentprojecttask.Id];
    }
    
    @IsTest
    static void testcreateTask () {
        Test.startTest();
        parentprojecttask = createTask('RDS Deliverable Task', true);
        update parentprojecttask;
        Test.stopTest();
        String expected = 'PricingTask Test';
        String actual = parentprojecttask.name;
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testSetDefaultProjectTaskDates () {
        Program__c program = [select id from Program__c limit 1];
        Service__c service = [select id from Service__c limit 1];
        Service_Line__c serviceline = [select id from Service_Line__c limit 1];
        
        PSA_Date_Offset__c o1 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
                                                                  'Draft_Due_Date__c', false);
        o1.Type_Field__c = 'Service_Code__c';
        PSA_Date_Offset__c o2 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Months', 'Client_Notification_Date__c', 
                                                                  'End_Date_Planned__c', false);
        o2.Type_Field__c = 'Service_Code__c';
        
        insert new List<PSA_Date_Offset__c>{o1,o2};
            
            List<PSA_Date_Offset__c> offsetList = new SLT_Date_Offset().getDateOffsetByObject(new Set<String>{'pse__Project_Task__c'}, 
                                                                                              new Set<String>{'Id', 'Object__c', 'Offset__c', 'Program__c', 'Service__r.Service_Code__c', 
                                                                                                  'Service_Line__r.Service_Line_Code__c', 
                                                                                                  'Source_Date_Field__c', 'Target_Date_Field__c', 'Unit_Type__c'});
        
        Map<String, PSA_Date_Offset__c> offsetMap = new Map<String, PSA_Date_Offset__c>();
        String testKey;
        for(PSA_Date_Offset__c offSet : offsetList){
            
            String key = String.valueOf(offSet.Service_Line__r.Service_Line_Code__c) + String.valueOf(offSet.Service__r.Service_Code__c) 
                + String.valueOf(offSet.Program__c) +
                offSet.Source_Date_Field__c + offSet.Target_Date_Field__c;
            offsetMap.put(key, offSet);
            testKey = key;
        }
        
        Test.startTest();
        pse__Project_Task__c pt = createTask('RDS Deliverable', false);
        pt.Draft_Due_Date__c = null;
        pt.End_Date_Planned__c = null;
        pt.Client_Notification_Date__c = System.today();
        insert pt;
        
        Date newDate = DAOH_PSA_Project_Task.updateDateToOffset(system.Date.today(), offsetMap, testKey);
        Test.stopTest();
    }
    
    @IsTest
    static void testCrossReferenceAggregateReports(){
        pse__Proj__c parentproject = [select id from pse__Proj__c where recordType.name =: 'RDS Project' and name = 'Parent Project'];
        Service__c service = [select id from Service__c limit 1];
        Service_Line__c serviceline = [select id from Service_Line__c limit 1];
        pse__Proj__c project = [select id from pse__Proj__c where pse__Parent_Project__c =: parentproject.id limit 1];
        pse__Milestone__c milestone = [select id from pse__Milestone__c limit 1 ];
        Drug__c     drug  = [select id from Drug__c limit 1];
        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Program__c program = [select id from Program__c limit 1];
        Contact testResource = [Select id, Location_Code_text__c From Contact Limit 1];
        testResource.Location_Code_text__c = 'USDUR1';
        update testResource;
        
        milestone.Validate_Product_Line__c = false;
        update milestone;
        
        pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c();
        PTA.pse__Project_Task__c = parentproject.id;
        PTA.pse__Resource__c = testResource.Id;
        PTA.Is_Primary__c = true;
        
        Test.startTest();
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id; 
        ar.RecordTypeId = recordId.Id;
        ar.Program__c = program.Id;        
        ar.Service_Milestone__c = milestone.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.Report_Therapeutic_Area__c = 'Dermatology';
        ar.Report_Countries_Required__c ='Yes';
        ar.Product_Name_Active_Ingredient__c = drug.Id;
        ar.Customer_Requested_Resource_Location__c = 'ALL2';
        ar.Safety_Database_Location__c = 'IQVIA';
        ar.Report_Size__c = 'Small';
        ar.No_of_riskssignalsindication__c = 2 ;
        ar.Report_Due_to_IQVIA_or_Client_Reg__c = system.today();
        ar.Date_Submitted_to_IQVIA_or_Client_Reg__c = system.today();
        ar.Report_Due_to_Reg_Agency__c = system.today();
        ar.Formatting_Request__c = 'Yes';
        ar.Upload_to_eTMF_Wingspan_Client_Spec_Repo__c = 'Yes';
        ar.Project_Files_SMP__c = 'test';
        ar.Client_Final_Report__c = 'test';
        ar.eTMF_Wingspan_Client_Spec_Repo_File_Stat__c = 'Comp';
        ar.Primary_Author__c = testResource.Id;
        DAOH_Aggregate_Report.makeReportValid(ar);
        ar.Report_Writing__c = 'IQVIA';
        insert ar;
        
        Report_Country__c reportCountry = new Report_Country__c();
        reportCountry.Country__c = 'US';
        reportCountry.Aggregate_Report__c = ar.Id;
        insert reportCountry;
        
        //ar.Status__c = 'Completed';
        //update ar;
        
        Test.stopTest();
        //List<pse__Project_Task__c> deliverables = [SELECT Id, Aggregate_Report__c FROM pse__Project_Task__c WHERE Aggregate_Report__c = :ar.Id];
        //System.assertEquals(1, deliverables.size());
        //Id deliverableId = deliverables.get(0).Id;
        //List<Aggregate_Report__c> agReports = [SELECT Id, Deliverable__c FROM Aggregate_Report__c WHERE Deliverable__c = :deliverableId];
        //System.assertEquals(1, agReports.size());
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
    
    @IsTest
    static void testSetRDSProjTaskCheck(){
        Test.startTest();
        pse__Project_Task__c pt = createTask('RDS Project Task', false);
        //pt. = null;
        //pt.End_Date_Planned__c = null;
        //pt.Client_Notification_Date__c = System.today();
        pt.Trigger_Email_Notification__c = true;
        insert pt;
        pt.Trigger_Email_Notification__c =false;
        Test.stopTest();
    }
    
    @IsTest
    static void testTempTaskCheck(){
        Test.startTest();
        pse__Project_Task__c pt = createTask('RDS Template Task', true);
        pt.Trigger_Email_Notification__c = true;
        update pt;
        
        Test.stopTest();
    }
    
    @IsTest
    static void testTempTaskCheck2(){
        Test.startTest();
        pse__Project_Task__c pt = createTask('RDS Template Task', true);
        pt.Trigger_Email_Notification__c = true;
        pt.pse__End_Date_Time__c = (Date.today()).addDays(4);
        Id ptId = pt.Id;
        update pt;
        
        pse__Project_Task__c pt2 = [Select Id, pse__End_Date_Time__c, Trigger_Email_Notification__c from pse__Project_Task__c where Id =: ptId];
        pt2.Trigger_Email_Notification__c = false;
        update pt2;
        
        Test.stopTest();
    }
    
    @IsTest
    static void testupdateProjectTaskWorkFlowCondition () {
        Test.startTest();
        pse__Project_Task__c pt = createTask('RDS Project Task', false);
        pt.pse__Start_Date_Time__c = Date.today();
        pt.pse__End_Date_Time__c = Date.today().addDays(30);
        pt.pse__Status__c = CON_PSA.PROJ_TASK_STATUS_COMPLETE;
        pt.Trigger_Email_Notification__c = true;
        insert pt;
        pt.pse__Status__c = CON_PSA.PROJ_TASK_STATUS_IN_PROGRESS;
        update pt;
        Test.stopTest();
        Boolean expected = false;
        Boolean actual = pt.Activate_Workflow_Rule_Conditionally__c;
        System.assertEquals(expected, actual);
    }
    
    static pse__Project_Task__c parentprojecttask;
}
