/**
 * @Author  : Vikram Singh Fartyal (Created Under CR-11525 on 02nd Feb 2018)
 * @Purpose : Test class for SCH_CDA_ProcessRequests Scheduler.
 */
@isTest(seeAllData=false)
private class TST_CDA_ProcessRequests {
	@testSetup
	public static void setupData() {
		TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
		testSetup.setupUserRequestor();
		testSetup.setUpCustomSetting();
		testSetup.setUpContactForEmail();

		//Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End

		//request with apttus doc Attachment
		CDA_Request__c cdaRecordCustomer2 = testSetup.setupTestDataForCustomer(testQiLegalEntity);	//Updated by Vikram Singh under CR-11576

		Attachment testAttachment = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_PDF , cdaRecordCustomer2.Id);

		cdaRecordCustomer2.Awaiting_Requestor_Submission_Date__c = Date.today().addDays(-1);
		cdaRecordCustomer2.Status__c = UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING;
		update cdaRecordCustomer2;

		Date awaitReqSubDate = date.newinstance(cdaRecordCustomer2.Awaiting_Requestor_Submission_Date__c.year(), cdaRecordCustomer2.Awaiting_Requestor_Submission_Date__c.month(), cdaRecordCustomer2.Awaiting_Requestor_Submission_Date__c.day());
        Integer dayDiff = awaitReqSubDate.daysBetween(Date.today());
        Integer daysInterval = 1;
        System.assertEquals(0, Math.mod(dayDiff, daysInterval));
	}

	@isTest static void test_Scheduler_Execute() {
		Test.startTest();
		UTL_CDAUtility.processRequestBatchExecutionTime = 120;
        String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
        String jobId = System.schedule('testProcessRequestsScheduler', CRON_EXP, new SCH_CDA_ProcessRequests());

        Test.stopTest();
	}
}