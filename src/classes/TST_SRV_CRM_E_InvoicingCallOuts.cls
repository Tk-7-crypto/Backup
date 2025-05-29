@isTest
public class TST_SRV_CRM_E_InvoicingCallOuts {
    
    @isTest
    private static void testCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        SRV_CRM_E_InvoicingCallOuts.makePostCallout('{"example":"test"}');
        Test.stopTest();
    }
    
    public class MockResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(201);
            return res;
        }
    }
}