@isTest
global class TST_Mock_UTL_PickListOptions implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String jsonResponse = '{';
        jsonResponse += '"values" : [ {';
        jsonResponse += '"attributes" : null,';
        jsonResponse += '"label" : "Mix ownership (various data assets owned by more than one country)",';
        jsonResponse += '"validFor" : [ ],';
        jsonResponse += '"value" : "Mix ownership (various data assets owned by more than one country)"';
        jsonResponse += '}]}';
        res.setBody(jsonResponse);
        return res;
    }
}