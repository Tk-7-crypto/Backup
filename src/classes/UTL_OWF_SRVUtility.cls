public class UTL_OWF_SRVUtility {
    
    
    public static String createBDRR(List<Id> updatedAssignmentIdList)
    {
        String idListAsJSONString = JSON.serialize(updatedAssignmentIdList);
        String doPostCaseString = 'createBDRR';
        String endPointURLString = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/OWFServices/RRSerevices';
        String contentTypeString = 'application/json';
        String authorizationHeaderString = 'OAuth '+UserInfo.getSessionId();
        
        JSONGenerator reqBodyJson = JSON.createGenerator(true);
        reqBodyJson.writeStartObject();
        reqBodyJson.writeStringField('doPostCase',doPostCaseString);
        reqBodyJson.writeObjectField('reuqiredParams',updatedAssignmentIdList);
        reqBodyJson.writeEndObject();

        
        Map<String,String> reqHeaderMap = new Map<String, String>();
        reqHeaderMap.put('Authorization',authorizationHeaderString);
        reqHeaderMap.put('content-type','application/json');
        
        String httpResp = universalHTTPReq(endPointURLString,reqHeaderMap,reqBodyJson,'POST');
        return httpResp;
        
    }
    
    
    
    private static String universalHTTPReq(String endPointURL,Map<String,String> reqHeader, JSONGenerator reqBody, String reqMethod)
    {
        HttpResponse resp;
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod(reqMethod);
            req.setBody(reqBody.getAsString());
            req.setTimeout(120000);
            for(String headerKey: reqHeader.keySet())
            {
                req.setHeader(headerKey, reqHeader.get(headerKey));    
            }
            
            Http http = new Http();
            system.debug('req.getBody()' + req.getBody());
            resp = http.send(req);

        }
        catch(Exception e)
        {

            system.debug('HTTP Exceptoin Occurred:Cause: ' + e.getCause());
            system.debug('HTTP Exceptoin Occurred:StackTrace: ' + e.getStackTraceString());
        }
            
        
        
        return '';
    }
    
}