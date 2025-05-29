/**
 * This is test class for DAO_IQ_DocuSignEnvelopeRS class.
 */
@isTest
private class TST_DAO_IQ_DocuSignEnvelopeRS {

    @testSetup
    static void dataSetup(){
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Status_Category__c = 'In Signatures';
        insert testAgreement;

        IQVIA_Agreement_Team__c testAgreementContact = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Account');
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        docuApiEnvelope.Agreement__c = testAgreement.Id;
        insert docuApiEnvelope;
    }

    @isTest
    private static void testDocusignEnvelope() {
        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQ_DocuSignEnvelope__c docuApiEnvelope1 = [SELECT Id FROM IQ_DocuSignEnvelope__c LIMIT 1];

        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope1.Id;
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
    
    @isTest
    private static void testDocusignEnvelopeRecipientStatusUpdate() {
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQ_DocuSignEnvelope__c docuApiEnvelope1 = [SELECT Id FROM IQ_DocuSignEnvelope__c LIMIT 1];

        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope1.Id;
        docuApiDocuSignEnvelopeReciStatus.Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Status__c = 'Sent';
        insert docuApiDocuSignEnvelopeReciStatus;
        docuApiDocuSignEnvelopeReciStatus.Status__c = CON_CLM.COMPLETED_STATUS;

        Test.startTest();
            update docuApiDocuSignEnvelopeReciStatus;
        Test.stopTest();

        IQ_DocuSignEnvelopeRecipientStatus__c udpatedRecipientStatus = [Select Id,Status__c
            From IQ_DocuSignEnvelopeRecipientStatus__c][0];
        system.assertEquals(CON_CLM.COMPLETED_STATUS, udpatedRecipientStatus.Status__c, 'Recipient Status should Update');
    }
}