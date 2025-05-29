@isTest
public class TST_CNT_OWF_ET31_GCCApprovalProcess {
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
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c gccBidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_GCC_SHORT_FORM_BID_HISTORY_RECORD_TYPE_ID);
        gccBidHistory.Bid_History_Status__c = CON_OWF.OWF_BID_HISTORY_STATUS_IN_AWAITING_APPROVAL;
        gccBidHistory.Opportunity_Type__c = CON_OWF.OWF_BID_HISTORY_OPPORTUNITY_TYPE_INTERNAL;
        gccBidHistory.RFP_Deliverables__c = CON_OWF.OWF_BID_HISTORY_RFP_DELIVERABLES_HIGH_LEVEL_COST;
        gccBidHistory.One_Off_Fees_For_Service_Implementation__c = 50;
        insert gccBidHistory;
    }
    static testmethod void testTemplate() 
	{
        test.startTest();
        Bid_History__c bidHistory= [SELECT Id,Bid_History_Status__c,Operational_Lead1__c FROM Bid_History__c limit 1];
        bidHistory.Bid_History_Status__c = CON_OWF.OWF_BID_HISTORY_STATUS_IN_AWAITING_APPROVAL;
        bidHistory.Operational_Lead1__c = userInfo.getUserId();
        update bidHistory;
        List<String> accFields = new List<String>{'Id','Name'};
        CNT_OWF_ET31_GCCApprovalProcess controller = new CNT_OWF_ET31_GCCApprovalProcess();
        controller.setRecordId(bidHistory.Id);
        controller.getRecordId();
        test.stopTest();
        
        Id expected = bidHistory.Id;
        Id actual = controller.getRecordId();
        system.assertEquals(expected, actual);   
    }
}