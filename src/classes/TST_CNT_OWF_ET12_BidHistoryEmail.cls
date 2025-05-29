@isTest
public class TST_CNT_OWF_ET12_BidHistoryEmail {

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
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        bidHistory.RFP_Ranking__c = '2';
        bidHistory.Budget_Deliverable__c = CON_OWF.BUDGET_DELIVERABLE;
        insert bidHistory;
    }
    
    /**
	* This test method used for testTemplate
	*/
    static testmethod void testTemplate() 
	{
        test.startTest();
			Bid_History__c bidHistory= [SELECT Id FROM Bid_History__c limit 1];
			List<String> accFields = new List<String>{'Id','Name'};
			CNT_OWF_ET12_BidHistoryEmail controller = new CNT_OWF_ET12_BidHistoryEmail();
			controller.setRecordId(bidHistory.Id);
			controller.getRecordId();
        	controller.setComponentRef('TriageTemplate');
        	controller.getComponentRef();
        test.stopTest();
        
        Id expected = bidHistory.Id;
        Id actual = controller.getRecordId();
        system.assertEquals(expected, actual);   
    }
}
