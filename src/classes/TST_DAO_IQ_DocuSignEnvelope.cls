@isTest
public class TST_DAO_IQ_DocuSignEnvelope {
	/**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {

        IQVIA_Agreement__c agreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        insert agreement;

        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Status__c = CON_CLM.DRAFT;
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Docusign_AccountId__c = '12345';
        docuSignEnvelope.Agreement__c = agreement.Id;
        docuSignEnvelope.DocumentName__c = '["Test Document.docx"]';
        insert docuSignEnvelope;
    }

    @isTest
    private static void testAfterUpdate(){
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test Agreement' LIMIT 1];
        IQ_DocuSignEnvelope__c docusignEnv = [SELECT Id FROM IQ_DocuSignEnvelope__c 
            WHERE Agreement__c =: agreement.Id LIMIT 1];
        
        Test.startTest();
            docusignEnv.Status__c = CON_CLM.ENVELOPE_STATUS_SENT;
        	update docusignEnv;
        Test.stopTest();

        IQVIA_Agreement__c updatedAgreement = [SELECT Id,Status__c FROM IQVIA_Agreement__c 
            WHERE Name = 'Test Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.SENT_FOR_SIGNATURES, updatedAgreement.Status__c, 'Status not updated to other party signature');
        
    }
}