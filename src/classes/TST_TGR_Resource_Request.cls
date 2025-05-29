/**
 * This test class is used to test Resource Request Trigger.
 * This is the main Test class for Resource Request Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Resource_Request.cls as well as TST_DAOH_PSA_Resource_Request.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */

@isTest
private class TST_TGR_Resource_Request {
	
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
        cont.pse__Group__c = grp.Id;
        insert cont;        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert agreement; 
    }
    
   	/**
    * This test method used for insert Resource Request record
    */
    static testmethod void testResourceRequestInsert() 
	{
        Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact' limit 1];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        pse__Proj__c project = [Select Id From pse__Proj__c limit 1];
        pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
        resourceRequest.pse__Group__c = grp1.Id;
        Test.startTest();
            insert resourceRequest;
        Test.stopTest();
		
        Integer expected = 3;
        Integer actual = [Select Id From pse__Resource_Request__c].size();
        system.assertEquals(expected, actual);
    }
	

//Test Methods for PSA    
	static pse__Proj__c parentproject;
	static pse__Proj__c project;
	static pse__Proj__c anotherproject;
	static Service_Line__c serviceLine;
	static pse__Milestone__c milestones;
	static Contact contact;
	static Contact anothercontact;
	static pse__Resource_Request__c resourcerequest;
	static void setupTestData () 
	{
		//contacts
		contact = UTL_PSA_TestData.resources[0];
		anothercontact = UTL_PSA_TestData.resources[1];

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
		project.pse__Project_Manager__c = contact.id;
		project.Service_Line_Lead__c = contact.id;
		insert project;

		UTL_PSA_TestData.createPermissionControls();
		//milestones
		milestones = UTL_PSA_TestData.createMilestones(1, false)[0];

		Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
		milestones.RecordTypeId = milestonerecTypeId;
		milestones.pse__Project__c = project.Id;
		insert milestones;

		//resource request
		resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
		resourcerequest.pse__Project__c = project.Id;
	}
    

	@IsTest
	static void testRRAfterInsert() 
	{
		setupTestData();
		Test.startTest();
		insert resourcerequest;
		Test.stopTest();
		
		// Verify Resource Request resource name:
		pse__Resource_Request__c resourceRequestTaskAfterInsert = [SELECT Name,Service_Line_Lead__c,Service_Line_Lead__r.Name,Project_Manager__c,Project_Manager__r.Name from pse__Resource_Request__c where Id=: resourcerequest.Id];
		System.assertEquals(contact.id, resourceRequestTaskAfterInsert.Service_Line_Lead__c);
		System.assertEquals(contact.id, resourceRequestTaskAfterInsert.Project_Manager__c);

	}
}
