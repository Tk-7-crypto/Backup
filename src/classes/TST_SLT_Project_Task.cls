/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Project_Task
 */


@isTest
private class TST_SLT_Project_Task {

    
    //Test get list of field names from field set by field set name
    @IsTest
    static void testgetFieldListByFieldSetName () {
        setupTestData();
        Test.startTest();
        
        List<String> fieldSetName = new SLT_Project_Task().getFieldListByFieldSetName('PSA_RDS_Deliverable_AR');
        //List<pse__Project_Task__c> idToServiceCode = new SLT_Project_Task().getFieldListByFieldSetName(fieldSetName);
        //sltProjectTaskAssignment.getSObjectType();
        Test.stopTest();
        Integer expected = 0;
        Integer actual = fieldSetName.size();
        System.assertNotEquals(expected, actual);


    }
   //Test get list of field names from field set by field set name
    @IsTest
    static void testgetFieldListByFieldSetNameSets () {
        setupTestData();
        Test.startTest();
        
        List<String> fieldSetName = new SLT_Project_Task().getFieldListByFieldSetName(new Set<String>{'PSA_RDS_Deliverable_AR'});
        //List<pse__Project_Task__c> idToServiceCode = new SLT_Project_Task().getFieldListByFieldSetName(fieldSetName);
        //sltProjectTaskAssignment.getSObjectType();
        Test.stopTest();
        Integer expected = 0;
        Integer actual = fieldSetName.size();
        System.assertNotEquals(expected, actual);


    }
    
   /**
     * This method used to get a Project Task by Id.
     */    
    @IsTest
    static void testgetProjectTaskById() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        Map<Id,pse__Project_Task__c> idToProjectTask = new SLT_Project_Task().getProjectTaskById(new Set<Id> {projecttask.id}, fieldSet );
        Test.stopTest();
        String expected = 'PTATestPT';
        String actual = idToProjectTask.get(projecttask.id).Name;
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Project Task by Service Code.
     */    
    @IsTest
    static void testgetProjectTaskByServiceCode() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        //Set<String> serviceCodeSet = new Set<String>{'Service_Code__c'};
        List<pse__Project_Task__c> idToServiceCode = new SLT_Project_Task().getTemplateTasksByServiceCode(new Set<String> {projecttask.Service_Code__c}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToServiceCode.size();
        System.assertEquals(expected, actual);
    }
    
    /*
     * By Vikas Soni
     * This method used to get a Project Task by Service Line Project
	getRDSRecordTypeProjectTasksByServiceLineProject
	*/
    @IsTest
    static void testgetRDSRecordTypeProjectTasksByServiceLineProject() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        List<pse__Project_Task__c> idToServiceLineTasks = new SLT_Project_Task().getRDSRecordTypeProjectTasksByServiceLineProject(new Set<Id> {project.Service_Line__c}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToServiceLineTasks.size();
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    static void testgetProjectTasksByServiceLineProject() {
        setupTestData();
        Test.startTest();
        //List<pse__Proj__c> projectList = new List<pse__Proj__c>();
        Set<String> fieldSet = new Set<String>{'Id','Service_Line_Scope__c','pse__Project__c'};
        List<pse__Project_Task__c> idToServiceLineTasks = new SLT_Project_Task().getProjectTasksByServiceLineProject(new Set<Id> {project.Id}, fieldSet );
        Test.stopTest();
        Integer expected = 2;
        Integer actual = idToServiceLineTasks.size();
        System.assertEquals(expected, actual);
    }
    
    /*
     * By Vikas Soni
     * This method used to get a Project Task by RDS Project
	getRDSRecordTypeProjectTasksByServiceLineProject
	*/
    @IsTest
    static void testgetRDSRecordTypeProjectTasksByRDSProject() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        List<pse__Project_Task__c> idToRDSTasks = new SLT_Project_Task().getRDSRecordTypeProjectTasksByRDSProject(new Set<Id> {parentproject.Id}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToRDSTasks.size();
        System.assertEquals(expected, actual);
    }
    
    /*
     * This method used to test getProjectTaskByIdAndCondition of SLT_Project_Task to get project tasks conditionally
	*/
    @IsTest
    static void testgetProjectTaskByIdAndCondition() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id', 'pse__Actual_End_Date_Time__c', 'RecordTypeId', 'pse__End_Date__c', 'Trigger_Email_Notification__c',
            'Parent_Project__r.RecordTypeId', 'pse__Project__r.RecordTypeId', 'Parent_Project__r.pse__Stage__c',
            'pse__Status__c', 'pse__End_Date_Time__c', 'pse__Actual_End_Date__c', 'pse__Project__r.pse__Stage__c','Activate_Workflow_Rule_Conditionally__c'};
        List<pse__Project_Task__c> projectTasks = new SLT_Project_Task().getProjectTaskByIdAndCondition(new Set<Id> {projecttask.Id}, fieldSet , '');
        Test.stopTest();
        Integer expected = 1;
        Integer actual = projectTasks.size();
        System.assertEquals(expected, actual);
    }

	/*
     * This method used to get a Project Task by Service Line.
     */    
    @IsTest
    static void testgetProjectTaskByServiceLine() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        List<pse__Project_Task__c> idToServiceLine = new SLT_Project_Task().getTemplateTasksByServiceLine(new Set<String> {projecttask.Service_Line__c}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToServiceLine.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get deliverable by service milestone
     */
    @IsTest
    static void testgetDeliverableByServiceMilestone() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Milestone__c'};
        List<pse__Project_Task__c> deliverablesByMilestone = new SLT_Project_Task().getDeliverableByServiceMilestone(new Set<String> {milestoneService.Id}, fieldSet );
        Test.stopTest();
        Integer expected = 1;
        Integer actual = deliverablesByMilestone.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Project Task by Program.
     */    
    @IsTest
    static void testgetProjectTaskByProgram() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        List<pse__Project_Task__c> idToProgram = new SLT_Project_Task().getProjectTasksByProgram(new Set<Id> {projecttask.id}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToProgram.size();
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get a Project Task list by Pricing Task Id. RETEST - MISSING LIST COVERAGE IN MIDDLE
     */    
    @IsTest
    static void testgetProjectTaskByPricingTask() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c', 'Pricing_Task_ID__c', 'RecordTypeId'};
        //List<pse__Project_Task__c> pricingTaskId = new SLT_Project_Task().selectByPricingTaskId(new Set<String> {projecttask.Pricing_Task_ID__c}, fieldSet );
        Map<String, List<pse__Project_Task__c>> pricingTaskId = new SLT_Project_Task().selectByPricingTaskId(new Set<String> {projecttask.Pricing_Task_ID__c}, fieldSet );
         System.debug('$$$ Got the project task map'+pricingTaskId);
        Test.stopTest();
    }


     /**
     * This method used to get a Project Task by Milestone Id and Billing Milestone Id.
    */ 
    @IsTest
    static void testgetProjectTaskByMilestone() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c'};
        List<pse__Project_Task__c> idToMilestone = new SLT_Project_Task().getProjectTasksByMilestone(new Set<Id> {projecttask.id}, fieldSet );
        List<pse__Project_Task__c> idListToMilestone = new SLT_Project_Task().getEligibleProjectTasksByMilestone(new Set<Id> {projecttask.id}, fieldSet );
        List<pse__Project_Task__c> idToBillingMilestone = new SLT_Project_Task().getProjectTasksByBillingMilestone(new Set<Id> {projecttask.id}, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToMilestone.size();
        System.assertEquals(expected, actual);
    }


    /**
     * This method used to get a Elligible Project Task by Service Name.
     */ 
    @IsTest
    static void testgetProjectTaskByServiceName() {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__Project__c', 'pse__Milestone__r.Id'};
        String milestoneId = projecttask.pse__Milestone__r.Id;
        List<pse__Project_Task__c> idToServiceName = new SLT_Project_Task().selectAllEligibleDeliverables(milestoneId, fieldSet );
        List<pse__Project_Task__c> idToHoldServiceName = new SLT_Project_Task().selectAllHoldDeliverables(milestoneId, fieldSet );
        Test.stopTest();
        Integer expected = 0;
        Integer actual = idToServiceName.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testselectProjTasksByProjId() {
        setupTestData();
        Test.startTest();
        Set<String> reportIdSet = new Set<String>();
        Set<String> fieldSet = new Set<String>{'Id', 'Service_Line_Lead__c','pse__Project__c'};
        //SD_Runs__c sdRec = [SELECT id from SD_Runs__c limit 1];
        reportIdSet.add(project.Id);
        Map<Id, List<pse__Project_Task__c>> projTaskList = new SLT_Project_Task().selectProjTasksByProjId(reportIdSet, fieldSet);
        Test.stopTest();
    }
    
    @isTest
    static void testgetProjectTasksBySDRuns() {
        setupTestData();
        Test.startTest();
        Set<Id> reportIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id','SD_Run_Status__c','Project_Code__c','SD_Run_ID__c','SD_Run_Due_Date__c','Identifier__c'};
        SD_Runs__c sdRec = [SELECT id from SD_Runs__c limit 1];
        reportIdSet.add(sdRec.Id);
        List<pse__Project_Task__c> projTaskList = new SLT_Project_Task().getProjectTasksBySDRuns(reportIdSet, fieldSet);
        Test.stopTest();
    }

    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Milestone__c milestoneService;
    static Service_Line__c serviceLine;
    static Service__c service;
    static pse__Project_Task__c projecttask;
    static pse__Project_Task_Assignment__c PTA;
    static pse__Project_Task__c deliverable;
    static Contact contact;
    static Contact anothercontact;
    
    static void setupTestData () {
      
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        serviceLine = UTL_PSA_TestData.createServiceLine(1).get(0);
        project.recordTypeId = recTypeId;
        project.Service_Line__c = serviceLine.Id;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        insert project;
        System.debug('&&& inserted sub project');

      
        UTL_PSA_TestData.createPermissionControls(); 

         //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
        
        anothercontact = UTL_PSA_TestData.resources[1];
        System.debug('&&& contact');
        
        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_TEMPLATE_TASK); 
        projecttask.pse__Project__c = project.id;
        projecttask.Pricing_Task_ID__c = '123456';
        insert projecttask;
        System.debug('&&& inserted project task');
         
        //Service milestone
        Id msRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE); 
        service = UTL_PSA_TestData.createService(1, serviceLine).get(0);
        milestoneService = UTL_PSA_TestData.createMilestones(1, project, serviceLine, service, false).get(0);
        //milestoneService.RecordTypeId = msRecordTypeId;
        insert milestoneService;

        //Deliverable
        Id deliverableRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE); 
        deliverable = new pse__Project_Task__c();
        deliverable.RecordTypeId = deliverableRecordTypeId;
        deliverable.Name = 'Deliverable';
        deliverable.pse__Project__c = project.Id;
        deliverable.pse__Milestone__c = milestoneService.Id;
        deliverable.Type__c = 'Deliverable';
        deliverable.pse__End_Date_Time__c = Datetime.now();
        deliverable.End_Date_Planned__c = System.today();
        deliverable.Resource__c = contact.Id;
        insert deliverable;

        //project task assignment
        PTA = new pse__Project_Task_Assignment__c();
        PTA.pse__Project_Task__c = projecttask.id;
        PTA.pse__Resource__c = contact.Id;
        PTA.Is_Primary__c = true;
        //insert PTA;
        System.debug('&&& inserted project task assignment');
        
        Service_Line__c serviceline1 = new Service_Line__c(
            Name = 'Signal Management',
            Active__c=true,
            Service_Line_Code__c = 'SM');
        insert serviceline1;
        
        //service
        Service__c service1 = new Service__c(Name = 'Miscellaneous');
        service1.Service_Code__c = '12345678';
        service1.Service_Line__c = serviceline1.Id;
        insert service1;
        
        pse__Proj__c project1 = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId1 = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project1.recordTypeId = recTypeId1;
        project1.pse__Project_Status__c = 'Start-up';
        project1.pse__Parent_Project__c = parentproject.Id;
        project1.Service_Line__c = serviceline1.Id;
        insert project1;
        
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Date_Activated__c = System.today(),
            Countries_NA__c = true
        );
        insert target;
        
        SD_Runs__c sdrunRec = new SD_Runs__c();
        sdrunRec.Frequency__c = 'Weekly';
        sdrunRec.Project__c = project.id;
        sdrunRec.Product__c = target.id;
        sdrunRec.Service_Line_Lead__c = contact.id;
        insert sdrunRec;       
       

}

}
