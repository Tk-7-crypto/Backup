/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Milestone
 */
@isTest
private class TST_SLT_Milestone {


	/**
	* This method used to get Milestone by Milestone Id.
	*/
	@IsTest
	static void testSelectByMilestoneId() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		pse__Milestone__c idToMilestone = new SLT_Milestone().selectByMilestoneId(new Set<Id> {milestones.id}, fieldSet );
		Test.stopTest();
	}


	/**
	* This method used to get a Map Milestone by Milestone Id.
	*/
	@IsTest
	static void testSelectMapByMilestoneId() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		Map<Id,pse__Milestone__c> idToMilestoneMap = new SLT_Milestone().getMilestoneById(new Set<Id> {milestones.id}, fieldSet );
		Test.stopTest();
	}


	/**
	* This method used to get a list of Milestone matching to Project ID
	*/
	@IsTest
	static void testSelectMilestoneByProjectId() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectMilestoneByProjectId(new Set<Id> {project.id}, fieldSet );
		Test.stopTest();
	}

	/**
	* This method used to get a Map of list of Milestone matching to Project ID
	*/
	@IsTest
	static void testSelectMapMilestoneListByProjectId() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		Map<Id, List<pse__Milestone__c> > idToMilestoneMapList = new SLT_Milestone().selectMilestoneListByProjectId(new Set<Id> {project.id}, fieldSet );
		Test.stopTest();
	}
    
    /**
	* This method used to get a Map of list of Milestone with keys made up of serviceId-parentProjectId
	*/
	@IsTest
	static void testSelectMapMilestoneListByServiceParentProject() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		Map<String, pse__Milestone__c > idToMilestoneMapList = new SLT_Milestone().selectByServiceAndParentProject(new Set<Id> {service.id}, new Set<Id> {parentProject.id}, fieldSet );
		Test.stopTest();
	}

	/**
	* This method returns list of RDS Service milestones projects
	*/
	@IsTest
	static void testSelectMilestoneByRDSServiceProjectId() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectMilestoneByRDSServiceProjectId(new Set<Id> {project.id}, fieldSet );
		Test.stopTest();
	}

	/**
	* This method used to get all Milestones by Parent Project
	*/
	@IsTest
	static void testSelectAllMilestonesByParentProject() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectAllMilestonesByParentProject(parentProject.id, fieldSet);
		Test.stopTest();
	}

	/*
	This method used to get all Milestones by Service Line, Start Date and End Date .
	* @return  List of pse__Milestone__c
	*/
	@IsTest
	static void testSelectAllMilestonesByServicelines() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Project__r.pse__Parent_Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectAllMilestonesByServicelines(parentProject.id,new Set<String>{'code'},system.today(),system.today().addDays(30),fieldSet);
		Test.stopTest();
	}


	/**
	* This method used to get all Milestones by Parent Project
	*/
	@IsTest
	static void testSelectAllMilestonesByProject() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectAllMilestonesByProject(project.id, fieldSet);
		Test.stopTest();
	}

	/**
		This method used to get all Milestones by Service Line, Start Date and End Date .
	* @return  List of pse__Milestone__c
	*/

	@IsTest
	static void testSelectAllMilestones() {
		setupTestData();
		Test.startTest();
		Set<String> fieldSet = new Set<String> {'Name','pse__Project__c','pse__Project__r.pse__Parent_Project__c','pse__Description__c','Billing_Type__c','Actual_Amount__c'};
		List<pse__Milestone__c> idToMilestoneList = new SLT_Milestone().selectAllMilestones(parentProject.id,'code',system.today(),system.today().addDays(30),fieldSet);
		Test.stopTest();
	}

    @IsTest
    static void testOnAfterInsert () {
        setupTestData();
        Test.startTest(); 
        milestones.pse__Billed__c = true;
        milestones.pse__Invoiced__c = true;
        milestones.pse__Billing_Event_Item__c = anotherBEI.id;

        //update projecttask;
        update milestones;     
        Test.stopTest();
    }

    
        @IsTest
        static void testupdateProjectTaskBilling () {
        setupTestData();

        Test.startTest();
        // project to update
        project.Service_Line_Lead__c = contact.Id;
        
        update project;  
        Test.stopTest();

        // Project's PM name:
        pse__Proj__c  projectAfterUpdate = [SELECT Name,Service_Line_Lead__r.Name from pse__Proj__c  where Id=: project.Id];
      
        // verify that Milestone Service Line Lead was set to the Project SLM.
        pse__Milestone__c milestoneAfterUpdate = [SELECT pse__Project__c,pse__Project__r.Name,Service_Line_Lead__c,Service_Line_Lead__r.Name from pse__milestone__c where Id=: milestones.Id];
    }

    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Service__c service;
    static Contact contact;
    static Contact anothercontact;
    static pse__Milestone__c milestones;
    static pse__Milestone__c rdsMilestone;
    static pse__Milestone__c oldmilestone;
    static pse__Billing_Event__c billingevent;
    static pse__Billing_Event__c anotherBE;
    static pse__Transaction__c transactions;
    static pse__Project_Task__c projecttask;
    static pse__Billing_Event_Item__c BEI;
    static pse__Billing_Event_Item__c anotherBEI;
    static pse__Resource_Request__c resourcerequest;
   
    static void setupTestData () {
      
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        insert project;

        UTL_PSA_TestData.createPermissionControls();

        //contacts
        contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
	    update contact;
        anothercontact = UTL_PSA_TestData.resources[1];
       
        //resoruce request
        resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = project.Id; 
        insert resourceRequest;


        //billing event
        billingevent = new pse__Billing_Event__c();
        insert billingevent;

        //another billing event
        anotherBE = new pse__Billing_Event__c();
        insert anotherBE;

        //billing event item
        BEI = new pse__Billing_Event_Item__c();
        BEI.pse__Object_Id__c = billingevent.id;
        insert BEI;

        //another billing event item
        anotherBEI = new pse__Billing_Event_Item__c();
        anotherBEI.pse__Object_Id__c = anotherBE.id;
        insert anotherBEI;
        
        //service line
        serviceLine = new Service_Line__c(Service_Line_Code__c = 'TEST');
        insert serviceLine;
        
        //service
		service = new Service__c(Service_Code__c = 'TEST1');
        service.Service_Line__c = serviceLine.Id;
        insert service;
        
        //milestones
        milestones = UTL_PSA_TestData.createMilestones(1, false)[0];
        
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_BILLING);  
        milestones.RecordTypeId = milestonerecTypeId;
        milestones.pse__Project__c = project.Id; 
        milestones.pse__Billed__c = false;
        milestones.pse__Invoiced__c = false;
        milestones.pse__Actual_Date__c = system.today();
        milestones.pse__Billing_Event_Item__c = BEI.id;
        milestones.pse__Include_In_Financials__c = true;
        milestones.pse__Approved__c = true;
        insert milestones;
        
        rdsMilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id rdsMilestoneId = Schema.SObjectType.pse__Milestone__c.getRecordTypeInfosByName().get('RDS Service').getRecordTypeId();
        rdsMilestone.RecordTypeId = rdsMilestoneId;
        rdsMilestone.pse__Project__c = project.Id;
        rdsMilestone.Service__c = service.Id;
        rdsMilestone.Service_Line__c = serviceLine.Id;
        rdsMilestone.pse__Billing_Event_Item__c = BEI.id;
        insert rdsMilestone;
       
        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable'); 
        projecttask.pse__Project__c = project.id;
        projecttask.Pricing_Task_ID__c = '123456';
        projecttask.Billing_Milestone__c = milestones.id;
        insert projecttask;
        
        //transaction
        transactions = new pse__Transaction__c();
        transactions.pse__Effective_Date__c = system.today();

    }
}