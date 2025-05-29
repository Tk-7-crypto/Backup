/**
 * This test class is used to test all methods in CNT_OWF_CreateAgreementFromAccount.
 * version : 1.0
 */
@isTest
private class TST_CNT_OWF_CreateAgreementFromAccount{

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
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id]; 
    }
    
	
    /**
    * This test method used for showAvailableAgrRecordTypeForAccount
    */
    static testmethod void testShowAvailableAgrRecordTypeForAccount() 
	{
        test.startTest();
		   Account acc= [SELECT Id FROM Account WHERE name = 'TestAccount'];
		   List<String> accFields = new List<String>{'Id','Name'};
		   CNT_OWF_CreateAgreementFromAccount controller = new CNT_OWF_CreateAgreementFromAccount (new ApexPages.StandardController(acc));
		   CNT_OWF_CreateAgreementFromAccount.showAvailableAgrRecordTypeForAccount(acc.id,accFields);
     	test.stopTest();
        
		List<CNT_OWF_CreateAgreementFromAccount.BidTypeWrapper> bidTypeList = CNT_OWF_CreateAgreementFromAccount.showAvailableAgrRecordTypeForAccount(acc.id,accFields);
        system.assert(bidTypeList.size() > 0);
    }
}