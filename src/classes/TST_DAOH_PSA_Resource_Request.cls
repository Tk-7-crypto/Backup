/**
 * This is Test Class for DAOH_PSA_Resource_Request.cls. It is copied over from TST_TGR_Resource_Request.cls
 * version : 1.0
 */
@isTest
private class TST_DAOH_PSA_Resource_Request {
	@testSetup
    static void dataSetup() 
	{
	Contact contact = UTL_PSA_TestData.resources[0];
	Contact anothercontact = UTL_PSA_TestData.resources[1];

	// Parent Project
	pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
	Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
	parentproject.recordTypeId = parentrecTypeId;
	parentproject.pse__Project_Status__c = 'Start-up';
	insert parentproject;

	// project
	pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
	Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
	project.recordTypeId = recTypeId;
	project.pse__Project_Status__c = 'Start-up';
	project.pse__Parent_Project__c = parentproject.id;
	project.pse__Project_Manager__c = contact.id;
	project.Service_Line_Lead__c = contact.id;
	insert project;

	UTL_PSA_TestData.createPermissionControls();
	//milestones
	pse__Milestone__c milestones = UTL_PSA_TestData.createMilestones(1, false)[0];
	Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
	milestones.RecordTypeId = milestonerecTypeId;
	milestones.pse__Project__c = project.Id;
	insert milestones;

	//resource request
	pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
	resourcerequest.pse__Project__c = project.Id;
	insert resourcerequest;
    }
    
    
@IsTest
static void testRRAfterInsert () {
	//setupTestData();
	Test.startTest();
	Contact contact =[Select Id, Name from Contact limit 1];
    pse__Resource_Request__c resourcerequest = [Select Id from pse__Resource_Request__c where pse__Project__c != Null limit 1];
	Test.stopTest();

	// Verify Resource Request resource name:
	pse__Resource_Request__c resourceRequestTaskAfterInsert = [SELECT Name,Service_Line_Lead__c,Service_Line_Lead__r.Name,Project_Manager__c,Project_Manager__r.Name from pse__Resource_Request__c where Id=: resourcerequest.Id];
	System.assertEquals(contact.id, resourceRequestTaskAfterInsert.Service_Line_Lead__c);
	System.assertEquals(contact.id, resourceRequestTaskAfterInsert.Project_Manager__c);

}
@IsTest
   static void testRRBeforeInsert () {
        Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        Test.startTest();
        pse__Proj__c parentproject=[Select Id,Name,RecordTypeId,pse__Region__c,pse__Group__c from pse__Proj__c  where RecordTypeId =:rdsrecTypeId limit 1];
        pse__Resource_Request__c req = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        req.pse__Project__c = parentproject.Id;
        req.pse__Resource_Held__c = true;
        req.pse__Region__c =parentproject.pse__Region__c;
        req.pse__Group__c = parentproject.pse__Group__c; 
        insert req;
        Test.stopTest();
        req = [SELECT Id, pse__Status__c FROM pse__Resource_Request__c WHERE Id = :req.Id];
        System.assertEquals(CON_PSA.RESOURCE_REQUEST_STATUS_HOLD, req.pse__Status__c, 
                            'Status should be updated to HOLD when Resource Held is set to true.');
    }
    @IsTest
    static void testRRBeforeUpdate () {
          pse__Resource_Request__c resourcerequestdata = [SELECT Id, pse__Status__c, pse__Resource_Held__c, recordTypeId 
                                                        FROM pse__Resource_Request__c 
                                                        WHERE pse__Project__c != NULL 
                                                        LIMIT 1];
        Test.startTest();
        resourcerequestdata.pse__Resource_Held__c =true;
        update resourcerequestdata;
        Test.stopTest();
        //Verfiy Resource request data
        resourcerequestdata = [SELECT Id, pse__Status__c, pse__Resource_Held__c, recordTypeId 
                                 FROM pse__Resource_Request__c 
                                 WHERE Id = :resourcerequestdata.Id 
                                 LIMIT 1];
        System.assertEquals(CON_PSA.RESOURCE_REQUEST_STATUS_HOLD, resourcerequestdata.pse__Status__c, 
                            'Status should be updated to HOLD when Resource Held is set to true.');
    }


    /*
static pse__Proj__c parentproject;
static pse__Proj__c project;
static pse__Proj__c anotherproject;
static Service_Line__c serviceLine;
static pse__Milestone__c milestones;
static Contact contact;
static Contact anothercontact;
static pse__Resource_Request__c resourcerequest;
static void setupTestData () {

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
*/
}