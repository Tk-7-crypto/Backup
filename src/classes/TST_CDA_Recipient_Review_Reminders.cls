/**
 * @Author  : Babita Dadarwal
 * @Name    : TST_CDA_Recipient_Review_Reminders
 * @Purpose : Test class for SCH_CDA_RecipientReviewReminders Scheduler.
 * Created under CR-11169
 */
@isTest(seeAllData = false)
private class TST_CDA_Recipient_Review_Reminders {

    @testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();

        CDA_Request__c cdaRecordAuditor =  new CDA_Request__c();
        cdaRecordAuditor.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecordAuditor.CDA_Type__c = UTL_CDAUtility.AUDITOR;
        cdaRecordAuditor.CDA_Effective_Date__c = Date.today();
        cdaRecordAuditor.Date_Sent_for_Review__c = Date.today().addDays(-3);
        cdaRecordAuditor.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordAuditor.Requestor_Carbon_Copies__c = false;
        cdaRecordAuditor.Date_executed_signed_contract_received__c = System.now();
        cdaRecordAuditor.status__c = UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW;
        insert cdaRecordAuditor;
        Date sentForReviewDate = date.newinstance(cdaRecordAuditor.Date_Sent_for_Review__c.year(), cdaRecordAuditor.Date_Sent_for_Review__c.month(), cdaRecordAuditor.Date_Sent_for_Review__c.day());
        Integer dayDiff = sentForReviewDate.daysBetween(Date.today());
        Integer daysInterval = 1;
        System.assertEquals(0, Math.mod(dayDiff, daysInterval));
        //System.assertEquals(3, dayDiff);
        System.assertEquals(true, dayDiff != 0 && Math.mod(dayDiff, daysInterval) == 0);
    }

    @isTest static void test_Scheduler_Execute() {
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1); 
        String jobId = System.schedule('testRecipientReviewReminderScheduler', CRON_EXP, new SCH_CDA_RecipientReviewReminders());

        Test.stopTest();
    }
}