/**
 * This is test class for DAOH_APTS_DocuApi_DocuSignEnvelopeRS class.
 */
@isTest
private class TST_DAOH_APTS_DocuApi_DocuSignEnvelopeRS {
    @testSetup
    static void dataSetup() {
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Apttus__Status_Category__c = 'In Signatures';
        insert testAgreement;

        Agreement_Contacts__c testAgreementContact = TST_CLM_TestDataFactory.createAgreementContact(testAgreement, true, 'Account');
        Agreement_Contacts__c testAgreementContact1 = TST_CLM_TestDataFactory.createAgreementContact(testAgreement, true, 'Legal Entity 1');
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuApiEnvelope.Apttus_CMDSign__Agreement__c = testAgreement.Id;
        insert docuApiEnvelope;

        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Email__c = 'testcontactRec1@example.com';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__RecipientName__c = 'Test';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Status__c = 'Completed';
        docuApiDocuSignEnvelopeReciStatus.Apttus_DocuApi__Title__c = 'test title';
        insert docuApiDocuSignEnvelopeReciStatus;

        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__DocuSignEnvelopeId__c = docuApiEnvelope.Id;
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__Email__c = 'testcontactRec2@example.com';
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__RoleName__c = 'Signer';
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__RecipientName__c = 'Test 2';
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__SignedDateTime__c = System.now();
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__Status__c = 'Completed';
        docuApiDocuSignEnvelopeReciStatus1.Apttus_DocuApi__Title__c = 'test title 2';
        insert docuApiDocuSignEnvelopeReciStatus1;
    } 

    @isTest
    private static void testUpdateSignerDetailsInAgreement(){
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> lstDocuSignEnvelopeRecipientStatus = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = [SELECT Id, Apttus_DocuApi__DocuSignEnvelopeId__c, Apttus_DocuApi__Email__c, Apttus_DocuApi__RoleName__c, Apttus_DocuApi__RecipientName__c, 
            Apttus_DocuApi__SignedDateTime__c, Apttus_DocuApi__Status__c, Apttus_DocuApi__Title__c FROM Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c WHERE Apttus_DocuApi__Email__c = 'testcontactRec1@example.com'];
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus2 = [SELECT Id, Apttus_DocuApi__DocuSignEnvelopeId__c, Apttus_DocuApi__Email__c, Apttus_DocuApi__RoleName__c, Apttus_DocuApi__RecipientName__c, 
            Apttus_DocuApi__SignedDateTime__c, Apttus_DocuApi__Status__c, Apttus_DocuApi__Title__c FROM Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c WHERE Apttus_DocuApi__Email__c = 'testcontactRec2@example.com'];
        lstDocuSignEnvelopeRecipientStatus.add(docuApiDocuSignEnvelopeReciStatus1);
        lstDocuSignEnvelopeRecipientStatus.add(docuApiDocuSignEnvelopeReciStatus2);

        Test.startTest();
            DAOH_APTS_DocuApi_DocuSignEnvelopeRS.updateSignerDetailsInAgreement(lstDocuSignEnvelopeRecipientStatus);
        Test.stopTest();

        Integer expected = 2;
        Integer actual = [Select Id From Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c].size();
        system.assertEquals(expected, actual);
    }
}