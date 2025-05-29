@isTest
public class TST_CNT_OWF_ASN_ET02_PendingForReview {
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
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.sub_group__c = 'TSL-Japan';
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
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.subgroup__c = 'TSL-Japan';
        resourceRequest.Suggested_FTE__c = 11;
        insert resourceRequest;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
		insert schedule;
		pse__Assignment__c assignment = UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
		insert assignment;
    }
    
    /**
	* This test method used for testTemplate
	*/
    static testmethod void testTemplate() 
    {
        test.startTest();
        pse__Assignment__c assignment = [SELECT Id from pse__Assignment__c limit 1];
        CNT_OWF_ASN_ET02_PendingForReview controller = new CNT_OWF_ASN_ET02_PendingForReview();
        controller.setRecordId(assignment.Id);
        controller.getRecordId();
        test.stopTest();
        Id expected = assignment.Id;
        Id actual = controller.getRecordId();
        system.assertEquals(expected, actual);
    }
}