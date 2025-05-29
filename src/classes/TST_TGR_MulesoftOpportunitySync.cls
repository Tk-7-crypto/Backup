@isTest
private class TST_TGR_MulesoftOpportunitySync {
    
    static testmethod void insertMulesoftOpportunitySyc () {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Mulesoft_Opportunity_Sync__c mos = new Mulesoft_Opportunity_Sync__c();
        mos.LI_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
        mos.LI_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
        mos.LI_Mulesoft_Sync_Timestamp__c = null;
        mos.LI_Mulesoft_Error_Message__c = null;  
        mos.LQ_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
        mos.LQ_Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
        mos.LQ_Mulesoft_Sync_Timestamp__c = null;
        mos.LQ_Mulesoft_Error_Message__c = null;
        mos.Opportunity__c = opp.Id;
        Test.startTest();
        try{
		insert mos;
		}
		catch(exception e){}
        Test.stopTest();
        
    }

}