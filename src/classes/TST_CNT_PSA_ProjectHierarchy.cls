/*
 * TST_CNT_PSA_ProjectHierarchy
 *
 * Providing proofs for the CNT PSA Project HierarchyReview page
 *
 *
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_ProjectHierarchy -c -r json
 */
@isTest(isParallel=false)
private class TST_CNT_PSA_ProjectHierarchy 
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
            
        UTL_PSA_TestData.key = 'MS1';
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        insert milestone;
    }

    /**
     * This method used to get a Program by Program Id.
     */
    @IsTest
    static void testGetProgramTree() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        List<CNT_PSA_ProjectHierarchy.ProgramWrapper> programWrapperList = CNT_PSA_ProjectHierarchy.getProgramTree(program.id, 'Program__c' );
        Test.stopTest();
        String expected = 'Program: TestProgram';
        String actual = programWrapperList[0].name;
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Program by Program Id.
     */
    @IsTest
    static void testGetProgramProjectTree() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c where Name='Test Parent Project' limit 1];
        Test.startTest();
        List<CNT_PSA_ProjectHierarchy.ProgramWrapper> programWrapperList = CNT_PSA_ProjectHierarchy.getProgramTree(parentproject.id, 'pse__Proj__c' );
        Test.stopTest();
        String expected = 'Project:Test Parent Project';
        String actual = programWrapperList[0].items[0].name;
        System.assertEquals(expected, actual);
    }

    /*
    static Program__c program;
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Service_Line__c anotherserviceLine;
    static Contact contact;
    static pse__Assignment__c assignment;
    static pse__Milestone__c milestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c anotherdeliverable;
    
    
    static void setupTestData () {
    
        //List<sObject> toInsert = new List<sObject>();
        //Insert Program
        program = new Program__c(Name = 'TestProgram');
        insert program;
    
    
        // parent project
        parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
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
    
    /*
        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
    
        pse__Permission_Control__c pc = UTL_PSA_TestData.createPermissionControls()[0];
        system.debug('Permission control: ');
        system.debug(pc);
        system.debug('Service line project: ');
        system.debug(servicelineproject);
    
        assignment = UTL_PSA_TestData.createAssignments(new List<Contact>{contact},servicelineproject, true)[0];
    
        system.debug('Assignment: ');
        system.debug(assignment);
    
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
    
        // service line
        anotherserviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'pv',
            Name = 'pv'
            );
        insert anotherserviceLine;
    
        // service
        Service__c anotherservice = new Service__c(
            Active__c = true,
            Service_Line__c = anotherserviceLine.id,
            Service_Code__c = 'pv'
    
            );
        insert anotherservice;
    */
    /*
        //milestones
        UTL_PSA_TestData.key = 'MS1';
        milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.pse__Project__c = servicelineproject.Id;
        //milestone.Service_Line__c = serviceLine.Id;
        //milestone.Service__c = service.id;
        //milestone.Start_Date__c = system.today();
        //milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
        insert milestone;
    
    */
    /*
        //Deliverable for milestone
        Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
        deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            //Service__c = service.Id,
            Service__c=UTL_PSA_TestData.services[0],
            pse__Milestone__c = milestone.Id,
            pse__Project__c = servicelineproject.Id,
            Billed__c= false,
            Billable__c=true,
            pse__End_Date_Time__c=System.now(), 
            Type__c='Deliverable',
            RecordTypeId=deliverableRecTypeId
            );
        insert deliverable;
        */
    /*
    }
    */
}