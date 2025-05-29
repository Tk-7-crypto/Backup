/**
 * This test class is used to test BCH_PSA_CDCHealthCheckup batch class.
 * version : 1.0
 */
@isTest
private class TST_BCH_PSA_CDCHealthCheckup {

 /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();
        
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Contact
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;
        Contact contact = testResource;
        
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
        
        pse__Proj__c templateProject = UTL_PSA_TestData.createProjects(1, false)[0];
        recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', 'RDS Template');
        templateProject.recordTypeId = recTypeId;
        templateProject.pse__Project_Status__c = 'Start-up';
        templateProject.pse__Is_Template__c = true;
        insert templateProject;
        
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Total_Fields_of_Aggregate_Report__c = 304;
        rdsSettings.Total_Fields_of_Project_Task__c = 219;
        rdsSettings.Total_Fields_of_Project_Log__c = 74;
        rdsSettings.Total_Fields_of_Target__c = 58;
        rdsSettings.User_Ids__c = UserInfo.getUserId();
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
        //  parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        //  parentprojecttask.pse__Top_level_Parent_Task__c = topprojecttask.id;
        parentprojecttask.Include_in_Financials__c = true;
        parentprojecttask.Resource__c = Contact.Id;
        test.startTest();
        //insert parentprojecttask;
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;
        
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
        projecttask.Resource__c = Contact.Id;
        insert projecttask;
        
        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.RecordTypeId = recordId.Id;
        ar.Comments__c='Test Comment DELETE';
        ar.Delete_Reason__c = 'Test';
        insert ar;
        
        Account account = UTL_PSA_TestData.accounts[0];
        account.Name = 'Test Account';
        Project_Log__c projectLog = new Project_Log__c();
        projectLog.Account__c = account.id;
        projectLog.Title__c='Test';
        projectLog.Program__c = program.id;
        insert projectLog;

        test.stopTest();
    }
    
    /**
    * This test method used to test BCH_PSA_CDCHealthCheckup batch class.
    */ 
    static testMethod void testBCH_PSA_CDCHealthCheckup() {
        Test.StartTest() ;
            BCH_PSA_CDCHealthCheckup batch = new BCH_PSA_CDCHealthCheckup();
            database.executeBatch(batch, 4);   
            BCH_PSA_CDCHealthCheckup batch2 = new BCH_PSA_CDCHealthCheckup();
            database.executeBatch(batch2, 4);        
        Test.StopTest() ;
    }

}
