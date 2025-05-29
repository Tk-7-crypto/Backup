public with sharing class UTL_TPA_Class_LoginAPI {

    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';
    public static string serverURL = '';

    public static String login(String user, String password) {
            try
            {
               HttpRequest req = new HttpRequest();
                req.setMethod('POST');   
                req.setTimeout(60000);
                req.setEndpoint(UTL_TPA.apiURL);
                req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
                req.setHeader('SOAPAction', '""');
                req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>');        
                HttpResponse res =  new Http().send(req);
                if(res.getStatusCode() != 200)
                {
                    Dom.Document responseDocument = res.getBodyDocument();
                    Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
                    Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
                    Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
                    Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring          
                //    throw new LoginException(faultStringElm.getText()); 
                }
                Dom.Document responseDocument = res.getBodyDocument();
                Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
                Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
                Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
                Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
                Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
                Dom.Xmlnode serverUrlElm = resultElm.getChildElement('serverUrl', NS_SF); // serverUrl
                UTL_TPA_Class_LoginAPI.serverUrl = serverUrlElm.getText();
                return sessionIdElm.getText();
        
            }
            catch(Exception ex)
            {
            return '';
            }
        }

         public class LoginException extends Exception {}
}