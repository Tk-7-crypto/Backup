/**
 * This is test class for IQ_DocuSignEnvelopeRecipientStatus__c trigger.
 */
@isTest
private class TST_TGR_IQ_DocuSignEnvRecipientStatus {

    @isTest
    private static void testDocusignEnvelopeRecipientStatus() {
        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Status_Category__c = 'In Signatures';
        insert testAgreement;

        IQVIA_Agreement_Team__c testAgreementContact = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Account');
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        docuApiEnvelope.Agreement__c = testAgreement.Id;
        insert docuApiEnvelope;

        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Status__c = CON_CLM.COMPLETED_STATUS;

        lstDocuApiDocuSignEnvelopeReciStatus.add(docuApiDocuSignEnvelopeReciStatus);

        Test.startTest();
            insert lstDocuApiDocuSignEnvelopeReciStatus;
        Test.stopTest();

        Integer expected = 1;
        Integer actual = [Select Id From IQ_DocuSignEnvelopeRecipientStatus__c].size();
        system.assertEquals(expected, actual);
    }
}