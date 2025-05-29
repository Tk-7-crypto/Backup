@isTest
private class TST_SLT_DocusignRecipient {

    @isTest
    private static void testSelectByIdShouldReturnList() {
        dsfs__DocuSign_Envelope__c envelope = new dsfs__DocuSign_Envelope__c();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id, true);
        
        TST_CLM_TestDataFactory.createClmConfigurationSetting(true);
        envelope.dsfs__Source_Object__c = agreement.Id;
        insert envelope;
        
        dsfs__DocuSign_Envelope_Recipient__c envelopeRecipient = new dsfs__DocuSign_Envelope_Recipient__c();
        envelopeRecipient.dsfs__DocuSign_EnvelopeID__c = envelope.Id;
        insert envelopeRecipient;

        Test.startTest();
            List<dsfs__DocuSign_Envelope_Recipient__c> resultList = new SLT_DocusignRecipient().selectById(
                new Set<Id>{envelopeRecipient.Id});
        Test.stopTest();

        System.assertNotEquals(0, resultList.size(), 'dsfs__DocuSign_Envelope_Recipient__c list should not be empty.');
    }
}