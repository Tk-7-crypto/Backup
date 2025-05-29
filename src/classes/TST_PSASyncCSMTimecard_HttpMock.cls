/*
* Author    :  Ritik Kumawat
* Purpose    : Mock class for SRV_PSA_SyncCSMTimecard
*/
@isTest
public class TST_PSASyncCSMTimecard_HttpMock implements HttpCalloutMock{
    protected String body;	
    protected Integer statusCode;
    public TST_PSASyncCSMTimecard_HttpMock(String body,Integer statusCode){
        this.body=body;
        this.statusCode=statusCode;
    }
	public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setHeader('Location', 'json');
        response.setBody(this.body);
        response.setStatusCode(this.statusCode);
        return response; 
    }
}