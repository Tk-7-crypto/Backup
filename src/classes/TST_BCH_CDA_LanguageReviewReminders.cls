@isTest(seeAllData=false)
public class TST_BCH_CDA_LanguageReviewReminders {
    @testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();

        //create Legal POC Attorney record 
        CDA_Legal_POC_Cross_Walk__c testLegalPOC = new CDA_Legal_POC_Cross_Walk__c(CDA_Language__c='Chinese',Legal_POC_First_Name__c='TestChinese',Legal_POC_Last_Name__c='Attorney',Legal_POC_Email_Address__c='test@abc.com');
		insert testLegalPOC;		

        CDA_Request__c cdaRecord =  new CDA_Request__c();
        cdaRecord.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecord.CDA_Type__c = UTL_CDAUtility.CUSTOMER;
        cdaRecord.CDA_Language__c = 'Chinese';
        cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRecord.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PROWORD;
        cdaRecord.CDA_Effective_Date__c = Date.today();
        cdaRecord.Date_Sent_for_Language_Review__c = Date.today().addDays(-2);
        cdaRecord.Requestor_Carbon_Copies__c = false;
        cdaRecord.Date_executed_signed_contract_received__c = System.now();
        cdaRecord.status__c = UTL_CDAUtility.STATUS_LANGUAGE_REVIEW;
        cdaRecord.Legal_POC_Cross_Walk__c = testLegalPOC.Id;
        cdaRecord.Originating_Requestor_Flag__c = UTL_CDAUtility.NO;
        insert cdaRecord;
        
        Date sentForReviewDate = date.newinstance(cdaRecord.Date_Sent_for_Language_Review__c.year(), cdaRecord.Date_Sent_for_Language_Review__c.month(), cdaRecord.Date_Sent_for_Language_Review__c.day());
        Integer dayDiff = sentForReviewDate.daysBetween(Date.today());
        Integer daysInterval = 1;
        System.assertEquals(0, Math.mod(dayDiff, daysInterval));
        System.assertEquals(true, dayDiff != 0 && Math.mod(dayDiff, daysInterval) == 0);
    }

    @isTest static void test_Scheduler_Execute() {
        Test.startTest();

        String CRON_EXP = '0 0 0 3 5 ? ' + (Date.Today().year() + 1);   //Cron Syntax: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year"
        String jobId = System.schedule('testLanguageReviewReminderScheduler', CRON_EXP, new SCH_CDA_LanguageReviewReminders());

        Test.stopTest();
    }
}