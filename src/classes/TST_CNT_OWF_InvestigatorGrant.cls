@isTest
private class TST_CNT_OWF_InvestigatorGrant {
    
    /**
    * This method is used to setup data for all methods.
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
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Bid_History__c bidhistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidhistory.Bid_Number__c = 0;
        insert bidhistory;
        Investigator_Grant__c ig = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(bidhistory.Id);
        ig.Request_Status__c = 'Open';
        insert ig;
    }
	
	static testmethod void testTemplate() 
	{
        test.startTest();
            Investigator_Grant__c IG= [SELECT Id FROM Investigator_Grant__c limit 1];

            CNT_OWF_InvestigatorGrant controller = new CNT_OWF_InvestigatorGrant();
            controller.setRecordId(IG.Id);
            controller.getRecordId();
        test.stopTest();
        
        Id expected = IG.Id;
        Id actual = controller.getRecordId();
        system.assertEquals(expected, actual);	
    }	
}