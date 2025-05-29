/**
 * @description Batch Class created to get latest Signed Documents from DocuSign to CLM IQVIA
 */
public class BCH_CLM_GetDocumentFromDocuSign implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Database.RaisesPlatformEvents{  
    String documentUri;
    String sEnvelopeId; 
    String baseUrl;
    String authCode;
    String userEmail;
    String agreementId;
    String accId;
    Integer numOfDocuments;
    
    public BCH_CLM_GetDocumentFromDocuSign(String documentUri, String sEnvelopeId, String baseUrl, String authCode,  String agreementId,String accId, String userEmail){
        this.documentUri = documentUri;
        this.sEnvelopeId = sEnvelopeId;
        this.baseUrl = baseUrl;
        this.authCode = authCode;
        this.userEmail = userEmail;
        this.agreementId = agreementId;
        this.accId = accId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, DocumentName__c, Agreement__c, Agreement__r.OwnerId FROM IQ_DocuSignEnvelope__c WHERE Id =:sEnvelopeId');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
		numOfDocuments=0;            
		HttpResponse docDetailsResponse = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, 
			documentUri, 'GET', authCode, null,userEmail);
		if(docDetailsResponse.getStatusCode() == 401) {
			authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
			docDetailsResponse = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, documentUri, 'GET', authCode,
				null,userEmail);
		}
		CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper resDocs = 
			(CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper)JSON.deserialize(
			docDetailsResponse.getBody(), CNT_CLM_AddDocusignRecipient.envelopeDocumentsResponseWrapper.class);
		for(CNT_CLM_AddDocusignRecipient.envelopeDocuments doc: resDocs.envelopeDocuments)
		{  if(doc.documentId != 'certificate')
			numOfDocuments++;
		}
		List<HttpResponse> responselist = new List<HttpResponse>();
		for(integer i=1;i<=numOfDocuments; i++) {
			HttpResponse response = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, 
				documentUri+ '/' + i, 'GET', authCode, null,userEmail);
			if(response.getStatusCode() == 401) {
				authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(accId,userEmail);
				response = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl,
					documentUri, 'GET', authCode, null, userEmail);
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
		responselist.add(responseCertificate); 
		
		IQ_DocuSignEnvelope__c envelope = (IQ_DocuSignEnvelope__c)scope[0];            
		List<string> docNames = (List<string>)Json.deserialize(envelope.DocumentName__c, List<string>.class);
		Integer docmentNameIndex=0;
		String docName;
		List<ContentVersion> cvList = new List<ContentVersion>();
		for(HttpResponse rec: responselist) {
			if (rec.getStatusCode() == 200) {
                ContentVersion cVersion = new ContentVersion();
				if(docNames.size() > docmentNameIndex){
					docName = (docNames[docmentNameIndex] != null) && (docNames[docmentNameIndex] != '') ? 
						docNames[docmentNameIndex] : '';
                    cVersion.Description = CON_CLM.FINAL_SIGNED_DOCUMENT;
				}
				else {
					docName = CON_CLM.CERT_OF_COMPLETION;
                    cVersion.Description = CON_CLM.CERT_OF_COMPLETION;
				}
				cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
				cVersion.PathOnClient = docName+'.pdf';
				cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
				cVersion.OwnerId = UserInfo.getUserId();//envelope.Agreement__r.OwnerId;//Owner of the file
				cVersion.Title = docName.contains('.doc') ? docName.substring(0, docName.indexOf('.doc'))+'.pdf' : docName;
				cVersion.VersionData = rec.getBodyAsBlob();//File content  
				cvList.add(cVersion);
			}
			else {
				CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper resError = (CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper)JSON.deserialize(
					rec.getBody(), CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper.class);
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
			
			for(string cvDoc: cvDocIds) {
				ContentDocumentLink cDocLink = new ContentDocumentLink();
				cDocLink.ContentDocumentId = cvDoc;//Add ContentDocumentId
				cDocLink.LinkedEntityId = envelope.Agreement__c;//Add attachment parentId
				cDocLink.ShareType = 'I';//V – Viewer permission. C – Collaborator permission. I – Inferred permission.
				cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
				cdlList.add(cDocLink);
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
                CNT_CLM_AddDocusignRecipient.authCode = authCode;                
            }
        }
    }
}