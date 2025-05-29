@isTest(seeAllData=false)
private class TST_BCH_OWF_Clean_AGR_Related_Projects {

    @testSetup
    static void dataSetup() 
	{
        
        User testUser = UTL_OWF_TestData.createUser('System Administrator',1)[0];
        insert testUser;
        Mulesoft_Integration_Control__c mfc = new Mulesoft_Integration_Control__c();
        mfc.Is_Mulesoft_User__c = true;
        mfc.Ignore_Validation_Rules__c = true;
        mfc.SetupOwnerId = testUser.Id;
        insert mfc;
        
		System.runAs(testUser)
        {
			Account acc = UTL_OWF_TestData.createAccount();
			insert acc;
			pse__Grp__c grp = UTL_OWF_TestData.createGroup();
			insert grp;
			Contact cont = UTL_OWF_TestData.createContact(acc.Id);
			cont.pse__Is_Resource__c = true;
			cont.pse__Is_Resource_Active__c = true;
			cont.pse__Group__c = grp.Id;
			cont.FirstName = UserInfo.getFirstName();
			cont.LastName = UserInfo.getLastName();
			cont.sub_group__c = 'TSL-Japan';
			cont.available_for_triage_flag__c = true;
			insert cont;
			pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
			insert permissionControlGroup;
			Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
			insert opp;
			Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement.Bid_Number__c = 0;
			agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
			agreement.RFP_Ranking__c = '2';
			agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
			test.startTest();
			insert agreement;        
			pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
			update bidProject; 
			pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
			insert schedule;
			pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
			resourceRequest.pse__Group__c = grp.Id;
			resourceRequest.RecordTypeId = Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosByDeveloperName().get('OWF_Resource_Request').getRecordTypeId();   
			insert resourceRequest;
			pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
			insert assignement;
			test.stopTest();
        }
		
        pse__Proj__c  bidProject1 = [Select id from pse__Proj__c limit 1];
        Map<Id,String> projectIdToErrorMessageMap = new Map<Id,String>();
        projectIdToErrorMessageMap.put(bidProject1.Id,'Error in Project deletion through queuable job: ' + 'Error in Project deletion through queuable job: TGR_Proj: execution of AfterDelete'
										+'caused by: fflib_SObjectDomain.DomainException: Permission to delete an pse__Proj__c denied.'
										+'Class.fflib_SObjectDomain.handleAfterDelete: line 233, column 1'
										+'Class.fflib_SObjectDomain: line 376, column 1'
										+'Class.fflib_SObjectDomain.triggerHandler: line 321, column 1'
										+'Trigger.TGR_Proj: line 8, column 1');
        UTL_OWF.createApexErrorLogs('Project (pse__Proj__c)', 'Error in Project deletion through queuable job: ', projectIdToErrorMessageMap);
    }
    
	@isTest
    static void testDeleteAgreementCascading()
    {        
        List<Map<Id,String>> coverageFixList = new List<Map<Id, String>>();
        Map<Id,String> coverageFixMap = new Map<Id,String>();
        Bid_History__c bid = [Select Id from Bid_History__c limit 1];
        coverageFixMap.put(bid.id,'Error in Project deletion through Batch: ' + 'Error in Project deletion through Batch: TGR_Proj: execution of AfterDelete'
										+'caused by: fflib_SObjectDomain.DomainException: Permission to delete an pse__Proj__c denied.'
										+'Class.fflib_SObjectDomain.handleAfterDelete: line 233, column 1'
										+'Class.fflib_SObjectDomain: line 376, column 1'
										+'Class.fflib_SObjectDomain.triggerHandler: line 321, column 1'
										+'Trigger.TGR_Proj: line 8, column 1');
        Test.startTest();
        BCH_OWF_Clean_AGR_Related_Projects batch = new BCH_OWF_Clean_AGR_Related_Projects();
        coverageFixList.add(coverageFixMap);
        batch.projectIdToErrorMessageMapList = coverageFixList;
        DataBase.executeBatch(batch,10);
        
        
        List<pse__Proj__c> bidProject = [Select Id from pse__Proj__c limit 1];
        Test.stopTest();
		Integer expected = 1;
        Integer actual = bidProject.size();
        system.assertEquals(expected, actual,'Verifying BCH_OWF_Clean_AGR_Related_Projects Functionality');
    }
}
