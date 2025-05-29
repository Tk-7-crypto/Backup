@isTest
private class TST_TGR_DocuSign_Envelope {

    /**
     * This is test class for docusign envelope trigger.
     */
    @isTest
    private static void testDocusignEnvelope() {
        dsfs__DocuSign_Envelope__c envelope = new dsfs__DocuSign_Envelope__c();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        TST_CLM_TestDataFactory.createClmConfigurationSetting(true);
        envelope.dsfs__Source_Object__c = agreement.Id;
        insert envelope;
    }
}