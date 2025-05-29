@isTest
private class TST_SCH_CRM_OpportunityRenewals_ClonSch {
    static testmethod void testBatchOppCloningScheduler() {
            Test.startTest();
            Renewal_Dashboard_Settings__c RDSetting = new Renewal_Dashboard_Settings__c();
            RDSetting.Cloning_Batch_Size__c = 5 ;
            RDSetting.Renewal_Year__c = 2017;
            insert RDSetting; 
        
            // Schedule the test job
            String jobId = System.schedule('testBatchOppCloningScheduler',
                                 SCH_CRM_OpportunityRenewals_ClonSch.CRON_EXP, new SCH_CRM_OpportunityRenewals_ClonSch());
            Test.stopTest();
    }
}