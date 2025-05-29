/**
* This test class is used to test SCH_PSA_DeleteEstVsActuals scheduler.
* version : 1.0
*/
@isTest
private class TST_SCH_PSA_DeleteEstVsActuals {
    /**
* This test method used to test SCH_PSA_DeleteEstVsActuals scheduler
*/
    static testMethod void testSCH_PSA_DeleteEstVsActuals() {
        Test.startTest();
        SCH_PSA_DeleteEstVsActuals sh = new SCH_PSA_DeleteEstVsActuals();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test SCH_PSA_DeleteEstVsActuals Job', sch, sh);
        Test.StopTest() ;
        
        //Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
}