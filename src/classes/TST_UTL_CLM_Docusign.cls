@isTest
public class TST_UTL_CLM_Docusign {
    @testSetup
    static void dataSetUp() {        
        IQVIA_Agreement__c testIQVIAAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testIQVIAAgreement.Name = 'Test IQVIA';
        testIQVIAAgreement.Status_Category__c = 'In Signatures';
        insert testIQVIAAgreement;
        
        IQ_DocuSignEnvelope__c docuApiEnvelopeIQ = new IQ_DocuSignEnvelope__c();
        docuApiEnvelopeIQ.Agreement__c = testIQVIAAgreement.Id;
        docuApiEnvelopeIQ.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelopeIQ.Docusign_AccountId__c = '12345';
        docuApiEnvelopeIQ.Send_As_User_Email__c = 'test';
        docuApiEnvelopeIQ.Docusign_App_Name__c = 'CLM Test';
        insert docuApiEnvelopeIQ;
        
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatusIQ = new IQ_DocuSignEnvelopeRecipientStatus__c();
        docuApiDocuSignEnvelopeReciStatusIQ.RoutingOrder__c = '1';
        docuApiDocuSignEnvelopeReciStatusIQ.Status__c = CON_CLM.SENT_STATUS;
        docuApiDocuSignEnvelopeReciStatusIQ.RecipientName__c = 'abc';
        docuApiDocuSignEnvelopeReciStatusIQ.Email__c = 'abc2@gmail.com';
        docuApiDocuSignEnvelopeReciStatusIQ.EnvelopeParentId__c = testIQVIAAgreement.Id;
        docuApiDocuSignEnvelopeReciStatusIQ.DocuSignEnvelopeId__c = docuApiEnvelopeIQ.Id;
        insert docuApiDocuSignEnvelopeReciStatusIQ;
        
        String clearText = 'Test Text Data';
        Blob key = Blob.valueOf(CON_CLM.BLOB_VALUE);
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        DocuSign_Auth_Data__c dsAuthData = new DocuSign_Auth_Data__c();
        dsAuthData.DocusignUser_Id__c = 'abc';
        dsAuthData.User_Name__c = 'dsuser001';
        dsAuthData.Account_Id__c = testIQVIAAgreement.Docusign_Account_Id__c;
        dsAuthData.Base_URL__c = 'https://demo.docusign.net';
        dsAuthData.Client_Id__c = 'c123';
        dsAuthData.Private_Key__c = 'pkey123';
        dsAuthData.Access_Token__c = '83f620794efd';
        dsAuthData.DocuSign_Pwd__c = encodedCipherText;
        dsAuthData.Reminder_Delay__c = 1.0;
        dsAuthData.Reminder_Frequency__c = 1.0;    
        dsAuthData.Expire_After__c = 2.0;
        dsAuthData.Expire_Warn__c = 2.0;
        dsAuthData.Name = 'CLM Test';
        insert dsAuthData;
        
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Certificate Test';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
    }
    
    @isTest
    private static void testPopulateIQVIADocuSignEnvelopeRecipientStatusMap() {
        Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> docuSignEnvelopeRecipientStatusMap = new Map<String, IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQVIA_Agreement__c testAgreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, Name, Docusign_AccountId__c, Send_As_User_Email__c, Docusign_App_Name__c
            FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
    
        Test.startTest();
            HTTPResponse response = new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test"}',
                'OK', 200).respond(null);
        	UTL_CLM_Docusign.populateIQVIADocuSignEnvelopeRecipientStatusMap(docuSignEnvelopeRecipientStatusMap, testAgreement.Id,
                docuApiEnvelope.Id, response);
        Test.stopTest();
        
        Assert.areEqual(true, !docuSignEnvelopeRecipientStatusMap.isEmpty(), 'Docusign Envelope Recipient Status Map must be populated.');
    }
    
    @isTest
    private static void testRecallSentEsignature() {
        IQVIA_Agreement__c testAgreement = [SELECT Id, Name, DocuSign_Envelope_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, EnvelopeId__c, Status__c, RecallReason__c, StatusChangeDateTime__c,
            Signers__c FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
        testAgreement.DocuSign_Envelope_Id__c = docuApiEnvelope.Id;
        AgreementWrapper agreementWrapper = new AgreementWrapper();
        agreementWrapper.iqviaAgreement = testAgreement;
    
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout('{"status":"Sent","access_token":"4006ffecf1e74ab4a5b283f620794efd"}',
                'OK', 200));
        	UTL_CLM_Docusign.recallEsignature(agreementWrapper);
        Test.stopTest();
        
        IQ_DocuSignEnvelope__c updatedEnvelope = [SELECT Id, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Docusign_App_Name__c = 'CLM Test'];
        Assert.areEqual(CON_CLM.IQ_VOIDED_STATUS, updatedEnvelope.Status__c, 'Docusign Envelope should be voided.');
    }
    
    @isTest
    private static void testRecallErrorResponse() {
        IQVIA_Agreement__c testAgreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, EnvelopeId__c, Status__c, RecallReason__c, StatusChangeDateTime__c,
            Signers__c FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
        DocuSign_Auth_Data__c dsAuth = [SELECT Id, User_Name__c, Name, Base_URL__c, Account_Id__c  FROM DocuSign_Auth_Data__c LIMIT 1];
        String mockResponse = '{"errorCode":"ERROR","message":"Error Response"}';
    
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 400));
        	UTL_CLM_Docusign.recallEsignature(testAgreement, docuApiEnvelope, dsAuth);
        Test.stopTest();
        
        Log_History__c logHistory = [Select Id, Log_Module__c from Log_History__c where Record_Id__c =: testAgreement.Id];
        Assert.areEqual('CLM', logHistory.Log_Module__c, 'Log History should be created');
    }
    
    @isTest
    private static void testRecallEsignature() {
        IQVIA_Agreement__c testAgreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, EnvelopeId__c, Status__c, RecallReason__c, StatusChangeDateTime__c,
            Signers__c FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
        DocuSign_Auth_Data__c dsAuth = [SELECT Id, User_Name__c, Name, Base_URL__c, Account_Id__c  FROM DocuSign_Auth_Data__c LIMIT 1];
        String mockResponse = '{"disabled":"false","Email":"achc@ahsh.com","FirstName":"sk","LastName":"k",'
            + '"access_token":"4006ffecf1e74ab4a5b283f620794efd"}';
    
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));
        	UTL_CLM_Docusign.recallEsignature(testAgreement, docuApiEnvelope, dsAuth);
        Test.stopTest();
        
        IQ_DocuSignEnvelope__c updatedEnvelope = [SELECT Id, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Docusign_App_Name__c = 'CLM Test'];
        Assert.areEqual(CON_CLM.IQ_VOIDED_STATUS, updatedEnvelope.Status__c, 'Docusign Envelope should be voided.');
    }
    
    @isTest
    private static void testUpdateEnvelope() {
        CNT_CLM_AddDocusignRecipient.EnvelopeWrapper EnvelopeWrapperObj = new CNT_CLM_AddDocusignRecipient.EnvelopeWrapper();
        EnvelopeWrapperObj.status = CON_CLM.COMPLETED_STATUS;
        IQ_DocuSignEnvelope__c docuSignEnvelope = [SELECT Id, Docusign_Envelope_Info__c, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Docusign_App_Name__c = 'CLM Test'];
    
        Test.startTest();
        	UTL_CLM_Docusign.updateEnvelope(docuSignEnvelope, EnvelopeWrapperObj);
        Test.stopTest();
        
        IQ_DocuSignEnvelope__c updatedEnvelope = [SELECT Id, Docusign_Envelope_Info__c, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Docusign_App_Name__c = 'CLM Test'];
        Assert.areEqual(CON_CLM.COMPLETED_STATUS, updatedEnvelope.Status__c, 'Docusign Envelope Status should updated.');
    }
    
    @isTest
    private static void testUpdateDocusignDocuments() {
        ContentDocument conDoc = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();
            UTL_CLM_Docusign.updateDocusignDocuments(new Set<Id>{conDoc.Id});
        Test.stopTest();
        
        ContentDocument finalConDoc = [SELECT Title, Description FROM ContentDocument LIMIT 1];
        Assert.areEqual(CON_CLM.CERT_OF_COMPLETION, finalConDoc.Title, 'Title must be set correctly.');
        Assert.areEqual(CON_CLM.CERT_OF_COMPLETION, finalConDoc.Description, 'Description must be set correctly.');
    }
}