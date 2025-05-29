@isTest
public class TST_BCH_CLM_DocuSignESignatureBatch {
    
    @testSetup
    static void dataSetup() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.IQVIA_SOW_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;
        
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(testAgreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c(Name='Test DocuSign Envelope', 
            Docusign_AccountId__c = '12345');
        docuApiEnvelope.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelope.Agreement__c = testAgreement.Id;    
        docuApiEnvelope.Signers__c = mockResponse; 
        docuApiEnvelope.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelope.EnvelopeId__c = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        docuApiEnvelope.Docusign_App_Name__c = 'CLM Test';
        insert docuApiEnvelope;
                
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
         
        String clearText = 'Test Text Data';
        Blob key = Blob.valueOf(CON_CLM.BLOB_VALUE);
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);       
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
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
        IQVIA_Agreement__c agreement = [SELECT FF_Agreement_Number__c, Id, Docusign_Account_Id__c, RecordTypeId FROM IQVIA_Agreement__c LIMIT 1];    
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(agreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(docusignWrapper);
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_CLM_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];   
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocusignUser_Id__c', 'Client_Id__c', 'Private_Key__c', 'Name'}, agreement.Docusign_Account_Id__c, 1);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            String batchId = Database.executeBatch(new BCH_CLM_DocuSignESignatureBatch(CON_CLM.SENT_STATUS, 'SubjectSample', '123456789012345678901234', lstContentVersion, 
                new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper}, agreement, reminderWrapper, 'xyz@gmail.com', null));
        Test.stopTest();
        
        System.assertNotEquals(null, batchId, 'The result should not be null');     
    }
}