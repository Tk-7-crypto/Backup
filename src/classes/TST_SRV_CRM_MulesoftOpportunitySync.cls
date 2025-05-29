/*
 * Version       : 1.0
 * Description   : test class for MulesoftOpportunitySync Service
 */
@isTest
private class TST_SRV_CRM_MulesoftOpportunitySync {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
    }
    
    /**
    * test method to test selectById
    */  
    static testmethod void testGetMulesoftOpportunitySyncByOppIds() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
            List<Mulesoft_Opportunity_Sync__c> oppSyncList = SRV_CRM_MulesoftOpportunitySync.getMulesoftOpportunitySyncByOppIds(new Set<Id>{opp.Id});
        Test.stopTest();
        
    }
    
    /**
    * test method to test selectById
    */  
    static testmethod void testGetMulesoftOpportunitySyncByOppIdsException() {
        Test.startTest();
            try {
                List<Mulesoft_Opportunity_Sync__c> oppSyncList = SRV_CRM_MulesoftOpportunitySync.getMulesoftOpportunitySyncByOppIds(null);
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals('SRV_CRM_MulesoftOpportunitySync.MulesoftOpportunitySyncException', ex.getTypeName());
            }
            
        Test.stopTest();
    }
}