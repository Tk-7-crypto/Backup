/*
Description : This is test class for QBL_AddDocuSignRecipientQueuable
*/
@isTest
public class TST_QBL_AddDocuSignRecipient {

    @testSetup
    static void dataSetup(){
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Apttus__Status_Category__c = 'In Signatures';
        insert testAgreement;
        
        Agreement_Contacts__c testAgreementContact = TST_CLM_TestDataFactory.createAgreementContact(testAgreement, true, 'Account');
        Agreement_Contacts__c testAgreementContact1 = TST_CLM_TestDataFactory.createAgreementContact(testAgreement, true, 'Legal Entity 1');
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c docuApiDocuSignEnvelopeReciStatus1 = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c();
        Apttus_DocuApi__DocuSignEnvelope__c docuApiEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuApiEnvelope.Apttus_CMDSign__Agreement__c = testAgreement.Id;
        docuApiEnvelope.Apttus_DocuApi__Status__c = 'sent';
        docuApiEnvelope.Docusign_AccountId__c = '12345';
        docuApiEnvelope.Send_As_User_Email__c = 'test';
        docuApiEnvelope.Docusign_App_Name__c = 'CLM Test';
        insert docuApiEnvelope;
        
        DocuSign_Auth_Data__c testdata = new DocuSign_Auth_Data__c();
        testdata.Name='CLM Test';
        testdata.account_id__c='12345';
        testdata.base_url__c='https://demo.docusign.net';
        testdata.Client_Id__c = '12345';
        testdata.Private_Key__c = 'MIIEpAIBAAKCAQEAhXR4OA1AS2IbdEjlyPB6xx0c5t7USYpMAugQOFnRPPySB5zY6lHx/cnNZg9LEAB10p5N1yZBpI+jAC30oFJGbuLu3dKYmYFZP7dYRnNWpuWpiaTkD86A2opyq8bCmKmF/oXoxLxlDTWKUPYA1EmcU/6dVb3+CP1nLqevDkaG1YaeEqX+QEeJ6JfUMsOGw7Ilkg1iMLB+saBVICGtF6DJklsL8Sqvz/B7tEWY7B/iCjNwninjYLeQYSn2GFe5E6yjkeouOyYHdU/DZseKAmZ2V+UexAObqNj7uZ6vJ/rc9XcVB4qYjwiD2pClS4+6gvDmaFaWvnxu+8yQKTEwqbr+lwIDAQABAoIBAAFVRAC6wt7d5jop6/bTqddyVO3u4XT64r59i6fuuuQekFMmJHDWwyPX6yJBWmyGbKbfJ8zl4SVEmS66D+7+5a8STauGkxTwUZ360V6P7fPe+rTrWRi1UwEuIiT11hg2uLhJEyWpFqx2ms6Y8MR3PKDh4G6aU+NcrBGK4WazUYHoXOQNaMojlrtd+RqlzThzjJnmUmtA7W/gHbzviKEOE3fQunqAVVZ3Qre4ySqeyI3RdM/3kdNYeMblp08CAmoIspQ6rT161sV6RMxypKd/+HJtxsOzkZ2GQvjvHXwbClKGxwKofF6mpX/iv4Wxw9xLEF3RmjansZgM+jntesvC/OUCgYEA669C9w6ih6t0BKRgDFKoMMHJZm8lyvGSodrLdwXNq3ak+yiiL1SScrsmr8J2PPA6R+dRLWYfWjVvHCFP94s/DSnTyTmHEN0xVuxERdsTesXP92JgahL0B8v5ubaMJu2mfuXsuNt+hkMHRkOArlh5Hw/C2Ln2kHGQwAm9I5NlZjMCgYEAkPVbC53DK5iQ7QFsRc1HG4w5d81ONb2aRHFkPGAmiuQwS1n3e/ObBf3Bk51gyPuUMDrmpXngtDmVZcJWVQ38HCzh8xfEr3dk9OY2+JGO1aZiyTrnln8fKkOV/acUqEokntfuwUkN98wewvCmnWtUExarP6mq1pFFycqZHRwd+g0CgYEAxx1irecnWQd5FRLqMn8CqW6PAIOWokZFY4i9rOiyQdISwD4sB2Cj+Voz7PmVexZZprW+12QXyNar8FAUh0aVFkHoM3Dus0isjos9gub7JhZJBO+QFQ2+LXgems+myJyutTb7L5IA6t1mH+6XoLQOYDeongE+VfocGKIhsRSt7hECgYAktBtTe6S5Wy4G9L9HhUyl6wF6Fh/hd5qiDdwFdYsMy+52hdcmKW5tO+1RxR2GhjzlYWSZLZz5xULQuz5E1v+o2qxzcuc4TpDfeZMdqS1zZ2fH8ARHlPR9LRPDYBTY770KAz7O7gJ9Zc+8KFbnsQ9erfS6b+lz3uC+0W+ncUEd2QKBgQCBsWyVUY4YqA6QTt/b1Bj6il3kV/DlMXwqW6gOHhmtIycqtDUVl7Ttilcbf7ScDUIxW4bJAUWhtvRI13eHADjC1aZE4kj79c2PNBChYj8vLR6DK+GVruxhzIKjRV5i+3RzXDeoMqW98BofpadZzlKkrC7XIWeSaZmr/PGMzf0CxA==';
        insert testdata;
    }

    @isTest
    public static void testaddDocuSignRecipient(){
        Apttus__APTS_Agreement__c testAgreement1 = [SELECT Id, Name, Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c LIMIT 1];

        test.startTest();
            Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout('{"signers":[{"creationReason":"test","isBulkRecipient":"true","name":"abc","email":"abc@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"test","signedDateTime":"2016-10-30T15:27:02.000Z"}],"carbonCopies":[{"name":"test","email":"test@gmail.com","recipientId":"test","recipientIdGuid":"test","requireIdLookup":"test","userId":"test","routingOrder":"test","roleName":"test","status":"tes"}],"recipientCount":"1","currentRoutingOrder":"test"}',
                    'OK', 200));
            CNT_APTMS_AddDocuSignRecipient.addDocuSignRecipient(testAgreement1.Id);
            SCH_APTMS_AddDocuSignRecipient obj = new SCH_APTMS_AddDocuSignRecipient(testAgreement1.Id);
            SchedulableContext sc = null;
            obj.execute(sc);
        test.stopTest();
    }
}