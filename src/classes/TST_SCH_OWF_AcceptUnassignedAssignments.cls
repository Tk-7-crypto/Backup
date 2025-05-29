/**
 * This test class is used to test SCH_OWF_AcceptUnassignedAssignments scheduler.
 * version : 1.0
 */
 
@isTest
private class TST_SCH_OWF_AcceptUnassignedAssignments {
    
    /**
     * This test method used to test SCH_OWF_AcceptUnassignedAssignments scheduler
    */ 
    static testMethod void testAcceptUnassignedAssignments()
	{
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_AcceptUnassignedAssignments');
        insert owfBatchConfig;
        Test.StartTest() ;
        SCH_OWF_AcceptUnassignedAssignments sh = new SCH_OWF_AcceptUnassignedAssignments();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Accept Unassigned Assignments', sch, sh);
        Test.StopTest() ;
		
		//Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
    
	
    /**
     * This test method used to test SCH_OWF_AcceptUnassignedAssignments scheduler with Default Batch Size
    */ 
    static testMethod void testAcceptUnassignedAssignmentsDefaultBatchSize(){
        Test.StartTest() ;
        SCH_OWF_AcceptUnassignedAssignments sh = new SCH_OWF_AcceptUnassignedAssignments();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Accept Unassigned Assignments', sch, sh);
        Test.StopTest() ;
		
		//Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
}