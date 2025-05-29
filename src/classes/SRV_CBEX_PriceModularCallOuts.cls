/**
 * Created by Ronak Mehta on 19-Jun-2023
 * Description : Service Class to Use Price Modular Cost
 **/
public class SRV_CBEX_PriceModularCallOuts {
    
    public static String endpoint_PriceModuler;
    public static String endpoint_Token;
    public static String body_Token;
    public static String access_token = '';
    
    private static String getRequestToken() {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(body_Token);
        req.setMethod('POST');
        req.setEndpoint(endpoint_Token);
        HttpResponse res = h.send(req);
        system.debug('Token status code: '+res.getStatusCode());
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        if(res.getStatusCode() == 200){
            access_token = (String)results.get('access_token');
        }
        return access_token;
    }
    
    /**
     * This Method to call rest API to get Cost
     * @params String payload
     * @return HttpResponse
     **/
    public static HttpResponse getCostPriceModuleAPICall(String payload) {
        
        CBEX_Price_Modular_Cred__c pmc = CBEX_Price_Modular_Cred__c.getInstance();
        endpoint_Token = pmc.Endpoint_Token__c;
        endpoint_PriceModuler = pmc.Endpoint_PriceModuler__c;
        body_Token = 'grant_type=client_credentials&client_id=' + pmc.Client_Id__c + '&client_secret=' + pmc.Client_Secret__c;
        
        if(String.isBlank(access_token)){
            getRequestToken();
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint_PriceModuler);
        request.setHeader('Authorization', 'Bearer ' + access_token);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody((payload));
        HTTPResponse response = http.send(request);
        system.debug('PriceModule status code: '+response.getStatusCode());
        return response;
    }

}