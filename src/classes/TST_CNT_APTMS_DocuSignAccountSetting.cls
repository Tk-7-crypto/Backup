/**
* This test class is used to test all methods in CNT_APTMS_DocuSignAccountSetting controller class.
*/
@isTest
public class TST_CNT_APTMS_DocuSignAccountSetting {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"userName":"dsuser001", "userEmail":"abc@example.com", "password":"test@123", "clientId":"abc", "accountId":"", "baseURL":"https://demo.docusign.net", "privateKey":"pkey123", "publicKey":"key123", "secretKey":"", "access_token":"83f620794efd", "expireAfter":"7", "expireWarn":"4", "reminderDelay":"2", "reminderFrequency":"2", "redirectURI":"","Users":[{"userId":"user001", "email":"abc@example.com"}, {"userId":"user002", "email":"xyz@example.com"}] , "resultSetSize": "1", "totalSetSize": "", "startPosition":"", "endPosition":""}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void setupData(){
        CLM_Configuration__c clmconfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmconfiguration.RDS_Account_Id__c = 'CLM Test';
        insert clmConfiguration;
        
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        testAgreement.Apttus__Status__c = 'Other party Signatures';
        insert testAgreement;
        
        List<Apttus_DocuApi__DocuSignEnvelope__c> lstDocuSignEnvelope = new List<Apttus_DocuApi__DocuSignEnvelope__c>();
        Apttus_DocuApi__DocuSignEnvelope__c docuSignEnvelope = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuSignEnvelope.Name = 'Test DocuSign Envelope';
        docuSignEnvelope.Apttus_DocuApi__Status__c = 'sent';
        docuSignEnvelope.Send_As_User_Email__c = 'abc@example.com';
        docuSignEnvelope.Docusign_AccountId__c = '12345';
        docuSignEnvelope.Apttus_CMDSign__Agreement__c = testAgreement.Id;
        docuSignEnvelope.Apttus_DocuApi__DocumentName__c = '["Test Document.docx"]';
        docuSignEnvelope.Docusign_App_Name__c = 'CLM Test';
        lstDocuSignEnvelope.add(docuSignEnvelope);

        Apttus_DocuApi__DocuSignEnvelope__c docuSignEnvelope1 = new Apttus_DocuApi__DocuSignEnvelope__c();
        docuSignEnvelope1.Name = 'Test DocuSign Envelope 1';
        docuSignEnvelope1.Apttus_DocuApi__Status__c = 'sent';
        docuSignEnvelope1.Send_As_User_Email__c = 'xyz@example.com';
        docuSignEnvelope1.Docusign_AccountId__c = '123456';
        docuSignEnvelope1.Apttus_CMDSign__Agreement__c = testAgreement.Id;
        docuSignEnvelope1.Apttus_DocuApi__DocumentName__c = '["Test Document 1.docx"]';
        docuSignEnvelope1.Docusign_App_Name__c = 'CLM Test';
        lstDocuSignEnvelope.add(docuSignEnvelope1);
        insert lstDocuSignEnvelope;
        
        testAgreement.Apttus_CMDSign__DocuSignEnvelopeId__c = docuSignEnvelope.Id;
        update testAgreement;
        
        List<DocuSign_Auth_Data__c> lstDocuSignAuthData = new List<DocuSign_Auth_Data__c>();
        DocuSign_Auth_Data__c docuSignAuthData = new DocuSign_Auth_Data__c();
        docuSignAuthData.Name = 'CLM Test';
        docuSignAuthData.DocusignUser_Id__c = 'xyz';
        docuSignAuthData.User_Name__c = 'dsuser001';
        docuSignAuthData.Base_URL__c = 'https://demo.docusign.net';
        docuSignAuthData.Account_Id__c = docuSignEnvelope.Docusign_AccountId__c;
        docuSignAuthData.Client_Id__c = 'abc';
        docuSIgnAuthData.Private_Key__c = 'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC7VJTUt9Us8cKjMzEfYyjiWA4R4/M2bS1GB4t7NXp98C3SC6dVMvDuictGeurT8jNbvJZHtCSuYEvuNMoSfm76oqFvAp8Gy0iz5sxjZmSnXyCdPEovGhLa0VzMaQ8s+CLOyS56YyCFGeJZqgtzJ6GR3eqoYSW9b9UMvkBpZODSctWSNGj3P7jRFDO5VoTwCQAWbFnOjDfH5Ulgp2PKSQnSJP3AJLQNFNe7br1XbrhV//eO+t51mIpGSDCUv3E0DDFcWDTH9cXDTTlRZVEiR2BwpZOOkE/Z0/BVnhZYL71oZV34bKfWjQIt6V/isSMahdsAASACp4ZTGtwiVuNd9tybAgMBAAECggEBAKTmjaS6tkK8BlPXClTQ2vpz/N6uxDeS35mXpqasqskVlaAidgg/sWqpjXDbXr93otIMLlWsM+X0CqMDgSXKejLS2jx4GDjI1ZTXg++0AMJ8sJ74pWzVDOfmCEQ/7wXs3+cbnXhKriO8Z036q92Qc1+N87SI38nkGa0ABH9CN83HmQqt4fB7UdHzuIRe/me2PGhIq5ZBzj6h3BpoPGzEP+x3l9YmK8t/1cN0pqI+dQwYdgfGjackLu/2qH80MCF7IyQaseZUOJyKrCLtSD/Iixv/hzDEUPfOCjFDgTpzf3cwta8+oE4wHCo1iI1/4TlPkwmXx4qSXtmw4aQPz7IDQvECgYEA8KNThCO2gsC2I9PQDM/8Cw0O983WCDY+oi+7JPiNAJwv5DYBqEZB1QYdj06YD16XlC/HAZMsMku1na2TN0driwenQQWzoev3g2S7gRDoS/FCJSI3jJ+kjgtaA7Qmzlgk1TxODN+G1H91HW7t0l7VnL27IWyYo2qRRK3jzxqUiPUCgYEAx0oQs2reBQGMVZnApD1jeq7n4MvNLcPvt8b/eU9iUv6Y4Mj0Suo/AU8lYZXm8ubbqAlwz2VSVunD2tOplHyMUrtCtObAfVDUAhCndKaA9gApgfb3xw1IKbuQ1u4IF1FJl3VtumfQn//LiH1B3rXhcdyo3/vIttEk48RakUKClU8CgYEAzV7W3COOlDDcQd935DdtKBFRAPRPAlspQUnzMi5eSHMD/ISLDY5IiQHbIH83D4bvXq0X7qQoSBSNP7Dvv3HYuqMhf0DaegrlBuJllFVVq9qPVRnKxt1Il2HgxOBvbhOT+9in1BzA+YJ99UzC85O0Qz06A+CmtHEy4aZ2kj5hHjECgYEAmNS4+A8Fkss8Js1RieK2LniBxMgmYml3pfVLKGnzmng7H2+cwPLhPIzIuwytXywh2bzbsYEfYx3EoEVgMEpPhoarQnYPukrJO4gwE2o5Te6T5mJSZGlQJQj9q4ZB2Dfzet6INsK0oG8XVGXSpQvQh3RUYekCZQkBBFcpqWpbIEsCgYAnM3DQf3FJoSnXaMhrVBIovic5l0xFkEHskAjFTevO86Fsz1C2aSeRKSqGFoOQ0tmJzBEs1R6KqnHInicDTQrKhArgLXX4v3CddjfTRJkFWDbE/CkvKZNOrcf1nhaGCPspRJj2KUkj1Fhl9Cncdn/RsYEONbwQSjIfMPkvxF+8HQ==';
        lstDocuSignAuthData.add(docuSignAuthData);

        DocuSign_Auth_Data__c docuSignAuthData1 = new DocuSign_Auth_Data__c();
        docuSignAuthData1.Name = 'CLM Test';
        docuSignAuthData1.DocusignUser_Id__c = 'abc';
        docuSignAuthData1.User_Name__c = 'dsuser002';
        docuSignAuthData1.Base_URL__c = 'https://demo.docusign.net';
        docuSignAuthData1.Account_Id__c = docuSignEnvelope1.Docusign_AccountId__c;
        docuSignAuthData1.Client_Id__c = 'abcd';
        docuSignAuthData1.Private_Key__c = 'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC7VJTUt9Us8cKjMzEfYyjiWA4R4/M2bS1GB4t7NXp98C3SC6dVMvDuictGeurT8jNbvJZHtCSuYEvuNMoSfm76oqFvAp8Gy0iz5sxjZmSnXyCdPEovGhLa0VzMaQ8s+CLOyS56YyCFGeJZqgtzJ6GR3eqoYSW9b9UMvkBpZODSctWSNGj3P7jRFDO5VoTwCQAWbFnOjDfH5Ulgp2PKSQnSJP3AJLQNFNe7br1XbrhV//eO+t51mIpGSDCUv3E0DDFcWDTH9cXDTTlRZVEiR2BwpZOOkE/Z0/BVnhZYL71oZV34bKfWjQIt6V/isSMahdsAASACp4ZTGtwiVuNd9tybAgMBAAECggEBAKTmjaS6tkK8BlPXClTQ2vpz/N6uxDeS35mXpqasqskVlaAidgg/sWqpjXDbXr93otIMLlWsM+X0CqMDgSXKejLS2jx4GDjI1ZTXg++0AMJ8sJ74pWzVDOfmCEQ/7wXs3+cbnXhKriO8Z036q92Qc1+N87SI38nkGa0ABH9CN83HmQqt4fB7UdHzuIRe/me2PGhIq5ZBzj6h3BpoPGzEP+x3l9YmK8t/1cN0pqI+dQwYdgfGjackLu/2qH80MCF7IyQaseZUOJyKrCLtSD/Iixv/hzDEUPfOCjFDgTpzf3cwta8+oE4wHCo1iI1/4TlPkwmXx4qSXtmw4aQPz7IDQvECgYEA8KNThCO2gsC2I9PQDM/8Cw0O983WCDY+oi+7JPiNAJwv5DYBqEZB1QYdj06YD16XlC/HAZMsMku1na2TN0driwenQQWzoev3g2S7gRDoS/FCJSI3jJ+kjgtaA7Qmzlgk1TxODN+G1H91HW7t0l7VnL27IWyYo2qRRK3jzxqUiPUCgYEAx0oQs2reBQGMVZnApD1jeq7n4MvNLcPvt8b/eU9iUv6Y4Mj0Suo/AU8lYZXm8ubbqAlwz2VSVunD2tOplHyMUrtCtObAfVDUAhCndKaA9gApgfb3xw1IKbuQ1u4IF1FJl3VtumfQn//LiH1B3rXhcdyo3/vIttEk48RakUKClU8CgYEAzV7W3COOlDDcQd935DdtKBFRAPRPAlspQUnzMi5eSHMD/ISLDY5IiQHbIH83D4bvXq0X7qQoSBSNP7Dvv3HYuqMhf0DaegrlBuJllFVVq9qPVRnKxt1Il2HgxOBvbhOT+9in1BzA+YJ99UzC85O0Qz06A+CmtHEy4aZ2kj5hHjECgYEAmNS4+A8Fkss8Js1RieK2LniBxMgmYml3pfVLKGnzmng7H2+cwPLhPIzIuwytXywh2bzbsYEfYx3EoEVgMEpPhoarQnYPukrJO4gwE2o5Te6T5mJSZGlQJQj9q4ZB2Dfzet6INsK0oG8XVGXSpQvQh3RUYekCZQkBBFcpqWpbIEsCgYAnM3DQf3FJoSnXaMhrVBIovic5l0xFkEHskAjFTevO86Fsz1C2aSeRKSqGFoOQ0tmJzBEs1R6KqnHInicDTQrKhArgLXX4v3CddjfTRJkFWDbE/CkvKZNOrcf1nhaGCPspRJj2KUkj1Fhl9Cncdn/RsYEONbwQSjIfMPkvxF+8HQ==';
        lstDocuSignAuthData.add(docuSignAuthData1);
        insert lstDocuSignAuthData;
        
        Apttus_DocuApi__DocuSignSystemProperties__c DocuSignSystemProperties = new Apttus_DocuApi__DocuSignSystemProperties__c(Name = 'System Properties', Apttus_DocuApi__ProductionEnvironment__c = false);
        insert DocuSignSystemProperties;
    }

    @isTest
    private static void testInsertDocusignAuthData() {
        List<Apttus_DocuApi__DocuSignEnvelope__c> docuSignEnvelope = [SELECT Id, Name, Docusign_AccountId__c, Docusign_App_Name__c FROM Apttus_DocuApi__DocuSignEnvelope__c WHERE Name = 'Test DocuSign Envelope' LIMIT 1];
        String packagedString = '[{"userName":"dsuser001", "userEmail":"abc@example.com", "password":"test@123", "clientId":"abc", "accountId":"'+ docuSignEnvelope[0].Docusign_AccountId__c +'", "baseURL":"https://demo.docusign.net", "privateKey":"", "publicKey":"", "secretKey":"", "accessToken":"", "expireAfter":"7", "expireWarn":"4", "reminderDelay":"2", "reminderFrequency":"2", "redirectURI":""}]';
        Boolean isInsert;
        Test.startTest();
            isInsert = CNT_APTMS_DocuSignAccountSetting.insertDocusignAuthData(packagedString);
        Test.stopTest();
        System.assertEquals(true, isInsert, 'Docusign Auth Data not inserted.');
    }
    
    @isTest
    private static void testGetUserInfoBeforeInserting() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            CNT_APTMS_DocuSignAccountSetting.ESignatureResponseWrapper response = 
                CNT_APTMS_DocuSignAccountSetting.getUserInfoBeforeInserting('CLM Test','abc@example.com');
        	CNT_APTMS_DocuSignAccountSetting cntAptmsDocuSignAccountSetting = new CNT_APTMS_DocuSignAccountSetting();
        	CNT_APTMS_DocuSignAccountSetting.ResponseErrorWrapper responseError = new CNT_APTMS_DocuSignAccountSetting.ResponseErrorWrapper();
        	String tempErrorVal = responseError.error;
        	tempErrorVal = responseError.message;
            tempErrorVal = responseError.errorCode;
        Test.stopTest();    
        
        System.assertEquals('SUCCESS', response.status, 'The response should match');
    }
	
    @isTest
    private static void testFetchDocusignData() {
        Test.startTest();
            List<DocuSign_Auth_Data__c> lstDocuSignAuthData = CNT_APTMS_DocuSignAccountSetting.fetchDocusignData();
        Test.stopTest();    
        
        System.assertEquals(true, lstDocuSignAuthData.size() > 0, 'Method should return list of records');
    }
}