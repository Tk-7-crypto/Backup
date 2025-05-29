@isTest
public class TST_DAO_APTS_DocuSignEnvelope {
	/**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {

        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        insert agreement;

        Apttus_DocuApi__DocuSignEnvelope__c docuSignEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Apttus_DocuApi__Status__c = CON_CLM.DRAFT;
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Docusign_AccountId__c = '12345';
        docuSignEnvelope.Apttus_CMDSign__Agreement__c = agreement.Id;
        docuSignEnvelope.Apttus_DocuApi__DocumentName__c = '["Test Document.docx"]';
        insert docuSignEnvelope;
    }

    @isTest
    private static void testAfterUpdate(){
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement' LIMIT 1];
        Apttus_DocuApi__DocuSignEnvelope__c docusignEnv = [SELECT Id FROM Apttus_DocuApi__DocuSignEnvelope__c 
            WHERE Apttus_CMDSign__Agreement__c =: agreement.Id LIMIT 1];
        
        Test.startTest();
            docusignEnv.Apttus_DocuApi__Status__c = CON_CLM.ENVELOPE_STATUS_SENT;
        	update docusignEnv;
        Test.stopTest();

        Apttus__APTS_Agreement__c updatedAgreement = [SELECT Id,Apttus__Status__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.STATUS_OTHER_PARTY_SIGNATURE, updatedAgreement.Apttus__Status__c, 'Status not updated to other party signature');
        
    }
}