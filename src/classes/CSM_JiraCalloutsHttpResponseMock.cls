@isTest
global class CSM_JiraCalloutsHttpResponseMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if( req.getEndpoint().contains('/comment')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"comments":[{"id":"1", "body":"aBody","author":{"displayName":"author"},"updateAuthor":{"displayName":"updateAuthor"},"created":"2019-01-07T08:48:34.791+0100","updated":"2019-01-07T08:48:34.791+0100"}]}');
            res.setStatusCode(200);
        }else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"key":"TestJiraKey","fields":{"summary":"test","description":"test","created":"2019-01-07T08:48:34.791+0100","updated":"2019-01-07T08:48:34.791+0100","issuetype":{"name":"IssuetypeName"},"status":{"name":"aStatus"},"priority":{"name":"aPriority"},"reporter":{"displayName":"reporter"},"assignee":{"displayName":"assignee"},"fixVersions":[{"name":"fixVersion"}],"customfield_16646":null,"customfield_14510":{"value":"country"},"customfield_14511":{"value":"customer"}, "customfield_14449":"2020-11-20T10:39:22.553+0100","customfield_10340":["val,val,val,name=Sprint"] }, "changelog":{"histories":[{"created":"2020-11-20T10:39:22.553+0100","items":[{"field":"Sprint"}]}]}}');
            res.setStatusCode(200);
        }
        return res;
    }
}