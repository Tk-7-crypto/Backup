public inherited sharing class OrgREST {
    
    public static String retriveResult(String strResourceName, String strMethod, String strBody) {
        String response;
        String strEndPonitURL = 'callout:Test_Named/services/data/v46.0/'+ strResourceName;
        if(String.isNotBlank(strResourceName)) {
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod(strMethod); 
            if(String.isNotBlank(strBody)) {
                httpRequest.setBody(strBody);
                httpRequest.setHeader('Content-Type', 'application/json');
                httpRequest.setHeader('Accept', 'application/json');
            }
            
            httpRequest.setEndpoint(strEndPonitURL); 
            
            try {  
                Http http = new Http(); 
                HttpResponse httpResponse;
                if(!Test.isRunningTest()){
                    httpResponse = http.send(httpRequest); 
                    
                    if (httpResponse.getStatusCode() == 200 ) {  
                        response = httpResponse.getBody();  
                    } 
                    
                }
                
            } 
            catch(Exception ex) {  
                system.debug('EXCCC'+ex);
                throw ex;  
            } 
        } 
        return response;
    }
}