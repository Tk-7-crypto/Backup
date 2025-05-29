@isTest
                        
global class TST_TPA_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><loginResponse xmlns="urn:partner.soap.sforce.com"><result><sessionId>ABC123</sessionId><serverUrl>qwerty</serverUrl></result></loginResponse><Fault><faultstring>fa</faultstring></Fault></Body></Envelope>');
        res.setStatusCode(201);
        return res;
    }
}