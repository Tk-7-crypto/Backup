public class CNT_DevOps_EmailVerificationInfo {

    @AuraEnabled(cacheable=true) 
    public static boolean isEmailVerified(){
        Boolean hasUserVerifiedEmail = false; 
        try {    
            System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());    
            Unverfied_User_Email_Settings__c devOpsSettings = Unverfied_User_Email_Settings__c.getValues('IQVIA');  
            if((d.getSandboxName() == null || d.getSandboxName() == devOpsSettings.Sandbox_Name__c ) 
                && devOpsSettings.Sandbox_ClientID__c != '' && devOpsSettings.Sandbox_Client_Secrate__c != '' && 
                devOpsSettings.Username__c != '' && devOpsSettings.PasswordWithToken__c != '' &&
                devOpsSettings.Salesforce_EndPointName__c != '' && devOpsSettings.Salesforce_TokenEndPoint__c != '') {                  
                HttpRequest req = new HttpRequest();            
                req.setEndpoint(devOpsSettings.Salesforce_TokenEndPoint__c);      
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                String body = 'grant_type=password' +
                    '&client_id=' + devOpsSettings.Sandbox_ClientID__c +
                    '&client_secret=' + devOpsSettings.Sandbox_Client_Secrate__c +
                    '&username=' + devOpsSettings.Username__c +
                    '&password=' + devOpsSettings.PasswordWithToken__c; 
                req.setBody(body);            
                Http http = new Http();
                HTTPResponse res = http.send(req);
                if (res.getStatusCode() == 200 && res.getBody() != null) {                            
                    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                
                    string accessToken = (String)results.get('access_token');
                    HttpRequest req2;
                    req2 = new HttpRequest(); 
                    req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    req2.setHeader('Authorization', 'Bearer '+accessToken);                                 
                    String query= 'SELECT+Id,HasUserVerifiedEmail+FROM+User+WHERE+Profile.Name+NOT+IN+(\'TPA+Customer+Community+Plus+Login+User\',+\'TPA+Vendor+Community+User\',+\'PRM+Community+User\',+\'Partner+Community+User\',+\'PEP+Community+User\',+\'Partner+Community+Login+User\',+\'CSM+Config+Community+Profile\',+\'CSM+Customer+Community+Plus+Login+User\',+\'testcommunity+Profile\',+\'Customer+Community+Plus+Login+User\')+AND+Id=\''+UserInfo.getUserId()+'\'+LIMIT+1';

                    req2.setEndpoint(devOpsSettings.Salesforce_EndPointName__c+'query/?q='+query);
                    req2.setMethod('GET');
                    HTTPResponse resp = http.send(req2);                
                    Map<String,Object> jsonMAP = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    Integer totalSize=(Integer)jsonMAP.get('totalSize');
                    if(totalSize>0){
                        List<Object> recordMap = (List<Object>) jsonMAP.get('records');
                        Map<String,Object> res2 = (Map<String,Object>)recordMap[0];
                        hasUserVerifiedEmail = (Boolean)res2.get('HasUserVerifiedEmail');                 
                        return !hasUserVerifiedEmail;
                    }
                }
            }
        } catch(Exception ex) {
            throw ex;
        }
        return hasUserVerifiedEmail;
    }

    @AuraEnabled
    public static Map<string,Object> sendVerificationMail(String userEmail){
        Map<String,Object> returnMapOfSuccesAndFaliure = new Map<String,Object>();
        User user = [Select Id, Email from User Where Id=:UserInfo.getUserId() Limit 1 ];
        try {
            if(user.email != userEmail){
                Unverfied_User_Email_Settings__c devOpsSettings = Unverfied_User_Email_Settings__c.getValues('IQVIA');        
                HttpRequest req = new HttpRequest();            
                req.setEndpoint(devOpsSettings.Salesforce_TokenEndPoint__c);        
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                String body = 'grant_type=password' +
                    '&client_id=' + devOpsSettings.Sandbox_ClientID__c +
                    '&client_secret=' + devOpsSettings.Sandbox_Client_Secrate__c +
                    '&username=' + devOpsSettings.Username__c +
                    '&password=' + devOpsSettings.PasswordWithToken__c;         

                req.setBody(body);            
                Http http = new Http();
                HTTPResponse res = http.send(req);
                if (res.getStatusCode() == 200) {                                 
                    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                    
                    string accessToken = (String)results.get('access_token'); 
                    HttpRequest req2;
                    req2 = new HttpRequest(); 
                    req2.setEndpoint(devOpsSettings.Salesforce_EndPointName__c+'sobjects/User/'+user.Id);
                    req2.setHeader('Authorization', 'Bearer '+accessToken);
                    req2.setHeader('Content-Type', 'application/json');       
                    req2.setMethod('PATCH');
                    String body2 = '{"Email": "' + userEmail + '"}';
                    req2.setBody(body2);
                    HTTPResponse resp = http.send(req2);                    
                    if (resp.getStatusCode() == 200) {                        
                        returnMapOfSuccesAndFaliure.put('success','Verification mail sent Succesfully');
                    } else {
                        returnMapOfSuccesAndFaliure.put('error','Following error for sending the verification email:  ' + resp.getStatus());
                    }
                }
            } else if(user.email == userEmail){
                System.UserManagement.sendAsyncEmailConfirmation(user.Id, null, null, null);
                returnMapOfSuccesAndFaliure.put('success','Verification mail sent Succesfully');
            }
        } catch(Exception ex) {
            returnMapOfSuccesAndFaliure.put('error','Following error for sending the verification email:  ' + ex.getMessage());
        }
        return returnMapOfSuccesAndFaliure;
    }
}