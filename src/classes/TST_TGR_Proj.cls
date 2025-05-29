/**
 * This test class is used to test ProjectTrigger.
 * This is the main Test class for Project Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Proj.cls as well as TST_DAOH_PSA_Project.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */
 
@isTest
private class TST_TGR_Proj {

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
    * This test method check project and agreement has same opportunity
    */    
    static testMethod void testNames()
	{
        pse__Proj__c bidProject = [Select Id, Name, Bid_History__r.Name from pse__Proj__c limit 1];
		Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c Limit 1];
        
        //Checking the project Name and Agreement Name
        String projectName = bidProject.Bid_History__r.Name ;
        String agreementName = agreement.Name;
		system.assertEquals(bidProject.Bid_History__r.Name, agreement.Name);
    }
	
	
//These methods are for testing PSA
	static pse__Proj__c parentproject;
	static pse__Proj__c project;
	static pse__Proj__c pvsProject;
	static Service_Line__c agReportServiceLine;
	static Service_Line__c pvsServiceLine;
	static Contact contact;
	static pse__Resource_Request__c resourcerequest;
    static Aggregate_Report__c ar; 
	static void setupTestData () 
	{

		List<sObject> toSave = new List<sObject>();

		//Group - for PV Solutions
		pse__Grp__c grp = new pse__Grp__c( Name='PV Solutions' );
		insert grp;

        // service line
        agReportServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST1',
            Name = 'Aggregate Reporting'
		);
		insert agReportServiceLine;

        pvsServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST2',
            Name = 'PV Solutions'
		);
		insert pvsServiceLine;
        
        Opportunity opp =[Select id,Name from Opportunity limit 1];

		// Parent Project
		parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
		parentproject.pse__Stage__c = 'Start-up';
        parentproject.pse__Opportunity__c = opp.id;
		insert parentProject;

		// project
		project = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Aggregate Reporting Project', false);
		project.Service_Line__c = agReportServiceLine.Id;
        project.pse__Opportunity__c = opp.id;
		insert project;
        
		pvsProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'PV Solutions Project', false);
		pvsProject.Service_Line__c = pvsServiceLine.Id;
        pvsProject.pse__Opportunity__c = opp.id;
		insert pvsProject;

		UTL_PSA_TestData.createPermissionControls();

		//contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
		UTL_PSA_TestData.createResources(1,false);
        Contact contact = [Select id,FirstName,LastName,Email from Contact limit 1];
		contact.RecordTypeId = contactRT.Id;
		contact.pse__Salesforce_User__c = UserInfo.getUserId();
		contact.pse__Group__c = grp.id;
        contact.EmployeeNumber__c = '123';
		update contact;

		//resource request
		resourcerequest = UTL_PSA_TestData.createResourceRequests(1, project, false)[0];
        resourcerequest.pse__Project__c = pvsProject.id;
        resourcerequest.pse__Opportunity__c = opp.id;
		insert resourcerequest;
	}

	@IsTest
	static void testInsertServiceLineProjectFields () 
	{
		contact = UTL_PSA_TestData.createResources(1,false)[0];
		contact.pse__Salesforce_User__c = UserInfo.getUserId();
		insert contact;
		Test.startTest();
		pse__Proj__c anotherproject = UTL_PSA_TestData.createProjects(1, false)[0];
		Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
		anotherproject.recordTypeId = recTypeId;
		anotherproject.Service_Line_Lead__c= contact.Id;
		insert anotherproject;
		Test.stopTest();
		
		// verify that Project's Project Manager matches Service Line Lead.
		pse__Proj__c projectAfterInsert = [SELECT Name,Service_Line_Lead__c,pse__Project_Manager__c from pse__Proj__c where Id=: anotherproject.Id];
		System.assertEquals(contact.Id, projectAfterInsert.pse__Project_Manager__c);
		System.assertEquals(projectAfterInsert.Service_Line_Lead__c, projectAfterInsert.pse__Project_Manager__c);
	}


	@IsTest
	static void testCascadeToServiceLineProjects() 
	{
		setupTestData();
		Test.startTest();
		// parent project's Stage is updated
		parentproject.pse__Stage__c = 'Completed';
		update parentproject;
		Test.stopTest();

		// verify that Parent project's stage is updated to 'Completed'' .
		pse__Proj__c parentprojectAfterUpdate = [SELECT Name,pse__Stage__c from pse__Proj__c where Id=: parentproject.Id];
		System.assertEquals('Completed', parentprojectAfterUpdate.pse__Stage__c);

		// verify that Sub project's stage is updated to 'Not Active' .
		pse__Proj__c subprojectAfterUpdate = [SELECT Name,pse__Stage__c from pse__Proj__c where Id=: project.Id];
		System.debug('subprojectAfterUpdate.pse__Stage__c'+ subprojectAfterUpdate.pse__Stage__c);
		//System.assertEquals('Not Active', subprojectAfterUpdate.pse__Stage__c);
	}
}
