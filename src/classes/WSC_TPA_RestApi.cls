@RestResource(urlMapping='/wscTpaRestApis/*') 
global without sharing class WSC_TPA_RestApi {  // will review, remove all unnecessary code from UTL_TPA_RestApi
 @HttpPost
 global static void handleHttpCall() {
     String httpBody = RestContext.request.requestBody.toString();
     system.debug('Hi Rest Api');
     UTL_TPA_RestApi request;
     UTL_TPA_RestApi result = new UTL_TPA_RestApi();
     RestResponse restResult = RestContext.response;
     try {
         system.debug(httpBody);
         request = (UTL_TPA_RestApi) JSON.deserialize(httpBody, UTL_TPA_RestApi.class);
         result.isSuccess = true;
         result.responseMessage = 'Success';

         if(request.actionType == 'UpdateUseOffData' ) {
             result = CNT_TPA_RequestSubmissionForm.updateALLData(request);             
             restResult.responseBody = Blob.valueOf(JSON.serialize(result));
             if(!result.isSuccess){
                restResult.statusCode = 701;

             }else{
                restResult.statusCode = 200;

             }
         }
         else if(request.actionType == 'DeleteUseOffData' ) {
            result = CNT_TPA_RequestSubmissionForm.deleteData(request);
            restResult.responseBody = Blob.valueOf(JSON.serialize(result));
            restResult.statusCode = 200;
        }
        
         else {
             result.isSuccess = false;
             result.responseMessage = 'Action Type: ' + request.actionType + ', Error: Collection is Empty';
             restResult.responseBody = Blob.valueOf(JSON.serialize(result));
             restResult.statusCode = 501;
         }
     } catch(Exception e) {
         system.debug(e.getMessage());
         system.debug('result.isSuccess:' + result.isSuccess);
         
         result.isSuccess = false;
         result.responseMessage = 'StackTrace: ' + e.getStackTraceString() + ' || Line#: ' + e.getLineNumber() + ' || Message: '+ e.getMessage();
         restResult.responseBody = Blob.valueOf(JSON.serialize(result));
         restResult.statusCode = 701; 
     }
 }
}