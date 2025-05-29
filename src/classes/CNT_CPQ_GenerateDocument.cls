public class CNT_CPQ_GenerateDocument {
    @AuraEnabled
    public static String getAvailableTemplate(String recordId, String objectAPIName, String pricingTools) {
        Set<String> pricingToolSet = new Set<String>();
        Set<String> templateNameSet = new Set<String>();
        String documentNames = '';
        List<CPQ_Mapping_Field_Set__mdt> cpqTemplateList = new List<CPQ_Mapping_Field_Set__mdt>();
        for (String pricingTool : pricingTools.split(';')) {
             pricingToolSet.add(pricingTool);
        }
        if (pricingToolSet.size() > 0) {
            cpqTemplateList = [SELECT Id, Pricing_Tool__c, Template_Name__c, Document_Formats__c FROM CPQ_Mapping_Field_Set__mdt WHERE Pricing_Tool__c IN : pricingToolSet AND Feature_Selection__c = 'Document Generation'];
        }
        if (cpqTemplateList.size() > 0 ) {
            for (CPQ_Mapping_Field_Set__mdt templateName : cpqTemplateList) {
                for (String tPname : templateName.Template_Name__c.split(';')) {
                     templateNameSet.add(tPname);
                }
            }
            if (templateNameSet.size() > 0) {
                for (String templateNames : templateNameSet) {
                     documentNames += templateNames + ',';
                } 
            }
            return documentNames.substring(0, documentNames.length()-1);
        } else {
            return CON_CPQ.FAILED;  
        }
    }

    @AuraEnabled
    public static String generateDocument(String templateName, Id recordId, String objectAPIName, String format) {
        Id templateId;
        if (!String.isBlank(templateName)) {
            templateId = [SELECT Id FROM Apttus__APTS_Template__c WHERE NAME =: templateName LIMIT 1].Id;
        }
        CPQ_Settings__c cpqs = [SELECT Id, Name, Client_Id__c, Client_Secret__c FROM CPQ_Settings__c LIMIT 1];
        String sessionId = getAccessToken(cpqs.Client_Id__c, cpqs.Client_Secret__c);
        if (sessionId.contains(CON_CPQ.ERROR)) {
            return sessionId;
        }
        return generateRequest(templateId, sessionId, recordId, objectAPIName, format);
    }

    public static String getAccessToken(String clientId, String clientSecret) {
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl() + '/services/oauth2/token?grant_type=client_credentials&client_id=' + clientId + '&client_secret=' + clientSecret);
            req.setMethod('POST');
            HttpResponse res = h.send(req);
            while (res.getStatusCode() == 302) {
                req.setEndpoint(res.getHeader('Location'));
                res = new Http().send(req);
            }
            Object result = JSON.deserializeUntyped(res.getBody());
            Map<String, Object> resultMap = (Map<String, Object>)result;
            String accessToken = (String)resultMap.get('access_token');
            return accessToken;
        } catch(Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }
    
    public static String generateRequest(Id templateId, String sessionId, Id recordId, String objectAPIName, String format) {
        string serverUrl = '';
        String contentDocumentId;
        try {
            if (!Test.isRunningTest()) {  
                serverUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/50.0/' + UserInfo.getOrganizationId();
                contentDocumentId = Apttus.MergeWebService.generateCustomDoc(templateId, recordId, objectAPIName, 'Full access', format, false, sessionId, serverUrl);
            }
        } catch(Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
        return contentDocumentId;
    }

    @AuraEnabled
    public static Quote__c getPricingTools(String recordId) {
        Quote__c quote = new SLT_IQVIA_Quote().getQuoteDetails(recordId);
        return quote;
    }

    @AuraEnabled
    public static Boolean updateContentDocuments(List<String> generatedDocuments){
        try {
            List<ContentDocument> contentDocuments = new List<ContentDocument>();
            if (!generatedDocuments.isEmpty()) {
                for (ContentDocument contentDocument : [SELECT Title, Description FROM ContentDocument WHERE Id IN: generatedDocuments]) {
                    contentDocument.Title = CON_CPQ.DRAFT_PREFIX + '_' + contentDocument.Title;
                    contentDocument.Description = CON_CPQ.DRAFT_PREFIX;
                    contentDocuments.add(contentDocument);
                }
                if (!contentDocuments.isEmpty()) {
                    update contentDocuments;
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}