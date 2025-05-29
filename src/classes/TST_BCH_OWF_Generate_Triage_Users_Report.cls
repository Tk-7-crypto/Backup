@isTest
private class TST_BCH_OWF_Generate_Triage_Users_Report {
    
    @testSetup
    static void dataSetup() 
	{
        List<User> userList = UTL_TestData.createUser('System Administrator', 2);
		userList[0].FirstName = 'Test1';
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
        userList[1].FirstName = 'Test2';
        userList[1].SUBREGION__c = 'United States of America';
        userList[1].IsActive = true;
        insert userList;
        
        Set<String> psNameSet = new Set<String> {'OWF_Triage_Manager'}; 
        PermissionSet triageManagerPermissionSet = [SELECT Id FROM PermissionSet WHERE Name in:psNameSet limit 1];
		insert new PermissionSetAssignment(AssigneeId = userList[0].id, PermissionSetId = triageManagerPermissionSet.Id);
    }
    
    
    static testMethod void testUserTriageAccess1()
    {
        List<User> testUserInstanceList =  [Select Id, Name, Triage_Access__c from User where FirstName = 'Test1'];
        Set<String> psNameSet = new Set<String> {'OWF_Triage_Manager'}; 
        PermissionSet triageManagerPermissionSet = [SELECT Id FROM PermissionSet WHERE Name in:psNameSet limit 1];
        Test.startTest();
			BCH_OWF_Generate_Triage_Users_Report batch = new BCH_OWF_Generate_Triage_Users_Report();
			batch.batchMod = 'PSASET';
			Database.QueryLocator ql = batch.start(null);
			batch.execute(null,testUserInstanceList);
			batch.Finish(null);
		Test.stopTest();
		
        String expected = 'PSASET';
        String actual = batch.batchMod;
        system.assertEquals(expected, actual);
	}
	
	
	static testMethod void testUserTriageAccess2()
    {
        List<User> testUserInstanceList =  [Select Id, Name, Triage_Access__c from User where FirstName = 'Test2'];
        Test.startTest();
			BCH_OWF_Generate_Triage_Users_Report batch1 = new BCH_OWF_Generate_Triage_Users_Report();
			batch1.batchMod = 'PSARESET';
			Database.QueryLocator ql1 = batch1.start(null);
			batch1.execute(null,testUserInstanceList);
			batch1.Finish(null);
		Test.stopTest();
			
		Boolean expected = False;
        List<User> user = [Select Id, Name, Triage_Access__c from User limit 1];
        Boolean actual = user[0].Triage_Access__c;
        system.assertEquals(expected, actual);
	}
    
    
    static testMethod void testUserTriageAccess3()
    {
        List<User> testUserInstanceList =  [Select Id, Name, PSA_Licence_Access__c from User where FirstName = 'Test1'];
        Set<String> psNameSet = new Set<String> {'OWF_Triage_Manager'}; 
        PermissionSet triageManagerPermissionSet = [SELECT Id FROM PermissionSet WHERE Name in:psNameSet limit 1];
        Test.startTest();
			BCH_OWF_Generate_Triage_Users_Report batch2 = new BCH_OWF_Generate_Triage_Users_Report();
			batch2.batchMod = 'LICENCESET';
			Database.QueryLocator ql2 = batch2.start(null);
			batch2.execute(null,testUserInstanceList);
			batch2.Finish(null);
		Test.stopTest();
        
        String expected = 'LICENCESET';
        String actual = batch2.batchMod;
        system.assertEquals(expected, actual);
	}    
    
    
    static testMethod void testUserTriageAccess4()
    {
        List<User> testUserInstanceList =  [Select Id, Name, PSA_Licence_Access__c from User where FirstName = 'Test2'];
        Set<String> psNameSet = new Set<String> {'OWF_Triage_Manager'}; 
        PermissionSet triageManagerPermissionSet = [SELECT Id FROM PermissionSet WHERE Name in:psNameSet limit 1];
        Test.startTest();
			BCH_OWF_Generate_Triage_Users_Report batch3 = new BCH_OWF_Generate_Triage_Users_Report();
			batch3.batchMod = 'LICENCERESET';
			Database.QueryLocator ql3 = batch3.start(null);
			batch3.execute(null,testUserInstanceList);
			batch3.Finish(null);  
		Test.stopTest();
        
        Boolean expected = False;
        List<User> user = [Select Id, Name, PSA_Licence_Access__c from User limit 1];
        Boolean actual = user[0].PSA_Licence_Access__c;
        system.assertEquals(expected, actual);
	}      
}