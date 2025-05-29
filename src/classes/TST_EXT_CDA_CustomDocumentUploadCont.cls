/**
 * @author   : Sweta Sharma
 * Purpose   : ER-3556 Test for EXT_CDA_CustomDocumentUploadCont page.
 *
 */
@isTest(SeeAllData = False)
private class TST_EXT_CDA_CustomDocumentUploadCont {
    private static TST_CDA_SetupData dataSetUp = new TST_CDA_SetupData();

    /**
    * Data Set Up Method.
    */
    private static void TestdataSetUp() {
        dataSetUp.setupUserRequestor();
        dataSetUp.setUpCustomSetting();
        //Added by Vikram Singh under CR-11576 Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;
        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
        insert testQiLegalEntity;
        //Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
    }

    /**
    * Test Method to test the insert of Attachment of External Document.
    */
    @isTest
    private static void testForExternalDocument() {
        TestdataSetUp();
        PageReference currPageTest = Page.VFP_CDA_CustomDocumentUploadPage;
        Test.setCurrentPage(currPageTest);
        ApexPages.currentPage().getParameters().put('attachmentType', 'External Document');
        ApexPages.StandardController cntTest = new ApexPages.Standardcontroller(dataSetUp.cdaRecordCustomer);
        EXT_CDA_CustomDocumentUploadCont testCnt = new EXT_CDA_CustomDocumentUploadCont(cntTest);
        test.startTest();
        testCnt.FileName = 'test.doc';
        testCnt.contentType = 'application/pdf';
        testCnt.filebody = Blob.valueof('test Body');
        testCnt.doSave();
        testCnt.doCancel();
        List < Attachment > attList = new List < Attachment > ([Select id from Attachment where ParentId =: dataSetUp.cdaRecordCustomer.id]);
        System.assertEquals(true, attList.size() > 0);
        test.stopTest();
    }

    /**
    * Test Method to test the insert of Attachment of External Document with PDF extension.
    */
    @isTest
    private static void testForExternalDocumentforPDFVersion() {
        TestdataSetUp();
        PageReference currPageTest = Page.VFP_CDA_CustomDocumentUploadPage;
        Test.setCurrentPage(currPageTest);
        ApexPages.currentPage().getParameters().put('attachmentType', 'External Document');
        ApexPages.StandardController cntTest = new ApexPages.Standardcontroller(dataSetUp.cdaRecordCustomer);
        EXT_CDA_CustomDocumentUploadCont testCnt = new EXT_CDA_CustomDocumentUploadCont(cntTest);
        test.startTest();
        testCnt.FileName = 'test.pdf';
        testCnt.contentType = 'application/pdf';
        testCnt.filebody = Blob.valueof('test Body');
        testCnt.doSave();
        testCnt.doCancel();
        List < Attachment > attList = new List < Attachment > ([Select id from Attachment where ParentId =: dataSetUp.cdaRecordCustomer.id]);
        System.assertEquals(false, attList.size() > 0);
        test.stopTest();
    }

    /**
    * Test Method to test the insert of Attachment with null Agreement Type.
    */
    @isTest
    private static void testForEmptyAttachmentType() {
        TestdataSetUp();
        PageReference currPageTest = Page.VFP_CDA_CustomDocumentUploadPage;
        Test.setCurrentPage(currPageTest);
        ApexPages.StandardController cntTest = new ApexPages.Standardcontroller(dataSetUp.cdaRecordCustomer);
        EXT_CDA_CustomDocumentUploadCont testCnt = new EXT_CDA_CustomDocumentUploadCont(cntTest);
        test.startTest();
        testCnt.FileName = 'test';
        testCnt.contentType = 'application/pdf';
        testCnt.filebody = Blob.valueof('test Body');
        testCnt.doSave();
        testCnt.doCancel();
        List < Attachment > attList = new List < Attachment > ([Select id from Attachment where ParentId =: dataSetUp.cdaRecordCustomer.id]);
        System.assertEquals(true, attList.size() > 0);
        test.stopTest();
    }

    /**
    * Test Method to test the Exception in code.
    */
    @isTest
    private static void testForExternalDocumentforException() {
        TestdataSetUp();
        PageReference currPageTest = Page.VFP_CDA_CustomDocumentUploadPage;
        Test.setCurrentPage(currPageTest);
        ApexPages.currentPage().getParameters().put('attachmentType', 'External Document');
        ApexPages.StandardController cntTest = new ApexPages.Standardcontroller(dataSetUp.cdaRecordCustomer);
        EXT_CDA_CustomDocumentUploadCont testCnt = new EXT_CDA_CustomDocumentUploadCont(cntTest);
        System.runAs(dataSetUp.user)
        {
        test.startTest();
        testCnt.FileName = 'test.doc';
        testCnt.contentType = 'application/pdf';
        testCnt.filebody = Blob.valueof('test Body');
        testCnt.doSave();
        testCnt.doCancel();
        List < Attachment > attList = new List < Attachment > ([Select id from Attachment where ParentId =: dataSetUp.cdaRecordCustomer.id]);
        System.assertEquals(false, attList.size() > 0);
        test.stopTest();
        }
    }
}