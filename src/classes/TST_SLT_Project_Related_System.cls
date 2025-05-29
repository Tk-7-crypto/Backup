/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Project_Related_System
 */
@isTest
private class TST_SLT_Project_Related_System {

    @isTest
    static void testGetSObjectFieldList() {
        setupTestData();

        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Project_Related_System(true,true).getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(0,fields.size());
    }

    @isTest 
    static void testGetRelatedSystemsByProject(){
        setupTestData();

        Test.startTest();
        List<Project_Related_System__c> results = new SLT_Project_Related_System(false).getRelatedSystemsByProject(new Set<Id>{parentProject.Id});
        Test.stopTest();

        System.assertEquals(1,results.size());
        System.assertEquals('Test Type',results[0].Type__c);
        System.assertEquals('Test Client System',results[0].Client_System_Name__c);
        System.assertEquals('IQVIA',results[0].Hosted_By__c);
    }

    @isTest 
    static void testGetProjectRelatedSystemsByPSASystem(){
        setupTestData();

        Test.startTest();
        List<Project_Related_System__c> results =  new SLT_Project_Related_System().getProjectRelatedSystemsByPSASystem(new Set<Id>{psaRS.Id} , parentProject.Id);
        Test.stopTest();

        System.assertEquals(1,results.size());
        System.assertEquals('Test Type',results[0].Type__c);
        System.assertEquals('Test Client System',results[0].Client_System_Name__c);
        System.assertEquals('IQVIA',results[0].Hosted_By__c);
    }

    static PSA_Related_System__c psaRS;
    static Project_Related_System__c projectRS;
    static pse__Proj__c parentProject;

    static void setupTestData(){
		// Parent Project
		parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        parentProject.pse__Stage__c = 'Start-up';
        insert parentProject;

        psaRS = new PSA_Related_System__c(
            Type__c='Test Type',
            System_Name__c='Test System',
            Hosted_By__c='IQVIA');
        insert psaRS;

        projectRS = new Project_Related_System__c(
            Project__c=parentProject.Id,
            PSA_Related_System__c=psaRS.Id,
            Hosted_By__c='IQVIA',
            Client_System_Name__c='Test Client System',
            Additional_Info__c='Test Additional Info'
        );
        insert projectRs;
    }
}