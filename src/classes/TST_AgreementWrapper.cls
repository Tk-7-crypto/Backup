@isTest
private class TST_AgreementWrapper {

    @isTest
    private static void testAgreementWrapper() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);
        Agreement_Extension__c agreementExtension = 
            TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id,true);
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.Name = 'Test Opp 1';
        opp.stageName = '1. Identifying Opportunity';
        insert opp;
        
        Agreement_Contacts__c agrContact = TST_CLM_TestDataFactory.createAgreementContact(agreement, true, 'Account');
        AgreementWrapper wrapper = new AgreementWrapper();
        IQVIA_Agreement__c iqAgr = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, true);

        Test.startTest();
            wrapper = new AgreementWrapper(agreement, agreementExtension, iqAgr);
            wrapper.isUpdatable = true;
            wrapper.isDeletable = false;
            wrapper.recordTypeName = 'Test';
            wrapper.showProjectManagerPrompt = true;
            wrapper.dateTrackingStarted = Date.today();
            wrapper.coNumber = 'Test';
            wrapper.action = 'Test';
            wrapper.docType = 'Test';
            AgreementWrapper.AmendAgreementWrapper amendWrapper = new AgreementWrapper.AmendAgreementWrapper();
            amendWrapper.contractId = 'Test';
            amendWrapper.action = 'Test';
            amendWrapper.agreementId = 'Test';
            amendWrapper.recordTypeDeveloperName = 'Test';
            amendWrapper.type = 'Test';
            amendWrapper.clinicalAgreement = agreement;
            amendWrapper.requestDate = Date.today();
            amendWrapper.contractRanking = 'Test';
            amendWrapper.selectedOpportunity = opp;
            amendWrapper.agreementContact = agrContact;
            AgreementWrapper.FileWrapper fileWrapper = new AgreementWrapper.FileWrapper();
            fileWrapper.title = 'Test';
            fileWrapper.id = 'Test';
            fileWrapper.conVerId = 'Test';
        Test.stopTest();

    }
}