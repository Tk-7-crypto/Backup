public class UTL_Docusign {

    //Get Rest Configuration Setings from Custom Metadata provided as a part of the installation source 
    
    public static  DocuSign_Auth_Data__c docusignAuthData {get; set;}
    
    public static DocuSign_Auth_Data__c getDocusignAuthData(String moduleName){
        if(docusignAuthData == null){
            docusignAuthData = new DocuSign_Auth_Data__c();
            docusignAuthData = [Select Id,Name,User_Name__c,Access_Token__c,Account_Id__c,Base_URL__c,Client_Id__c,DocuSign_Pwd__c,DocusignUser_Id__c,Private_Key__c,Public_Key__c,Docusign_Auth_Body__c,Docusign_Auth_ContentType__c,Docusign_Auth_Endpoint__c,Docusign_Auth_Scope__c from DocuSign_Auth_Data__c where Name =: moduleName limit 1];
        }
        system.debug('docusignAuthData' + docusignAuthData);
        return docusignAuthData;
    }

    //This method will call the DocuSignJWT class to obtain an access token from DocuSign
    public static String getJWTAccessToken(String moduleName) {
        String access_token = null;
        
        //Instantiate a request object
        try {
        HttpRequest req = new HttpRequest();
        //set the request METHOD
        req.setMethod('POST');
        
        //set the request headers
        getDocusignAuthData(moduleName);
        
        //1. Host
        String authRequestDomain = docusignAuthData.Base_URL__c;
        System.Debug(LoggingLevel.INFO, '**authRequestDomain ' + authRequestDomain);
        req.setHeader('Host', authRequestDomain);
        
        //set the request endpoint
        String authRequestEndPoint = docusignAuthData.Docusign_Auth_Endpoint__c;
        req.setEndPoint(authRequestEndPoint);

        //2. Content -type
        String authRequestContentType = docusignAuthData.Docusign_Auth_ContentType__c;
        //System.Debug(LoggingLevel.INFO, '**authRequestContentType ' + authRequestContentType);
        req.setHeader('Content-type', authRequestContentType);

        
        //Body of the request
        String alg = Test.isRunningTest() ? 'none' : 'RS256';
        String iss = docusignAuthData.Client_Id__c;
        String pkey = docusignAuthData.Private_Key__c;
        String scope = docusignAuthData.Docusign_Auth_Scope__c;
        DocuSignJWT jwtObject = new DocuSignJWT(alg, docusignAuthData.DocusignUser_Id__c, iss, pkey, scope, authRequestDomain);
		
		//Set the request body	
        String requestBody = docusignAuthData.Docusign_Auth_Body__c + jwtObject.issue();
        System.Debug(LoggingLevel.INFO, '**RequestAuthBody' + requestBody);
        req.setBody(requestBody);

        //call the service
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.Debug(LoggingLevel.INFO, '**ResponseAuthBody' + res.getbody());
        System.Debug(LoggingLevel.INFO, '**ResponseAuth' + res);
		
	//Obtain the access token from the Response
        if (res.getStatusCode() == 200) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
            
        }catch (Exception ex){
            System.debug(ex.getMessage());
        }
        return access_token;

    }
    

}