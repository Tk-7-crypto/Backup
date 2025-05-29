@isTest
private class TST_SLT_InvestigatorGrant {
    
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
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreement(acc.Id, opp.Id);
        
        insert agreement;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        Investigator_Grant__c ig = UTL_OWF_TestData.createInvestigatorGrantByAgreementId(agreement.Id);
        ig.Request_Status__c = 'Open';
        insert ig;
        Investigator_Grant__c ig1 = UTL_OWF_TestData.createInvestigatorGrantByBidHistory(bidHistory.Id);
        ig1.Request_Status__c = 'Open';
        insert ig1;
    }
    
    @isTest
    static void testGetInvestigatorGrantById()
	{
        Investigator_Grant__c ig = [Select Id From Investigator_Grant__c][0];
        Set<Id> idSet = new Set<Id>{ig.Id};
        Set<String> fieldSet = new Set<String>{'Id'};
        Map<Id, Investigator_Grant__c> idToAgreementMap = new SLT_InvestigatorGrant().getInvestigatorGrantById(idSet, fieldSet);
		
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    @isTest
    static void testGetInvestigatorGrantByBidHistoryId()
	{
        Bid_History__c bid = [Select Id From Bid_History__c][0];
        Set<Id> idSet = new Set<Id>{bid.Id};
        Set<String> fieldSet = new Set<String>{'Id'};
        String condition = 'Bid_History__c in: sObjectIdset';
        List<Investigator_Grant__c> igList = new SLT_InvestigatorGrant().getInvestigatorGrantByBidHistoryId(idSet,condition, fieldSet);
		
        Integer expected = 1;
        System.assertEquals(expected, igList.size());
    }
}