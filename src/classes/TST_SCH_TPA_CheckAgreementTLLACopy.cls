@isTest(seeAllData = false)
public class TST_SCH_TPA_CheckAgreementTLLACopy {    
    public static testMethod void testCheckAgreementTLLA() {
        Test.startTest();      
        TPA_Settings__c tpaSetting = UTL_TPA_SetupTestData.createTPASettingsData();
        tpaSetting.TLLA_Batch_Execution_Time__c = 900;
        update tpaSetting;
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_CheckAgreementTLLACopy());
        Test.stopTest();
    }
}