@RestResource(urlMapping='/OWFServices/DataServices')
global with sharing class SRV_OWF_RST_DataService {
    @HttpGet
    global static String getData(){
        RestRequest req = RestContext.request;
        return UTL_OWF_DataProcessUtility.getData(req.params.get('requestString'),req.params.get('requestedBy'));
    }
	@HttpPut
    global static Map<String, String> doPut(){
        Map<String, String> responseMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String response = UTL_OWF_DataProcessUtility.handlePutAndPostRequest(req.requestBody.toString());
        if(response != 'Success') {
            responseMap.put('errorCode', '400');
        	responseMap.put('message', response);  
        }
        else{
            responseMap.put('errorCode', '200');
        	responseMap.put('message', response);  
        }
        return responseMap;
    }
    @HttpPost
    global static Map<String, String> doPost(){
        Map<String, String> responseMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String response = UTL_OWF_DataProcessUtility.handlePutAndPostRequest(req.requestBody.toString());
        if(response != 'Success') {
            responseMap.put('errorCode', '400');
        	responseMap.put('message', response);  
        }
        else{
            responseMap.put('errorCode', '200');
        	responseMap.put('message', response);  
        }
        return responseMap;
    }
}