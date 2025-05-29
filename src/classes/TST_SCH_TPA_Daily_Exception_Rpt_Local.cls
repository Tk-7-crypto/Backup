@isTest(seeAllData = false)
public class TST_SCH_TPA_Daily_Exception_Rpt_Local {
    public static testMethod void testSCH_TPA_Daily_Exception_Rpt_Local() {
        Test.startTest();      
		String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        UTL_TPA_SetupTestData.createTPASettingData();
		String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_Daily_Exception_Rpt_Local());
		Test.stopTest();
    }

}