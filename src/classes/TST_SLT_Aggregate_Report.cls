/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Aggregate_Report
 */
@isTest
private class TST_SLT_Aggregate_Report {

    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Aggregate_Report(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }

	@IsTest
	static void testGetAggregateReportsByParentProject(){

		setupTestData();
		Test.startTest();
    	Map<Id,List<Aggregate_Report__c>> agReports = new SLT_Aggregate_Report(true).getAggregateReportsByParentProject(new Set<Id>{parentproject.Id}, requestedFields);
		Test.stopTest();
		List<Aggregate_Report__c> agReportList = agReports.get(parentproject.Id);
		System.assertEquals(1,agReportList.size());
	}


	static pse__Proj__c parentproject;
	static pse__Proj__c project;
	static Service_Line__c agReportServiceLine;
	static Aggregate_Report__c ar; 
	static Set<String> requestedFields;

	static void setupTestData () {

		requestedFields = new Set<String>{
			'Id', 'Name', 'Project__c', 'Project__r.pse__Parent_Project__c'
		};

		List<sObject> toSave = new List<sObject>();

        // service line
        agReportServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST1',
            Name = 'Aggregate Reporting'
		);
		toSave.add(agReportServiceLine);

		// Parent Project
		parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
		parentproject.pse__Stage__c = 'Start-up';
		toSave.add(parentProject);

		insert toSave;
		toSave = new List<sObject>();

		// project
		project = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Aggregate Reporting Project', false);
		project.Service_Line__c = agReportServiceLine.Id;
		toSave.add(project);

		UTL_PSA_TestData.createPermissionControls();

		insert toSave;
		toSave = new List<sObject>();

        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        ar = new Aggregate_Report__c();
		ar.Project__c = project.Id; 
		ar.RecordTypeId = recordId.Id;
		toSave.add(ar);

		insert toSave;
	} 
}