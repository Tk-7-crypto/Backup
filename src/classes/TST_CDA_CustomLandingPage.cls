/**
 * @author   : Vikram Singh Fartyal
 * Test Class for CNT_CDA_CustomLandingPage. (created under ER-3556 on 16/06/2017)
 */

@isTest(seeAllData=false)
private class TST_CDA_CustomLandingPage {
	private static TST_CDA_SetupData testSetup = new TST_CDA_SetupData();

	@testSetup
    public static void setupData() {
		//Added by Vikram Singh under CR-11576 Start
		testSetup.setUpCustomSetting();
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End

        testSetup.setupTestDataForCustomer(testQiLegalEntity);	//Updated by Vikram Singh under CR-11576
		testSetup.setupTestDataForVendor(testQiLegalEntity);	//Updated by Vikram Singh under CR-11576
		testSetup.setupTestDataForAuditor(testQiLegalEntity);	//Updated by Vikram Singh under CR-11576
		//testSetup.setupTestDataForCEVA();
		testSetup.setRecordsPerPage();
    }

	@isTest
	public static void customLandingPageTest() {
		Test.startTest();

		PageReference pageRef = Page.VFP_CDA_CustomLandingPage;
		Test.setCurrentPage(pageRef);

        //Added by Vikram Singh under CR-11576 Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL01');
        insert governingLaw;

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity321', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End

		QI_Legal_Entity__c qiLegalEntityRecord = SRV_CDA_CDARequest.getQILegalEntity(testQiLegalEntity.Id);	//Updated by Vikram Singh under CR-11576
		CDA_Account__c cdaAccountRecord = SRV_CDA_CDARequest.getCDAAccount(testSetup.cdaAccount.Id);
		CDA_Request__c cdaRequestRecord = SRV_CDA_CDARequest.getCDARequest(testSetup.setupTestDataForCEVA(testQiLegalentity).Id);

		CNT_CDA_CustomLandingPage conObj = new CNT_CDA_CustomLandingPage();

		conObj.qiLegalEntityName = qiLegalEntityRecord.Name;
		conObj.recipientLegalEntityName = cdaAccountRecord.Name;
		conObj.cdaRequestorName = cdaRequestRecord.Owner.Name;
		conObj.idToView = cdaRequestRecord.Id;
		conObj.idToUpdate = cdaRequestRecord.Id;

		conObj.refresh();
        system.assertEquals(4, conObj.getRequestList().size());
		system.assertEquals(10, conObj.setCon.getPageSize());

		conObj.toggleSort();
        system.assertEquals('asc', conObj.sortDir);

		conObj.getRecordsPerPage();
		system.assertEquals(4, conObj.getRecordsPerPage().size());

		conObj.size = 20;
		conObj.refreshPageSize();
		system.assertEquals(20, conObj.setCon.getPageSize());

		conObj.runSearch();
		//system.assertEquals(4, conObj.noOfRecords);

		cdaRequestRecord.Status__c = UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES;
		cdaRequestRecord.RecordTypeId = TST_CDA_SetupData.getRecordType().Id; //Added by Vikram Singh under CR-11691
		update cdaRequestRecord;
		SRV_CDA_CDARequest.query = testSetup.cdaQuery;
		conObj.runSearchForCustomReport();
		system.assertEquals(1, conObj.noOfRecords);

		String newReqPage = conObj.goToNewRequest().getUrl();
		Boolean isNewReqPageRendered = newReqPage.contains(UTL_CDAUtility.PAGE_EDIT_SCREEN);
		System.assertEquals(true, isNewReqPageRendered);

		String viewReqPage = conObj.goToViewRequest().getUrl();
		Boolean isViewReqPageRendered = viewReqPage.contains(UTL_CDAUtility.PAGE_VIEW_SCREEN);
		System.assertEquals(true, isViewReqPageRendered);

		String editReqPage = conObj.goToEditRequest().getUrl();
		Boolean isEditReqPageRendered = editReqPage.contains(UTL_CDAUtility.PAGE_EDIT_SCREEN);
		System.assertEquals(true, isEditReqPageRendered);

		Test.stopTest();
	}
}