/**
 * @author   : Vikram Singh Fartyal
 * Test Class for CNT_CDA_CrosswalkDataUploadPage. (created under ER-3556 on 20/06/2017)
 */

@isTest(seeAllData=false)
private class TST_CDA_CrosswalkDataUploadPage {
	private static TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
	private static CDA_Language_Cross_Walk__c cwRecord = new CDA_Language_Cross_Walk__c();

	@testSetup
    public static void setupData() {
		cwRecord = testSetup.setCDAMultilingualCrossWalkData();
    }

	@isTest
	public static void crosswalkDataTest() {
		Test.startTest();

		PageReference pageRef = Page.VFP_CDA_CrosswalkDataUploadPage;
		System.assertNotEquals(null, cwRecord);
		pageRef.getParameters().put('id', cwRecord.Id);
        Test.setCurrentPage(pageRef);

		CNT_CDA_CrosswalkDataUploadPage conObj = new CNT_CDA_CrosswalkDataUploadPage();
		CNT_CDA_CrosswalkDataUploadPage.allData conObjad = new CNT_CDA_CrosswalkDataUploadPage.allData();

		conObj.getRecordId();
		conObj.getAllData();
		conObj.isSorteable = true;
		conObj.isSearchAllowed = true;
		conObjad.editorRecords = CNT_CDA_CrosswalkDataUploadPage.getCDAMultilingualCrossWalkData('english');
		System.assertEquals(1, conObjad.editorRecords.size());

		Test.stopTest();
	}

	@isTest
	public static void saveCrosswalkRecordTest() {
		Test.startTest();

		PageReference pageRef = Page.VFP_CDA_CrosswalkDataUploadPage;
		System.assertNotEquals(null, cwRecord);
		pageRef.getParameters().put('id', cwRecord.Id);
        Test.setCurrentPage(pageRef);

		CNT_CDA_CrosswalkDataUploadPage conObj = new CNT_CDA_CrosswalkDataUploadPage();
		CNT_CDA_CrosswalkDataUploadPage.allData conObjad = new CNT_CDA_CrosswalkDataUploadPage.allData();
		conObj.getRecordId();
		conObj.getAllData();
		conObj.isSorteable = true;
		conObj.isSearchAllowed = true;
		conObjad.editorRecords = CNT_CDA_CrosswalkDataUploadPage.getCDAMultilingualCrossWalkData('english');

		String actualRecord = JSON.serialize(conObjad.editorRecords[0]);
		conObjad.editorRecords[0].Japanese_Translation__c = 'Test GL JP';
		String editRecord = JSON.serialize(conObjad.editorRecords[0]);

		CNT_CDA_CrosswalkDataUploadPage.saveRecord(editRecord, actualRecord);
		System.assertNotEquals(null, CNT_CDA_CrosswalkDataUploadPage.dataObj);

		Test.stopTest();
	}

	@isTest
	public static void donotSaveCrosswalkRecordTest() {
		Test.startTest();

		PageReference pageRef = Page.VFP_CDA_CrosswalkDataUploadPage;
		System.assertNotEquals(null, cwRecord);
		pageRef.getParameters().put('id', cwRecord.Id);
		Test.setCurrentPage(pageRef);

		CNT_CDA_CrosswalkDataUploadPage.saveRecord(null, null);
		System.assertEquals(null, CNT_CDA_CrosswalkDataUploadPage.dataObj);

		Test.stopTest();
	}
}