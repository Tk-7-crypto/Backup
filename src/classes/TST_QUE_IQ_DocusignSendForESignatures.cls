@isTest
public class TST_QUE_IQ_DocusignSendForESignatures { 
    
    @testSetup
    static void dataSetup() {
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;       
        
        IQ_DocuSignEnvelope__c docuApiEnvelopeSent = new IQ_DocuSignEnvelope__c(); 
        docuApiEnvelopeSent.Name = 'Docusign Sent';
        docuApiEnvelopeSent.Docusign_AccountId__c = '98765';
        docuApiEnvelopeSent.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelopeSent.Agreement__c = testAgreement.Id;    
        docuApiEnvelopeSent.Signers__c = mockResponse; 
        docuApiEnvelopeSent.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelopeSent.EnvelopeId__c = 'fa41d5fb-0289-4968-ba51-e8890196158a';
        docuApiEnvelopeSent.DocumentName__c = JSON.serialize(new List<String>{'Test Document'});
        insert docuApiEnvelopeSent;
        
    } 
    
    @isTest
    private static void testMigrateAsCombinedDocument() {
        IQ_DocuSignEnvelope__c env = [SELECT Id, Send_As_User_Email__c, Docusign_AccountId__c, Name, DocumentName__c, Agreement__c 
            FROM IQ_DocuSignEnvelope__c LIMIT 1];
        CNT_CLM_AddDocusignRecipient.envelopeDocuments envDocs = new CNT_CLM_AddDocusignRecipient.envelopeDocuments();
        envDocs.documentId = '1';
        envDocs.name = 'Test Sample';
        envDocs.order = '1';
        envDocs.uri = '/envelopes/0903a3ed-10d7-4d3b-93b0-372cdb984fbe/documents/1';

        CNT_CLM_AddDocusignRecipient.envelopeDocuments envDocsCertificate = new CNT_CLM_AddDocusignRecipient.envelopeDocuments();
        envDocsCertificate.documentId = 'certificate';
        envDocsCertificate.name = 'Test Sample';
        envDocsCertificate.order = '99';
        envDocsCertificate.uri = '/envelopes/0903a3ed-10d7-4d3b-93b0-372cdb984fbe/documents/certificate';
        
        CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper envDocWrapper = new CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper();
        envDocWrapper.envelopeId = '0903a3ed-10d7-4d3b-93b0-372cdb984fbe';
        envDocWrapper.envelopeDocuments = new List<CNT_CLM_AddDocusignRecipient.envelopeDocuments>{envDocs,envDocsCertificate};    
        String mockResponse = JSON.serialize(envDocWrapper);
        QUE_CLM_IQ_DocusignSendForESignatures docusignQueue = new QUE_CLM_IQ_DocusignSendForESignatures('https://iqvia--clm.sandbox', env, '123456789');   
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));   
            docusignQueue.migrateAsCombinedDocument();
        Test.stopTest();        
        
        ContentVersion cVersion = [SELECT Id FROM ContentVersion WHERE Description = 'Final Signed Document' LIMIT 1];
        System.assertNotEquals(null, cVersion, 'The content version should be created');
    }
}