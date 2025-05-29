global class TST_Mock_CSM_GenericCallOut implements HttpCalloutMock{

    global TST_Mock_CSM_GenericCallOut(){

    }
    global TST_Mock_CSM_GenericCallOut(String json){
        this.json = json;
    }
    global String json;
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }
    
    
}