/**
 * This test class is used to test all methods in UTL_PSA class.
 * version : 1.0
 */
@isTest
private class TST_UTL_PSA 
{
	@testSetup
    static void setupTestData(){
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
    
        UTL_PSA_TestData.createPermissionControls();
    
        Contact contact = UTL_PSA_TestData.resources[0];
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        update contact;
        
        Service_Line__c serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'code',
            Name = 'code'
            );
        insert serviceLine;
    
        Service__c service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'code'
            );
        insert service;
    
        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1, false)[0];
        resourceRequest.pse__Project__c = servicelineproject.Id;
        insert resourceRequest;

        pse__Project_Task__c projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', 'RDS Deliverable Task');
        projecttask.pse__Project__c = parentproject.id;
        insert projecttask;
    
        pse__Project_Task__c deliverable = new pse__Project_Task__c(
            Quantity__c = 100,
            Resource__c = contact.Id,
            Billing_Hold__c = true,
            Include_in_Financials__c=true,
            Service__c = service.Id,
            pse__Project__c = servicelineproject.Id
            );
        insert deliverable;
    }
    
    /**
     * This test method used for testing UTL_PSA method deleteProjectHierarchy
     */
    @isTest
    static void testDeleteHierarchy() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c where Name ='Test Parent Project'];
        Service_Line__c serviceLine = [Select Id, Name from Service_Line__c where Active__c = True limit 1];
        Test.startTest();
        UTL_PSA.updateActiveResourceLitertureProjectList(new set<Id> {parentProject.Id});
        UTL_PSA.deleteProjectHierarchy(program.Id, parentproject.Id, serviceLine.Id, true);
        System.assertNotEquals(0, [Select Id, Name from Service_Line__c where Active__c = True limit 1].size(), 'Testing Delete Service Line Project');
        Test.stopTest();
    
    }

    /**
     * This test method used for testing UTL_PSA deleteProjectHierarchy by Program
     */
    @isTest
    static void testDeleteHierarchyByProgram() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        UTL_PSA.deleteProjectHierarchy(program.Id);
        System.assertEquals(0, [Select Id, Name from Program__c limit 1].size(), 'Testing Delete Program');
        Test.stopTest();
    }

    /**
     * This test method used for testing UTL_PSA deleteProjectHierarchy by Program
     */
    @isTest
    static void testDeleteHierarchyByProgramBatch() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        UTL_PSA.deleteProjectHierarchy(new Set<Id>{program.Id});
        System.assertNotEquals(0, [Select Id, Name from Program__c limit 1].size(), 'Testing Delete Program');
        Test.stopTest();
    }

    /**
     * This test method used for testing UTL_PSA deleteProjectHierarchy by Program and deleteParent
     */
    @isTest
    static void testDeleteHierarchyByProgramAndDeleteParent() {
        //setupTestData();
        Program__c program = [Select Id, Name from Program__c limit 1];
        Test.startTest();
        UTL_PSA.deleteProjectHierarchy(program.Id, true);
        System.assertEquals(0, [Select Id, Name from Program__c limit 1].size(), 'Testing Delete Program');
        Test.stopTest();
    }


    /**
     * This test method used for testing UTL_PSA deleteProjectHierarchy by Project
     */
    @isTest
    static void testDeleteHierarchyByProject() {
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c where Name ='Test Parent Project'];
        Test.startTest();
        UTL_PSA.getTargetRecords(parentproject.Id);
        UTL_PSA.deleteProjectHierarchyByProject(parentproject.Id);
        System.assertEquals(0, [Select Id, Name from pse__Proj__c where Name ='Test Parent Project'].size(), 'Testing Delete Project');
        Test.stopTest();
    }


    /**
     * This test method used for testing UTL_PSA deleteProjectHierarchy by Service Line
     */
    @isTest
    static void testDeleteHierarchyByServiceLine() {
        //setupTestData();
        Service_Line__c serviceLine = [Select Id, Name from Service_Line__c where Active__c = True limit 1];
        Test.startTest();
        UTL_PSA.deleteProjectHierarchyByServiceLine(serviceLine.Id);
        System.assertNotEquals(0, [Select Id, Name from Service_Line__c where Active__c = True limit 1].size(), 'Testing Delete Service Line Project');
        Test.stopTest();
    }

/**
 * This test method used for testing UTL_PSA calculateEndDate 
 */
    @isTest
    static void testCalculateEndDate() {
        Test.startTest();
        UTL_PSA.calculateEndDate(System.today(), 10);
        UTL_PSA.calculateWorkingDate(System.today(), 1, new Set<String>{String.valueOf(System.today())});
        System.assertNotEquals(0, [Select Id, Name from Service_Line__c where Active__c = True limit 1].size(), 'Testing Delete Service Line Project');
        Test.stopTest();
    }
}
