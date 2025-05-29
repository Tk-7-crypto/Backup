/*
 * Version       : 1.0
 * Description   : Test Class for CNT_PSA_manageRelatedSystems
 */
@isTest 
private class TST_CNT_PSA_manageRelatedSystems 
{
	@testSetup
    static void dataSetup() 
    {
		pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
        parentProject.pse__Stage__c = 'Start-up';
        insert parentProject;

        PSA_Related_System__c psaRS = new PSA_Related_System__c(
            Type__c='Test Type',
            System_Name__c='Test System',
            Hosted_By__c='IQVIA');
        insert psaRS;

        Project_Related_System__c projectRS = new Project_Related_System__c(
            Project__c=parentProject.Id,
            PSA_Related_System__c=psaRS.Id,
            Hosted_By__c='IQVIA',
            Client_System_Name__c='Test Client System',
            Additional_Info__c='Test Additional Info'
        );
        insert projectRS;
    }   
    
    @isTest 
    static void testGetProjectRelatedSystems(){
        //setupTestData();
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c limit 1];
        Test.startTest();
        Map<Id,Project_Related_System__c> relatedSystems = CNT_PSA_manageRelatedSystems.getProjectRelatedSystems(parentProject.Id);
        Test.stopTest();
        System.assertEquals(1,relatedSystems.size());
    }

    @isTest 
    static void testGetPSARelatedSystems()
    {
        //setupTestData();
        Test.startTest();
        Map<Id,PSA_Related_System__c> relatedSystems = CNT_PSA_manageRelatedSystems.getPSARelatedSystems();
        Test.stopTest();
        System.assertEquals(1,relatedSystems.size());
    }

    @isTest 
    static void testGetJunctions()
    {
        //setupTestData();
        Test.startTest();
        List<PSA_Related_Systems_Service_Lines__c> junctions = CNT_PSA_manageRelatedSystems.getJunctions(); 
        Test.stopTest();
        System.assertEquals(0,junctions.size());
    }

    @isTest 
    static void testAddRelatedSystems()
    {
        //setupTestData();
        PSA_Related_System__c psaRS = [Select Id, Name from PSA_Related_System__c limit 1];
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c limit 1];
        Project_Related_System__c projectRS = [Select Id, Name from Project_Related_System__c limit 1];
        
        Map<String,String> systemData = new Map<String,String>{
            'id' => psaRS.Id,
            'clientSystemName' => 'Test Client System 2',
            'hostedBy' => 'Client',
            'additionalInfo' => 'Test Additional Info 2'
        };
        List<Map<String,String>> rows = new List<Map<String,String>>{systemData};
        Test.startTest();
        CNT_PSA_manageRelatedSystems.addRelatedSystems(rows, parentProject.Id);
        delete projectRS;
        CNT_PSA_manageRelatedSystems.addRelatedSystems(rows, parentProject.Id);
        Test.stopTest();
        
        List<Project_Related_System__c> systems = new SLT_Project_Related_System().getRelatedSystemsByProject( new Set<Id>{parentProject.Id} );
        System.assertEquals('Client', systems[0].Hosted_By__c);
    }


    @isTest 
    static void testUpdateRelatedSystems(){
        //setupTestData();
        PSA_Related_System__c psaRS = [Select Id, Name from PSA_Related_System__c limit 1];
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c limit 1];
        Project_Related_System__c projectRS = [Select Id, Name from Project_Related_System__c limit 1];
        
        Map<String,String> systemData = new Map<String,String>{
            'projectRelatedSystem' => projectRS.Id,
            'id' => psaRS.Id,
            'project' => parentProject.Id,
            'clientSystemName' => 'Test Update',
            'hostedBy' => 'Test Update',
            'additionalInfo' => 'Test Update'
        };
        List<Map<String,String>> rows = new List<Map<String,String>>{systemData};
        Test.startTest();
        CNT_PSA_manageRelatedSystems.updateRelatedSystems(rows);
        Test.stopTest();
        
        List<Project_Related_System__c> systems = new SLT_Project_Related_System().getRelatedSystemsByProject( new Set<Id>{parentProject.Id} );
        System.assertEquals('Test Update', systems[0].Hosted_By__c);
        System.assertEquals('Test Update', systems[0].Client_System_Name__c);
        System.assertEquals('Test Update', systems[0].Additional_Info__c);
    }
    
    @isTest 
    static void testRemoveRelatedSystems(){
        //setupTestData();
        PSA_Related_System__c psaRS = [Select Id, Name from PSA_Related_System__c limit 1];
        pse__Proj__c parentProject = [Select Id, Name from pse__Proj__c limit 1];
        
        Test.startTest();
        CNT_PSA_manageRelatedSystems.removeRelatedSystems(new List<Id>{psaRS.Id},parentProject.Id);
        Test.stopTest();

        List<Project_Related_System__c> systems = new SLT_Project_Related_System().getRelatedSystemsByProject( new Set<Id>{parentProject.Id} );
        System.assertEquals(0,systems.size());
    }

    /*
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
        insert projectRS;
    }
	*/
}