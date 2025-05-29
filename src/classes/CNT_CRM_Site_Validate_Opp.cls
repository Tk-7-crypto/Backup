public class CNT_CRM_Site_Validate_Opp {
   public Long oppNumber {get;set;}
   public integer number1 {get;set;} 
   public Boolean oppFound {get;set;} 
   public String showMessage{get;set;}
   private String AccessToken;
    
    public PageReference getDetails() {
        getAccessToken();
        Integer size = 0;
        if(AccessToken != NULL) {
            size = validateOpportunity();
            oppFound = true;
        }  
        // Parse JSON response to get all the totalPrice field values.
        else{
            oppFound = false;
        }
        if(oppFound) {
            if(size == 0 )
                showMessage = 'This is not a valid opportunity number.';
            else
                showMessage = 'This is a valid opportunity number.';
        }
        return null;
    }
    
    private string getAccessToken() {
        if(AccessToken != NULL)
            return accessToken;
        CRM_Site_API_Settings__c apiSettings = CRM_Site_API_Settings__c.getOrgDefaults();
        Map<String, String> params1 = new Map<String,String>();
        try {
        params1.put('username', apiSettings.UserName__c);
        params1.put('password', UTL_CRM.decryptPassword(apiSettings.Password__c));
        params1.put('client_id', apiSettings.Client_Id__c);
        params1.put('client_secret',apiSettings.Client_Secret__c);
        params1.put('grant_type','password');
        }
        catch(Exception e) {
            ErrorMessagePage();
            return null;
        }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept','application/json');
        req.setEndpoint(apiSettings.Base_URL__c + '/services/oauth2/token');
        req.setMethod('POST');
        req.setBody(getDataString(params1));
        HttpResponse res = h.send(req);
        system.debug(res.getStatusCode()); 
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String token = '';
        if(res.getStatusCode() == 200){
            token = (String)results.get('access_token');
            System.debug('token' + token);
            accessToken = token;
        }
        else{
            ErrorMessagePage();
            sendErrorMailNotification(res.getStatusCode() + res.getStatus());
        }
        return accessToken;
    }
    
    private String getDataString(Map<String, String> params){
        String result = '';
        boolean first = true;
        for(String entry : params.keySet()){
            if (first)
                first = false;
            else
                result = result + '&';
            result = result + EncodingUtil.urlEncode(entry, 'UTF-8');
            result = result + '=';
            result = result + EncodingUtil.urlEncode(params.get(entry), 'UTF-8');
        }    
        return result;
    }
    
    private Integer validateOpportunity() {
        CRM_Site_API_Settings__c apiSettings = CRM_Site_API_Settings__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiSettings.Base_URL__c + '/services/data/v57.0/query?q=Select+opportunity_number__c+from+opportunity+where+opportunity_number__c=\''+ oppNumber+ '\'+limit+1');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        Integer totalSize = 0;
        HTTPResponse res = http.send(req);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            totalSize = (Integer)results.get('totalSize');
            System.debug('totalSize' + totalSize);
        } else{
            ErrorMessagePage();
            sendErrorMailNotification(res.getStatusCode() + res.getStatus());			 
        }
        return totalSize;
    }
    
    public static void ErrorMessagePage(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'There is some internal error in the site Please Contact Your Administrator '));
    }
   
    public static void sendErrorMailNotification(String ErrorExceptionMsg){
        CRM_Site_API_Settings__c apiSettings = CRM_Site_API_Settings__c.getOrgDefaults();
        Messaging.SingleEmailMessage singleEmail  =  new Messaging.SingleEmailMessage();
            if (apiSettings.Sender_Id__c != null) {
                singleEmail.setOrgWideEmailAddressId(apiSettings.Sender_Id__c);
            }
        if(apiSettings.Exception_Error_Email__c != null) {
            singleEmail.setToAddresses(new List<String>(apiSettings.Exception_Error_Email__c.split(',')));
        }
        singleEmail.setSubject('CRM Site Exception in Opportunity Validate');
        singleEmail.setHtmlBody('An exception occurred in the Site :\n' + ErrorExceptionMsg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail }); 
    }
}