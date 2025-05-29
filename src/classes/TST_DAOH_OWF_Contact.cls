@isTest
private class TST_DAOH_OWF_Contact {
	
	/**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.sub_group__c = 'TSL-Japan';
        cont.Secondary_Sub_Group__c = 'GBO-Lead PD';
        cont.Baseline_FTE__c = 1.0;
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
		insert agreement;
		pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
    }
	
    @isTest
    static void testCloseRelatedAssignmentsOnUpdate()
    {
        Integer aftereUpdateCount; 
        Test.startTest();
        	Contact cont = [Select Id From Contact Where Name = 'Test Contact'][0];
        	cont.pse__Is_Resource__c = false;
        	cont.pse__Is_Resource_Active__c = false;
        	update cont;
        	aftereUpdateCount = [Select Count() from pse__Assignment__c where pse__Status__c = 'Pending'];
        Test.stopTest();
		
        system.assertEquals(aftereUpdateCount, 0, 'All Related Assignment should be in Closed status if the Related Resource has isResource & isResourceActive as False');
    }
    
    @isTest
    static void testCloseRelatedAssignmentsOnUpdateForFutureStartDate()
    {
        Integer aftereUpdateCount; 
        pse__Schedule__c schedule = [Select id from pse__Schedule__c limit 1];
        schedule.pse__Start_Date__c = Date.today()+2;
        update schedule;
        Test.startTest();
        	Contact cont = [Select Id From Contact Where Name = 'Test Contact'][0];
        	cont.pse__Is_Resource__c = false;
        	cont.pse__Is_Resource_Active__c = false;
        	update cont;
        	aftereUpdateCount = [Select Count() from pse__Assignment__c where pse__Status__c = 'Pending'];
        Test.stopTest();
		
        system.assertEquals(aftereUpdateCount, 0, 'All Related Assignment should be in Closed status if the Related Resource has isResource & isResourceActive as False');
    }
    
    
    @isTest
    static void testvalidateBaselineFTE()
    {	
        Test.startTest();
        	Contact cont = [Select Id,Baseline_FTE__c From Contact Where Name = 'Test Contact'][0];
        	cont.Baseline_FTE__c = 2.0;
        	update cont;
        	Contact aftereUpdateCont = [Select Id,Baseline_FTE__c From Contact Where Name = 'Test Contact'][0];
     	Test.stopTest();
        system.assertEquals(aftereUpdateCont.Baseline_FTE__c, 2.0, 'If Contact have any GBO subgroup assigned in Subgroup or Additional Subgroup, then Baseline FTE can be greater than 1.0 ');
    }
}
