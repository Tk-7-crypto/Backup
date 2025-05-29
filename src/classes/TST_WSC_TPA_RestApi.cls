@isTest
public class TST_WSC_TPA_RestApi {
    public static UTL_TPA_RestApi getRequestArg(Boolean flag){
        TPA_Request__c tpaReq = UTL_TPA_SetupTestData.getTestTPARequest();
        
        UTL_TPA_RestApi requestArg = new UTL_TPA_RestApi();
        
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaReqDet =  new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        tpaReqDet.tpaRequest = tpaReq;
        requestArg.requestObj = tpaReqDet; 
        
        requestArg.actionType = flag == null ? '' : (flag ? 'UpdateUseOffData' : 'DeleteUseOffData') ;
        return requestArg;
    }
    @isTest static void testhandleHttpCall(){
        RestRequest request = new RestRequest();
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        
        UTL_TPA_RestApi requestArg = getRequestArg(true);
       
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestArg));
        response.responseBody = Blob.valueOf(JSON.serialize(requestArg));
        RestContext.response = response;
        
        WSC_TPA_RestApi.handleHttpCall();
    }
    
    @isTest static void testhandleHttpCallDelete(){
        RestRequest request = new RestRequest();
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        
        UTL_TPA_RestApi requestArg = getRequestArg(false);
       	
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestArg));
        response.responseBody = Blob.valueOf(JSON.serialize(requestArg));
        RestContext.response = response;
        
        WSC_TPA_RestApi.handleHttpCall();
    }
    
    @isTest static void testhandleHttpCallBlank(){
        RestRequest request = new RestRequest();
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        
        UTL_TPA_RestApi requestArg = getRequestArg(null);
       	
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestArg));
        response.responseBody = Blob.valueOf(JSON.serialize(requestArg));
        RestContext.response = response;
        
        WSC_TPA_RestApi.handleHttpCall();
    }
}