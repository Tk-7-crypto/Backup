@isTest
public class TST_CNT_CRM_Site_Validate_Opp {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        CRM_Site_API_Settings__c siteAPISettings = new CRM_Site_API_Settings__c();
        siteAPISettings.Name = 'CRM_Site_API_Setting';
        siteAPISettings.UserName__c = 'dheeraj.kumar1@metacube.com.siteapi';
        siteAPISettings.Password__c = 'lWH31fgwPWum5ukSdX25q844onfT6sGYwZjWx94Cv1SwB6NvqdEKH4447r0qbXCAoTaEnwvn4842L8uXWxFtuw==';
        siteAPISettings.Client_Id__c = '3MVG93MGy9V8hF9OK4Z4gQBI0DBRlftF';
        siteAPISettings.Client_Secret__c = '28E9CE28891AB6ACF1A6B00B21BB1853AE64D50223D19EE84D38BA2FB21E9E6A';
        siteAPISettings.Base_URL__c = 'https://iqvia--crm.sandbox.my.salesforce.com';
        siteAPISettings.Sender_Id__c = '0D26A000000L1W5';
        siteAPISettings.Exception_Error_Email__c = 'test@gail.com';
        insert siteAPISettings;
        
    }
    
    @isTest
    static void testGetAccessToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        new CNT_CRM_Site_Validate_Opp().getDetails();
        Test.stopTest();
    }
    
        
    @isTest
    static void testSendErrorMailNotification() {
        Test.startTest();
        CNT_CRM_Site_Validate_Opp.sendErrorMailNotification('ERROR MESSAGE');
        Test.stopTest();
    }
    
    
    
    
    private static final String FAKE_RESPONSE_JSON = '{"Status":"OK", "StatusCode":"200", "access_token":"qw323vd43"}';
    
    private class Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(200);
            return res;
        }
    }
}