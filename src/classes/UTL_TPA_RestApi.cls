public class UTL_TPA_RestApi {  // will review, remove all unnecessary code from UTL_TPA_RestApi
    public String actionType;
    public CNT_TPA_RequestSubmissionForm.tpaRequestDetails requestObj;
    
    public String responseMessage;
    public Boolean isSuccess = false;
    public Set<Id> psaLogIds;

    
    public static UTL_TPA_RestApi callTpaRestApiHttpPost(UTL_TPA_RestApi arg, String sessionId) {
        UTL_TPA_RestApi returnResult;
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        try {
            Http http = new Http();
            request.setHeader('Content-Type', 'application/json');
            String EndpointURL = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c.substringBeforeLast('/') + '/services/apexrest/wscTpaRestApis/' ;
            request.setEndpoint(EndpointURL);
            
            request.setHeader('Authorization', 'OAuth ' + sessionId);
            request.setMethod('POST');
            request.setTimeout(120000);
            
            request.setBody(JSON.serialize(arg));
            response = http.send(request);
            while (response.getStatusCode() == 302) {
                request.setEndpoint(response.getHeader('Location'));
                response = new Http().send(request);
            }
            if(response.getStatusCode() == 200) {
                returnResult = (UTL_TPA_RestApi) JSON.deserialize(response.getBody(), UTL_TPA_RestApi.class);
                return returnResult;
            }
            else {
                returnResult = (UTL_TPA_RestApi) JSON.deserialize(response.getBody(), UTL_TPA_RestApi.class);
                returnResult.isSuccess = false;
                
                return returnResult;
            }
        }
        catch(Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::UTL_TPA_RestApi.callTpaRestApiHttpPost', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            
            //will review, exception logs
            returnResult = new UTL_TPA_RestApi();
            returnResult.isSuccess = false;
            returnResult.responseMessage = 'ERROR: Line->' + e.getLineNumber() + ', Message->' + e.getMessage();
            
            return returnResult;
        }
    }
    
}