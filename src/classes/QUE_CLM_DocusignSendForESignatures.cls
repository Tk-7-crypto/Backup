/**
* This Queueable class is used for the purpose of updating docusign E signatures status
*/ 
public class QUE_CLM_DocusignSendForESignatures implements Queueable, Database.AllowsCallouts {
    String baseUrl;
    IQ_DocuSignEnvelope__c env;   
    String authCode;
    public QUE_CLM_DocusignSendForESignatures(String baseUrl, IQ_DocuSignEnvelope__c env, String authCode) {
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
        HttpResponse docDetailsresponse = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null, userEmail);
        if(docDetailsresponse.getStatusCode() == 401) {
            authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(accId, userEmail);
            docDetailsresponse = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null, userEmail);
        }
        CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper resdocs = 
            (CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper)JSON.deserialize(
                docDetailsresponse.getBody(), CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper.class);
        for(CNT_APTMS_AddDocusignRecipient.envelopeDocuments doc : resdocs.envelopeDocuments) { 
            if(doc.documentId != 'certificate') {
                numOfDocuments++;
            }
        }
        List<HttpResponse> responselist = new List<HttpResponse>();
        for(Integer i = 1; i <= numOfDocuments; i++) {
            HttpResponse response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri + '/' + i, 'GET', authCode, null, userEmail);
            if(response.getStatusCode() == 401) {
                authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
                response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode, null,userEmail);
            }
            responselist.add(response);
        }
        HttpResponse responseCertificate = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl,
            documentUri+ '/' + 'certificate', 'GET', authCode, null,userEmail);
        if(responseCertificate.getStatusCode() == 401) {
            authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
            responseCertificate = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl,
                documentUri, 'GET', authCode, null, userEmail);
        }
        IQ_DocuSignEnvelope__c envelope = env;            
        List<String> docNames = (List<String>)Json.deserialize(envelope.DocumentName__c, List<String>.class);
        Integer documentNameIndex = 0; 
        String docName;
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(HttpResponse rec : responselist) {
            if(rec.getStatusCode() == 200) {
                if(docNames.size() > documentNameIndex){
                    docName = (docNames[documentNameIndex] != null) && (docNames[documentNameIndex] != '') ? docNames[documentNameIndex] : '';
                }else{
                    docName = CON_CLM.CERT_OF_COMPLETION;
                }
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = docName + '.pdf';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = docName.contains('.doc') ? docName.substring(0, docName.indexOf('.doc'))+'.pdf' : docName;
                cVersion.VersionData = rec.getBodyAsBlob();
                cvList.add(cVersion);
            }
            else {
                CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper resError = (CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper)JSON.deserialize(
                    rec.getBody(), CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper.class);
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
                uow.registerNew(cvList);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
            for(ContentVersion rec : cvList) {
                cvIds.add(rec.Id);
            }
            List<ContentVersion> cvNewList = new SLT_ContentVersion().selectById(cvIds);
            List<Apttus__DocumentVersion__c> docVerList = new List<Apttus__DocumentVersion__c>();
            Map<Id, Apttus__DocumentVersion__c> contentVersionIdToDocumentVersionMap = new Map<Id, Apttus__DocumentVersion__c>();
            Map<Id, Apttus__DocumentVersionDetail__c> contentVersionIdToDocumentVersionDetailMap = new Map<Id, Apttus__DocumentVersionDetail__c>();  
            for(ContentVersion cv : cvNewList) {
                Apttus__DocumentVersion__c docVer = new Apttus__DocumentVersion__c();
                docVer.Apttus__Title__c = cv.Title.contains('.') ? cv.Title.substring(0, cv.Title.indexOf('.'))+'.pdf' : cv.Title;
                docVer.Name = CON_CLM.SIGNED_DOCUMENT;
                docVer.Apttus__AgreementId__c = envelope.APTS_Agreement__c;
                docVer.Apttus__LatestVersion__c = '1.0.0';
                docVer.Apttus__DocumentType__c = CON_CLM.EXECUTED_DOCUMENT;
                contentVersionIdToDocumentVersionMap.put(cv.Id, docVer);
            }
            try {  
                fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__DocumentVersion__c.SObjectType
                    }
                );
                uow1.registerNew(contentVersionIdToDocumentVersionMap.values());
                uow1.commitWork();
            }
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }            
            for(ContentVersion cv : cvNewList) {
                if(contentVersionIdToDocumentVersionMap.containsKey(cv.Id))  {
                    Apttus__DocumentVersionDetail__c docVersionDetail = new Apttus__DocumentVersionDetail__c();
                    docVersionDetail.Name = '1.0.0';
                    docVersionDetail.Apttus__Title__c = cv.Title;
                    docVersionDetail.Apttus__DocumentVersionId__c = contentVersionIdToDocumentVersionMap.get(cv.Id).Id;
                    docVersionDetail.Apttus__ContentId__c = cv.ContentDocumentId;
                    docVersionDetail.Apttus__Action2__c = CON_CLM.SIGNED_DOCUMENT;
                    docVersionDetail.Apttus__VersionMajor__c = 1;
                    docVersionDetail.Apttus__VersionMinor__c = 0;
                    docVersionDetail.Apttus__VersionRevision__c = 0;       
                    docVersionDetail.Apttus__IsTransient__c = false;    
                    contentVersionIdToDocumentVersionDetailMap.put(cv.Id, docVersionDetail);
                }
            }
            try {  
                fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__DocumentVersionDetail__c.SObjectType
                    }
                );
                uow2.registerNew(contentVersionIdToDocumentVersionDetailMap.values());
                uow2.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
            for(ContentVersion cv : cvNewList) {
                if(contentVersionIdToDocumentVersionDetailMap.containsKey(cv.Id)) {
                    contentVersionIdToDocumentVersionMap.get(cv.Id).Apttus__LatestVersionId__c = contentVersionIdToDocumentVersionDetailMap.get(cv.Id).Id;
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = cv.ContentDocumentId;
                    cDocLink.LinkedEntityId = contentVersionIdToDocumentVersionDetailMap.get(cv.Id).Id;
                    cDocLink.ShareType = 'I';
                    cDocLink.Visibility = 'InternalUsers';          
                    cdList.add(cDocLink);                      
                }
            }
            try {  
                fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__DocumentVersion__c.SObjectType, ContentDocumentLink.SObjectType
                    }
                );
                uow3.registerDirty(contentVersionIdToDocumentVersionMap.values());
                uow3.registerNew(cdList);
                uow3.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }    
        }
    }
}