/*
 * TST_CNT_PSA_ManageDeliverables
 *
 * Providing proofs for the CNT PSA Manage Deliverables page
 *
 *
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_ManageDeliverables -c -r json
 */
@isTest(isParallel=false)
private class TST_CNT_PSA_ManageDeliverables 
{
    @testSetup
    static void dataSetup() 
    {
        Program__c program = UTL_PSA_TestData.programs[0];
 
        Account account = UTL_PSA_TestData.accounts[0];
        UTL_PSA_TestData.createPermissionControls();

        pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentProject.recordTypeId = rdsrecTypeId;
        parentProject.Name = 'Test Parent Project';
        parentProject.pse__Account__c = account.id;
        insert parentProject;
    
        // Service line project
        pse__Proj__c servicelineproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        servicelineproject.recordTypeId = recTypeId;
        servicelineproject.pse__Parent_Project__c = parentProject.id;
        servicelineproject.pse__Account__c= account.id;
        servicelineproject.pse__Exclude_From_Billing__c = false;
        servicelineproject.Program__c = program.Id;
        insert servicelineproject;
    
        //resource request
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        resourcerequest.pse__Project__c = servicelineproject.Id;
        insert resourcerequest;
    
    
        //contacts
        Contact contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
    
        // service line
        Service_Line__c serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'ADP',
            Name = 'ADP'
        );
        insert serviceLine;
    
        // service
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'ADP'
        );
        insert service;
    
        //milestones
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
    
        //Deliverable for milestone
        pse__Project_Task__c deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            Service_Line__c= serviceLine.id,
            pse__Milestone__c = milestone.id,
            pse__Project__c = servicelineproject.id,
            Billable__c=true
        );
        insert deliverable;
     
        //assignment for Deliverable
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {contact},servicelineproject,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;
            
    }
    
    @isTest static void testGetTargetsByProgram(){
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        Target__c target = new Target__C(
        Name='Test Target',
        API__c='Test API',
        Strength__c='Super strong',
        Dosage_Form__c='Huge pill',
        Program__c=program.Id,
        Inactivated_Date__c = system.today(),
        Date_Activated__c = system.today(),
        Countries_NA__c = true
        );
        insert target;

        CNT_PSA_ManageDeliverables.getTargetsByProgram(program.Id);
        Test.stopTest();
    }

    @isTest static void testGetProjectTasksByMilestone() {
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id from pse__Project_Task__c limit 1];
        Contact contact = [Select Id from Contact limit 1];
        pse__Milestone__c milestone = [Select Id from pse__Milestone__c limit 1];
        test.startTest();
        pse__Project_Task_Assignment__c projecttaskassignment = new pse__Project_Task_Assignment__c(
            pse__Project_Task__c = deliverable.id,
            pse__Resource__c = contact.id
            );
        insert projecttaskassignment;
        
        List<pse__Project_Task__c> projecttasks = CNT_PSA_ManageDeliverables.getProjectTasksByMilestone(milestone.id,new List<String> {'Service_Line__c'});
        system.assertEquals(deliverable.id, projecttasks[0].id);
        test.stopTest();
    }


    @isTest static void testGetTaskAssignmentsByMilestone() {
        //setupTestData();
        pse__Project_Task__c deliverable = [Select Id from pse__Project_Task__c limit 1];
        Contact contact = [Select Id from Contact limit 1];
        pse__Milestone__c milestone = [Select Id from pse__Milestone__c limit 1];
        test.startTest();
        pse__Project_Task_Assignment__c projecttaskassignment = new pse__Project_Task_Assignment__c(
            pse__Project_Task__c = deliverable.id,
            pse__Resource__c = contact.id
        );
        insert projecttaskassignment;
        List<pse__Project_Task_Assignment__c> projecttaskassignments = CNT_PSA_ManageDeliverables.getTaskAssignmentsByMilestone(milestone.id,new List<String> {'pse__Resource__c'});
        system.assertEquals(projecttaskassignment.id, projecttaskassignments[0].id);
        test.stopTest();
    }

    @isTest static void testGetServiceLineDeliverableFields() {
        //setupTestData();
        Service_Line__c serviceLine = [Select Id, Name,  Service_Line_Code__c from Service_Line__c limit 1];
        Service__c service = [Select Id, Name, Service_Code__c from Service__c limit 1];
        test.startTest();
        List<String> taskFields = CNT_PSA_ManageDeliverables.getServiceLineDeliverableFields(service.Service_Code__c,serviceLine.Service_Line_Code__c);
        system.assertNotEquals(null, taskFields.size());
        test.stopTest();
    }
    
    @isTest static void testGetGeneralDeliverableFields() {
        //setupTestData();
        test.startTest();
        List<String> taskFields = CNT_PSA_ManageDeliverables.getGeneralDeliverableFields();
        system.assertNotEquals(null, taskFields.size());
        test.stopTest();
    }

    @isTest static void testGetBillingDeliverableFields() {
        //setupTestData();
        test.startTest();
        List<String> taskFields = CNT_PSA_ManageDeliverables.getBillingDeliverableFields();
        system.assertNotEquals(null, taskFields.size());
        test.stopTest();
    }

    @isTest static void testGetServiceLineTaskFields() {
        //setupTestData();
        Service_Line__c serviceLine = [Select Id, Name,  Service_Line_Code__c from Service_Line__c limit 1];
        test.startTest();
        List<String> taskFields = CNT_PSA_ManageDeliverables.getServiceLineTaskFields(serviceLine.id);
        system.assertNotEquals(null, taskFields.size());
        test.stopTest();
    }


    @isTest static void testGetGeneralTaskFields() {
        //setupTestData();
        test.startTest();
        List<String> taskFields  = CNT_PSA_ManageDeliverables.getGeneralTaskFields();
        system.assertNotEquals(null, taskFields.size());
        test.stopTest();
    }

    @isTest static void testGetServiceLineInfo() {
        //setupTestData();
        Service_Line__c serviceLine = [Select Id, Name,  Service_Line_Code__c from Service_Line__c limit 1];
        test.startTest();
        Service_Line__c servicelineresult = CNT_PSA_ManageDeliverables.getServiceLineInfo(serviceLine.id);
        system.assertEquals(serviceline.id, servicelineresult.id);
        test.stopTest();
    }

    @isTest static void testGetProjectsByProgram() {
        //setupTestData();
        pse__Proj__c servicelineproject = [Select Id,pse__Stage__c,Service_Line__c from pse__Proj__c where pse__Parent_Project__c != NULL];
        Service_Line__c serviceLine = [Select Id, Name,  Service_Line_Code__c from Service_Line__c limit 1];
        Program__c program = [Select Id, Name from Program__c limit 1];
        
        servicelineproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        servicelineproject.Service_Line__c = serviceLine.Id;
        update servicelineproject;
        serviceLine.Service_Line_Code__c = 'PVA';
        update serviceLine;
        
        test.startTest();
        List<pse__Proj__c> projectList = CNT_PSA_ManageDeliverables.getProjectsByProgram(program.Id);
        system.assert(projectList.size() > 0);
        test.stopTest();
    }

    @isTest static void testGetMilestonesByProject() {
        //setupTestData();
        pse__Proj__c servicelineproject = [Select Id,pse__Stage__c,Service_Line__c from pse__Proj__c where pse__Parent_Project__c != NULL];
       
        test.startTest();
        List<pse__Milestone__c> msList = CNT_PSA_ManageDeliverables.getMilestonesByProject(servicelineproject.Id);
        system.assert(msList.size() > 0);
        test.stopTest();
    } 

    @isTest static void testCheckDateOffset() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Service_Line__c serviceLine = [Select Id, Name,  Service_Line_Code__c from Service_Line__c limit 1];
    	Service__c service = [Select Id, Name, Service_Code__c from Service__c limit 1];
        
        PSA_Date_Offset__c o1 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
        'Draft_Due_Date__c', true);
        PSA_Date_Offset__c o2 = UTL_PSA_TestData.createDateOffset(program.Id, service.Id, serviceLine.Id, null, 'pse__Project_Task__c', 5.0, 'Weekday', 'Client_Notification_Date__c', 
        'End_Date_Planned__c', true);
        test.startTest();
        Date dueDate = null;
        Date endDate = null;
        Map<String, Object> dateMap = CNT_PSA_ManageDeliverables.checkDateOffset( serviceLine.Service_Line_Code__c, service.Service_Code__c, program.Id, System.today(),
        endDate, dueDate  );
        system.assert(dateMap.size() > 0);
        test.stopTest();
    }
    
    @isTest static void testgetFieldIsEditableForBillingSection() {
        CNT_PSA_ManageDeliverables.getFieldIsEditableForBillingSection();
    }

    /*
    static Account account;
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
    static pse__Resource_Request__c anotherresourcerequest;
    static pse__Assignment__c assignment;
    static pse__Project_Task_Assignment__c projecttaskassignment;
    static Service__c service;
    static Program__c program;
    
    static void setupTestData () {
    
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
    
        //resource request
        resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        resourcerequest.pse__Project__c = servicelineproject.Id;
        insert resourcerequest;
    
        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
    
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
        deliverable = new pse__Project_Task__c(
        Quantity__c = 100,
        Resource__c = contact.Id,
        Billing_Hold__c = true,
        Include_in_Financials__c=true,
        Service__c = service.Id,
        Service_Line__c= serviceLine.id,
        pse__Milestone__c = milestone.id,
        pse__Project__c = servicelineproject.id,
        Billable__c=true
        );
        insert deliverable;
     
        //assignment for Deliverable
        assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {contact},servicelineproject,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;
    }
	*/
} 