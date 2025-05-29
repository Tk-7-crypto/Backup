/**
* This test class is used to test all methods in DAOH_OWF_Day_Off Class.
* version : 1.0
*/

@isTest
private class TST_DAOH_OWF_Day_Off {
	
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        List<PermissionSetAssignment> psaList = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        if(psaList.size() == 0){
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        }
        System.runAs(new User(Id = UserInfo.getUserId()))
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
    }
    
	
    /**
    * This test method used to test insertion of Assignment & Schedule through upsertRelatedAssignmentAndSchedule method
    */
    @isTest
    static void testUpsertRelatedAssignmentAndSchedule1() {
        Contact cont = [Select Id from Contact Limit 1];  
        Days_Off__c validDaysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        validDaysOff.Status__c = 'Approved';
        Days_Off__c pastDaysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        pastDaysOff.First_Day_Off__c = System.today().addDays(-1);
        Days_Off__c invalidDaysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        invalidDaysOff.First_Day_Off__c = System.today().addDays(2);
        invalidDaysOff.Last_Day_Off__c = System.today();
        Test.startTest();
        insert validDaysOff;
        try {
            insert pastDaysOff; 
                System.assert(true, 'Expected validation error for past First_Day_Off__c');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('First day off requested must be in the future.'));
            }        
            try {
                insert invalidDaysOff;
                System.assert(false, 'Expected validation error for Last_Day_Off__c before First_Day_Off__c');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Last day off needs to be greater than or equal to the first day off.'));
            }
            Test.stopTest();
            Integer expected = 2;
            Integer actual = [Select Id From pse__Assignment__c limit 10].size();
            System.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
            actual = [Select Id From pse__Schedule__c limit 10].size();
            System.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
    }
    
	
    /**
    * This test method used to test updation of Assignment & Schedule through upsertRelatedAssignmentAndSchedule method, 
    */
    @isTest
    static void testUpsertRelatedAssignmentAndSchedule2() 
	{
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
            insert daysOff;
            daysOff.First_Day_Off__c = System.today().addDays(1);
            update daysOff;
        Test.stopTest();
		
        Date expected = System.today().addDays(1);
        Date actual = [Select Id,pse__Start_Date__c From pse__Schedule__c limit 1].pse__Start_Date__c;
        system.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
    }
    
	
    /**
    * This test method used to test deletion of Assignment & Schedule through upsertRelatedAssignmentAndSchedule method, 
    */
    @isTest
    static void testUpsertRelatedAssignmentAndSchedule3() 
	{
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
        insert daysOff;
        delete daysOff;
        Test.stopTest();		
        Integer expected = 0;
        Integer actual = [Select Id From pse__Assignment__c limit 10].size();
        system.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
        
		actual = [Select Id From pse__Schedule__c limit 10].size();
        system.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
    }
    
      @isTest
    static void testUpsertRelatedAssignmentAndSchedule4() 
	{
        Contact cont = [Select Id from Contact Limit 1];
        Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
        Days_Off__c daysOff2 = UTL_OWF_TestData.createDaysOff(cont.Id);
        Test.startTest();
        insert daysOff2;
        insert daysOff;
        daysOff.First_Day_Off__c = System.today().addDays(1);
        daysOff.Status__c = 'Cancelled'; 
        daysOff.Assignment_Type__c ='Days Off';
        update daysOff;   
        daysOff2.First_Day_Off__c = System.today().addDays(-2);
        daysOff2.Status__c = 'Cancelled'; 
        daysOff2.Assignment_Type__c ='Days Off';
        update daysOff2; 
        Test.stopTest();		
        Date expected = System.today().addDays(-2);
        Date actual = [Select Id,pse__Start_Date__c From pse__Schedule__c limit 1].pse__Start_Date__c;
        system.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
    }
    
    static void testUpsertRelatedAssignmentAndSchedule5(){
       Account acc = [Select Id from Account Limit 1];
       Contact cont = [Select Id from Contact Limit 1];
       Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.id);
       insert opp;
       Bid_History__c BidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
       insert BidHistory;
       pse__Grp__c grp = [Select Id from pse__Grp__c Limit 1];
       pse__Proj__c daysOffProject = UTL_OWF_TestData.createBidProject(grp.Id);
       daysOffProject.name = 'test1';
       daysOffProject.Bid_History__c = BidHistory.id;
       daysOffProject.pse__Opportunity__c = opp.id;
       Days_Off__c daysOff = UTL_OWF_TestData.createDaysOff(cont.Id);
       daysOff.First_Day_Off__c = System.today().addDays(1);
       Test.startTest();
       insert daysOffProject;
       insert daysOff;
       Test.stopTest();
       Date expected = System.today().addDays(1);
       Date actual = [Select Id,pse__Start_Date__c From pse__Schedule__c limit 1].pse__Start_Date__c;
       system.assertEquals(expected, actual, 'Verifying upsertRelatedAssignmentAndSchedule Functionality');
    }
 
}
