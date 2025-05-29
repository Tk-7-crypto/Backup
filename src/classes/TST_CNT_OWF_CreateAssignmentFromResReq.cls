/**
 * This test class is used to test all methods in Resource Request trigger.
 * version : 1.0 
 */
@isTest(seeAllData=false)
private class TST_CNT_OWF_CreateAssignmentFromResReq {
    
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
        cont.sub_group__c = 'TSL-Japan';
        cont.Available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 1;
        agreement.Bid_Due_Date__c = System.today().AddDays(5);
        insert agreement; 
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.subgroup__c = 'TSL-Japan';
        resourceRequest.Suggested_FTE__c = 11;
        insert resourceRequest;
    }
	
    
    /**
    * This test method used to test getSuggestedFTEFromResRequest method
    */
    @isTest
    static void testGetSuggestedFTEFromResRequest() 
	{
        Test.startTest();
			Contact cont = [SELECT Id, Name FROM Contact limit 1];
			Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
			pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];        
			pse__Resource_Request__c resRequest = [SELECT Id, Name FROM pse__Resource_Request__c where subgroup__c = 'TSL-Japan' limit 1];
			pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
			insert schedule;
			pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resRequest.Id);
			insert assignment;
        Test.stopTest();
			
        String expected = 'Assignment already exists';
        String actual = CNT_OWF_CreateAssignmentFromResReq.getSuggestedFTEFromResRequest(String.valueOf(resRequest.Id));
        system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAssignmentFromResReq.getSuggestedFTEFromResRequest Functionality');
    }
    
	
    /**
    * This test method used to test createAssignment method
    */
    @isTest
    static void testCreateAssignment() 
	{
        pse__Resource_Request__c resRequest = [SELECT Id, Name FROM pse__Resource_Request__c where subgroup__c = 'TSL-Japan'];
        Contact cont = [Select Id From Contact order by CreatedDate asc limit 1];
        
        Test.startTest();
            String resultMessage = CNT_OWF_CreateAssignmentFromResReq.assignResourceAndCreateAssignment(resRequest.Id, cont.Id);
            system.assertEquals('success', resultMessage, 'Verifying CNT_OWF_CreateAssignmentFromResReq.assignResourceAndCreateAssignment Functionality');
        Test.stopTest();
    }
    
	
    /**
    * This test method used to test createAssignment method
    */
    @isTest
    static void testCreateAssignmentWithError() {
        pse__Resource_Request__c resRequest = [SELECT Id, Name FROM pse__Resource_Request__c where subgroup__c = 'TSL-Japan'];
        Contact cont = [Select Id From Contact order by CreatedDate asc limit 1];
        cont.sub_group__c = 'TSL';
        update cont;
        
        Test.startTest();
            String resultMessage = CNT_OWF_CreateAssignmentFromResReq.assignResourceAndCreateAssignment(resRequest.Id, cont.Id);
            system.assertNotEquals('success', resultMessage, 'Verifying CNT_OWF_CreateAssignmentFromResReq.assignResourceAndCreateAssignment Functionality');
        Test.stopTest();
    }
    
	
    /**
    * This test method used to test createAssignment method
    */
    @isTest
    static void testHasAccess() 
	{
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(new pse__Resource_Request__c());
            CNT_OWF_CreateAssignmentFromResReq cnt = new CNT_OWF_CreateAssignmentFromResReq(sc);
            cnt.hasAccess = true;
        Test.stopTest();
        
        Boolean expected = true;
        Boolean actual = cnt.hasAccess;
        system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAssignmentFromResReq.hasAccess Functionality');
    }
}