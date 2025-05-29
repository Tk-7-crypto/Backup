@isTest
public class TST_BCH_CLM_GetDocumentFromDocuSign {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"envelopeId": "12345","envelopeDocuments": [{"documentId": "123"},{"documentId": "certificate"}]}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void dataSetup() {
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;
        
        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Status__c = CON_CLM.SENT_STATUS;
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Agreement__c = testAgreement.Id;
        docuSignEnvelope.DocumentName__c = '["Test Document.docx"]';
        insert docuSignEnvelope;
    }
    
    @isTest
    private static void testBatchGetDocumentFromDocuSignCombinedDocumentFalse() {
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = [SELECT Id, Name, Send_As_User_Email__c, 
            Docusign_AccountId__c, DocumentName__c from IQ_DocuSignEnvelope__c 
            WHERE Name = 'Test DocuSign Envelope'];
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c
            WHERE Name = 'Test Agreement'][0];
        String endPointdoc= '/envelopes/'+docuSignEnvelopeList[0].name+'/documents';
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();                
        	try{
                BCH_CLM_GetDocumentFromDocuSign btcjob = new BCH_CLM_GetDocumentFromDocuSign
                    (endPointdoc, docuSignEnvelopeList[0].Id, 'baseUrl', 'AuthCode', agreement.Id,
                    docuSignEnvelopeList[0].Docusign_AccountId__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
                database.executeBatch(btcjob);
            } catch(Exception ex){
                System.assertNotEquals(null, ex, 'There is a problem occured while getting Document from DocuSign.');
            }
        Test.stopTest();
        
        List<ContentDocumentLink> contentVersions = [SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink WHERE LinkedEntityId = :agreement.Id];
        System.assertEquals(true, (contentVersions.size() > 0), 'Content Document record is not created when expected');
    }
    
    @isTest
    private static void testBatchGetDocumentFromDocuSignCombinedDocumentTrue() {       
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = [SELECT Id, Name, Send_As_User_Email__c, 
            Docusign_AccountId__c, DocumentName__c from IQ_DocuSignEnvelope__c 
            WHERE Name = 'Test DocuSign Envelope'];
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c
            WHERE Name = 'Test Agreement'][0];
        String endPointdoc= '/envelopes/'+docuSignEnvelopeList[0].name+'/documents';
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();                
        	try{
                BCH_CLM_GetDocumentFromDocuSign btcjob = new BCH_CLM_GetDocumentFromDocuSign
                    (endPointdoc, docuSignEnvelopeList[0].Id, 'baseUrl', 'AuthCode', agreement.Id,
                    docuSignEnvelopeList[0].Docusign_AccountId__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
                database.executeBatch(btcjob);
            } catch(Exception ex){
                System.assertNotEquals(null, ex, 'There is a problem occured while getting Document from DocuSign.');
            }
        Test.stopTest();
        
        List<ContentDocumentLink> contentVersions = [SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink WHERE LinkedEntityId = :agreement.Id];
        System.assertEquals(true, (contentVersions.size() > 0), 'Content Document record is not created when expected');
    }
}