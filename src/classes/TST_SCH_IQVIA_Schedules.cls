@isTest
public class TST_SCH_IQVIA_Schedules {
    @testSetup
    static void dataSetup() 
    {
        List<User> userList = UTL_TestData.createUser('System Administrator Integration', 1);
        userList[0].FirstName = 'OWF';
        userList[0].LastName =  'Notification User1';
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
		userList[0].employeenumber = null;
        userList[0].Audit_Employee_Number_Reason__c = 'test sch class user';
        insert userList;
        List<IQVIA_Schedule_Setting__c> iqviaScheduleSettingList =new List<IQVIA_Schedule_Setting__c>();
        IQVIA_Schedule_Setting__c  iqviaScheduleSetting = UTL_TestData.createIqviaSchedulesetting();
        
        iqviaScheduleSetting.Running_User__c=userList[0].id;
        iqviaScheduleSettingList.add(iqviaScheduleSetting);
        IQVIA_Schedule_Setting__c  iqviaScheduleSetting1 = UTL_TestData.createIqviaSchedulesetting();
        
        iqviaScheduleSetting1.Running_User__c=userList[0].id;
        iqviaScheduleSetting1.Abort_Current_Batch__c=true;
        iqviaScheduleSettingList.add(iqviaScheduleSetting1);
        IQVIA_Schedule_Setting__c  iqviaScheduleSetting2 = UTL_TestData.createIqviaSchedulesetting();
        
        iqviaScheduleSetting2.Running_User__c=userList[0].id;
        iqviaScheduleSetting2.Abort_Previous_Batch__c=true;
        iqviaScheduleSettingList.add(iqviaScheduleSetting2);
        IQVIA_Schedule_Setting__c  iqviaScheduleSetting3 = UTL_TestData.createIqviaSchedulesetting();
        
        iqviaScheduleSetting3.Running_User__c=userList[0].id;
        iqviaScheduleSetting3.Batch_Name__c ='TST';
        iqviaScheduleSettingList.add(iqviaScheduleSetting3);
         insert iqviaScheduleSettingList;
        Schedule_Failure_Notification_Mail__c scheduleFailureNotificationMail =new  Schedule_Failure_Notification_Mail__c();
        scheduleFailureNotificationMail.Module_Name__c ='OWF'; 
        scheduleFailureNotificationMail.User_Ids__c=userList[0].id;
        scheduleFailureNotificationMail.Name='test1';
        insert scheduleFailureNotificationMail;
        Schedule_Failure_Notification_Mail__c scheduleFailureNotificationMail1 =new  Schedule_Failure_Notification_Mail__c();
        scheduleFailureNotificationMail1.Module_Name__c ='Devops';
        scheduleFailureNotificationMail1.Name='test2';
        scheduleFailureNotificationMail1.User_Ids__c=userList[0].id;
        insert scheduleFailureNotificationMail1;
         
    }
    static testMethod void testscheduleExecution(){
        OWF_Batch_Config__c owfBatchConfig = UTL_OWF_TestData.setupOWFBatchConfig('BCH_OWF_Generate_Triage_Users_Report');
        insert owfBatchConfig;
        User u= [Select id from User where Name= 'OWF Notification User1' LIMIT 1];
        System.runAs(u) {
            Test.StartTest() ;
            SCH_IQVIA_Schedules sh = new SCH_IQVIA_Schedules();
            
            String sch = '0 0 1 1 2 ? *';
            String jobId = system.schedule('OWF Schedule Test', sch, sh);
            Test.StopTest() ;
            
            //Verifying the Cron Expression
            CronTrigger actual = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            String expected = '0 0 1 1 2 ? *';
            system.assertEquals(expected, actual.CronExpression);
        }
    }
    
    
}