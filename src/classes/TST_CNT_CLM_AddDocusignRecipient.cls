/*
Description : This class is used for test coverage of CNT_CLM_AddDocusignRecipient
*/
@isTest
public class TST_CNT_CLM_AddDocusignRecipient {

    @testSetup
    static void dataSetup(){ 
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.IQVIA_SOW_Account_Id__c = 'CLM Test';
        insert clmConfiguration;

        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDocuApiDocuSignEnvelopeReciStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        IQVIA_Agreement__c testAgreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        testAgreement.Name = 'Test SOW Agreement';
        testAgreement.Status_Category__c = 'In Signatures';
        insert testAgreement;

        IQVIA_Agreement_Team__c testAgreementContact = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Account');
        IQVIA_Agreement_Team__c testAgreementContact1 = TST_CLM_TestDataFactory.createIQAgreementContact(testAgreement, true, 'Legal Entity 1');
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQ_DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = new IQ_DocuSignEnvelopeRecipientStatus__c();
        IQ_DocuSignEnvelope__c docuApiEnvelope = new IQ_DocuSignEnvelope__c();
        docuApiEnvelope.Agreement__c = testAgreement.Id;
        docuApiEnvelope.Status__c = 'Draft';
        docuApiEnvelope.Docusign_AccountId__c = '12345';
        docuApiEnvelope.Send_As_User_Email__c = 'test';
        docuApiEnvelope.Docusign_App_Name__c = 'CLM Test';
        insert docuApiEnvelope;
        
        DocuSign_Auth_Data__c testdata = new DocuSign_Auth_Data__c();
        testdata.Name='CLM Test';
        testdata.Account_Id__c='12345';
        testdata.Base_URL__c='https://demo.docusign.net';
        testdata.Client_Id__c = '12345';
        testdata.Private_Key__c = 'MIIEpAIBAAKCAQEAhXR4OA1AS2IbdEjlyPB6xx0c5t7USYpMAugQOFnRPPySB5zY6lHx/cnNZg9LEAB10p5N1yZBpI+jAC30oFJGbuLu3dKYmYFZP7dYRnNWpuWpiaTkD86A2opyq8bCmKmF/oXoxLxlDTWKUPYA1EmcU/6dVb3+CP1nLqevDkaG1YaeEqX+QEeJ6JfUMsOGw7Ilkg1iMLB+saBVICGtF6DJklsL8Sqvz/B7tEWY7B/iCjNwninjYLeQYSn2GFe5E6yjkeouOyYHdU/DZseKAmZ2V+UexAObqNj7uZ6vJ/rc9XcVB4qYjwiD2pClS4+6gvDmaFaWvnxu+8yQKTEwqbr+lwIDAQABAoIBAAFVRAC6wt7d5jop6/bTqddyVO3u4XT64r59i6fuuuQekFMmJHDWwyPX6yJBWmyGbKbfJ8zl4SVEmS66D+7+5a8STauGkxTwUZ360V6P7fPe+rTrWRi1UwEuIiT11hg2uLhJEyWpFqx2ms6Y8MR3PKDh4G6aU+NcrBGK4WazUYHoXOQNaMojlrtd+RqlzThzjJnmUmtA7W/gHbzviKEOE3fQunqAVVZ3Qre4ySqeyI3RdM/3kdNYeMblp08CAmoIspQ6rT161sV6RMxypKd/+HJtxsOzkZ2GQvjvHXwbClKGxwKofF6mpX/iv4Wxw9xLEF3RmjansZgM+jntesvC/OUCgYEA669C9w6ih6t0BKRgDFKoMMHJZm8lyvGSodrLdwXNq3ak+yiiL1SScrsmr8J2PPA6R+dRLWYfWjVvHCFP94s/DSnTyTmHEN0xVuxERdsTesXP92JgahL0B8v5ubaMJu2mfuXsuNt+hkMHRkOArlh5Hw/C2Ln2kHGQwAm9I5NlZjMCgYEAkPVbC53DK5iQ7QFsRc1HG4w5d81ONb2aRHFkPGAmiuQwS1n3e/ObBf3Bk51gyPuUMDrmpXngtDmVZcJWVQ38HCzh8xfEr3dk9OY2+JGO1aZiyTrnln8fKkOV/acUqEokntfuwUkN98wewvCmnWtUExarP6mq1pFFycqZHRwd+g0CgYEAxx1irecnWQd5FRLqMn8CqW6PAIOWokZFY4i9rOiyQdISwD4sB2Cj+Voz7PmVexZZprW+12QXyNar8FAUh0aVFkHoM3Dus0isjos9gub7JhZJBO+QFQ2+LXgems+myJyutTb7L5IA6t1mH+6XoLQOYDeongE+VfocGKIhsRSt7hECgYAktBtTe6S5Wy4G9L9HhUyl6wF6Fh/hd5qiDdwFdYsMy+52hdcmKW5tO+1RxR2GhjzlYWSZLZz5xULQuz5E1v+o2qxzcuc4TpDfeZMdqS1zZ2fH8ARHlPR9LRPDYBTY770KAz7O7gJ9Zc+8KFbnsQ9erfS6b+lz3uC+0W+ncUEd2QKBgQCBsWyVUY4YqA6QTt/b1Bj6il3kV/DlMXwqW6gOHhmtIycqtDUVl7Ttilcbf7ScDUIxW4bJAUWhtvRI13eHADjC1aZE4kj79c2PNBChYj8vLR6DK+GVruxhzIKjRV5i+3RzXDeoMqW98BofpadZzlKkrC7XIWeSaZmr/PGMzf0CxA==';
        insert testdata;
    }
    
    @isTest
    public static void testAddDocuSignRecipient(){
        IQVIA_Agreement__c testAgreement = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test"}',
                'OK', 200));
        	CNT_CLM_AddDocusignRecipient.addDocuSignRecipient(testAgreement.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCompleteSentEnvelope(){
        IQVIA_Agreement__c testAgreement = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];
        testAgreement.Status_Category__c = 'In Signatures';
        testAgreement.Company_Signed_Date__c = System.today();
        testAgreement.Other_Party_Signed_Date__c = System.today();
        update testAgreement;
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, Name, Docusign_AccountId__c, Send_As_User_Email__c, Docusign_App_Name__c FROM IQ_DocuSignEnvelope__c WHERE Agreement__c =: testAgreement.Id];
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test"}',
                'OK', 200));
        	CNT_CLM_AddDocusignRecipient.completeSentEnvelope(testAgreement.Id,docuApiEnvelope.Name,'https://demo.docusign.net',docuApiEnvelope.Id, docuApiEnvelope.Docusign_App_Name__c, docuApiEnvelope.Send_As_User_Email__c,false);
        Test.stopTest();
    }
    
    @isTest
    public static void testDeclineSentEnvelope(){
        IQVIA_Agreement__c testAgreement = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, Name, Docusign_AccountId__c, Send_As_User_Email__c, Docusign_App_Name__c
            FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
    
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test"}',
                'OK', 200));
        	CNT_CLM_AddDocusignRecipient.declineSentEnvelope(testAgreement.Id,docuApiEnvelope.Name,'https://demo.docusign.net',
                docuApiEnvelope.Id, docuApiEnvelope.Docusign_App_Name__c, docuApiEnvelope.Send_As_User_Email__c);
        test.stopTest();
    }
    
    @isTest
    public static void testApexJobWrapper(){
        CNT_CLM_AddDocusignRecipient.ApexJobWrapper obj = new CNT_CLM_AddDocusignRecipient.ApexJobWrapper('test','test',1,1,1);
    }
    
    @isTest
    public static void testVoidSentEnvelope(){
        IQVIA_Agreement__c testAgreement = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];
        IQ_DocuSignEnvelope__c docuApiEnvelope = [SELECT Id, Name, Docusign_AccountId__c, Send_As_User_Email__c, Docusign_App_Name__c
            FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
    
        test.startTest();
            HTTPResponse response = new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test","voidedReason":"NOK"}',
                'OK', 200).respond(null);
            CNT_CLM_AddDocusignRecipient.EnvelopeWrapper EnvelopeWrapperObj = 
                (CNT_CLM_AddDocusignRecipient.EnvelopeWrapper)JSON.deserialize(response.getBody(), CNT_CLM_AddDocusignRecipient.EnvelopeWrapper.class);
        	CNT_CLM_AddDocusignRecipient.voidSentEnvelope(testAgreement.Id,docuApiEnvelope.Id,EnvelopeWrapperObj);
        test.stopTest();
        
        IQVIA_Agreement__c updatedAgreement = [SELECT Id,Status__c FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];
        IQ_DocuSignEnvelope__c updatedDocuApiEnvelope = [SELECT Id, Name, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: testAgreement.Id];
        assert.areEqual(CON_CLM.READY_FOR_SIGNATURES, updatedAgreement.Status__c, 'Agreement Status should be Ready for Signatures');
                assert.areEqual(CON_CLM.IQ_VOIDED_STATUS, updatedDocuApiEnvelope.Status__c, 'Envelope Status should be voided');

    }
    
    @isTest
    public static void testCancelDraftEnvelopes(){
        List<IQVIA_Agreement__c> agreements = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test SOW Agreement'];
    
        test.startTest();
        	CNT_CLM_AddDocusignRecipient.cancelDraftEnvelopes(agreements);
        test.stopTest();
        
        IQ_DocuSignEnvelope__c updatedDocuApiEnvelope = [SELECT Id, Name, Status__c
            FROM IQ_DocuSignEnvelope__c  WHERE Agreement__c =: agreements[0].Id];
        assert.areEqual('Cancelled', updatedDocuApiEnvelope.Status__c, 'Envelope Status should be Cancelled');
    }
}