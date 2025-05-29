@isTest
public class TST_SCH_CLM_BoxMigration {

    @isTest
    private static void testBoxMigrationScheduler() {
        String query = 'SELECT Id FROM Contract';        
        SCH_CLM_BoxMigration scheduler = new SCH_CLM_BoxMigration(query);
        String CRON_EXP = '0 0 0 22 9 ? '+ (Date.Today().year() + 1);
        
        Test.startTest();
            String jobId = System.schedule('TST_SCH_CLM_BoxMigration', CRON_EXP, scheduler);
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'The cron expression should be same after scheduled job');
    }
}