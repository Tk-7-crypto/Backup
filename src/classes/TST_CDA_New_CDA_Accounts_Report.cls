/**
 * @Author  : Babita Dadarwal
 * @Name    : TST_CDA_New_CDA_Accounts_Report
 * @Purpose : Test class for SCH_CDA_New_CDA_Account_Report Scheduler.
 */
@isTest(seeAllData = false)
private class TST_CDA_New_CDA_Accounts_Report {

    @testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();

        CDA_Request__c cdaRecordAuditor =  new CDA_Request__c();
        cdaRecordAuditor.QuintilesIMS_Business__c = UTL_CDAUtility.CDA_BUSINESS_PART_LQ;
        cdaRecordAuditor.CDA_Type__c = UTL_CDAUtility.AUDITOR;
        cdaRecordAuditor.CDA_Effective_Date__c = Date.today();
        cdaRecordAuditor.QuintilesIMS_Affiliates_Value__c = 'Yes';
        cdaRecordAuditor.Requestor_Carbon_Copies__c = false;
        cdaRecordAuditor.Date_executed_signed_contract_received__c = System.now();
        insert cdaRecordAuditor;

        CDA_Account__c testCustomerAccount  = new CDA_Account__c();
        testCustomerAccount.Name = 'Test Account';
        testCustomerAccount.Account_Source__c = 'CDA Process';
        insert testCustomerAccount;

        CDA_Account__c testRecipientAccount  = new CDA_Account__c();
        testRecipientAccount.Name = 'Test Account';
        testRecipientAccount.Account_Source__c = 'CDA Process';
        insert testRecipientAccount;

        cdaRecordAuditor.Cust_Legal_Entity_Name__c = testCustomerAccount.Id;
        cdaRecordAuditor.Recipient_Account__c = testRecipientAccount.Id;
        Update cdaRecordAuditor;
    }

    @isTest static void test_Scheduler_Execute() {
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        String jobId = System.schedule('testNewCdaAccountScheduler', CRON_EXP, new SCH_CDA_New_CDA_Account_Report());

        Test.stopTest();
    }
}