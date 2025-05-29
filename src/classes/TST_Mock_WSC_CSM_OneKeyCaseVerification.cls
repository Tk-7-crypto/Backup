public class TST_Mock_WSC_CSM_OneKeyCaseVerification implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"response": {"success": true,"status": "SUCCESS","results": [{ "onekeyEid": "WFRD0089045001","individual": {'+
                    '"individualEid": "WFRD00890450","firstName": "ALAIN","lastName": "BISMUTH"}}]}}');
        res.setStatusCode(200);
        return res;
    }
}