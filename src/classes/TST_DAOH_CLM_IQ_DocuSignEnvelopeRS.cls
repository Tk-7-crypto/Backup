/**
 * This is test class for DAOH_CLM_IQ_DocuSignEnvelopeRS class.
 */
@isTest
private class TST_DAOH_CLM_IQ_DocuSignEnvelopeRS {
    @testSetup
    static void dataSetup() {
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Status_Category__c = 'In Signatures';
        insert testAgreement;

        IQVIA_Agreement_Team__c testAgreementContact = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Account');
        IQVIA_Agreement_Team__c testAgreementContact1 = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Legal Entity 1');
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        docuApiEnvelope.Agreement__c = testAgreement.Id;
        insert docuApiEnvelope;

        docuApiDocuSignEnvelopeReciStatus.DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Status__c = CON_CLM.COMPLETED_STATUS;
        docuApiDocuSignEnvelopeReciStatus.Title__c = 'test title';
        insert docuApiDocuSignEnvelopeReciStatus;

        docuApiDocuSignEnvelopeReciStatus1.DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus1.Email__c = 'testcontactRec2@example.com';
        docuApiDocuSignEnvelopeReciStatus1.RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus1.RecipientName__c = 'Test 2';
        docuApiDocuSignEnvelopeReciStatus1.SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus1.Status__c = CON_CLM.COMPLETED_STATUS;
        docuApiDocuSignEnvelopeReciStatus1.Title__c = 'test title 2';
        insert docuApiDocuSignEnvelopeReciStatus1;
    } 

    @isTest
    private static void testUpdateSignerDetailsInAgreement(){
        List<IQ_DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = [SELECT Id, DocuSignEnvelopeId__c, Email__c, RoleName__c, RecipientName__c, 
            SignedDateTime__c, Status__c, Title__c FROM IQ_DocuSignEnvelopeRecipientStatus__c WHERE Email__c = 'testcontactRec1@example.com'];
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus2 = [SELECT Id, DocuSignEnvelopeId__c, Email__c, RoleName__c, RecipientName__c, 
            SignedDateTime__c, Status__c, Title__c FROM IQ_DocuSignEnvelopeRecipientStatus__c WHERE Email__c = 'testcontactRec2@example.com'];
        lstDocuSignEnvelopeRecipientStatus.add(docuApiDocuSignEnvelopeReciStatus1);
        lstDocuSignEnvelopeRecipientStatus.add(docuApiDocuSignEnvelopeReciStatus2);

        Test.startTest();
            DAOH_CLM_IQ_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        Test.stopTest();

        Integer expected = 2;
        Integer actual = [Select Id From IQ_DocuSignEnvelopeRecipientStatus__c].size();
        system.assertEquals(expected, actual);
    }
}