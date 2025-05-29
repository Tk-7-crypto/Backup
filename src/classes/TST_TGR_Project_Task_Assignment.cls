/**
 * This test class is used to test Project_Task_Assignment Trigger.
 * This is the main Test class for Project_Task_Assignment Trigger and is copied over to dependant Trigger handler Test classes TST_DAO_Project_Task_Assignment.cls as well as TST_DAOH_PSA_Project_Task_Assignment.cls.
 * Any change to the main test class needs to be reflected in their dependant test classes
 * version : 1.0
 */

@isTest
private class TST_TGR_Project_Task_Assignment 
{
	@testSetup
    static void dataSetup() 
	{
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
		insert project;
	
		UTL_PSA_TestData.createPermissionControls();

		//contacts
		Contact contact = UTL_PSA_TestData.resources[0];
		contact.pse__Salesforce_User__c = UserInfo.getUserId();
		update contact;
	
		Contact anothercontact = UTL_PSA_TestData.resources[1];
	

		//Project Task
		pse__Project_Task__c projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
	
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task');
		projecttask.pse__Project__c = project.id;
		insert projecttask;
    }


    @IsTest
    static void testInsertPrimaryResourceOnTask () 
    {
        pse__Project_Task__c projecttask = [Select Id, Name from pse__Project_Task__c limit 1];
        Contact contact = [Select Id, Name from Contact limit 1];
        //setupTestData();
        Test.startTest();
        pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c();
		PTA.pse__Project_Task__c = projecttask.id;
		PTA.pse__Resource__c = contact.Id;
		PTA.Is_Primary__c = true;
        insert PTA;
        Test.stopTest();
        
        // Verify Project Task resource name:
        pse__Project_Task__c projectTaskAfterInsert = [SELECT Name,Resource__r.Name from pse__Project_Task__c where Id=: projecttask.Id];
        System.assertEquals('Test Resource 1 FF', projectTaskAfterInsert.Resource__r.Name);
    }

    @IsTest
    static void testUpdateSetPrimaryResourceOnTask () 
    {
        pse__Project_Task__c projecttask = [Select Id, Name from pse__Project_Task__c limit 1];
        Contact contact = [Select Id, Name from Contact limit 1];
        //setupTestData();
        Test.startTest();
       	pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c();
		PTA.pse__Project_Task__c = projecttask.id;
		PTA.pse__Resource__c = contact.Id;
		PTA.Is_Primary__c = true;
        insert PTA;
        Contact anothercontact = [Select Id, Name from Contact limit 1];
        PTA.pse__Resource__c = anothercontact.Id;
        update PTA;
        Test.stopTest();
        
        // Verify Project Task resource name:
        pse__Project_Task__c projectTaskAfterUpdate = [SELECT Name,Resource__r.Name from pse__Project_Task__c where Id=: projecttask.Id];
        System.assertEquals(contact.id, projectTaskAfterUpdate.Resource__c);
    }

    /*
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Project_Task__c projecttask;
    static pse__Project_Task_Assignment__c PTA;
    static Contact contact;
    static Contact anothercontact;
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
        //Project Task
        projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task');
        projecttask.pse__Project__c = project.id;
        insert projecttask;
        //project task assignment
        PTA = new pse__Project_Task_Assignment__c();
        PTA.pse__Project_Task__c = projecttask.id;
        PTA.pse__Resource__c = contact.Id;
        PTA.Is_Primary__c = true;
    }
	*/
}