/**
 * This test class is used to test SCH_PSA_CDCHealthCheckup scheduler.
 * version : 1.0
 */
 
@isTest
private class TST_SCH_PSA_CDCHealthCheckup {
    
    /**
     * This test method used to test SCH_PSA_CDCHealthCheckup scheduler
    */ 
    static testMethod void testSCH_PSA_CDCHealthCheckup() {
        Test.StartTest() ;
        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Total_Fields_of_Aggregate_Report__c = 304;
        rdsSettings.Total_Fields_of_Project_Task__c = 219;
        rdsSettings.Total_Fields_of_Project_Log__c = 74;
        rdsSettings.Total_Fields_of_Target__c = 58;
        rdsSettings.User_Ids__c = UserInfo.getUserId();
        insert rdsSettings;
        SCH_PSA_CDCHealthCheckup sh = new SCH_PSA_CDCHealthCheckup();
        String sch = '0 0 12 1 1 ? *';
        String jobId = system.schedule('Test CDC Monitor Job', sch, sh);
        Test.StopTest() ;
    
    //Verifying the Cron Expression
        CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        String expected = '0 0 12 1 1 ? *';
        system.assertEquals(expected, actual.CronExpression);
    }
}