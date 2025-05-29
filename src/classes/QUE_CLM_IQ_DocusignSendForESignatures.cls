/**
* This Queueable class is used for the purpose of updating docusign E signatures status
*/ 
public class QUE_CLM_IQ_DocusignSendForESignatures implements Queueable, Database.AllowsCallouts {
    String baseUrl;
    IQ_DocuSignEnvelope__c env;   
    String authCode;
    public QUE_CLM_IQ_DocusignSendForESignatures(String baseUrl, IQ_DocuSignEnvelope__c env, String authCode) {
        this.baseUrl = baseUrl;
        this.env = env;
        this.authCode = authCode;
    }
    
    public void execute(QueueableContext context) { 
        migrateAsCombinedDocument();
    }
    
    /**
    * This method is used for migrating documents and changing status 
    */
    @testVisible
    private void migrateAsCombinedDocument() {  
        Integer numOfDocuments = 0;
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        String userEmail = env.Send_As_User_Email__c;
        String accId = env.Docusign_AccountId__c;
        String documentUri = '/envelopes/' + env.Name + '/documents';  
        HttpResponse docDetailsresponse = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null, userEmail);
        if(docDetailsresponse.getStatusCode() == 401) {
            authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(accId, userEmail);
            docDetailsresponse = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null, userEmail);
        }
        CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper resdocs = 
            (CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper)JSON.deserialize(
                docDetailsresponse.getBody(), CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper.class);
        for(CNT_CLM_AddDocusignRecipient.envelopeDocuments doc : resdocs.envelopeDocuments) { 
            if(doc.documentId != 'certificate') {
                numOfDocuments++;
            }
        }
        List<HttpResponse> responselist = new List<HttpResponse>();
        for(Integer i = 1; i <= numOfDocuments; i++) {
            HttpResponse response = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri + '/' + i, 'GET', authCode, null, userEmail);
            if(response.getStatusCode() == 401) {
                authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
                response = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null,userEmail);
            }
            responselist.add(response);
        }
        HttpResponse responseCertificate = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl,
            documentUri+ '/' + 'certificate', 'GET', authCode, null,userEmail);
        if(responseCertificate.getStatusCode() == 401) {
            authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
            responseCertificate = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl,
                documentUri, 'GET', authCode, null, userEmail);
        }
        IQ_DocuSignEnvelope__c envelope = env;            
        List<String> docNames = (List<String>)Json.deserialize(envelope.DocumentName__c, List<String>.class);
        Integer documentNameIndex = 0; 
        String docName;
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(HttpResponse rec : responselist) {
            if(rec.getStatusCode() == 200) {
                ContentVersion cVersion = new ContentVersion();
                if(docNames.size() > documentNameIndex){
                    docName = (docNames[documentNameIndex] != null) && (docNames[documentNameIndex] != '') ? docNames[documentNameIndex] : '';
                    cVersion.Description = CON_CLM.FINAL_SIGNED_DOCUMENT;
                }else{
                    docName = CON_CLM.CERT_OF_COMPLETION;
                    cVersion.Description = CON_CLM.CERT_OF_COMPLETION;
                }
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = docName + '.pdf';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = docName.contains('.doc') ? docName.substring(0, docName.indexOf('.doc'))+'.pdf' : docName;
                cVersion.VersionData = rec.getBodyAsBlob();
                cvList.add(cVersion);
            }
            else {
                CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper resError = (CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper)JSON.deserialize(
                    rec.getBody(), CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper.class);
            }
            documentNameIndex++; 
        }
        if(cvList.size() > 0) {
            Set<Id> cvIds = new Set<Id>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        ContentVersion.SObjectType
                    }
                );
                system.debug(cvList);
                uow.registerNew(cvList);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
            for(ContentVersion rec : cvList) {
                cvIds.add(rec.Id);
                system.debug('cvidsss'+cvIds);
            }
            List<ContentVersion> cvNewList = new SLT_ContentVersion().selectById(cvIds);           
            for(ContentVersion cv : cvNewList) {
				ContentDocumentLink cDocLink = new ContentDocumentLink();
				cDocLink.ContentDocumentId = cv.ContentDocumentId;
				cDocLink.LinkedEntityId = env.Agreement__c;
				cDocLink.ShareType = 'I';
				cDocLink.Visibility = 'InternalUsers';          
				cdList.add(cDocLink);                                    
            }
            try {  
                fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                ContentDocumentLink.SObjectType
                    }
                );
                uow3.registerNew(cdList);
                uow3.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }    
        }
    }
}