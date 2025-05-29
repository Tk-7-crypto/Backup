@isTest(seeAllData = false)
public class TST_SCH_DeleteWorkflowEmailRecords {
    public static testMethod void testSCH_DeleteEmailWorkflowRecords()
    {
        insert new Log_Setting__c(Name = 'Test Module', Workflow_Email_Record_keep_for__c = 2);
        Workflow_Email_Record__c objworkFlowRecord = new Workflow_Email_Record__c(content_1__c = 'Test Content', Email_Action__c = 'TPA_01_SendEmail', Email_Subject__c = 'Test Subject', Module_Name__c = 'Test Module', To_Email_1__c = 'test@test.com');
        insert objworkFlowRecord;
        Datetime yesterday = Datetime.now().addDays(-4);
        Test.setCreatedDate(objworkFlowRecord.Id, yesterday);
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_DeleteWorkflowEmailRecords());
        Test.stopTest();
    }
}