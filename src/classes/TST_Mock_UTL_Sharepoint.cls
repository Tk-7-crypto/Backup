public with sharing class TST_Mock_UTL_Sharepoint implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        if(endpoint.startsWith('https://accounts.accesscontrol.windows.net')){
            UTL_Sharepoint.AccessToken objAccessToken = new UTL_Sharepoint.AccessToken();
            objAccessToken.token_type = 'Bearer';
            objAccessToken.expires_in = '28800';
            objAccessToken.not_before = '1564669142';
            objAccessToken.expires_on = '1564698242';
            objAccessToken.resource = '00000003-0000-0ff1-ce00-000000000000/test.sharepoint.com@2b863f8d-1234-5678-9101-16b65591950b';
            objAccessToken.access_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6InU0T2ZORlBId0VCb3NIanRyYXVPYlY4NExuWSIsImtpZCI6InU0T2ZORlBId0VCb3NIanRyYXVPYlY4NExuWSJ9.';
            res.setStatusCode(200);
            res.setBody(JSON.serialize(objAccessToken));
        }
        else if(endpoint.contains('/_api/contextinfo')){
            res.setBody('{"d":{"GetContextWebInformation":{"__metadata":{"type":"SP.ContextWebInformation"},"FormDigestTimeoutSeconds":1800,"FormDigestValue":"0x487504734A4CDC3DDB135C431D6FD6A80A4C33F62EEFD936F8EF0FB1DDFEF1920CF7DA91ACF0266299B683F56C88761693D64E51C26088790FA40F8D04D70CF3,01 Aug 2019 14:31:39 -0000","LibraryVersion":"16.0.9124.1217","SiteFullUrl":"https://test.sharepoint.com","SupportedSchemaVersions":{"__metadata":{"type":"Collection(Edm.String)"},"results":["14.0.0.0","15.0.0.0"]},"WebFullUrl":"https://test.sharepoint.com"}}}');
            res.setStatusCode(200);
        }
        else if(endpoint.contains('/_api/web/folders')){
            res.setStatusCode(201);
            res.setBody('{"d":{"ServerRelativeUrl":"/Shared Documents/test"}}');
        }
        else if(endpoint.contains('Files/add')){
            res.setStatusCode(200);
            res.setBody('{"d":{"ServerRelativeUrl":"/Shared Documents/test/test.pdf"}}');
        }
        else if(endpoint.contains('/$value')){
            res.setStatusCode(200);
            res.setHeader('Content-Disposition','attachment');
            res.setBody('Test Data');
        }
        else if(req.getHeader('X-HTTP-Method') == 'DELETE'){
            res.setStatusCode(200);
        }
        else if(endpoint.contains('client.svc')){
            res.setHeader('WWW-Authenticate', 'Bearer realm="2b863f8d-1234-5678-9101-16b65591950b",client_id="00000003-0000-0ff1-ce00-000000000000",trusted_issuers="00000001-0000-0000-c000-000000000000@*,D3776938-3DBA-481F-A652-4BEDFCAB7CD8@*,https://sts.windows.net/*/,00000003-0000-0ff1-ce00-000000000000@90140122-8516-11e1-8eff-49304924019b",authorization_uri="https://login.windows.net/common/oauth2/authorize"');
            res.setStatusCode(401);
        }
        return res;
    }
}