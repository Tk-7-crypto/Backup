@isTest
public class TST_BCH_APTMS_BulkCheckESignatureStatus {

    @testSetup
    static void dataSetup() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.RDS_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Apttus__Status__c = 'Other party Signatures';
        insert testAgreement;
        
        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Status__c = CON_CLM.SENT_STATUS;
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Docusign_AccountId__c = '12345';
        docuSignEnvelope.APTS_Agreement__c = testAgreement.Id;
        docuSignEnvelope.DocumentName__c = '["Test Document.docx"]';
        docuSignEnvelope.Docusign_App_Name__c = 'CLM Test';
        insert docuSignEnvelope;
        
        testAgreement.DocuSign_Envelope_Id__c = docuSignEnvelope.Id;
        update testAgreement;
        
        DocuSign_Auth_Data__c docuSignAuthData = new DocuSign_Auth_Data__c();
        docuSignAuthData.Name = 'CLM Test';
        docuSignAuthData.Base_URL__c = 'https://demo.docusign.net';
        docuSignAuthData.Account_Id__c = docuSignEnvelope.Docusign_AccountId__c;
        docuSignAuthData.Client_Id__c = 'abc';
        docuSignAuthData.Private_Key__c = 'MIIEowIBAAKCAQEA1BfkblFldMwm7LeXhiA18/3g+LwVBvu4T7WmZ5dPRXacTqDP8ChLTL70/Mx7qSWQNzYYgkT1x1kqB4V0SbsQ7vVIUzbohmVdfnQ0IKtlXIFcXgmg4YHVfaQyQ1+NCdBY8JbnFY3EmNj78MSBCGppg9Vuj+TO2JwofAwTk9UO4HJCs866/kweMo0EXxsz2HUVAvCn4bHJjsb5dlMz6fycwC8ph70h/RTqdL4Dv4hBydzw8APfzwbZWr8CuFoHMWLbMfET5FimwYAKJo36/lLBXb1eX45cGPSe9bQ2SUoY+AHPmJfr48UZzcY9TJdBJ6Fr4l6MRCvG7mui5hSv7OUZUwIDAQABAoIBACMuX2bpO5IXNzG29nx6JVj2uPWphTdmU9ltAVBXqf+UwDLOvA9TL8JoPo0cgjq5j2WJJKGfPMG3iaA7w+FjFVj9+ORMzF9Wux55uhfdNnAUyTSUFkqx1a8EqI3CcMu68rXd4jESFhVgkNIMVncF58DFi5R02NbXeGOzQSAZjGEwZXrVVwo/raybuA6XQE+Nw5fZD/eToKcQzzYLuBe5RCe0iQ2qH0fEmJna+KSKhFegnX9mcWFT1FfdIa3du7Lis9dJr/MvhLbXKHKntzGjoJiz9UU/ALy6FQD9e7nvg3Ykt03DlkZPPSdZ0GEvLfDU3kFnFxOLzE4WdySz/b4Z6FECgYEA9BtXqBWcGCRwvPfUyIH3/QD6AtOovIr6++cCX0dHV0CcRHc48YsOiL7UaTHjG6C+RdcY622T45gkqM2Leo6Wnird7P7DOqBPLHYGa5/BsPq9cCfCxJ7EL0ps+pVoNvpzEKAeFdoa8hX8WGUI5+sN7FbMlI3qE5KHRzB3MntL+bkCgYEA3m1B1TJtAVy1GHaTGMevuG6ONbNbrbI2bMje8eV7+tlZdvf/cgga3EulfRTh9H4b1uvkyjvKGUFtE9X005kD/CyZbBAaGWTZkD3dup7P7xq3EiYUf903b8L0+83+D7sBFr/j+FPO22HP+eL5ciy1bhzVzPqxU2xnu2h9ScZ6AWsCgYBO5Z95RjLDYtPFX9y4SbmbXntv+nUpK0pfrJSJswIN42YeguI2v5kc/YCt11/uCBA3hoQZY7tO7le672RLYlawHG7KMLVs929fkW4VzvbNet1LqK482ovSNR3wB+Y9Dsmt7/KJYYsf/5cmAtHUE5bWcl+BDDVByjRLABEmkc9GkQKBgH0tefZVObmhhh2tZd11TDR8q7YXKcpYWH7ikW4Lm7myJsJoka+IVi2SuSDq5rtlWZ+cBJe4DGYoRw35xJ5tKCv8oZ+KdFXERxkBaE8F37oOC+e/3JuVUQSp8Jvh81DBCrzV46O27tzScGyOy5nxBW5h9gU1NSThBoQXKyOg+rrfAoGBANJYeXeRjpkJuKGNadgdKiNWuMI/AHtC86iSy/5PuV3U1azanKoivWBa+7eYplTCQLJuLrDaCYAJikB9SywaeI7xIiuPhZEjlLp3vSNtgC0usmEkBQeHQT3qQvbMAx8dsrH0DXaGTMb2Lmq5+kn/TB6IE+69f4cde+UVqc8OyPJS';
        insert docuSignAuthData;
    }

    @isTest
    private static void testBatchCheckESignatureStatus() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        String query = 'SELECT DocuSign_Envelope_Id__c, Id, Apttus__FF_Agreement_Number__c, Docusign_Account_Id__c'  
            + ' FROM Apttus__APTS_Agreement__c WHERE Id=\'' + agreement.Id + '\'';
        String mockResponseFirst = '{"status": "Declined","documentsUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/documents","recipientsUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/recipients",'
            + '"attachmentsUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/attachments","envelopeUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333",'
            + '"emailSubject": "Agreement is ready for signature-00071731.0","emailBlurb": "Please sign","envelopeId": "fc418f6b-b8c3-41b1-a38e-4c4f24d9f333",'
            + '"customFieldsUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/custom_fields","autoNavigation": "true","envelopeIdStamping": "true",'
            + '"notificationUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/notification","enableWetSign": "true","allowMarkup": "false","allowReassign": "true",'
            + '"createdDateTime": "2022-09-13T09:15:37.0900000Z","lastModifiedDateTime": "2022-09-13T09:15:37.0900000Z","initialSentDateTime": "2022-09-13T09:15:38.0430000Z",'
            + '"sentDateTime": "2022-09-13T09:15:38.0430000Z","statusChangedDateTime": "2022-09-13T09:15:38.0430000Z","documentsCombinedUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/documents/combined",'
            + '"certificateUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/documents/certificate","templatesUri": "/envelopes/fc418f6b-b8c3-41b1-a38e-4c4f24d9f333/templates",'
            + '"purgeState": "unpurged","is21CFRPart11": "false","signerCanSignOnMobile": "true","isSignatureProviderEnvelope": "false","allowViewHistory": "true",'
            + '"disabled":"false","Email":"achc@ahsh.com","FirstName":"sk","LastName":"k",'
            + '"access_token":"4006ffecf1e74ab4a5b283f620794efd","signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc",'
            + '"email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test",'
            + '"routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],'
            + '"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test",'
            + '"requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],'
            + '"recipientCount":"1","currentRoutingOrder":"test"}';  
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseFirst,'OK', 200));    
            Database.executeBatch(new BCH_APTMS_BulkCheckESignatureStatus(query));
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreementResult = [SELECT Id, Apttus__Status__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        System.assertEquals(CON_CLM.STATUS_OTHER_PARTY_SIGNATURE, agreementResult.Apttus__Status__c, 'The agreement status should be updated to Signature Declined');
    }
}