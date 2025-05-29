/**
 * This is test class for Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c trigger.
 */
@isTest
private class TST_TGR_APTS_DocuSignEnvRecipientStatus {

    @isTest
    private static void testDocusignEnvelopeRecipientStatus() {
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Apttus__Status_Category__c = 'In Signatures';
        insert testAgreement;

        Agreement_Contacts__c testAgreementContact = TST_CLM_TestDataFactory.createAgreementContact(testAgreement, true, 'Account');
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuApiEnvelope.Apttus_CMDSign__Agreement__c = testAgreement.Id;
        insert docuApiEnvelope;

        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Status__c = 'Completed';

        lstDocuApiDocuSignEnvelopeReciStatus.add(docuApiDocuSignEnvelopeReciStatus);

        Test.startTest();
            insert lstDocuApiDocuSignEnvelopeReciStatus;
        Test.stopTest();

        Integer expected = 1;
        Integer actual = [Select Id From Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c].size();
        system.assertEquals(expected, actual);
    }
}