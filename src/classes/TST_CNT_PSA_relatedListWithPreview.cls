@isTest
private class TST_CNT_PSA_relatedListWithPreview {
    @testSetup
    static void dataSetup() 
	{
     	Contact contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;

        Program__c program = UTL_PSA_TestData.programs[0];

        Account account = UTL_PSA_TestData.accounts[0];
        UTL_PSA_TestData.createPermissionControls();

        pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentProject.pse__Account__c = account.id;
        insert parentProject;

        pse__Proj__c servicelineproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.pse__Account__c= account.id;
        servicelineproject.pse__Exclude_From_Billing__c = false;
        servicelineproject.Program__c = program.Id;
        insert servicelineproject;

        Service_Line__c serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'ADP',
            Name = 'ADP'
            );
        insert serviceLine;

        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'ADP'
            );
        insert service;

        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Service__c = service.id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        milestone.pse__Exclude_from_Billing__c = false;
        insert milestone;
        
        //Pricing Task
        Pricing_Task__c pricingtask = new Pricing_Task__c(Name = 'PricingTask Test');
        pricingtask.Project__c = parentproject.id;
        pricingtask.Service__c = service.id;
        pricingtask.Service_Milestone__c = milestone.id;
        pricingtask.Budget_Hours__c = 20;
        pricingtask.Task_Id__c = '123456789';
        insert pricingtask;
        
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
        
        pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
        parentprojecttask.recordTypeId = deliverableRecTypeId;
        parentprojecttask.pse__Project__c = servicelineproject.id;
        parentprojecttask.pse__Milestone__c = milestone.id;
        parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
        parentprojecttask.Service_Line__c = serviceline.id;
        parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
        parentprojecttask.pse__Status__c = 'Planned';
        parentprojecttask.Unit_Price__c = 200;
        parentprojecttask.Budgeted_Hours__c = 10;
        parentprojecttask.Role__c = 'Coordinator';
        parentprojecttask.Include_in_Financials__c = true;
        parentprojecttask.Resource__c = Contact.Id;
        
        pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
        PTA2.pse__Project_Task__c = parentprojecttask.id;
        PTA2.pse__Resource__c = contact.Id;
        PTA2.Is_Primary__c = true;

		pse__Project_Task__c projecttask = new pse__Project_Task__c();
        projecttask.Name = pricingtask.Name;
        projecttask.pse__Project__c = parentprojecttask.pse__Project__c;
        projecttask.Parent_Project__c = pricingtask.Project__c;
        projecttask.pse__Milestone__c = parentprojecttask.pse__Milestone__c;
        //projecttask.Target__c = target.id;
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
        
        pse__Project_Task__c deliverable = new pse__Project_Task__c(
            RecordTypeId=deliverableRecTypeId,
            Quantity__c = 100,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            Service_Line__c= serviceLine.id,
            pse__Milestone__c = milestone.id,
            pse__Project__c = servicelineproject.id,
            Billable__c=true,
            pse__Parent_Task__c = parentprojecttask.Id,
            resource__c = contact.Id
            );
        insert deliverable;
		
        Id deliverableTaskRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE_TASK);
        pse__Project_Task__c childTask = new pse__Project_Task__c(
            RecordTypeId=deliverableTaskRecTypeId,
            pse__Parent_Task__c=deliverable.Id,
            pse__Milestone__c = milestone.id
        );
        insert childTask;
    }
    
    
    @isTest
    static void testGetProjectTaskPreviewItems(){
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id,Billable__c from pse__Project_Task__c where Billable__c = true and recordtype.name = 'RDS DELIVERABLE'];
        Test.startTest();
        CNT_PSA_relatedListWithPreview.AuraResult auraResult = CNT_PSA_relatedListWithPreview.getProjectTaskPreviewItems(deliverable.Id);
        Test.stopTest();
    }

    /*
    static Account account;
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static Service_Line__c serviceLine;
    static pse__Milestone__c milestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c childTask;
    static Service__c service;
    static Program__c program;
    static Contact contact;

    static void setupTestData () {

        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;

        program = UTL_PSA_TestData.programs[0];

        // Account
        account = UTL_PSA_TestData.accounts[0];
        UTL_PSA_TestData.createPermissionControls();
        System.debug(UTL_PSA_TestData.createPermissionControls());


        // parent project
        parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentProject.pse__Account__c = account.id;
        insert parentProject;

        // Service line project
        servicelineproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.pse__Account__c= account.id;
        servicelineproject.pse__Exclude_From_Billing__c = false;
        servicelineproject.Program__c = program.Id;
        insert servicelineproject;

        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'ADP',
            Name = 'ADP'
            );
        insert serviceLine;

        // service
        service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'ADP'
            );
        insert service;

        //milestones
        milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        milestone.Service_Line__c = serviceLine.Id;
        milestone.Service__c = service.id;
        milestone.Start_Date__c = system.today();
        milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        milestone.pse__Exclude_from_Billing__c = false;
        insert milestone;

        //Deliverable for milestone
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
        deliverable = new pse__Project_Task__c(
            RecordTypeId=deliverableRecTypeId,
            Quantity__c = 100,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            Service_Line__c= serviceLine.id,
            pse__Milestone__c = milestone.id,
            pse__Project__c = servicelineproject.id,
            Billable__c=true
            );
        insert deliverable;

        Id deliverableTaskRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE_TASK);
        childTask = new pse__Project_Task__c(
            RecordTypeId=deliverableTaskRecTypeId,
            pse__Parent_Task__c=deliverable.Id,
            pse__Milestone__c = milestone.id
        );
        insert childTask;
    
    }
    */
}