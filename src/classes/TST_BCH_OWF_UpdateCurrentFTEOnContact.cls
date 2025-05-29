/**
 * This test class is used to test BCH_OWF_UpdateCurrentFTEOnContact.cls batch class.
 * version : 1.0
 */
@isTest(seeAllData=false)
private class TST_BCH_OWF_UpdateCurrentFTEOnContact {
    
	/**
    * This method is used to setup data for all methods.
    */
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
        cont.pse__Salesforce_User__c = userList[0].id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = Date.newInstance(2020, 05, 08);
        opp.Presentation_Country__c = 'Armenia';
        opp.Presentation_Date_Status__c = 'Estimated';
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
        system.debug('agreement.RFP_Ranking__c' + agreement);
        insert agreement;
        Test.startTest();
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
        Test.stopTest();
    }
    
	
    /**
    * This test method used to test BCH_OWF_UpdateCurrentFTEOnContact batch class.
    */ 
    static testMethod void testUpdateCompletedStatusOnAssignment()
	{
        pse__Assignment__c assignement = [Select id, pse__Status__c, pse__Start_Date__c from pse__Assignment__c limit 1];
        assignement.pse__Status__c = CON_OWF.OWF_STATUS_ACCEPTED;
        Test.StartTest() ;
            update assignement;
            BCH_OWF_UpdateCurrentFTEOnContact batch = new BCH_OWF_UpdateCurrentFTEOnContact();
            database.executeBatch(batch, 1);        
        
			Date currentDate = Date.today();
			Decimal currentFTE = 0.0;
			for(pse__assignment__c assignment : [select id, Suggested_FTE__c, pse__Resource__r.Current_FTE__c  from pse__Assignment__c where pse__Status__c = 'Accepted' and pse__Start_Date__c <=: currentDate]) 
            {
                        currentFTE += assignment.Suggested_FTE__c;                                     
			}
        Test.StopTest();
        
		//Checking the status of the Assignment
        pse__Assignment__c assignment = [Select id, pse__Status__c from pse__Assignment__c limit 1];
        system.assertEquals(CON_OWF.OWF_STATUS_ACCEPTED, assignment.pse__Status__c);  
    }
}