/**
* This test class is used to test all methods in Investigator Grant trigger helper.
* version : 1.0
*/
@IsTest
public class TST_DAO_Investigator_Grant {
    
    /**
    * This method is used to setup data for all methods.
    */
    @TestSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert bidHistory; 
    }
    
	
    /**
    * This test method used for insert Investigator Grant
    */ 
    static testMethod void testInvestigatorGrantInsert() 
	{   
        Bid_History__c bidHistory =[Select id from Bid_History__c limit 1];
        Test.startTest();
        Investigator_Grant__c investigatorGrantRecord = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(bidHistory.id);
        insert investigatorGrantRecord;
		Test.stopTest();
		Integer expected = 1;
        Integer actual = [Select id from Investigator_Grant__c].size();
        system.assertEquals(expected, actual);
    }
    
	

}