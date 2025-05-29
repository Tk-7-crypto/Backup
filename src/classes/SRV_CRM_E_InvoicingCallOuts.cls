/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Service Class to Send Data to the Ebex for E-Invoicing
*/
public class SRV_CRM_E_InvoicingCallOuts {
    
    /**
     * This Method to call rest API for E-invoicing request
     * @params String JSONString
     * @return HttpResponse
     */
    public static HttpResponse makePostCallout(String JSONString) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Sale_Org_Ext');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSONString);
        
        Http http = new Http();
        HTTPResponse response = http.send(req);
        return response;
    }
    
}