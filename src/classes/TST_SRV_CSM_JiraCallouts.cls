@isTest
private class TST_SRV_CSM_JiraCallouts {
    @testSetup
    static void dataSetup() {
        CSM_Jira_Config__c config= new CSM_Jira_Config__c ();
        config.Name='nameTest';
        config.jira_base_url__c ='http://example.com';
        config.token__c ='tokenTest';
        insert config;
    }

    @isTest
    private static void testCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_MockHttpResponseGenerator());
        SRV_CSM_JiraCallouts.makeGetCallout('http://example.com/rest/api/');
        SRV_CSM_JiraCallouts.makePostCallout('http://example.com/rest/api/','{"example":"test"}');
        SRV_CSM_JiraCallouts.makePostAttachmentCallout('http://example.com/rest/api/','fileNameTest',Blob.valueOf('Unit Test Attachment Body'));
        Test.stopTest();
    }
    public class TST_MockHttpResponseGenerator implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }

}