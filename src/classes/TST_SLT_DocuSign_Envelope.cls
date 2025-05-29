@isTest
public class TST_SLT_DocuSign_Envelope {

    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreementPSA.Name = 'Test PSA agreement';
        insert agreementPSA;

        dsfs__DocuSign_Envelope__c docusignEnvelope = TST_CLM_TestDataFactory.createDocuSignEnvelope(true, agreementPSA.Id);
    }

    @isTest
    private static void testSelectByIdShouldReturnList() {
        dsfs__DocuSign_Envelope__c docusignEnvelope = [SELECT Id, Name FROM dsfs__DocuSign_Envelope__c  LIMIT 1];

        Test.startTest();
            List<dsfs__DocuSign_Envelope__c> docusignEnvelopeList = new SLT_DocuSign_Envelope().selectById(new Set<Id> {docusignEnvelope.Id});
        Test.stopTest();

        System.assertNotEquals(0, docusignEnvelopeList.size(), 'Docusign Envelope list is empty when not expected.');
    }

    @isTest
    static void testSelectDocusignEnvelopeFieldsById(){
        dsfs__DocuSign_Envelope__c docusignEnvelope = [SELECT Id, Name FROM dsfs__DocuSign_Envelope__c  LIMIT 1];
        Set<String> fieldSet = new Set<String>{'ID', 'Name', 'dsfs__Source_Object__c'};

        Test.startTest();
            List<dsfs__DocuSign_Envelope__c> attachmentList = new SLT_DocuSign_Envelope().selectDocusignEnvelopeFieldsById(fieldSet, new Set<Id>{docusignEnvelope.Id});
        Test.stopTest();

        system.assertEquals(true, attachmentList.size() > 0, 'Should Return docusign envelope.');
    }
}