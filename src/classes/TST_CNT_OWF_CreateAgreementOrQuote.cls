@isTest
public class TST_CNT_OWF_CreateAgreementOrQuote {
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
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.sub_group__c = 'GBO-Lead PD';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
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
        Bid_History__c agreement =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
        test.startTest();
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.SubGroup__c = 'GBO-Lead PD';
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
    }
     @isTest
    public static void testCanCurrentUserCreateQuote(){
        Bid_History__c bid = [Select id from bid_history__c limit 1];
        boolean hasAccess = CNT_OWF_CreateAgreementOrQuote.canCurrentUserCreateQuoteOrAgreement(bid.id,'Create_Budget');
        System.assertEquals(false, hasAccess, 'Checking if User has access');
    }
     @isTest
    public static void testCanCurrentUserCreateAgreement(){
        Bid_History__c bid = [Select id from bid_history__c limit 1];
        boolean hasAccess = CNT_OWF_CreateAgreementOrQuote.canCurrentUserCreateQuoteOrAgreement(bid.id,'Create_Agreement');
        System.assertEquals(false, hasAccess, 'Checking if User has access');
    }

}
