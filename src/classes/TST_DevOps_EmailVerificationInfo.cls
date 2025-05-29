@isTest(seealldata=false)
public class TST_DevOps_EmailVerificationInfo {
    
    @testSetup 
    static void setup() {  
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());         	
       		Unverfied_User_Email_Settings__c devOpsSettings = new Unverfied_User_Email_Settings__c();
        	devOpsSettings.Name='IQVIA';
        	devOpsSettings.Sandbox_Name__c=d.getSandboxName();
        	devOpsSettings.Sandbox_ClientID__c='3MVG9_4NR96cWRpFZI7CQzfLCCRYWmYZNyGieY0FkgxJjF6CPKyVazD21kIt27mJ_lQMZb9CYen6yF6dQU_D_	';
        	devOpsSettings.Sandbox_Client_Secrate__c='DE7FA2143FC99EBF42C34711A8EE46719109965432F4D866CC5C05DD0403F453';
        	devOpsSettings.Username__c='ajeet.jha@imshealth.com.devxap';
        	devOpsSettings.PasswordWithToken__c='Meta@1234Ol6Jhe6aAm3BKWBqIBaavradk';
        	devOpsSettings.Salesforce_TokenEndPoint__c='https://test.salesforce.com/services/oauth2/token';
            devOpsSettings.Salesforce_EndPointName__c='https://imshealth--devxap.sandbox.my.salesforce.com/services/data/v63.0/';
        	insert devOpsSettings;            
        
    }
    
 // Mock class for simulating HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testRunisEmailVerifiedMethod() { 
           	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        	CNT_DevOps_EmailVerificationInfo.isEmailVerified();
        	CNT_DevOps_EmailVerificationInfo.sendVerificationMail('Test@test.com');  
        	Test.stopTest();
    }
     
     
}