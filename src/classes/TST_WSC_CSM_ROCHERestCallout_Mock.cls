@isTest
global class TST_WSC_CSM_ROCHERestCallout_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"number":"1234", "response_code":"200", "response_message":"Message received and processed. Record(s) inserted/updated."}}');
        res.setStatusCode(200);
        return res;
    }
}