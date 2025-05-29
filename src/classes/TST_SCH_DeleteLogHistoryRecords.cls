@isTest(seeAllData = false)
public class TST_SCH_DeleteLogHistoryRecords {
    public static testMethod void testSCH_DeleteTpaLogs()
    {
        insert new Log_Setting__c(Name = 'TPA', Log_Data_to_keep_for__c = 2);
        Log_History__c objLogHist = new Log_History__c(GUID__c = UTL_LogFactory.Guid, Log_Level__c = 'INFO', Log_Module__c = 'TPA', Log_Detail__c = 'Test', Log_Type__c = 'Custom');
        insert objLogHist;
        Datetime yesterday = Datetime.now().addDays(-3);
        Test.setCreatedDate(objLogHist.Id, yesterday);
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_DeleteLogHistoryRecords());
        Test.stopTest();
    }

}