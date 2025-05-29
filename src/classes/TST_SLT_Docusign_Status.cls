@isTest
private class TST_SLT_Docusign_Status {

    @isTest
    private static void testSelectByIdShouldReturnList() {
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        insert status;

        Test.startTest();
            List<dsfs__DocuSign_Status__c> statusList = new SLT_Docusign_Status().selectById(new Set<Id> {status.Id});
        Test.stopTest();

        System.assertNotEquals(0, statusList.size(), 'Docusign status list is empty when not expected');
    }

    @isTest
    private static void testGetDocuSignStatusShouldReturnList() {
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        insert status;

        Test.startTest();
            List<dsfs__DocuSign_Status__c> statusList = new SLT_Docusign_Status().getDocuSignStatus(new Set<String> {'Id'}, '');
        Test.stopTest();

        System.assertNotEquals(0, statusList.size(), 'Docusign status list is empty when not expected.');
    }

    @isTest
    private static void testGetDocuSignStatusShouldReturnListWithAgreementId() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id, true);
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Agreement__c = agreement.Id;
        insert status;

        Test.startTest();
            List<dsfs__DocuSign_Status__c> statusList = new SLT_Docusign_Status().getDocuSignStatus(new Set<String> {'Id'}, '', 
                new Set<Id>{agreement.Id});
        Test.stopTest();

        System.assertNotEquals(0, statusList.size(), 'Docusign status list is empty when not expected.');
    }

    @isTest
    private static void testGetDocusignStatusByAGRIdWithDocusignRecipientStatusFromLastEnvelopeShouldReturnMap() {
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        TST_CLM_TestDataFactory.createAgreementExtension(agreement.Id, true);
        status.Agreement__c = agreement.Id;
        insert status;

        Test.startTest();
            Map<Id, dsfs__DocuSign_Status__c> statusMap = new SLT_Docusign_Status()
                .getDocusignStatusByAGRIdWithDocusignRecipientStatusFromLastEnvelope(
                new Set<Id> {agreement.Id}, new Set<String> {'Id', 'Agreement__c'}, '');
        Test.stopTest();

        System.assertNotEquals(0, statusMap.size(), 'Docusign status map is empty when not expected.');
    }
}