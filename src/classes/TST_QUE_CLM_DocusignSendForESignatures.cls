@isTest
public class TST_QUE_CLM_DocusignSendForESignatures {
    
    @testSetup
    static void dataSetup() {
        CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Execution_Order__c = CON_CLM.EXTERNAL_ONLY;
        insert testAgreement;       
        
        IQ_DocuSignEnvelope__c docuApiEnvelopeSent = new IQ_DocuSignEnvelope__c(); 
        docuApiEnvelopeSent.Name = 'Docusign Sent';
        docuApiEnvelopeSent.Docusign_AccountId__c = '98765';
        docuApiEnvelopeSent.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelopeSent.APTS_Agreement__c = testAgreement.Id;    
        docuApiEnvelopeSent.Signers__c = mockResponse; 
        docuApiEnvelopeSent.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelopeSent.EnvelopeId__c = 'fa41d5fb-0289-4968-ba51-e8890196158a';
        docuApiEnvelopeSent.DocumentName__c = JSON.serialize(new List<String>{'Test Document'});
        insert docuApiEnvelopeSent;
        
        Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c();
        dv.Name = 'Test ABC';
        dv.Apttus__AgreementId__c = testAgreement.Id;
        dv.Apttus__LatestVersion__c = '1.0.0';
        dv.Apttus__Title__c = 'Test';
        insert dv;
        
        Apttus__DocumentVersionDetail__c dvd = new Apttus__DocumentVersionDetail__c();
        dvd.Name = 'TestName';
        dvd.Apttus__DocumentVersionId__c = dv.Id;
        dvd.Apttus__Title__c ='TestTitle';
        dvd.Apttus__VersionMajor__c = 1;
        dvd.Apttus__VersionMinor__c = 0;
        dvd.Apttus__VersionRevision__c = 0;
        insert dvd;
    } 
    
    @isTest
    private static void testMigrateAsCombinedDocument() {
        IQ_DocuSignEnvelope__c env = [SELECT Id, Send_As_User_Email__c, Docusign_AccountId__c, Name, DocumentName__c, APTS_Agreement__c 
            FROM IQ_DocuSignEnvelope__c LIMIT 1];
        CNT_APTMS_AddDocusignRecipient.envelopeDocuments envDocs = new CNT_APTMS_AddDocusignRecipient.envelopeDocuments();
        envDocs.documentId = '1';
        envDocs.name = 'Test Sample';
        envDocs.order = '1';
        envDocs.uri = '/envelopes/0903a3ed-10d7-4d3b-93b0-372cdb984fbe/documents/1';

        CNT_APTMS_AddDocusignRecipient.envelopeDocuments envDocsCertificate = new CNT_APTMS_AddDocusignRecipient.envelopeDocuments();
        envDocsCertificate.documentId = 'certificate';
        envDocsCertificate.name = 'Test Sample';
        envDocsCertificate.order = '99';
        envDocsCertificate.uri = '/envelopes/0903a3ed-10d7-4d3b-93b0-372cdb984fbe/documents/certificate';
        
        CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper envDocWrapper = new CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper();
        envDocWrapper.envelopeId = '0903a3ed-10d7-4d3b-93b0-372cdb984fbe';
        envDocWrapper.envelopeDocuments = new List<CNT_APTMS_AddDocusignRecipient.envelopeDocuments>{envDocs,envDocsCertificate};    
        String mockResponse = JSON.serialize(envDocWrapper);
        QUE_CLM_DocusignSendForESignatures docusignQueue = new QUE_CLM_DocusignSendForESignatures('https://iqvia--clm.sandbox', env, '123456789');   
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));   
            docusignQueue.migrateAsCombinedDocument();
        Test.stopTest();        
        
        Apttus__DocumentVersion__c docVersion = [SELECT Id FROM Apttus__DocumentVersion__c WHERE Name = 'Signed Document' LIMIT 1];
        System.assertNotEquals(null, docVersion, 'The document version should be created');
    }
}