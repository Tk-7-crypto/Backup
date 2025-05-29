/**
 * This test class is used to test Assignment Trigger.
 * This is the main Test class for Assignment Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Assignment.cls as well as TST_DAOH_PSA_Assignments.cls. 
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */

@isTest
private class TST_TGR_Assignment {
	
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert agreement; 
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'TSL-Japan';
        insert resourceRequest;
        
    }
	
	
	/**
    * This test method used for insert Assignment record
    */
    static testmethod void testAssignmentInsert() 
	{
        Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact'];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        pse__Proj__c project = [Select Id From pse__Proj__c where Bid_History__c =: agreement.id];
        pse__Resource_Request__c resourceRequest = [Select Id From pse__Resource_Request__c Where SubGroup__c = 'TSL-Japan'  limit 1];
        pse__Schedule__c schedule = [Select Id From pse__Schedule__c limit 1];
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, project.Id, schedule.Id, cont.Id, resourceRequest.Id);
        Test.startTest();
          insert assignement;
        Test.stopTest();
        
		Integer expected = 1;
        Integer actual = [Select Id From pse__Assignment__c].size();
        system.assertEquals(expected, actual);
    }

    
//These methods are for testing PSA
	static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static pse__Milestone__c milestones;
    static Contact contact;
    static Contact anothercontact;
    static pse__Resource_Request__c resourcerequest;
    static pse__Assignment__c assignment;
    static void setupTestData () 
	{
        
        List<sObject> toSave = new List<sObject>();

        System.debug('A:' + Limits.getQueries());
		
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        System.debug('B:' + Limits.getQueries());
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        System.debug('C:' + Limits.getQueries());
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        insert project;
		
        System.debug('D:' + Limits.getQueries());
        System.debug('&&& inserted sub project');
      
        //UTL_PSA_TestData.createPermissionControls(); 
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
		pc.CurrencyIsoCode = project.CurrencyIsoCode;
		pc.pse__User__c = UserInfo.getUserId();
		pc.pse__Region__c = project.pse__region__c;
		pc.pse__Cascading_Permission__c = true;
		pc.Unit_Entry_Ops_Edit__c = true;
		pc.pse__Billing__c = true;
		pc.pse__Expense_Entry__c = true;
		pc.pse__Expense_Ops_Edit__c = true;
		pc.pse__Forecast_Edit__c = true;
		pc.pse__Forecast_View__c = true;
		pc.pse__Invoicing__c = true;
		pc.pse__Edit_Task_Manager__c = true;
		pc.pse__View_Task_Manager__c = true;
		pc.pse__Resource_Request_Entry__c = true;
		pc.pse__Skills_And_Certifications_Entry__c = true;
		pc.pse__Skills_And_Certifications_View__c = true;
		pc.pse__Staffing__c = true;
		pc.pse__Timecard_Entry__c = true;
		pc.pse__Timecard_Ops_Edit__c = true;
		pc.Unit_Entry_Ops_Edit__c = true;
		insert pc;        

        System.debug('E:' + Limits.getQueries());
         
        //contacts
        UTL_PSA_TestData.createResources(1,false);
        Contact testResource = [Select id,FirstName,LastName,Email from Contact limit 1];
        System.debug('F:' + Limits.getQueries());
       
        resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
		resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
		resourcerequest.pse__Project__c = project.id;
		//resourcerequest.pse__Opportunity__c = opty != null ? opty.Id : null;
		resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
		resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
		resourcerequest.pse__Region__c = project.pse__Region__c;
		//resourcerequest.pse__Practice__c = proj != null ? proj.pse__Practice__c : opty.pse__Practice__c;
		resourcerequest.pse__Group__c = project.pse__Group__c;
		resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER;
		resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
		resourcerequest.pse__SOW_Hours__c = 500;
		resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
		resourcerequest.pse__Notes__c = 'Test';
		resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
		resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
		insert resourcerequest;
        //toSave.add(resourcerequest);
                
        pse__Schedule__c sch = new pse__Schedule__c();
		sch.pse__Start_Date__c = project.pse__Start_Date__c;
		sch.pse__End_Date__c = project.pse__End_Date__c;
		sch.pse__Monday_Hours__c = 8;
		sch.pse__Tuesday_Hours__c = 8;
		sch.pse__Wednesday_Hours__c = 8;
		sch.pse__Thursday_Hours__c = 8;
		sch.pse__Friday_Hours__c = 8;
		sch.pse__Saturday_Hours__c = 0;
		sch.pse__Sunday_Hours__c = 0;
		insert sch;
        
        assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
		assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
		assignment.pse__Planned_Hours__c = 100;
		assignment.pse__Project__c = project.Id;
		assignment.pse__Resource__c = testResource.id;
		assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_LINE_MANAGER;
		assignment.pse__Schedule__c = sch.Id;
		assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
		assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
		assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
		assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        //insert assignment;
        //toSave.add(assignment);
        
        System.debug('J:' + Limits.getQueries());
		 
    }
	
  
    @IsTest
    static void testRRFieldsCopyToAssignment() {
        System.debug('before setupTestData:' + Limits.getQueries());
        setupTestData();
        System.debug('after setupTestData:' + Limits.getQueries());
        Test.startTest();
        System.debug('after startTest:' + Limits.getQueries());
        assignment.pse__Resource_Request__c = resourcerequest.id;       
        insert assignment;
        Test.stopTest();

        pse__Assignment__c  assignmentAfterInsert = [SELECT Name, pse__Resource__c, pse__Resource_Request__r.Name, Resource_Request_Type__c  from pse__Assignment__c where Id=: assignment.Id];
        String assignmentResourceRequestType = assignmentAfterInsert.Resource_Request_Type__c ;
        String requestResourceRequestType = resourcerequest.Resource_Request_Type__c;
		system.assertEquals(requestResourceRequestType, assignmentResourceRequestType);
    }

    
    @isTest
    static void testDeleteAssignment(){
        setupTestData();
        Test.startTest();
			insert assignment;
			delete assignment;
        Test.stopTest();
		
		Integer expected = 0;
        Integer actual = [Select Id From pse__Assignment__c].size();
        system.assertEquals(expected, actual);
    }

    
    @isTest
    static void testUpdateAssignment()
	{
        setupTestData();
        Test.startTest();
			insert assignment;
			assignment.pse__Planned_Bill_rate__c = 100;
			update assignment;
        Test.stopTest();
		
		Integer expected = 100;
        pse__Assignment__c actual = [Select Id,  pse__Planned_Bill_rate__c From pse__Assignment__c];
        system.assertEquals(expected, actual.pse__Planned_Bill_rate__c);
    }
}
