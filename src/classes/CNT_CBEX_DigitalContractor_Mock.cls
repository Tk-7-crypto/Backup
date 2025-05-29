@isTest
global class CNT_CBEX_DigitalContractor_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        //Create response Instance and set fake response and success status code
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"cost": "169172811.67795414"}');
        response.setStatusCode(200);
        return response;
    }
}