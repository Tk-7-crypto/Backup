/*
* Version       : 1.0
* Description   : Apex Utility class for CLM Docusign. 
*/ 
public class UTL_CLM_Docusign {
    /**
    * This method Populates Docusign Envelope Recipient Status Map for IQVIA Agreements
    * @param Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> docuSignEnvelopeRecipientStatusMap
    * @param String agreementId
    * @param String evelopeSFID
    * @param HttpResponse response
    */    
    public static void populateIQVIADocuSignEnvelopeRecipientStatusMap(Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> docuSignEnvelopeRecipientStatusMap,
        String agreementId, String evelopeSFID, HttpResponse response) {
        List<IQ_DocuSignEnvelopeRecipientStatus__c>  lstDSEnvelopeRecipientStatus = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();
        Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> recipientGUIDToDocusignRecipientStatus = 
            new Map<String, IQ_DocuSignEnvelopeRecipientStatus__c>();
        Set<String> fields = new Set<String>{'Id', 'RoutingOrder__c', 'Status__c', 'RecipientName__c', 'Email__c', 'EnvelopeParentId__c',
            'RoleName__c', 'SignedDateTime__c','DeliveredDateTime__c', 'DocuSign_Recipient_Id__c'};
        lstDSEnvelopeRecipientStatus = new SLT_IQ_DS_EnvRecipientStatus().getDSEnvelopeRecipientStatusByEnvelopeId(
            evelopeSFID, fields);
        for(IQ_DocuSignEnvelopeRecipientStatus__c docusignRecipientStatus:lstDSEnvelopeRecipientStatus) {
            if(docusignRecipientStatus.DocuSign_Recipient_Id__c != null) {
                recipientGUIDToDocusignRecipientStatus.put(docusignRecipientStatus.DocuSign_Recipient_Id__c.toUpperCase(), docusignRecipientStatus);
            }
        }            
        CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipients = 
            (CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper)JSON.deserialize(response.getBody(),
            CNT_CLM_DocuSignESignature.DocuSignEnvelopeRecipientStatusResponseWrapper.class);
        for(CNT_CLM_DocuSignESignature.Signers signer: docuSignRecipients.signers) {
            IQ_DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus;
            if(recipientGUIDToDocusignRecipientStatus.containsKey(signer.recipientIdGuid != null ? signer.recipientIdGuid.toUpperCase() : null)) {
                docuSignEnvelopeRecipientStatus = recipientGUIDToDocusignRecipientStatus.remove(signer.recipientIdGuid != null ? signer.recipientIdGuid.toUpperCase() : null);
            } else {
                docuSignEnvelopeRecipientStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
            }
            docuSignEnvelopeRecipientStatus.RoutingOrder__c = signer.routingOrder;
            docuSignEnvelopeRecipientStatus.Status__c = (signer.status).capitalize();
            docuSignEnvelopeRecipientStatus.RecipientName__c = signer.name;
            docuSignEnvelopeRecipientStatus.Email__c = signer.email;
            docuSignEnvelopeRecipientStatus.EnvelopeParentId__c = agreementId;
            if(signer.tabs != null) {
                docuSignEnvelopeRecipientStatus.RecipientTab__c = signer.tabs.toString();
                if(signer.tabs.textTabs != null) {
                    if(signer.tabs.textTabs.get(0).name.equals('Title')) {
                        docuSignEnvelopeRecipientStatus.Title__c = signer.tabs.textTabs.get(0).value;
                    }
                }
                if(signer.tabs.companyTabs != null) {
                    docuSignEnvelopeRecipientStatus.Company__c = signer.tabs.companyTabs.get(0).value;
                }
            }
            docuSignEnvelopeRecipientStatus.RoleName__c = signer.roleName;
            docuSignEnvelopeRecipientStatus.SignedDateTime__c = signer.signedDateTime;
            docuSignEnvelopeRecipientStatus.DeliveredDateTime__c = signer.deliveredDateTime;
            docuSignEnvelopeRecipientStatus.DocuSign_Recipient_Id__c = signer.recipientIdGuid != null ? signer.recipientIdGuid.toUpperCase() : null;
            docuSignEnvelopeRecipientStatusMap.put(signer.roleName + signer.routingOrder + signer.email,
                docuSignEnvelopeRecipientStatus);
        }
        for(CNT_CLM_DocuSignESignature.CarbonCopies carbonCopy: docuSignRecipients.CarbonCopies) {
            IQ_DocuSignEnvelopeRecipientStatus__c docuSignEnvelopeRecipientStatus;
            if(recipientGUIDToDocusignRecipientStatus.containsKey(carbonCopy.recipientIdGuid != null ? carbonCopy.recipientIdGuid.toUpperCase() : null)) {
                docuSignEnvelopeRecipientStatus = recipientGUIDToDocusignRecipientStatus.remove(carbonCopy.recipientIdGuid != null ? carbonCopy.recipientIdGuid.toUpperCase() : null);
            } else {
                docuSignEnvelopeRecipientStatus = new IQ_DocuSignEnvelopeRecipientStatus__c();
            }
            docuSignEnvelopeRecipientStatus.RoutingOrder__c = carbonCopy.routingOrder;
            docuSignEnvelopeRecipientStatus.Status__c = (carbonCopy.status).capitalize();
            docuSignEnvelopeRecipientStatus.RecipientName__c = carbonCopy.name;
            docuSignEnvelopeRecipientStatus.Email__c = carbonCopy.email;
            docuSignEnvelopeRecipientStatus.RoleName__c = carbonCopy.roleName;                
            docuSignEnvelopeRecipientStatus.EnvelopeParentId__c = agreementId;
            docuSignEnvelopeRecipientStatus.DocuSign_Recipient_Id__c = carbonCopy.recipientIdGuid != null ? carbonCopy.recipientIdGuid.toUpperCase() : null;
            if(carbonCopy.tabs != null) {
                docuSignEnvelopeRecipientStatus.RecipientTab__c = carbonCopy.tabs.toString();
            }
            docuSignEnvelopeRecipientStatusMap.put(carbonCopy.roleName + carbonCopy.routingOrder + carbonCopy.email,
                docuSignEnvelopeRecipientStatus);
        }
    }
    
     /**
    * This method is used to recall Docusign Envelope if it is in sent status at docusign portal
	* Need to refactor these method where controller classes are used CNT_CLM_AddDocusignRecipient, CNT_CLM_DocuSignESignature 
    * @params  Id agreementId
    * @return  void
    */
    public static void recallEsignature(AgreementWrapper agreementWrapper){
        IQVIA_Agreement__c iqviaAgreement = agreementWrapper.iqviaAgreement;
        List<Log_History__c> lstLogsForError = new List<Log_History__c>();
        String condition = 'Id =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(
            condition, null, iqviaAgreement.DocuSign_Envelope_Id__c, new Set<String>{'Id', 'Name','Status__c', 
            'Docusign_Envelope_Info__c', 'Send_As_User_Email__c', 'RecallReason__c', 'StatusChangeDateTime__c',
            'Signers__c','EnvelopeId__c','Docusign_AccountId__c', 'Docusign_App_Name__c'}, 'CreatedDate', 'DESC', null);
        if(docuSignEnvelopeList.size() > 0 && docuSignEnvelopeList[0].Status__c == CON_CLM.SENT_STATUS){
            try {
                DocuSign_Auth_Data__c docuSignData;
                String consentURL;

                List<DocuSign_Auth_Data__c> docuSignDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(
                    new Set<String>{'Id', 'Base_URL__c', 'Client_Id__c', 'Account_Id__c', 'Name', 'User_Name__c'}, docuSignEnvelopeList[0].Docusign_App_Name__c, 1);
                docuSignData = docuSignDataList.size() > 0 ? docuSignDataList[0] : new DocuSign_Auth_Data__c();
            
                String baseUrl = docuSignData.Base_URL__c+'/restapi/v2/accounts/'+docuSignData.Account_Id__c   ;
                String endPoint = '/envelopes/'+docuSignEnvelopeList[0].name; 
                String method = 'GET';
                string authCode = CNT_CLM_AddDocusignRecipient.getJWTAccessToken(docuSignEnvelopeList[0].Docusign_App_Name__c,
                    docuSignEnvelopeList[0].Send_As_User_Email__c);
                if(authCode != '' && authCode != null){
                    HttpResponse response = CNT_CLM_AddDocusignRecipient.doHttpCallout(baseUrl, endPoint, method, authCode, 
                        null, docuSignEnvelopeList[0].Send_As_User_Email__c);
                    if (response.getStatusCode() == 200) {
                        CNT_CLM_AddDocusignRecipient.EnvelopeWrapper EnvelopeWrapperObj = 
                            (CNT_CLM_AddDocusignRecipient.EnvelopeWrapper)JSON.deserialize(response.getBody(), CNT_CLM_AddDocusignRecipient.EnvelopeWrapper.class);
                        if(EnvelopeWrapperObj.status == CON_CLM.SENT_STATUS || EnvelopeWrapperObj.status == CON_CLM.IQ_DELIVERED_STATUS){
                            recallEsignature(iqviaAgreement, docuSignEnvelopeList[0], docuSignData);
                        } else {
                            updateEnvelope(docuSignEnvelopeList[0], EnvelopeWrapperObj);
                        }
                    } else { 
                        CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper resError = (CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper)JSON.deserialize(
                            response.getBody(), CNT_CLM_AddDocusignRecipient.ResponseErrorWrapper.class);
                        lstLogsForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, resError.message, 'CLM',
                            'Custom', 'ERROR', resError.errorCode, iqviaAgreement.Id));
                    }
                } else {
                    lstLogsForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, 'Error in getting access token...',
                        'CLM', 'Custom', 'ERROR', 'Error in getting access token...', iqviaAgreement.Id));
                }
            } catch(Exception e) {
                CNT_CLM_AddDocusignRecipient.EnvelopeWrapper EnvelopeWrapperObj = new CNT_CLM_AddDocusignRecipient.EnvelopeWrapper();
                EnvelopeWrapperObj.status = CON_CLM.SENT_STATUS;
                updateEnvelope(docuSignEnvelopeList[0], EnvelopeWrapperObj);
                lstLogsForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, e.getMessage(), 'CLM', 'Exception',
                    'ERROR', 'Error in Docusign Recall API', iqviaAgreement.Id));
            }
        }
        CNT_CLM_AddDocusignRecipient.cancelDraftEnvelopes(new List<IQVIA_Agreement__c>{new IQVIA_Agreement__c(Id = iqviaAgreement.Id)});
        if(!lstLogsForError.isEmpty()) {
            try {
                UTL_LogFactory.saveLogs(lstLogsForError, false);
            }
            catch(Exception e) {
                System.debug(e);   
            }
        }
    }
    
    /**
    * This method is used to recall Docusign Envelope
    * @params  Id agreementId
    * @return  void
    */
    public static void recallEsignature(IQVIA_Agreement__c iqviaAgreement, IQ_DocuSignEnvelope__c docuSignEnvelope, 
        DocuSign_Auth_Data__c docuSignIntegrationSettings) {
        fflib_StringBuilder body = new fflib_StringBuilder();
        body.add('{"status": "voided", "voidedReason": "Upload Signed Document action - envelope voided."}');
        String sendAsUserEmail = docuSignIntegrationSettings.User_Name__c;		
        String authCode = CNT_CLM_DocuSignESignature.getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,true);
        HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
            + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR
            + docuSignEnvelope.EnvelopeId__c, 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
        if(response.getStatusCode() == 200) {
            docuSignEnvelope.Status__c = CON_CLM.IQ_VOIDED_STATUS; 
            docuSignEnvelope.RecallReason__c = 'Upload Signed Document action - envelope voided.';
            docuSignEnvelope.StatusChangeDateTime__c = DateTime.now();
            docuSignEnvelope.Signers__c = '';
			docuSignEnvelope.Docusign_Envelope_Info__c = 'Upload Signed Document action - envelope voided.';
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType});
            uow.registerDirty(docuSignEnvelope);
            uow.commitWork();
        }
        else {
            CNT_CLM_DocuSignESignature.ResponseErrorWrapper resError = (CNT_CLM_DocuSignESignature.ResponseErrorWrapper)JSON.deserialize(
                response.getBody(), CNT_CLM_DocuSignESignature.ResponseErrorWrapper.class);
            List<Log_History__c> lstLogsForError = new List<Log_History__c>();
            lstLogsForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, resError.message, 'CLM',
                'Custom', 'ERROR', resError.errorCode, iqviaAgreement.Id));
            try {
                UTL_LogFactory.saveLogs(lstLogsForError, false);
            }
            catch(Exception e) {
                System.debug(e);   
            }
        }
    }
    
    /**
    * This method is used to update Docusign Envelope
    * @params  Id agreementId
    * @return  void
    */
    public static void updateEnvelope(IQ_DocuSignEnvelope__c docuSignEnvelope, CNT_CLM_AddDocusignRecipient.EnvelopeWrapper EnvelopeWrapperObj) {
        if(EnvelopeWrapperObj.status == CON_CLM.SENT_STATUS || EnvelopeWrapperObj.status == CON_CLM.IQ_DELIVERED_STATUS) {
            docuSignEnvelope.Docusign_Envelope_Info__c = 'Upload Signed Document action - envelope voided.';
        } else {
            if(EnvelopeWrapperObj.status == CON_CLM.COMPLETED_STATUS){
                docuSignEnvelope.Status__c = CON_CLM.COMPLETED_STATUS;
            } else if(EnvelopeWrapperObj.status == CON_CLM.DECLINED_STATUS){
                docuSignEnvelope.Status__c = CON_CLM.DECLINED_STATUS;
            } else {
                docuSignEnvelope.Status__c = EnvelopeWrapperObj.status;
            }
            docuSignEnvelope.Docusign_Envelope_Info__c = 'Upload Signed Document action - envelope already ' + EnvelopeWrapperObj.status + '.';
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType});
        uow.registerDirty(docuSignEnvelope);
        uow.commitWork();
    }
    
    /**
    * This method is used to update docusign documents  
    * @param Set<Id> conDocIds
    */
    @future
    public static void updateDocusignDocuments(Set<Id> conDocIds) {
        List<ContentDocument> lstConDoc = new SLT_ContentDocument().selectById(new Set<String>{'Title', 'Description'}, 
            'Id IN: docIds', conDocIds);
        for(ContentDocument conDoc : lstConDoc) {
            if(String.isNotBlank(conDoc.Title) && conDoc.Title.contains('Certificate')) {
                conDoc.Title = CON_CLM.CERT_OF_COMPLETION;
                conDoc.Description = CON_CLM.CERT_OF_COMPLETION;   
            }
            else {
                conDoc.Description = CON_CLM.FINAL_SIGNED_DOCUMENT;
            }
        }         
        if(!lstConDoc.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                    ContentDocument.SObjectType
                });
                uow.registerDirty(lstConDoc);
                uow.commitWork();   
            }
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }    
}