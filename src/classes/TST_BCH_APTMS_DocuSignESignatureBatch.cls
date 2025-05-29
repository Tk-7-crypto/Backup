@isTest
public class TST_BCH_APTMS_DocuSignESignatureBatch {

    @testSetup
    static void dataSetup() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.RDS_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Execution_Order__c = CON_CLM.LEGAL_ENTITIES_FIRST;
        insert testAgreement;
        
        CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c(Name='Test DocuSign Envelope', 
            Docusign_AccountId__c = '12345');
        docuApiEnvelope.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelope.APTS_Agreement__c = testAgreement.Id;    
        docuApiEnvelope.Signers__c = mockResponse; 
        docuApiEnvelope.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelope.EnvelopeId__c = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        docuApiEnvelope.Docusign_App_Name__c = 'CLM Test';
        insert docuApiEnvelope;
        
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
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Test Content'];
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = dvd.Id; 
        contentDocLink.ContentDocumentId = contDocs[0].Id; 
        insert contentDocLink;  
        String clearText = 'Test Text Data';
        Blob key = Blob.valueOf(CON_CLM.BLOB_VALUE);
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);       
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        DocuSign_Auth_Data__c dsAuthData = new DocuSign_Auth_Data__c();
        dsAuthData.DocusignUser_Id__c = 'abc';
        dsAuthData.User_Name__c = 'dsuser001';
        dsAuthData.Account_Id__c = agreement.Docusign_Account_Id__c;
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
    }    
    
    @isTest
    private static void testDocusignBatch() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__FF_Agreement_Number__c, Id, Docusign_Account_Id__c, Execution_Order__c FROM Apttus__APTS_Agreement__c LIMIT 1];    
        CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(docusignWrapper);
        CNT_APTMS_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_APTMS_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];   
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocusignUser_Id__c', 'Client_Id__c', 'Private_Key__c', 'Name'}, agreement.Docusign_Account_Id__c, 1);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            String batchId = Database.executeBatch(new BCH_APTMS_DocuSignESignatureBatch(CON_CLM.SENT_STATUS, 'SubjectSample', '123456789012345678901234', lstContentVersion, 
                new List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper}, agreement, reminderWrapper, 'xyz@gmail.com', null));
        Test.stopTest();
        
        System.assertNotEquals(null, batchId, 'The result should not be null');     
    }    
}