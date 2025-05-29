/**
 * @author   : Sweta Sharma
 * Purpose   : ER-3556 Test for SRV_CDA_DocusignStatus class.
 *
 */
@isTest(SeeAllData = False)
private class TST_CDA_DocusignStatusService {

    private static TST_CDA_SetupData dataSetUp = new TST_CDA_SetupData();

    /**
     * Data Set Up Method.
     */
    @testSetup
    private static void TestdataSetUp() {
        dataSetUp.setupUserRequestor();
        dataSetUp.setUpCustomSetting();
        dataSetUp.setUpContactForEmail();
    }

    /**
     * Test Method to test the create and send envelope.
     */
    @isTest
    private static void testForSendAndCreateEnvelopeForCustomer() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        test.startTest();
        //Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL1');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
        CDA_Request__c cdaRecord = new CDA_Request__c();
        cdaRecord = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordCustomer.id];
        dsfs__DocuSign_Status__c DSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecord.Name);
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.CUSTOMER_MUTUAL_CDA_TEMPLATE;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = dataSetUp.cdaRecordCustomer.id;
        insert attach;
        SRV_CDA_DocusignStatus.createAndSendEnvelope(dataSetUp.cdaRecordCustomer.id);
        test.stopTest();
        //system.assertEquals('Sent for Signature', [select id, status__c from CDA_Request__c where id =: dataSetUp.cdaRecordCustomer.id].get(0).Status__c);
    }

    /**
     * Test Method to test the create and send envelope for auditor.
     */
    @isTest
    private static void testForSendAndCreateEnvelopeforAuditor() {
        //Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL2');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity222', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForAuditor(testQiLegalEntity);   //Updated by Vikram Singh under CR-11576
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        test.startTest();
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.AUDITOR_CDA_TEMPLATE;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = dataSetUp.cdaRecordAuditor.id;
        insert attach;
        Attachment attach1 = new Attachment();
        attach1.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE;
        bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach1.body = bodyBlob;
        attach1.parentId = dataSetUp.cdaRecordAuditor.id;
        insert attach1;
        Attachment attach2 = new Attachment();
        attach2.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
        bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach2.body = bodyBlob;
        attach2.parentId = dataSetUp.cdaRecordAuditor.id;
        insert attach2;
        dataSetUp.cdaRecordAuditor.Customer_Consent_to_Disclose__c = 'Yes';
        update dataSetUp.cdaRecordAuditor;
        SRV_CDA_DocusignStatus.createAndSendEnvelope(dataSetUp.cdaRecordAuditor.id);
        CDA_Request__c cdaRecord = new CDA_Request__c();
        cdaRecord = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
        dsfs__DocuSign_Status__c DSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecord.Name);
        test.stopTest();
        //system.assertEquals('Sent for Signature', [select id, status__c from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id].get(0).Status__c);
    }

    /**
     * Test Method to test the create and send envelope for auditor with customer consert form.
     */
    @isTest
    private static void testForSendAndCreateEnvelopeforAuditorWithoutCustomerConcert() {
        //Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL3');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity3', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForAuditor(testQiLegalEntity);   //Updated by Vikram Singh under CR-11576
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        test.startTest();
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.AUDITOR_CDA_TEMPLATE;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = dataSetUp.cdaRecordAuditor.id;
        insert attach;
        Attachment attach1 = new Attachment();
        attach1.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE;
        bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach1.body = bodyBlob;
        attach1.parentId = dataSetUp.cdaRecordAuditor.id;
        insert attach1;
        dataSetUp.cdaRecordAuditor.Requestor_Carbon_Copies__c = true;
        dataSetUp.cdaRecordAuditor.Recipient_Authorized_Signer_Email_Addres__c = 'test1@gmail.com';
        update dataSetUp.cdaRecordAuditor;
        SRV_CDA_DocusignStatus.createAndSendEnvelope(dataSetUp.cdaRecordAuditor.id);
        CDA_Request__c cdaRecord = new CDA_Request__c();
        cdaRecord = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
        dsfs__DocuSign_Status__c DSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecord.Name);
        test.stopTest();
        //system.assertEquals('Sent for Signature', [select id, status__c from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id].get(0).Status__c);
    }

    /**
     * Test Method to test the void envelope.
     */
    @isTest
    private static void testForVoidEnvelope() {
        //Added by Vikram Singh under CR-11576 Start
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL4');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity4', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End
        dataSetUp.setupTestDataForAuditor(testQiLegalEntity);   //Updated by Vikram Singh under CR-11576
        CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
        cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
        try {
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
            dsfs__DocuSign_Status__c testDSStatus = new dsfs__DocuSign_Status__c();
            dsfs__DocuSign_Envelope__c testDSEnvelope = new dsfs__DocuSign_Envelope__c();
            insert testDSEnvelope;
            testDSStatus.dsfs__Envelope_Status__c = 'Sent';
            testDSStatus.dsfs__DocuSign_Envelope_ID__c = testDSEnvelope.Id;
            testDSStatus.dsfs__Subject__c = cdaRecordAuditor.Name + '- REQUEST FOR SIGNATURE';
            testDSStatus.dsfs__Sender__c = 'IQVIA';     //Modified by Vikram Singh under CR-11577
            testDSStatus.dsfs__Sender_Email__c = 'sender.mail@gmail.com';
            testDSStatus.CDA_Request__c = cdaRecordAuditor.Id;
            insert testDSStatus;
            dsfs__DocuSign_Status__c testDSStatus1 = new dsfs__DocuSign_Status__c();
            dsfs__DocuSign_Envelope__c testDSEnvelope1 = new dsfs__DocuSign_Envelope__c();
            insert testDSEnvelope1;
            testDSStatus1.dsfs__Envelope_Status__c = 'Sent';
            testDSStatus1.dsfs__DocuSign_Envelope_ID__c = testDSEnvelope1.Id;
            testDSStatus1.dsfs__Subject__c = cdaRecordAuditor.Name + '- REQUEST FOR SIGNATURE';
            testDSStatus1.dsfs__Sender__c = 'IQVIA';     //Modified by Vikram Singh under CR-11577
            testDSStatus1.dsfs__Sender_Email__c = 'sender.mail@gmail.com';
            testDSStatus1.CDA_Request__c = cdaRecordAuditor.Id;
            insert testDSStatus1;
            test.stopTest();
        } catch (Exception e) {

        }
    }

    /**
     * Test Method to test the test the flow after completion docusmnet get attached by docussign to status Record.
     */
    @isTest
    static void testForWetSignFunctionality() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        test.startTest();
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr1' Limit 1].get(0);
        System.runas(user) {
            //Added by Vikram Singh under CR-11576 Start
    		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL5');
    		insert governingLaw;
    		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity5', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
    		insert testQiLegalEntity;
    		//Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity);   //Updated by Vikram Singh under CR-11576
            CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
            Attachment attach = new Attachment();
            attach.Name = 'Unit Test Attachment_Completed' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = testDSStatus.id;
            insert attach;
        }
        test.stopTest();
        //system.assertEquals(UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE, [select id, status__c from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id].get(0).Status__c);
    }
}