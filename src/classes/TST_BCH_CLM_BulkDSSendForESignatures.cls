@isTest
public class TST_BCH_CLM_BulkDSSendForESignatures {
    
    @testSetup
    static void dataSetup() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.Contracts_Distribution_Email__c = 'test@gmail.com';
        clmconfiguration.RDS_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Execution_Order__c = CON_CLM.LEGAL_ENTITIES_FIRST;
        insert testAgreement;
        
        CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_APTMS_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        IQ_DocuSignEnvelope__c docuApiEnvelopeSent = new IQ_DocuSignEnvelope__c(); 
        docuApiEnvelopeSent.Name = 'Docusign Sent';
        docuApiEnvelopeSent.Docusign_AccountId__c = '98765';
        docuApiEnvelopeSent.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelopeSent.APTS_Agreement__c = testAgreement.Id;    
        docuApiEnvelopeSent.Signers__c = mockResponse; 
        docuApiEnvelopeSent.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelopeSent.EnvelopeId__c = 'fa41d5fb-0289-4968-ba51-e8890196158a';
        docuApiEnvelopeSent.Docusign_App_Name__c = 'CLM Test';
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
        //dsAuthData.Redirect_URL__c = '';
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
        
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@gmail.com', LastName ='lastname');
        contact.Account = account;
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
        insert contact;
        
        Agreement_Contacts__c agreementContact = TST_CLM_TestDataFactory.createAgreementContacts(testAgreement.Id, false);
        agreementContact.Agreement__c = testAgreement.Id;
        agreementContact.Account_Contact__c = contact.Id;
        agreementContact.Contact__c = contact.Id;
        agreementContact.Type__c = CON_CLM.CONTACT_TYPE;
        agreementContact.DocuSign_Recipient__c = true;
        insert agreementContact;
    }
    
    @isTest
    private static void testDocusignSendForESignaturesBatch() {
        String query = 'SELECT Id, DocuSign_Envelope_Id__c, Apttus__FF_Agreement_Number__c, Docusign_Account_Id__c, Execution_Order__c FROM Apttus__APTS_Agreement__c';
        EmailTemplate emailTemp = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        BCH_CLM_BulkDocusignSendForESignatures docusignBatch = new BCH_CLM_BulkDocusignSendForESignatures(query, emailTemp.DeveloperName, 'abc@gmail.com');
        CNT_APTMS_DocuSignESignature.DocuSignEnvelopeResponseWrapper derw = new CNT_APTMS_DocuSignESignature.DocuSignEnvelopeResponseWrapper();
        derw.envelopeId = '05fb40f1-e33c-4335-8dc1-ee432be8a167'; 
        derw.uri = 'sampleURI';
        derw.statusDateTime = 'today()';
        derw.status = 'sent';
        String mockResponse = JSON.serialize(derw);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            Database.executeBatch(docusignBatch, 1); 
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Status__c FROM Apttus__APTS_Agreement__c LIMIT 1]; 
        System.assertEquals(CON_CLM.STATUS_OTHER_PARTY_SIGNATURE, agreement.Apttus__Status__c, 'The agreement status should be updated to Other Party Signatures');
    } 
}