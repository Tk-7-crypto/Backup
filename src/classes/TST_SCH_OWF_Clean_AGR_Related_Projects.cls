/**
* This test class is used to test SCH_OWF_Clean_AGR_Related_Projects scheduler.
* version : 1.0 
*/

@isTest
private class TST_SCH_OWF_Clean_AGR_Related_Projects 
{
    
    /**
	* This test method used to test SCH_OWF_UpdateResourceRequestStatus scheduler
	*/ 
    static testMethod void testAcceptUnassignedAssignments()
    {
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_Clean_AGR_Related_Projects');
        insert owfBatchConfig;
        Test.StartTest() ;
        SCH_OWF_Clean_AGR_Related_Projects sh = new SCH_OWF_Clean_AGR_Related_Projects();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Delete: Delete Projects in Cascading related to Deleted Agreement Records', sch, sh);
        Test.StopTest() ;
        
        //Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
    
   	static testMethod void testAcceptUnassignedAssignmentsNeagtive(){        
        Test.StartTest() ;
        SCH_OWF_Clean_AGR_Related_Projects sh = new SCH_OWF_Clean_AGR_Related_Projects();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test Delete: Delete Projects in Cascading related to Deleted Agreement Records', sch, sh);
        Test.StopTest() ;

        //Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }  
}