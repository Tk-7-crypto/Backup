@isTest
public class TST_SCH_OWF_CommonSchedule {
    @testSetup
    static void dataSetup() 
    {
        List<User> userList = UTL_TestData.createUser('System Administrator Integration', 2);
        userList[0].FirstName = 'OWF';
        userList[0].LastName =  'Notification User';
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
        userList[0].FirstName = 'PSA';
        userList[0].LastName =  'Notification User';
        userList[1].SUBREGION__c = 'United States of America';
        userList[1].IsActive = true;
        insert userList;
    }
    
    static testMethod void testTimeScenario1(){
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_Generate_Triage_Users_Report');
        insert owfBatchConfig;
        User u= [Select id from User where Name= 'OWF Notification User' LIMIT 1];
        System.runAs(u) {
            Test.StartTest() ;
            SCH_OWF_CommonSchedule sh = new SCH_OWF_CommonSchedule();
            
            String sch = '0 0 1 1/1 * ? *';
            String jobId = system.schedule('OWF Schedule Test', sch, sh);
            Test.StopTest() ;
            
            //Verifying the Cron Expression
            CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            String expected = '0 0 1 1/1 * ? *';
            system.assertEquals(expected, actual.CronExpression);
        }
    }
    
    static testMethod void testTimeScenario2(){
        User u= [Select id from User where Name= 'OWF Notification User' LIMIT 1];
        System.runAs (u) {
            Test.StartTest() ;
            SCH_OWF_CommonSchedule sh = new SCH_OWF_CommonSchedule();
            
            String sch = '0 0 13 * * ? *';
            String jobId = system.schedule('OWF Schedule Test 1', sch, sh);
            Test.StopTest() ;
            
            //Verifying the Cron Expression
            CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            String expected = '0 0 13 * * ? *';
            system.assertEquals(expected, actual.CronExpression);
        }
    }
    static testMethod void testTimeScenario7(){
        User u= [Select id from User where Name= 'PSA Notification User' LIMIT 1];
        System.runAs (u) {
            Test.StartTest() ;
            SCH_OWF_CommonSchedule sh = new SCH_OWF_CommonSchedule();
            
            String sch = '0 0 1 1 */1 ?';
            String jobId = system.schedule('PSA Schedule Test', sch, sh);
            Test.StopTest() ;
            
            //Verifying the Cron Expression
            CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            String expected = '0 0 1 1 */1 ?';
            system.assertEquals(expected, actual.CronExpression);
        }
    }
    
    
}