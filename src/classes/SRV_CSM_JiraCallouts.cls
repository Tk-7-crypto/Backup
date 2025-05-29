/*
 * Description : Service Class to Send Data to the JIRA REST and Get Data from the JIRA REST
 */
public class SRV_CSM_JiraCallouts {
    /* Call REST API with GET method
     * Returns HttpResponse:
     * @url - String to url to request
     */
    public static HttpResponse makeGetCallout(String url) {
        String token = getJiraToken(url);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Basic ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        return res;
    }
    /* Call REST API with POST method
     * Returns HttpResponse:
     * @url - String to url to request
     * JSONString - Post request parameter
     */
    public static HttpResponse makePostCallout(String url, String JSONString) {
        String token = getJiraToken(url);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Basic ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(JSONString);
        HttpResponse res = h.send(req);
        return res;
    }

    /* Call REST API with POST method
     * Returns HttpResponse:
     * @url - String to url to request
     * JSONString - Post request parameter
     */
    public static HttpResponse makePostAttachmentCallout(String url,String fileName, Blob fileBody) {
        String token = getJiraToken(url);
        String boundary = '----------------------------741e90d31eff';
        String header = '--' + boundary + '\n' +
                        'Content-Disposition: form-data; name="file"; filename="' + fileName + '";\n' +
                        'Content-Type: application/octet-stream';

        String footer = '--' + boundary + '--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        while (headerEncoded.endsWith('=')) {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }

        String bodyEncoded = EncodingUtil.base64Encode(fileBody);

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;

            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0, 3) + 'N';
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        }

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('Authorization', 'Basic ' + token);
        req.setHeader('X-Atlassian-Token', 'nocheck');
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setBodyAsBlob(bodyBlob);
        req.setTimeout(120000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    public static String getJiraToken(String url){
        String token = '';
        String base_url = '';
        if (url.indexOf('/rest/api') > -1) {
            base_url = url.split('/rest/api')[0];
        }
        List<CSM_Jira_Config__c> jiraConf= [SELECT token__c FROM CSM_Jira_Config__c WHERE jira_base_url__c =: base_url ];
        if (jiraConf != null && jiraConf.size() >0 ) {
            token = jiraConf[0].token__c;
        }
        return token;
    }
}