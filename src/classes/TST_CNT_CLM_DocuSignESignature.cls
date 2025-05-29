@isTest
public class TST_CNT_CLM_DocuSignESignature {

    @testSetup
    static void dataSetup() { 
        List<IQ_DocuSignEnvelope__c> lstDocEnv = new List<IQ_DocuSignEnvelope__c>();
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.IQVIA_SOW_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;
        
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(testAgreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});

        IQ_DocuSignEnvelope__c docuApiEnvelopeCreated = new IQ_DocuSignEnvelope__c(Name='Docusign Create', 
            Docusign_AccountId__c = '12345');
        docuApiEnvelopeCreated.Status__c = CON_CLM.IQ_ENVELOPE_STATUS_CREATED;
        docuApiEnvelopeCreated.Agreement__c = testAgreement.Id;    
        docuApiEnvelopeCreated.Signers__c = mockResponse; 
        docuApiEnvelopeCreated.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelopeCreated.EnvelopeId__c = '05fb40f1-e33c-4335-8dc1-ee432be8a166';
        lstDocEnv.add(docuApiEnvelopeCreated);
  
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c(Name='Test DocuSign Envelope', 
            Docusign_AccountId__c = '12345');
        docuApiEnvelope.Status__c = CON_CLM.SENT_STATUS;
        docuApiEnvelope.Agreement__c = testAgreement.Id;    
        docuApiEnvelope.Signers__c = mockResponse; 
        docuApiEnvelope.Send_As_User_Email__c = 'xyz@gmail.com';
        docuApiEnvelope.EnvelopeId__c = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        docuApiEnvelope.Docusign_App_Name__c = 'CLM Test';
        lstDocEnv.add(docuApiEnvelope);
        insert lstDocEnv;
                
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;
        
        List<ContentDocument> contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Test Content'];        
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = testAgreement.Id; 
        contentDocLink.ContentDocumentId = contDocs[0].Id; 
        insert contentDocLink;          
         
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
        
        Account account = new Account(Name = 'IMS Health Global', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@gmail.com', LastName ='lastname');
        contact.Account = account;
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact').getRecordTypeId();
        insert contact;
        
        IQVIA_Agreement_Team__c agreementTeam = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, false, 'Account');
        agreementTeam.Agreement__c = testAgreement.Id;
        agreementTeam.Contact__c = contact.Id;
        agreementTeam.Type__c = CON_CLM.CONTACT_TYPE;
        agreementTeam.DocuSign_Recipient__c = true;
        insert agreementTeam;
    }
    
    @isTest
    private static void testFetchUser() {
        
        Test.startTest();
            User u = CNT_CLM_DocuSignESignature.fetchUser();
        Test.stopTest();        
        
        System.assertNotEquals(null, u, 'The user should not be null');      
    }
    
    @isTest
    private static void testGetAllDocuments() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CLM_DocuSignESignature.AttachmentWrapper> resultDocument = CNT_CLM_DocuSignESignature.getAllDocuments(agreement.Id);
        Test.stopTest();    
        
        System.assertNotEquals(0, resultDocument.size(), 'The document should be present');    
    }
    
    @isTest
    private static void testDoHttpCallout() {
        String mockResponse = '{"type":"folder","id":"128836283233","sequence_id":"0","etag":"0","name":"Test Folder","created_at":"2020-12-29T21:17:56-08:00",'
            + '"modified_at":"2020-12-29T21:17:56-08:00","description":"","size":4263142,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,'
            + '"etag":null,"name":"All Files"},{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"},{"type":"folder","id":"104028912491","sequence_id":"1",'
            + '"etag":"1","name":"Agreements"}]},"created_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"modified_by":{"type":"user","id":"14013138185","name":"ABC"}}'; 
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));
            HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout('https://iqvia--clm', 'salesforce.com', CON_CLM.POST, '4006ffec', new fflib_StringBuilder(new List<String>{'body'}), 'Yes');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'The response should not be null');
    }
    
    @isTest
    private static void testUpdateAgreementStatus() {
        IQVIA_Agreement__c agreement = [SELECT Id, RecordTypeId FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            CNT_CLM_DocuSignESignature.updateAgreementStatus(agreement, null, CON_CLM.SENT_STATUS);
        Test.stopTest();
        
        IQVIA_Agreement__c finalAgreement = [SELECT Id, Status__c, Status_Category__c FROM IQVIA_Agreement__c WHERE Id =: agreement.Id];
        System.assertEquals(CON_CLM.SENT_FOR_SIGNATURES, finalAgreement.Status__c, 'Status should be updated');    
    }        
    
    @isTest
    private static void testGetJWTAccessToken() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        String mockBody = '[{"disabled":"false","Email":"achc@ahsh.com","FirstName":"sk","LastName":"k",'
            + '"access_token":"4006ffecf1e74ab4a5b283f620794efd"}]';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockBody, 'OK', 200));
            String response = CNT_CLM_DocuSignESignature.getJWTAccessToken(agreement.Docusign_Account_Id__c, 'xyz@gmail.com',
                false);
        Test.stopTest();    
        
        System.assertEquals('4006ffecf1e74ab4a5b283f620794efd', response, 'The response should match');
    }
    
    @isTest
    private static void testGetEmailTemplateExecutedBody() {
        EmailTemplate et = [SELECT Id, Subject, Name FROM EmailTemplate LIMIT 1];
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            CNT_CLM_DocuSignESignature.EmailDataWrapper  edw = CNT_CLM_DocuSignESignature.getEmailTemplateExecutedBody(agreement.Id, et.Name);
        Test.stopTest();
        
        System.assertNotEquals(null, edw, 'Wrapper should not be null');
    }
    
    @isTest
    private static void testCreateEmailSubject() {
        
        Test.startTest();
            String result = CNT_CLM_DocuSignESignature.createEmailSubject('Sample Subject', 'a1F050000007EJsEAM');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Email Subject should be created');
    }    
    
    @isTest
    private static void testCheckSignerStatusForReminder() {
        
        Test.startTest();
            Boolean result = CNT_CLM_DocuSignESignature.checkSignerStatusForReminder('NCOMPLETE');
        Test.stopTest();
        
        System.assertEquals(false, result, 'The result should be false');
    }    
    
    @isTest
    private static void testCreateBodyForRecallESignature() {
        
        Test.startTest();
            String body = CNT_CLM_DocuSignESignature.createBodyForRecallESignature('reason');
        Test.stopTest();
        
        System.assertNotEquals(null, body, 'The body must not be null');
    }    
    
    @isTest
    private static void testCheckSignerStatus() {
        
        Test.startTest();
            Boolean result = CNT_CLM_DocuSignESignature.checkSignerStatus(CON_CLM.IQ_ENVELOPE_STATUS_CREATED);
        Test.stopTest();
        
        System.assertEquals(false, result, 'The result should be false');
    }
    
    @isTest
    private static void testCheckHeapSize() {
        
        Test.startTest();
            Boolean result = CNT_CLM_DocuSignESignature.checkHeapSize();
        Test.stopTest();    
        
        System.assertEquals(true, result, 'The value must be true');
    }     
    
    @isTest    
    private static void testDecryptPassword() {
        String clearText = 'Test Text Data';
        Blob key = Blob.valueOf(CON_CLM.BLOB_VALUE);
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        
        Test.startTest();
            String resultText = CNT_CLM_DocuSignESignature.decryptPassword(encodedCipherText);
        Test.stopTest();    
        
        System.assertEquals('Test Text Data', resultText, 'Text data should match');
    }
    
    @isTest
    private static void testGetAccessToken() {
        CNT_CLM_DocuSignESignature.AccessTokenWrapper accWrap = new CNT_CLM_DocuSignESignature.AccessTokenWrapper();
        accWrap.accessToken = '98765';
        accWrap.scope = 'S';
        accWrap.tokenType = 't1234';
        String mockResponse = JSON.serialize(accWrap);    
        DocuSign_Auth_Data__c dsAuth = [SELECT Id, Name  FROM DocuSign_Auth_Data__c LIMIT 1]; 
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));
            String accessToken = CNT_CLM_DocuSignESignature.getAccessToken(CON_CLM.ACCESS_TOKEN_NEW, dsAuth.Name); 
        Test.stopTest();

        System.assertEquals('98765', accessToken, 'Access Token should be same ');
    }    
    
    @isTest
    private static void testSaveAccessToken() {
        CNT_CLM_DocuSignESignature.accessTokenChanged = true;
        DocuSign_Auth_Data__c dsAuthOld = [SELECT Id, Account_Id__c  FROM DocuSign_Auth_Data__c LIMIT 1]; 
        
        Test.startTest();
            CNT_CLM_DocuSignESignature.saveAccessToken('83f620794efd', dsAuthOld.Account_Id__c); 
        Test.stopTest();
        
        DocuSign_Auth_Data__c dsAuthUpdated = [SELECT Id, Access_Token__c FROM DocuSign_Auth_Data__c WHERE Id =: dsAuthOld.Id];
        System.assertEquals('83f620794efd', dsAuthUpdated.Access_Token__c, 'Access Token should be updated');       
    }     
    
    @isTest
    private static void testGetAgreementTeams() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<SObject> agrCont = CNT_CLM_DocuSignESignature.getAgreementTeams(agreement.Id);    
        Test.stopTest();
        
        System.assertNotEquals(0, agrCont.size(), 'The size of list must not be 0');
    }    
    
    @isTest
    private static void testGetEmailTemplateNames() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CLM_DocuSignESignature.EmailTemplateWrapper> emailWrapper = CNT_CLM_DocuSignESignature.getEmailTemplateNames(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, emailWrapper, 'The result should not be null');      
    }    
    
    @isTest
    private static void testGetRecords() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<SObject> sObj = CNT_CLM_DocuSignESignature.getRecords('test@gmail.com', 'IQVIA_Agreement_Team__c', 
                'Id', 'Contact__r.Email', '', 1, agreement.Id);
        Test.stopTest(); 
        
        System.assertNotEquals(0, sObj.size(), 'The list size must not be 0');
    }      
    
    @isTest
    private static void testCheckIfAccountDetailsAvailable() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        Test.startTest();
            String result = CNT_CLM_DocuSignESignature.checkIfAccountDetailsAvailable(String.valueOf(agreement.Id));
        Test.stopTest();
        
        System.assertEquals('dsuser001', result, 'null should be returned');
    }    
    
    @isTest
    private static void testDoDocuSignCallout() {
        IQVIA_Agreement__c agreement = [SELECT FF_Agreement_Number__c, Id, Docusign_Account_Id__c, RecordTypeId FROM IQVIA_Agreement__c LIMIT 1];    
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(agreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(docusignWrapper);
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_CLM_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];   
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocusignUser_Id__c', 'Client_Id__c', 'Private_Key__c'}, agreement.Docusign_Account_Id__c, 1);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper result = CNT_CLM_DocuSignESignature.doDocuSignCallout(false, 
                CON_CLM.SENT_STATUS, 'SubjectSample', '123456789012345678901234', lstContentVersion, 
                new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper}, agreement, reminderWrapper,
                'xyz@gmail.com', null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'The result should not be null');     
    }   
    
    @isTest
    private static void testGetDocusignUserMetadataList() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CLM_DocuSignESignature.DocusignUserMetadataWrapper> resultWrapper = CNT_CLM_DocuSignESignature.getDocusignUserMetadataList(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }
    
    @isTest
    private static void testSendReminderForESignature() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c, FF_Agreement_Number__c   FROM IQVIA_Agreement__c LIMIT 1];
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(agreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponseOne = '[{"disabled":"true","Email":"achc@ahsh.com","FirstName":"i","LastName":"k","PrivateMessage":"","RecipientId":"1",'
            + '"RecipientType":"Signer","SigningOrder":"1"},{"disabled":"false","Email":"asas@ahsh.com","FirstName":"N","LastName":"R_updated_new",'
            + '"PrivateMessage":"","RecipientId":"2","RecipientType":"Carbon copy","SigningOrder":"2"},{"disabled":"false","Email":"a@a.com",'
            + '"FirstName":"AB","LastName":"A","PrivateMessage":"","RecipientId":"3","RecipientType":"Signer","SigningOrder":"3"}]';
        docusignWrapper.disabled = 'false';
        CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper  dsView = new  CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper('https://iqvia--clmxaj.sandbox.my.salesforce.com');
        String mockResponseTwo = JSON.serialize(dsView);
        BoxTestMockCallout.MockResponse firstResponse = new BoxTestMockCallout.MockResponse(mockResponseOne, 'OK', 200);
        BoxTestMockCallout.MockResponse secondResponse = new BoxTestMockCallout.MockResponse(mockResponseTwo, 'OK', 201);
        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>{firstResponse, secondResponse};
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper result = CNT_CLM_DocuSignESignature.sendReminderForESignature(agreement.Id, 
                JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper}));
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'The wrapper must not be null');
    }
    
    @isTest
    private static void testPreviewEnvelopeWithRecipents() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];        
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];
        Set<Id> idSet = new Set<Id>{lstContentVersion[0].Id};
        String att = JSON.serialize(idSet);
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(agreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String signerJSON = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});       
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_CLM_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        String mockResponse = JSON.serialize(docusignWrapper);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.previewEnvelopeWithRecipents(att, 
                signerJSON, 'sampleSubject', '2345675643223', agreement.Id,  JSON.serialize(reminderWrapper), 'xyz@gmail.com');
            CNT_CLM_DocuSignESignature.ApexJobWrapper result = CNT_CLM_DocuSignESignature.getBatchCurrentStatus(resultWrapper.batchId);
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
        System.assertNotEquals(null, result, 'The result should not be null');
    }    
    
    @isTest   
    private static void testCheckIfUserExistInDocuSign() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper(agreement.Id, 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(docusignWrapper);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.checkIfUserExistInDocuSign(agreement.Id, CON_CLM.LOGGED_IN_USER);
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }     
    
    @isTest
    private static void testLoadRecipientsDataForReminder() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];  
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String mockResponse = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper parentWrapper = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper();
        CNT_CLM_DocuSignESignature.Signers sign = new CNT_CLM_DocuSignESignature.Signers();
        sign.creationReason = 'cR';
        sign.isBulkRecipient = 'No';
        sign.name = 'nm';
        sign.email = 'abc@gmail.com';
        sign.recipientId = 'aOl05000000Gma9CAC';
        sign.recipientIdGuid = 'aOl05000000Gma9CAC';
        sign.requireIdLookup = 'aOl03000000Gma9CAC';   
        sign.userId = 'aOl05000000Gma9QAC';
        sign.routingOrder = '1';
        sign.roleName = 'rName';
        sign.status = 'Completed';
        sign.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CarbonCopies cc = new CNT_CLM_DocuSignESignature.CarbonCopies();
        cc.name = 'SK';
        cc.email = 'abc@gmail.com';
        cc.recipientId = 'aOl05780000Gma9QAC';
        cc.recipientIdGuid = 'aOl05000000Gst9QAC';
        cc.requireIdLookup = 'aOl05000000Gma2QAC';
        cc.userId = 'aOl05000000Gma9QAC';
        cc.routingOrder = '1';
        cc.roleName = 'role';
        cc.status = 'Çompleted';
        cc.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CertifiedDeliveries cd = new CNT_CLM_DocuSignESignature.CertifiedDeliveries();
        cd.name = 'SK';
        cd.email = 'abc@gmail.com';
        cd.recipientId = 'aOl05780000Gma9QAC';
        cd.recipientIdGuid = 'aOl05000000Gst9QAC';
        cd.requireIdLookup = 'aOl05000000Gma2QAC';
        cd.userId = 'aOl05000000Gma9QAC';
        cd.routingOrder = '1';
        cd.roleName = 'role2';
        cd.status = 'Çompleted';
        cd.recipientTab = 'rTab';
        parentWrapper.signers = new List<CNT_CLM_DocuSignESignature.Signers>{sign};
        parentWrapper.carbonCopies = new List<CNT_CLM_DocuSignESignature.CarbonCopies>{cc};
        parentWrapper.certifiedDeliveries = new List<CNT_CLM_DocuSignESignature.CertifiedDeliveries>{cd};
        parentWrapper.recipientCount = '1';
        parentWrapper.currentRoutingOrder = '1';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(JSON.serialize(parentWrapper), 'OK', 200));    
            CNT_CLM_DocuSignESignature.DocuSignRecipientsListWrapper resultWrapper = CNT_CLM_DocuSignESignature.loadRecipientsDataForReminder(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');    
    }   
    
    @isTest
    private static void testRecallESignature() {
        IQVIA_Agreement__c agreement = [SELECT Id, Status__c, Status_Category__c FROM IQVIA_Agreement__c LIMIT 1];
        agreement.Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Status__c = CON_CLM.AUTHOR_CONTRACT;
        update agreement;
        
        String mockResponse = '[{"disabled":"false","Email":"achc@ahsh.com","FirstName":"sk","LastName":"k",'
            + '"access_token":"4006ffecf1e74ab4a5b283f620794efd"}]';     
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper result = CNT_CLM_DocuSignESignature.recallESignature(agreement.Id, 'Voided');
        Test.stopTest();
        
        IQVIA_Agreement__c agreementFinal = [SELECT Id, Status__c FROM IQVIA_Agreement__c WHERE Id=: agreement.Id];
        System.assertEquals(CON_CLM.READY_FOR_SIGNATURES, agreementFinal.Status__c, 'Agreement Status should be updated');   
    }    
    
    @isTest
    private static void testGetReminderAndExpiration() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            CNT_CLM_DocuSignESignature.ReminderAndExpWrapper resultWrapper = CNT_CLM_DocuSignESignature.getReminderAndExpiration(agreement.Docusign_Account_Id__c); 
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper must not be null');
    }    
    
    @isTest
    private static void testProcessFinalizeInDocuSign() {
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];
        Set<Id> idSet = new Set<Id>{lstContentVersion[0].Id};
        String att = JSON.serialize(idSet);
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String signerJSON = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});       
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_CLM_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeResponseWrapper derw = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeResponseWrapper();
        derw.envelopeId = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        derw.uri = 'sampleURI';
        derw.statusDateTime = 'today()';
        derw.status = CON_CLM.SENT_STATUS;
        String mockResponse = JSON.serialize(derw);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.processFinalizeInDocuSign(att, 
                signerJSON, 'sampleSubject', '2345675643223', agreement.Id,  JSON.serialize(reminderWrapper), 'xyz@gmail.com');
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }    
    
    @isTest
    private static void testLoadDataForCorrectRecipients() {
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper parentWrapper = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper();
        CNT_CLM_DocuSignESignature.Signers sign = new CNT_CLM_DocuSignESignature.Signers();
        sign.creationReason = 'cR';
        sign.isBulkRecipient = 'No';
        sign.name = 'nm';
        sign.email = 'abc@gmail.com';
        sign.recipientId = 'aOl05000000Gma9CAC';
        sign.recipientIdGuid = 'aOl05000000Gma9CAC';
        sign.requireIdLookup = 'aOl03000000Gma9CAC';   
        sign.userId = 'aOl05000000Gma9QAC';
        sign.routingOrder = '1';
        sign.roleName = 'rName';
        sign.status = 'Completed';
        sign.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CarbonCopies cc = new CNT_CLM_DocuSignESignature.CarbonCopies();
        cc.name = 'SK';
        cc.email = 'abc@gmail.com';
        cc.recipientId = 'aOl05780000Gma9QAC';
        cc.recipientIdGuid = 'aOl05000000Gst9QAC';
        cc.requireIdLookup = 'aOl05000000Gma2QAC';
        cc.userId = 'aOl05000000Gma9QAC';
        cc.routingOrder = '1';
        cc.roleName = 'role';
        cc.status = 'Çompleted';
        cc.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CertifiedDeliveries cd = new CNT_CLM_DocuSignESignature.CertifiedDeliveries();
        cd.name = 'SK';
        cd.email = 'abc@gmail.com';
        cd.recipientId = 'aOl05780000Gma9QAC';
        cd.recipientIdGuid = 'aOl05000000Gst9QAC';
        cd.requireIdLookup = 'aOl05000000Gma2QAC';
        cd.userId = 'aOl05000000Gma9QAC';
        cd.routingOrder = '1';
        cd.roleName = 'role2';
        cd.status = 'Çompleted';
        cd.recipientTab = 'rTab';
        parentWrapper.signers = new List<CNT_CLM_DocuSignESignature.Signers>{sign};
        parentWrapper.carbonCopies = new List<CNT_CLM_DocuSignESignature.CarbonCopies>{cc};
        parentWrapper.certifiedDeliveries = new List<CNT_CLM_DocuSignESignature.CertifiedDeliveries>{cd};
        parentWrapper.recipientCount = '1';
        parentWrapper.currentRoutingOrder = '1';
        String mockResponse = JSON.serialize(parentWrapper);
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200)); 
            CNT_CLM_DocuSignESignature.DocuSignRecipientsListWrapper  resultWrapper = CNT_CLM_DocuSignESignature.loadDataForCorrectRecipients(agreement.Id); 
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }  
    
    @isTest
    private static void testGetIndividualEmailTemplateBody() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CLM_DocuSignESignature.BulkEmailDataWrapper> bulkWrapper = CNT_CLM_DocuSignESignature.getIndividualEmailTemplateBody(agreement.Id,
                new List<String>{'Agreement_Review'});
        Test.stopTest();
        
        System.assertNotEquals(0, bulkWrapper.size(), 'The size of list should not be 0');
    }          
    
    @isTest
    private static void testGetUrlForFinalizeInDocuSign() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        String envelopeId = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper  dsView 
            = new  CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper('https://iqvia--clmxaj.sandbox.my.salesforce.com');
        String mockResponse = JSON.serialize(dsView);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.getUrlForFinalizeInDocuSign(envelopeId, 
                agreement.Id, 'abc@gmail.com', agreement.Docusign_Account_Id__c);
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper must not be null');
    }    
    
    @isTest
    private static void testGetDocuSignPreviewUrl() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        String envelopeId = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper  dsView = new  CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper('https://iqvia--clmxaj.sandbox.my.salesforce.com');
        String mockResponse = JSON.serialize(dsView);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));    
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.getDocuSignPreviewUrl(agreement.Id, 
                'abc@gmail.com', agreement.Docusign_Account_Id__c, '1');
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper must not be null');
    }    
    
    @isTest
    private static void testUpdateDocuSignEnvelope() {
        IQ_DocuSignEnvelope__c docEnv = [SELECT Id, EnvelopeId__c FROM IQ_DocuSignEnvelope__c WHERE Name = 'Docusign Create'];
        
        Test.startTest();
            CNT_CLM_DocuSignESignature.updateDocuSignEnvelope(docEnv.EnvelopeId__c);
        Test.stopTest();
        
        IQ_DocuSignEnvelope__c finalDoc = [SELECT Id, Status__c FROM IQ_DocuSignEnvelope__c WHERE Name = 'Docusign Create']; 
        System.assertEquals(CON_CLM.SENT_STATUS, finalDoc.Status__c, 'The status should be updated');     
    }             
    
    @isTest        
    private static void testCreateDocuSignEnvelopeRecipientStatus() {
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper parentWrapper = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper();
        CNT_CLM_DocuSignESignature.Signers sign = new CNT_CLM_DocuSignESignature.Signers();
        sign.creationReason = 'cR';
        sign.isBulkRecipient = 'No';
        sign.name = 'nm';
        sign.email = 'abc@gmail.com';
        sign.recipientId = 'aOl05000000Gma9CAC';
        sign.recipientIdGuid = 'aOl05000000Gma9CAC';
        sign.requireIdLookup = 'aOl03000000Gma9CAC';   
        sign.userId = 'aOl05000000Gma9QAC';
        sign.routingOrder = '1';
        sign.roleName = 'rName';
        sign.status = 'Completed';
        sign.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CarbonCopies cc = new CNT_CLM_DocuSignESignature.CarbonCopies();
        cc.name = 'SK';
        cc.email = 'abc@gmail.com';
        cc.recipientId = 'aOl05780000Gma9QAC';
        cc.recipientIdGuid = 'aOl05000000Gst9QAC';
        cc.requireIdLookup = 'aOl05000000Gma2QAC';
        cc.userId = 'aOl05000000Gma9QAC';
        cc.routingOrder = '1';
        cc.roleName = 'role';
        cc.status = 'Çompleted';
        cc.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CertifiedDeliveries cd = new CNT_CLM_DocuSignESignature.CertifiedDeliveries();
        cd.name = 'SK';
        cd.email = 'abc@gmail.com';
        cd.recipientId = 'aOl05780000Gma9QAC';
        cd.recipientIdGuid = 'aOl05000000Gst9QAC';
        cd.requireIdLookup = 'aOl05000000Gma2QAC';
        cd.userId = 'aOl05000000Gma9QAC';
        cd.routingOrder = '1';
        cd.roleName = 'role2';
        cd.status = 'Çompleted';
        cd.recipientTab = 'rTab';
        parentWrapper.signers = new List<CNT_CLM_DocuSignESignature.Signers>{sign};
        parentWrapper.carbonCopies = new List<CNT_CLM_DocuSignESignature.CarbonCopies>{cc};
        parentWrapper.certifiedDeliveries = new List<CNT_CLM_DocuSignESignature.CertifiedDeliveries>{cd};
        parentWrapper.recipientCount = '1';
        parentWrapper.currentRoutingOrder = '1';
        String mockResponse = JSON.serialize(parentWrapper);
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));   
            CNT_CLM_DocuSignESignature.createOrUpdateDocuSignEnvelopeRecipientStatus(agreement.Id, '05fb40f1-e33c-4335-8dc1-ee432be8a167', 
                'https://iqvia--clm', '4o4bd232', agreement.Docusign_Account_Id__c, 'abc@gmail.com', agreement.Docusign_Account_Id__c, null);
        Test.stopTest();
        
        System.assertEquals(true, !CNT_CLM_DocuSignESignature.docuSignEnvelopeRecipientStatusMap.isEmpty(), 'The map should not be empty');       
    }    

    @isTest
    private static void testProcessESignature() {
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion];
        Set<Id> idSet = new Set<Id>{lstContentVersion[0].Id};
        String att = JSON.serialize(idSet);
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String signerJSON = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});       
        CNT_CLM_DocuSignESignature.ReminderAndExpWrapper reminderWrapper = new CNT_CLM_DocuSignESignature.ReminderAndExpWrapper('2', '1', '3', '4');     
        IQVIA_Agreement__c agreement = [SELECT Id, RecordTypeId, Status__c, Status_Category__c FROM IQVIA_Agreement__c LIMIT 1];
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeResponseWrapper derw = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeResponseWrapper();
        derw.envelopeId = '05fb40f1-e33c-4335-8dc1-ee432be8a167';
        derw.uri = 'sampleURI';
        derw.statusDateTime = 'today()';
        derw.status = CON_CLM.SENT_STATUS;
        String mockResponse = JSON.serialize(derw);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 201));  
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper resultWrapper = CNT_CLM_DocuSignESignature.processESignature(att, 
                signerJSON, 'sampleSubject', '2345675643223', agreement.Id,  JSON.serialize(reminderWrapper), 'xyz@gmail.com');
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }        
    
    @isTest
    private static void testPreviewRecipents() {
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
          
        Test.startTest();
            CNT_CLM_DocuSignESignature.DocuSignRecipientsListWrapper resultWrapper = CNT_CLM_DocuSignESignature.previewRecipents(JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper})); 
        Test.stopTest();
        
        System.assertNotEquals(null, resultWrapper, 'The wrapper should not be null');
    }
    
    @isTest
    private static void testSendDocusignEnv() {
        CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper  dsView = new  CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper('https://iqvia--clmxaj.sandbox.my.salesforce.com');
        String mockResponse = JSON.serialize(dsView);
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];    
         
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponse, 'OK', 200));    
            CNT_CLM_DocuSignESignature.sendDocusignEnv(agreement.Id, 'abc@gmail.com', agreement.Docusign_Account_Id__c);
        Test.stopTest();   
         
        IQVIA_Agreement__c agreementFinal = [SELECT Id, Status_Category__c FROM IQVIA_Agreement__c LIMIT 1];    
        System.assertEquals(CON_CLM.IN_SIGNATURES, agreementFinal.Status_Category__c, 'The status category should be updated');    
    }
    
    @isTest
    private static void testCreateBodyForUpdateESignature() {
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        
        Test.startTest();
            String result = CNT_CLM_DocuSignESignature.createBodyForUpdateESignature(JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper}));
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'The result should not be null');
    }
    
    @isTest
    private static void testGetOpenDocuSignEnvelope() {
        IQVIA_Agreement__c agreement = [SELECT Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];    
         
        Test.startTest();   
            List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = CNT_CLM_DocuSignESignature.getOpenDocuSignEnvelope(agreement.Id);
        Test.stopTest();   
       
        System.assertEquals(true, docuSignEnvelopeList.size()>0, 'Docusign Envelope should return');    
    }
    
    @isTest
    private static void testUpdateCorrectESignature() {
        IQVIA_Agreement__c agreement = [SELECT FF_Agreement_Number__c, Id, Docusign_Account_Id__c FROM IQVIA_Agreement__c LIMIT 1];    
        String jsonString = '["signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test]';
        CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper docusignWrapper = new CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper('aOl05000000Gma9CAC', 
            '1', '1', 'certifieddelivery', 'Test', 'xyz@gmail.com', 'privateMessage');
        String signerJSON = JSON.serialize(new List<CNT_CLM_DocuSignESignature.DocuSignRecipientsWrapper>{docusignWrapper});
        
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper parentWrapper = new CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper();
        CNT_CLM_DocuSignESignature.Signers sign = new CNT_CLM_DocuSignESignature.Signers();
        sign.creationReason = 'cR';
        sign.isBulkRecipient = 'No';
        sign.name = 'nm';
        sign.email = 'abc@gmail.com';
        sign.recipientId = 'aOl05000000Gma9CAC';
        sign.recipientIdGuid = 'aOl05000000Gma9CAC';
        sign.requireIdLookup = 'aOl03000000Gma9CAC';   
        sign.userId = 'aOl05000000Gma9QAC';
        sign.routingOrder = '1';
        sign.roleName = 'rName';
        sign.status = 'Completed';
        sign.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CarbonCopies cc = new CNT_CLM_DocuSignESignature.CarbonCopies();
        cc.name = 'SK';
        cc.email = 'abc@gmail.com';
        cc.recipientId = 'aOl05780000Gma9QAC';
        cc.recipientIdGuid = 'aOl05000000Gst9QAC';
        cc.requireIdLookup = 'aOl05000000Gma2QAC';
        cc.userId = 'aOl05000000Gma9QAC';
        cc.routingOrder = '1';
        cc.roleName = 'role';
        cc.status = 'Çompleted';
        cc.recipientTab = 'rTab';
        
        CNT_CLM_DocuSignESignature.CertifiedDeliveries cd = new CNT_CLM_DocuSignESignature.CertifiedDeliveries();
        cd.name = 'SK';
        cd.email = 'abc@gmail.com';
        cd.recipientId = 'aOl05780000Gma9QAC';
        cd.recipientIdGuid = 'aOl05000000Gst9QAC';
        cd.requireIdLookup = 'aOl05000000Gma2QAC';
        cd.userId = 'aOl05000000Gma9QAC';
        cd.routingOrder = '1';
        cd.roleName = 'role2';
        cd.status = 'Çompleted';
        cd.recipientTab = 'rTab';
        parentWrapper.signers = new List<CNT_CLM_DocuSignESignature.Signers>{sign};
        parentWrapper.carbonCopies = new List<CNT_CLM_DocuSignESignature.CarbonCopies>{cc};
        parentWrapper.certifiedDeliveries = new List<CNT_CLM_DocuSignESignature.CertifiedDeliveries>{cd};
        parentWrapper.recipientCount = '1';
        parentWrapper.currentRoutingOrder = '1';
        String mockResponseOne = JSON.serialize(parentWrapper);
        
        CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper  dsView 
            = new  CNT_CLM_DocuSignESignature.DocuSignSenderViewResponseWrapper('https://iqvia--clmxaj.sandbox.my.salesforce.com');
        String mockResponseTwo = JSON.serialize(dsView);
        
        BoxTestMockCallout.MockResponse firstResponse = new BoxTestMockCallout.MockResponse(mockResponseOne, 'OK', 200);
        BoxTestMockCallout.MockResponse secondResponse = new BoxTestMockCallout.MockResponse(mockResponseTwo, 'OK', 200);
        List<BoxTestMockCallout.MockResponse> responses = new List<BoxTestMockCallout.MockResponse>{firstResponse, secondResponse,firstResponse};
        
        Test.startTest();  
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses)); 
            CNT_CLM_DocuSignESignature.ESignatureResponseWrapper result = CNT_CLM_DocuSignESignature.updateCorrectESignature(
                agreement.Id, signerJSON, 'xyz@gmail.com');
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'The result should not be null');     
    }
}