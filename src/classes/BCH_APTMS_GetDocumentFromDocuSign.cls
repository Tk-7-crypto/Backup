/**
 * @description Batch Class created to get latest Signed Documents from DocuSign to Conga CLM
 */
public class BCH_APTMS_GetDocumentFromDocuSign implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents{  
    String documentUri;
    String sEnvelopeId; 
    String baseUrl;
    String authCode;
    String userEmail;
    String agreementId;
    String accId;
    Integer numOfDocuments;
    
    public BCH_APTMS_GetDocumentFromDocuSign(String documentUri, String sEnvelopeId, String baseUrl, String authCode,  String agreementId,String accId, String userEmail){
        this.documentUri = documentUri;
        this.sEnvelopeId = sEnvelopeId;
        this.baseUrl = baseUrl;
        this.authCode = authCode;
        this.userEmail = userEmail;
        this.agreementId = agreementId;
        this.accId = accId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, DocumentName__c, APTS_Agreement__c, APTS_Agreement__r.OwnerId FROM IQ_DocuSignEnvelope__c WHERE Id =:sEnvelopeId');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Boolean enableDocumentVersioning =  Apttus__ComplySystemProperties__c.getValues('System Properties').Apttus__EnableDocumentVersioning__c; 
        numOfDocuments=0;            
        HttpResponse docDetailsResponse = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, 
            documentUri, 'GET', authCode, null,userEmail);
        if(docDetailsResponse.getStatusCode() == 401) {
            authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
            docDetailsResponse = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode,
                null,userEmail);
        }
        CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper resDocs = 
            (CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper)JSON.deserialize(
            docDetailsResponse.getBody(), CNT_APTMS_AddDocusignRecipient.envelopeDocumentsResponseWrapper.class);
        for(CNT_APTMS_AddDocusignRecipient.envelopeDocuments doc: resDocs.envelopeDocuments)
        {  if(doc.documentId != 'certificate')
            numOfDocuments++;
        }
        List<HttpResponse> responselist = new List<HttpResponse>();
        for(integer i=1;i<=numOfDocuments; i++) {
            HttpResponse response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl, 
                documentUri+ '/' + i, 'GET', authCode, null,userEmail);
            if(response.getStatusCode() == 401) {
                authCode = CNT_APTMS_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
                response = CNT_APTMS_AddDocusignRecipient.doHttpCallout(baseUrl,
                    documentUri, 'GET', authCode, null, userEmail);
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
        responselist.add(responseCertificate); 
        
        IQ_DocuSignEnvelope__c envelope = (IQ_DocuSignEnvelope__c)scope[0];            
        List<string> docNames = (List<string>)Json.deserialize(envelope.DocumentName__c, List<string>.class);
        Integer docmentNameIndex=0;
        String docName;
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(HttpResponse rec: responselist) {
            if (rec.getStatusCode() == 200) {
                if(docNames.size() > docmentNameIndex){
                    docName = (docNames[docmentNameIndex] != null) && (docNames[docmentNameIndex] != '') ? 
                        docNames[docmentNameIndex] : '';
                }
                else {
                    docName = CON_CLM.CERT_OF_COMPLETION;
                }
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                cVersion.PathOnClient = docName+'.pdf';
                cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                cVersion.OwnerId = UserInfo.getUserId();//envelope.APTS_Agreement__r.OwnerId;//Owner of the file
                cVersion.Title = docName.contains('.doc') ? docName.substring(0, docName.indexOf('.doc'))+'.pdf' : docName;
                cVersion.VersionData = rec.getBodyAsBlob();//File content            
                cvList.add(cVersion);
            }
            else {
                CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper resError = (CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper)JSON.deserialize(
                    rec.getBody(), CNT_APTMS_AddDocusignRecipient.ResponseErrorWrapper.class);
            }
            docmentNameIndex++; 
        }
        if(cvList.size()>0) {
            List<string> cvDocIds = new List<string>();
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
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
            for(ContentVersion rec: cvList) {
                cvIds.add(rec.Id);
            }
            List<ContentVersion> cvNewList = new SLT_ContentVersion().selectById(cvIds);
            for(ContentVersion rec: cvNewList) {
                cvDocIds.add(rec.ContentDocumentId);
            }
            if(!enableDocumentVersioning) {
                for(string cvDoc: cvDocIds) {
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = cvDoc;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = envelope.APTS_Agreement__c;//Add attachment parentId
                    cDocLink.ShareType = 'I';//V – Viewer permission. C – Collaborator permission. I – Inferred permission.
                    cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
                    cdlList.add(cDocLink);
                }
            } else { 
                List<Apttus__DocumentVersion__c> docVerList = new List<Apttus__DocumentVersion__c>();
                for(ContentVersion cv : cvNewList) {
                    Apttus__DocumentVersion__c docVer = new Apttus__DocumentVersion__c();
                    docVer.Apttus__Title__c = cv.Title;
                    docVer.Name = CON_CLM.SIGNED_DOCUMENT;
                    docVer.Apttus__AgreementId__c = envelope.APTS_Agreement__c;
                    docVer.Apttus__LatestVersion__c = '1.0.0';
                    docVer.Apttus__DocumentType__c = CON_CLM.EXECUTED_DOCUMENT;
                    try {  
                        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                            new Schema.SObjectType[] {
                                Apttus__DocumentVersion__c.SObjectType
                            }
                        );
                        uow1.registerNew(docVer);
                        uow1.commitWork();
                    } catch(DMLException dmlExp) {
                        System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                    }
                    
                    Apttus__DocumentVersionDetail__c docVersionDetail = new Apttus__DocumentVersionDetail__c();
                    docVersionDetail.Name = '1.0.0';
                    docVersionDetail.Apttus__Title__c = cv.Title;
                    docVersionDetail.Apttus__DocumentVersionId__c = docVer.Id;
                    docVersionDetail.Apttus__ContentId__c = cv.ContentDocumentId;
                    docVersionDetail.Apttus__Action2__c = CON_CLM.SIGNED_DOCUMENT;
                    docVersionDetail.Apttus__VersionMajor__c = 1;
                    docVersionDetail.Apttus__VersionMinor__c = 0;
                    docVersionDetail.Apttus__VersionRevision__c =0;
                    docVersionDetail.Apttus__IsTransient__c = false;
                    try {  
                        fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
                            new Schema.SObjectType[] {
                                Apttus__DocumentVersionDetail__c.SObjectType
                            }
                        );
                        uow2.registerNew(docVersionDetail);
                        uow2.commitWork();
                    } catch(DMLException dmlExp) {
                        System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                    }
                    docVer.Apttus__LatestVersionId__c = docVersionDetail.Id;
                    
                    docVerList.add(docVer);
                    
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = cv.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = docVersionDetail.Id;//Add attachment parentId
                    cDocLink.ShareType = 'I';//V – Viewer permission. C – Collaborator permission. I – Inferred permission.
                    cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers                
                    cdlList.add(cDocLink);                        
                }
                try {  
                    fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            Apttus__DocumentVersion__c.SObjectType
                        }
                    );
                    uow3.registerDirty(docVerList);
                    uow3.commitWork();
                } catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }              
            }
            try {  
                fflib_SObjectUnitOfWork uow4 = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        ContentDocumentLink.SObjectType
                    }
                );
                uow4.registerNew(cdlList);
                uow4.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        //Create a new envelope and receipient using the newly pulled Signed documents from DocuSign
        if( (numOfDocuments!=0 && numOfDocuments !=null) || test.isRunningTest()) {
            List<contentDocumentLink> agrCDLlist = new SLT_ContentDocumentLink().getCDLByLinkedEntityWithLimitAndOrder(
                new Set<String>{'Id', 'ContentDocumentId'}, new Set<Id>{agreementId}, numOfDocuments,
                'ContentDocument.CreatedDate');
            if(agrCDLlist.size() >0) {
                Set<Id> agrContendIds = new Set<Id>();
                for(contentDocumentLink rec: agrCDLlist ) {
                    agrContendIds.add(rec.ContentDocumentId);
                }
                String condition = 'ContentDocumentId IN :docIds AND IsLatest = true';
                list<ContentVersion> agrCVList = new SLT_ContentVersion().getContentVersions(condition, agrContendIds);
                CNT_APTMS_AddDocusignRecipient.authCode = authCode;                
            }
        }
    }
}