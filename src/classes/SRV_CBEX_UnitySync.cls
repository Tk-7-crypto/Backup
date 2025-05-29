/**
 * Created by Aman Kumar on 16-10-2024
 * Description : Service Class to Use Price Modular Cost
 **/
public class SRV_CBEX_UnitySync {
    
    public static String Endpoint_UnityFlag;
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
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        if(res.getStatusCode() == 200){
            access_token = (String)results.get('access_token');
        }
        System.debug('UnityFlagSync Token status code: '+res.getStatusCode());
        return access_token;
    }
    
    /**
     * This Method to call rest API to get Cost
     * @params String payload
     * @return HttpResponse
     **/
    @InvocableMethod(label='Get Unity Flag API Call' description='Makes an API call to Unity Flag and returns the response')
    public static List<String> getCostUnityFlagAPICall(List<id> recordId) {
        List<String>responseList = new List<String>();
        List<Intake_Unity_Flag_Sync__c> iufsList = [Select Id, SObject_Id__c, SObject_Type__c FROM Intake_Unity_Flag_Sync__c WHERE Id IN :recordId];
        String payload  = genratePayload(iufsList);
        
        CBEX_Unity_Flag_Outbound__c uf = CBEX_Unity_Flag_Outbound__c.getInstance();
        if(uf != null && uf.Endpoint_Token__c != null){
            endpoint_Token = uf.Endpoint_Token__c;
            Endpoint_UnityFlag = uf.Endpoint_Unity_Flag__c;
            body_Token = 'grant_type=client_credentials&client_id=' + uf.Client_Id__c + '&client_secret=' + uf.Client_Secret__c;
            
            if (String.isBlank(access_token)) {
                getRequestToken();
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Endpoint_UnityFlag);
            request.setHeader('Authorization', 'Bearer ' + access_token);
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('POST');
            request.setBody(payload);
            //request.setTimeout(30000);
            HTTPResponse response = http.send(request);
            System.debug('UnityFlagSync status code: ' + response.getStatusCode());
            responseList.add(response.getBody());
        }
        return responseList;
    }
    
    private Static String genratePayload(List<Intake_Unity_Flag_Sync__c> iufsList){
        String OrganizationId = UserInfo.getOrganizationId();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
        gen.writeStringField('OrganizationId', OrganizationId);
        
        gen.writeFieldName('Notifications');
        gen.writeStartArray();
        for(Intake_Unity_Flag_Sync__c iufs :iufsList){
            gen.writeStartObject();
            gen.writeStringField('Id', iufs.Id);
            gen.writeFieldName('sObject');
            gen.writeStartObject();
            gen.writeStringField('Id', iufs.Id);
            gen.writeStringField('SObject_Id__c', iufs.SObject_Id__c);
            gen.writeStringField('SObject_Type__c', iufs.SObject_Type__c);
            gen.writeEndObject();
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        if(!String.isBlank(jsonData)) {
            return jsonData;
        }
        else {
            return null;
        }
    }
    
}