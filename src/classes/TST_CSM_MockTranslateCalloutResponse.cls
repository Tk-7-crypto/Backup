@IsTest
global class TST_CSM_MockTranslateCalloutResponse implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data": {"translations": [{"translatedText": "Hallo Welt", "detectedSourceLanguage": "en"}]}}');
        res.setStatusCode(200);
        return res;
    }
}