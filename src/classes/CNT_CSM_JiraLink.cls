/*
 * Author: Fabien Delief
 * Purpose: This class mainly allows to interact with the jira api rest
 */
public with sharing class CNT_CSM_JiraLink {
    /*
     * Returns the values from picklit of  CSM_QI_JiraLink__c custom field
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getJiraBaseUrls(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = CSM_QI_JiraLink__c.jira_base_url__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getValue());
        }
        return options;
    }

    /*
     * Return list of CSM_QI_JiraLink__c SObject using SOQL for a given record ID (return 1 value)
     */
    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_JiraLink__c> getJiraLink(String recordId) {
        return new SLT_JiraLink().selectByCaseId(new Set<Id> {recordId});
    }

    /* Call REST API with GET method
     * Returns String Array:
     * return String[0] - the status code of HTTP response
     * return String[1] - the response body (JSON format)
     * @url - String to url to request
     */
    @AuraEnabled
    public static String[] getCalloutResponseContents(String url) {
        HttpResponse res = SRV_CSM_JiraCallouts.makeGetCallout(url);
        String [] result = new String[2];
        result[0]=res.getStatusCode()+'';
        result[1]=res.getBody();
        return result;
    }

    /* Call REST API with POST method
     * Returns String Array with
     * return String[0] - the status code of HTTP response
     * return String[1] - the response body (JSON format)
     * @url - String to url to request
     * JSONString - Post request parameter
     */
    @AuraEnabled(cacheable=true)
    public static String[] postCalloutResponseContents(String url, String JSONString) {
        HttpResponse res = SRV_CSM_JiraCallouts.makePostCallout(url, JSONString);
        String [] result = new String[2];
        result[0]=res.getStatusCode()+'';
        result[1]=res.getBody();
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String[] postAttachmentCalloutResponseContents(String url,String contentDocumentId) {
        ContentVersion attach =[SELECT PathOnClient, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true];
        HttpResponse res = SRV_CSM_JiraCallouts.makePostAttachmentCallout(url,attach.PathOnClient,attach.VersionData);
        String [] result = new String[2];
        result[0]=res.getStatusCode()+'';
        result[1]=res.getBody();
        return result;
    }
/*
    public static String authenticateAndGetCookie(String jiraBaseUrl) {
        HttpResponse res = SRV_CSM_JiraCallouts.makePostCallout(jiraBaseUrl +'/rest/auth/1/session', '');
        String cookie = res.getHeader('Set-Cookie');
        return cookie;
    }

    @AuraEnabled(cacheable=true)
    public static String getAttachmentCalloutResponseContents(String url) {
        String cookie = authenticateAndGetCookie('https://jiraims.rm.imshealth.com');
        System.debug('cookie: '+ cookie);
        HttpResponse res = SRV_CSM_JiraCallouts.makeGetCalloutWithCookie(url, cookie);
        if (res.getStatusCode() == 200) {
            System.debug('Response Content Type: ' + res.getHeader('Content-Type'));
            System.debug('Response Blob Size: ' + res.getBodyAsBlob().size());
            String responseBody = res.getBody();
            return responseBody;
        } else {
            System.debug('Error downloading attachment. Status code: ' + res.getStatusCode());
            return null;
        }
    }
*/
    @AuraEnabled
    public static void deleteContentDocumentById(String contentDocumentId){
        ContentDocument cd = New ContentDocument (Id=contentDocumentId);
        delete cd;
    }

    /*
     * Return List of Cases using SOQL for a given case ID
     */
    @AuraEnabled
    public static List<Case> getCase(String caseId){
        //return new SLT_Case().selectById(new Set<Id> { caseId });
        return new SLT_Case().selectByCaseIdList(new Set<Id> { caseId },new Set<String> {'Account.Name','Account.AccountCountry__c','Subject','Description','PSACode__c'});
    }

    /*
     * Update Jira issue in case object
     */
    @AuraEnabled
    public static void updateCaseJiraIssue(String caseId, String jiraIssue){
        List<Case> c = new List<Case>();
        c = new SLT_Case().selectById(new Set<Id> { caseId });
        c[0].Jira_Issue__c = jiraIssue;
        update c[0];
    }

    @AuraEnabled
    public static void insertCaseComments(List<FeedItem> caseComments){
        try{
            insert caseComments;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String getCountryLabelByCode(String codeCountry){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get('AccountCountry__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            if(pickListVal.getValue()==codeCountry){
                return pickListVal.getLabel();
            }
        }
        return '';
    }

    /**
     * This method used to upsert a List<JiraLinkComments>
     * @params List<Object> jiraLinkComments
     */
    @AuraEnabled
    public static List<CSM_QI_JiraLinkComment__c> upsertJiraLinkComments(String jsonJiraComments) {
        List<CSM_QI_JiraLinkComment__c> jlclToUpdate = new List<CSM_QI_JiraLinkComment__c>();
        List<CSM_QI_JiraLinkComment__c> newJiraComments = new List<CSM_QI_JiraLinkComment__c>();
        List<JiraComment> jiraComments = (List<JiraComment>) JSON.deserialize(jsonJiraComments, List<JiraComment>.Class);
        CSM_QI_JiraLinkComment__c jlc;
        List<CSM_QI_JiraLinkComment__c> jlcl;
        for (JiraComment jc : jiraComments) {
            jlcl = new List<CSM_QI_JiraLinkComment__c>();
            jlcl = [select Id, Source__c from CSM_QI_JiraLinkComment__c where JiraCommentId__c =: jc.id and JiraLink__c =: jc.jiraLinkId];
            if (jlcl.size() > 0){
                jlc = jlcl[0];
            }else{
                jlc = new CSM_QI_JiraLinkComment__c();
            }
            jlc.Body__c = jc.body;
            jlc.JiraCommentId__c = jc.id;
            jlc.JiraCommentCreatedDate__c = jc.created;
            jlc.JiraCommentUpdatedDate__c = jc.updated;
            jlc.JiraLink__c = jc.jiraLinkId;
            if(jlc.Source__c != 'CSM') {
                jlc.Author__c = jc.author;
                jlc.Source__c = 'JIRA';
            }
            jlc.UpdateAuthor__c = jc.updateAuthor;
            jlc.Restricted__c = jc.restricted;

            jlclToUpdate.add(jlc);
        }
        try{
            List<Id> comId = new List<Id>();
            Database.UpsertResult[] upsertResults = Database.upsert(jlclToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                if (result.isSuccess() && result.isCreated()) {
                    comId.add(result.getId());
                }
            }
            if (comId.size() > 0 ){
                newJiraComments = [select JiraCommentCreatedDate__c, Body__c,Author__c, JiraLink__r.jira_key__c, JiraLink__r.jira_base_url__c from CSM_QI_JiraLinkComment__c where Restricted__c = false and Id IN : comId];
            }
            return newJiraComments;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void saveJiraCommentFromCSM(String jiraCommentId, String jiraLinkId){
        CSM_QI_JiraLinkComment__c jlc = new CSM_QI_JiraLinkComment__c();
        jlc.JiraLink__c = jiraLinkId;
        jlc.Author__c = UserInfo.getName();
        jlc.JiraCommentId__c = jiraCommentId;
        jlc.Source__c = 'CSM';
        try{
            insert jlc;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

    }

    @AuraEnabled
    public static List<CSM_QI_JiraLinkComment__c> getJiraLinkComments(String jiraLinkId ) {
        List<CSM_QI_JiraLinkComment__c> jlcl = new List<CSM_QI_JiraLinkComment__c>();
        jlcl = [select Id, JiraCommentId__c,  JiraLink__c, Body__c, Author__c, JiraCommentCreatedDate__c, JiraCommentUpdatedDate__c, UpdateAuthor__c, Source__c from CSM_QI_JiraLinkComment__c where JiraLink__c =: jiraLinkId order by JiraCommentCreatedDate__c desc];
        return jlcl;
    }

    private final static Integer MAX_RESULTS = 5;
    @AuraEnabled(Cacheable=true)
    public static List<UTL_LookupSearchResult> searchUsers(String searchTerm) {
        searchTerm += '*';
        List<List<SObject> > searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
            User(Id, Name)
            LIMIT :MAX_RESULTS
        ];
        List<UTL_LookupSearchResult> results = new List<UTL_LookupSearchResult>();
        String userIcon = 'standard:user';
        for (User user: (List<User>) searchResults[0]) {
            results.add(
                new UTL_LookupSearchResult(
                    user.Id,
                    'User__c',
                    userIcon,
                    user.Name,
                    'User'
                    )
                );
        }
        results.sort();
        return results;
    }

    public class JiraComment {
        @AuraEnabled
        public String body {get; set;}
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public Datetime created {get; set;}
        @AuraEnabled
        public Datetime updated {get; set;}
        @AuraEnabled
        public String jiraLinkId {get; set;}
        @AuraEnabled
        public String author {get; set;}
        @AuraEnabled
        public String updateAuthor {get; set;}
        @AuraEnabled
        public Boolean restricted {get; set;}
    }
}
