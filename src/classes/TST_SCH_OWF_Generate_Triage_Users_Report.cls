@isTest
private class TST_SCH_OWF_Generate_Triage_Users_Report {

    static testMethod void testAcceptUnassignedAssignments()
	{
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_Generate_Triage_Users_Report');
        insert owfBatchConfig;
        Test.StartTest() ;
        SCH_OWF_Generate_Triage_Users_Report sh = new SCH_OWF_Generate_Triage_Users_Report('PSASET');
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Update:Test updated user triage access', sch, sh);
        Test.StopTest() ;
		
		//Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
    
	
    static testMethod void testAcceptUnassignedAssignmentsNegative()
	{
        Test.StartTest() ;
        SCH_OWF_Generate_Triage_Users_Report sh = new SCH_OWF_Generate_Triage_Users_Report('PSASET');
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Update:Test updated user triage access', sch, sh);
        Test.StopTest();
		
		//Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
}