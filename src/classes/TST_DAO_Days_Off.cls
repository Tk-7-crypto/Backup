/**
* This test class is used to test all methods in DAO_Days_Off Class.
* version : 1.0
*/
@isTest
private class TST_DAO_Days_Off {
    
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
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        pse__Proj__c daysOffProject = UTL_OWF_TestData.createBidProject(grp.Id);
        daysOffProject.name = 'Annual Leave/Vacation';
        insert daysOffProject;
    }
    
	
    /**
    * This test method used for insert Days Off record
    */
    static testmethod void testDaysOffInsert() {
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
            insert daysOff;
        Test.stopTest();
		
        Integer expected = 1;
        Integer actual = [Select Id From Days_Off__c].size();
        system.assertEquals(expected, actual);
    }
    
	
    /**
    * This test method used for insert Days Off record
    */
    static testmethod void testDaysOffUpdate() 
	{
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
            insert daysOff;
            daysOff.First_Day_Off__c = System.today().addDays(1);
            update daysOff;
        Test.stopTest();
		
        Date expected = System.today().addDays(1);
        Date actual = [Select Id,First_Day_Off__c From Days_Off__c limit 1].First_Day_Off__c;
        system.assertEquals(expected, actual);
    }
	
    
    /**
    * This test method used for insert Days Off record
    */
    static testmethod void testDaysOffDelete() {
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
            insert daysOff;
            delete daysOff;
        Test.stopTest();
		
        Integer expected = 0;
        Integer actual = [Select Id From Days_Off__c].size();
        system.assertEquals(expected, actual);
    }
}