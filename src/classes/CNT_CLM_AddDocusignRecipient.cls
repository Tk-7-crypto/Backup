/**
 * @description Docusign Recipient controller class
 */
public class CNT_CLM_AddDocusignRecipient {
    public static Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> docuSignEnvelopeRecipientStatusMap;
    public static string authCode;
    public static Boolean isFieldEmpty = true;
    /**
    * This method is used to Post Agreement Effective date to DocuSign when External signature is complete and Internal signature is Inprogress
    * @params  Id agreementId
    * @return  ESignatureResponseWrapper
    */
    @AuraEnabled
    public static ESignatureResponseWrapper addDocuSignRecipient(Id agreementId){
        String jobId = '';
        String errorMsg = '';

        String condition = 'Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, 
            null, agreementId, new Set<String>{'Id', 'Name','Status__c','NumberOfDocuments__c','Send_As_User_Email__c','Docusign_AccountId__c', 'Docusign_App_Name__c'}, 'CreatedDate', 'DESC', null);

        if(docuSignEnvelopeList.size() > 0 && docuSignEnvelopeList[0].Status__c == CON_CLM.SENT_STATUS){
            DocuSign_Auth_Data__c docuSignData;
            String consentURL;

            List<DocuSign_Auth_Data__c> docuSignDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 'Base_URL__c', 'Client_Id__c', 'Account_Id__c', 'Name'}, docuSignEnvelopeList[0].Docusign_App_Name__c, 1);
            docuSignData = docuSignDataList.size() > 0 ? docuSignDataList[0] : new DocuSign_Auth_Data__c();
            
            String baseUrl = docuSignData.Base_URL__c+'/restapi/v2/accounts/'+docuSignData.Account_Id__c   ;
            String endPoint = '/envelopes/'+docuSignEnvelopeList[0].name; 
            String method = 'GET';
            authCode = getJWTAccessToken(docuSignEnvelopeList[0].Docusign_App_Name__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
            if(authCode != '' && authCode != null){
                HttpResponse response = doHttpCallout(baseUrl, endPoint, method, authCode, null, docuSignEnvelopeList[0].Send_As_User_Email__c);
                if(response.getStatusCode() == 401){
                    authCode = getJWTAccessToken(docuSignEnvelopeList[0].Docusign_App_Name__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
                    response = doHttpCallout(baseUrl, endPoint, method, AuthCode, null,docuSignEnvelopeList[0].Send_As_User_Email__c);
                }
                if (response.getStatusCode() == 200) {
                    EnvelopeWrapper EnvelopeWrapperObj = (EnvelopeWrapper)JSON.deserialize(response.getBody(), EnvelopeWrapper.class);
                    if(EnvelopeWrapperObj.status == CON_CLM.COMPLETED_STATUS){
                        completeSentEnvelope(agreementId, docuSignEnvelopeList[0].name, baseUrl, docuSignEnvelopeList[0].Id,
                            docuSignEnvelopeList[0].Docusign_App_Name__c, docuSignEnvelopeList[0].Send_As_User_Email__c,false);
                        String endPointdoc= '/envelopes/'+docuSignEnvelopeList[0].name+'/documents';                 
                        if(!Test.isRunningTest())
                        { 
                            BCH_CLM_GetDocumentFromDocuSign btcjob = new BCH_CLM_GetDocumentFromDocuSign(endPointdoc, docuSignEnvelopeList[0].Id, baseUrl, authCode, agreementId, docuSignEnvelopeList[0].Docusign_AccountId__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
                            jobId = database.executeBatch(btcjob);
                        }                                           
                    }else if(EnvelopeWrapperObj.status == CON_CLM.DECLINED_STATUS){
                        declineSentEnvelope(agreementId, docuSignEnvelopeList[0].name, baseUrl, docuSignEnvelopeList[0].Id,
                            docuSignEnvelopeList[0].Docusign_App_Name__c, docuSignEnvelopeList[0].Send_As_User_Email__c);
                    } else if(EnvelopeWrapperObj.status == CON_CLM.SENT_STATUS){
                        completeSentEnvelope(agreementId, docuSignEnvelopeList[0].name, baseUrl, docuSignEnvelopeList[0].Id,
                            docuSignEnvelopeList[0].Docusign_App_Name__c, docuSignEnvelopeList[0].Send_As_User_Email__c,true);
                    } else if(EnvelopeWrapperObj.status == CON_CLM.IQ_VOIDED_STATUS){
                        voidSentEnvelope(agreementId, docuSignEnvelopeList[0].Id, EnvelopeWrapperObj);
                    }
                } else { 
                    errorMsg = 'The status code returned was not expected: ' + response.getStatusCode();
                }
            }else {
                errorMsg = 'ERROR: Error in getting access token...';
            }                        
        }
        CNT_CLM_AddDocusignRecipient.cancelDraftEnvelopes(new List<IQVIA_Agreement__c>{new IQVIA_Agreement__c(Id = agreementId)});
        if(errorMsg != null && errorMsg != ''){
            return new ESignatureResponseWrapper('', 'FAILED',errorMsg, isFieldEmpty);
        }else{
            return new ESignatureResponseWrapper(jobId, 'SUCCESS', '', isFieldEmpty);
        } 
    }
    
    /**
    * This method is used to update envelope status to completed and add envelope recipients to it.
    * @params  String agreementId
    * @params  String envelopeId
    * @params  String baseUrl
    * @params  String evelopeSFID
    * @params  String accountId
    * @params  String userEmail
    * @return  void
    */
    public static void completeSentEnvelope(String agreementId, String envelopeId, String baseUrl, String evelopeSFID,
            String accountId, String userEmail, Boolean updateOnlyRecipientStatus){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                IQ_DocuSignEnvelopeRecipientStatus__c.SObjectType,
                IQ_DocuSignEnvelope__c.SObjectType
            }
        );
        createOrUpdateDocuSignEnvelopeRecipientStatus(agreementId, envelopeId, baseUrl, evelopeSFID, accountId, userEmail);
        if(!updateOnlyRecipientStatus) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
            docuSignEnvelope.Id = evelopeSFID;
            docuSignEnvelope.Status__c = CON_CLM.COMPLETED_STATUS;
            if(docuSignEnvelope != null) {
                uow.registerDirty(docuSignEnvelope);
            }
        }
        
        for(String key: docuSignEnvelopeRecipientStatusMap.keySet()){
            if(docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c == null) {
                docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c = evelopeSFID;
            }
        }
        if(docuSignEnvelopeRecipientStatusMap.values() != null) {
            uow.registerUpsert(docuSignEnvelopeRecipientStatusMap.values());
        }
        IQVIA_Agreement__c agr = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id','Name',
            'Company_Signed_Date__c', 'Other_Party_Signed_Date__c','Other_Party_Does_Not_Need_To_Sign__c'});
		if(!updateOnlyRecipientStatus && ((!agr.Other_Party_Does_Not_Need_To_Sign__c 
            && (agr.Other_Party_Signed_Date__c != null && agr.Company_Signed_Date__c != null) 
            ||(agr.Other_Party_Does_Not_Need_To_Sign__c && agr.Company_Signed_Date__c != null)))){
            isFieldEmpty = false;
		}

        uow.commitWork();       
    } 
    
    /**
    * This method is used to decline sent envelope
    * @params  String agreementId
    * @params  String envelopeId
    * @params  String baseUrl
    * @params  String evelopeSFID
    * @params  String accountId
    * @params  String userEmail
    * @return  void
    */
    public static void declineSentEnvelope(String agreementId, String envelopeId, String baseUrl, String evelopeSFID,
            String accountId, String userEmail){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                IQ_DocuSignEnvelopeRecipientStatus__c.SObjectType,
                IQ_DocuSignEnvelope__c.SObjectType
            }
        );
        createOrUpdateDocuSignEnvelopeRecipientStatus(agreementId, envelopeId, baseUrl, evelopeSFID, accountId, userEmail);
        for(String key: docuSignEnvelopeRecipientStatusMap.keySet()){
            if(docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c == null) {
                docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c = evelopeSFID;
            }
        }
        if(docuSignEnvelopeRecipientStatusMap.values() != null) {
            uow.registerUpsert(docuSignEnvelopeRecipientStatusMap.values());
        }
        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Id = evelopeSFID;
        docuSignEnvelope.Status__c = CON_CLM.DECLINED_STATUS;
        if(docuSignEnvelope != null) {
            uow.registerDirty(docuSignEnvelope);
        }
        uow.commitWork();
    } 
    
    /**
    * This method is used to void sent envelope
    * @params  String agreementId
    * @params  String evelopeSFID
    * @return  void
    */
    public static void voidSentEnvelope(String agreementId, String evelopeSFID, EnvelopeWrapper EnvelopeWrapperObj){
        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        docuSignEnvelope.Id = evelopeSFID;
        docuSignEnvelope.Status__c = CON_CLM.IQ_VOIDED_STATUS; 
        docuSignEnvelope.RecallReason__c = EnvelopeWrapperObj.voidedReason.stripHtmlTags();
        docuSignEnvelope.StatusChangeDateTime__c = DateTime.now();
        docuSignEnvelope.Signers__c = '';
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType});
        uow.registerDirty(docuSignEnvelope);
        uow.commitWork();
    }
    
    /**
    * This method is used to create Recipients for an Envelope 
    * @params  String agreementId
    * @params  String envelopeId
    * @params  String baseUrl
    * @params  String accountId
    * @params  String userEmail
    * @return  void
    */
    public static void createOrUpdateDocuSignEnvelopeRecipientStatus(String agreementId, String envelopeId, String baseUrl, 
            String evelopeSFID, String accountId, String userEmail){
        docuSignEnvelopeRecipientStatusMap = new Map<String, IQ_DocuSignEnvelopeRecipientStatus__c>();
        HttpResponse response = doHttpCallout(baseUrl, '/envelopes/'+envelopeId+'/recipients?include_tabs=true', 'GET', authCode, null,userEmail);
        if(response.getStatusCode() == 401 ||test.isRunningTest()){
            authCode = getJWTAccessToken( accountId, userEmail);
            response = doHttpCallout(baseUrl, '/envelopes/'+envelopeId+'/recipients', 'GET', authCode, null,userEmail);
        }
        if (response.getStatusCode() == 200) {
            UTL_CLM_Docusign.populateIQVIADocuSignEnvelopeRecipientStatusMap(docuSignEnvelopeRecipientStatusMap, agreementId, evelopeSFID,
                response);
        } else{
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
        }
    }
    
    /**
    * This method is used to cancel Draft envelopes of agreements
    * @params  List<IQVIA_Agreement__c> agreements
    * @return  void
    */
    public static void cancelDraftEnvelopes(List<IQVIA_Agreement__c> agreements){
        Set<id> agreementIds = new Set<Id>();
        for(IQVIA_Agreement__c agreement: agreements) {
            agreementIds.add(agreement.Id);
        }
        String condition = 'Agreement__c =: agreementIds And Status__c = \'Draft\'';
        Set<String> fieldSet = new Set<String>{'Id', 'Status__c'};
        List<IQ_DocuSignEnvelope__c> docusignEnvelopes = new SLT_IQDocuSignEnvelope().
            getDocusignEnvelopeByConditionAndAgreementIds(condition, agreementIds, fieldSet);
        for(IQ_DocuSignEnvelope__c envelope: docusignEnvelopes) {
            envelope.Status__c = CON_CLM.CANCELLED;
        }
        if(!docusignEnvelopes.isEmpty()){
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType});
                uow.registerDirty(docusignEnvelopes);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }    
    
    /**
    * This method is generic function for callouts
    * @params  String baseUrl
    * @params  String endPoint
    * @params  String method
    * @params  String authCode
    * @params  String body
    * @params  String userEmail
    * @return  void
    */
    public static HttpResponse doHttpCallout(String baseUrl, String endPoint, String method, String authCode, String body, String userEmail){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl + endPoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer '+ authCode);
        request.setHeader('X-DocuSign-Act-As-User', userEmail);
        request.setTimeout(120000);
        if(method == 'POST' || method == 'PUT'){
            request.setBody(body);
        }
        HttpResponse response = http.send(request);
        return response;
    }
    
    /**
    * This method is generic function to fetch Saved or a New Access Token
    * @params  String accId
    * @params  String userEmail
    * @return  String
    */
    public static String getJWTAccessToken(String accId,String userEmail) {        
        DocuSign_Auth_Data__c docuSignIntegrationSettings;
        List<DocuSign_Auth_Data__c> DocuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 'Base_URL__c', 'Client_Id__c','Account_Id__c','DocusignUser_Id__c','Private_Key__c', 'Name'}, accId, 1);
        docuSignIntegrationSettings = DocuSignAccountSettingList.size() > 0 ? DocuSignAccountSettingList[0] : new DocuSign_Auth_Data__c();
        String authBaseUrl = (docuSignIntegrationSettings.Base_URL__c).contains('demo') ? 'account-d.docusign.com' : 'account.docusign.com' ;
        String access_token = null;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint('https://'+authBaseUrl+'/oauth/token');
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', authBaseUrl);
        String alg = Test.isRunningTest() ? 'none' : 'RS256';
        String iss = docuSignIntegrationSettings.Client_Id__c;
        String pkey = docuSignIntegrationSettings.Private_Key__c;
        String duserId = docuSignIntegrationSettings.DocusignUser_Id__c;
        String scope = 'signature impersonation';
        DocuSignJWT jwtObject = new DocuSignJWT(alg,duserId, iss, pkey, scope,authBaseUrl);
        
        String requestBody = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwtObject.issue();
        req.setBody(requestBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
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
        return access_token;
    }
    
    @AuraEnabled
    public static ApexJobWrapper getBatchCurrentStatus(String batchId){
        AsyncApexJob aj = new SLT_AsyncApexJob().getJobFieldsForId(batchId, new Set<String>{'ExtendedStatus', 'Status', 'JobItemsProcessed', 'TotalJobItems', 'NumberOfErrors'});
        return new ApexJobWrapper(aj.ExtendedStatus, aj.Status, aj.JobItemsProcessed, aj.TotalJobItems, aj.NumberOfErrors);
    }

    public class ApexJobWrapper{
        @AuraEnabled
        public string extendedStatus {get; set;}
        @AuraEnabled
        public string status {get; set;}
        @AuraEnabled
        public integer jobItemsProcessed {get; set;}
        @AuraEnabled
        public integer totalJobItems {get; set;}
        @AuraEnabled
        public integer numberOfErrors {get; set;}
        
        public ApexJobWrapper(string extendedStatus, string status, integer jobItemsProcessed, integer totalJobItems, integer numberOfErrors){
            this.extendedStatus = extendedStatus;
            this.status = status;
            this.jobItemsProcessed = jobItemsProcessed;
            this.totalJobItems = totalJobItems;
            this.numberOfErrors = numberOfErrors;
        }
    }

    public class EnvelopeWrapper {  
        public String allowMarkup;
        public String autoNavigation;
        public String brandId;
        public String certificateUri;
        public String createdDateTime;
        public String customFieldsUri;
        public String documentsCombinedUri;
        public String documentsUri;
        public String emailSubject;
        public String enableWetSign;
        public String envelopeId;
        public String envelopeIdStamping;
        public String envelopeUri;
        public String initialSentDateTime;
        public String is21CFRPart11;
        public String isSignatureProviderEnvelope;
        public String lastModifiedDateTime;
        public String notificationUri;
        public String purgeState;
        public String recipientsUri;
        public String sentDateTime;
        public String status;
        public String statusChangedDateTime;
        public String templatesUri;
        public String voidedReason;
    }       
    
    public class DocuSignEnvelopeRecipientStatusResponseWrapper {
        public List<Signers> signers;
        public List<CarbonCopies> carbonCopies;
        public String recipientCount;
        public String currentRoutingOrder;
    }
  
    public class Signers {
        public String creationReason;
        public String isBulkRecipient;
        public String name;
        public String email;
        public String recipientId;
        public String recipientIdGuid;
        public String requireIdLookup;
        public String userId;
        public String routingOrder;
        public String roleName;
        public String status;
        public DateTime signedDateTime;
        public DateTime deliveredDateTime;
        public Tabs tabs;
    }
    public class TextTabs {
        public String name;
        public String value;
    }
    public class CompanyTabs {
        public String value;
    }
    public class Tabs {
        public List<TextTabs> textTabs;
        public List<CompanyTabs> companyTabs;  
    }

    public class CarbonCopies {
        public String name;
        public String email;
        public String recipientId;
        public String recipientIdGuid;
        public String requireIdLookup;
        public String userId;
        public String routingOrder;
        public String roleName;
        public String status;
    }

    public class ResponseErrorWrapper{        
        public string errorCode;
        public string message;        
    }    

    public class envelopeDocumentsResponseWrapper {
        public List<envelopeDocuments> envelopeDocuments;       
        public String envelopeId;
    }

    public class envelopeDocuments {
        public String documentId;
        public String name;
        public String order;
        public String uri;
    }
    
    public class ESignatureResponseWrapper{
        @AuraEnabled
        public string batchId {get; set;}
        @AuraEnabled
        public string status {get; set;}
        @AuraEnabled
        public string message {get; set;}
        @AuraEnabled
        public Boolean isFieldEmpty {get; set;}       
        public ESignatureResponseWrapper(string batchId, string status, string message, boolean isFieldEmpty){
            this.batchId = batchId;
            this.status = status;
            this.message = message;
            this.isFieldEmpty = isFieldEmpty;
        }
    }
}