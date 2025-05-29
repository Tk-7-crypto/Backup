public class CNT_CLM_DocuSignESignature {
    public static Map<String, IQ_DocuSignEnvelopeRecipientStatus__c> docuSignEnvelopeRecipientStatusMap = new Map<String, IQ_DocuSignEnvelopeRecipientStatus__c>();
    public static Boolean accessTokenChanged = false;
    public static String errorList = '';
    public static Cache.SessionPartition sessionPartiton = Cache.Session.getPartition('local.CLM');
    private static String docusignUserId;

    /**
    * This method returns user on the basis of Id
    * @return User
    */
    @AuraEnabled 
    public static User fetchUser() {
        User usr = SLT_User.getUsersByUserIds(new List<Id>{userInfo.getUserId()})[0];
        return usr;
    }   
    
    /**
    * This method is used to get documents on the basis of agreementId
    * @param String agreementId
    * @return List<AttachmentWrapper>
    */ 
    @AuraEnabled
    public static List<AttachmentWrapper> getAllDocuments(String agreementId) {
        List<AttachmentWrapper> attachmentList = new List<AttachmentWrapper>();
        List<ContentVersion> contVrsnList =  new List<ContentVersion>();      
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
        Set<String> contDocIds = new Set<String>();
        lstContentDocumentLink = new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(new Set<Id>{agreementId});
        for(ContentDocumentLink cdl : lstContentDocumentLink) {  
            contDocIds.add(cdl.ContentDocumentId);
        }
        contVrsnList = new SLT_ContentVersion().getContentVersionFromDocumentId(contDocIds, new Set<String>{'Id','ContentModifiedBy.Name',
            'ContentModifiedDate', 'ContentSize', 'FileExtension', 'FileType', 'Title', 'Description', 'ContentDocumentId'});
        for(ContentVersion cvsn : contVrsnList) {
            if(cvsn.FileType != 'SNOTE') {
                String fileName = cvsn.Title;
                String docType = cvsn.Description;
                if(!cvsn.FileExtension.equalsIgnoreCase(fileName.substringAfterLast('.'))) {
                    fileName = cvsn.Title +'.'+cvsn.FileExtension;
                }
                attachmentList.add(new AttachmentWrapper(cvsn.id, fileName, cvsn.ContentModifiedDate, String.valueOf(cvsn.ContentSize),cvsn.ContentModifiedBy.Name, docType, false)); 
            }  
        }
        return AttachmentList;
    }
    
    /**
    * This method returns EmailDataWrapper on the basis of EmailTemplate DeveloperName  
    * @param String agreementId
    * @param String emailTemplateName
    * @return EmailDataWrapper
    */ 
    @AuraEnabled
    public static EmailDataWrapper getEmailTemplateExecutedBody(String agreementId, String emailTemplateName) {
        List<EmailTemplate> etList = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(emailTemplateName, new Set<String>{'Id', 'Subject'});
        String emailBody = null;
        String subject = null;
        EmailDataWrapper edw = new EmailDataWrapper();
        if(etList != null && !etList.isEmpty()) {
            Messaging.SingleEmailMessage res = Messaging.renderStoredEmailTemplate(etList[0].Id, UserInfo.getUserId(), agreementId);
            if(res.getHtmlBody() != null) {
                emailBody = res.getHtmlBody();
            } else if(res.getPlainTextBody() != null) {
                emailBody = res.getPlainTextBody(); 
            }
            if(etList[0].Subject != null) {
                subject = res.getSubject();
            }
            edw = new EmailDataWrapper(subject, emailBody);
        }
        return edw;
    }

    /**
    * This method returns wrapper ESignatureResponseWrapper 
    * @param String selectedAttJSON
    * @param String selectedSignersJSON
    * @param String emailSubject
    * @param String emailBlurb
    * @param String agreementId
    * @param String reminderAndExp
    * @param String sendAsUserEmail
    * @return ESignatureResponseWrapper
    */
    @AuraEnabled
    public static ESignatureResponseWrapper previewEnvelopeWithRecipents(String selectedAttJSON, String selectedSignersJSON, 
        String emailSubject, String emailBlurb, String agreementId, String reminderAndExp, String sendAsUserEmail) {
        errorList = '';        
        Set<Id> selectedAttIds = (Set<Id>)JSON.deserialize(selectedAttJSON, Set<Id>.class);
        List<ContentVersion> selectedAttList = new SLT_ContentVersion().getContentVersionByIds(selectedAttIds, new Set<String>{'Id', 'ContentSize'});
        List<DocuSignRecipientsWrapper> selectedSignersList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(selectedSignersJSON, List<DocuSignRecipientsWrapper>.class);
        ReminderAndExpWrapper reminderAndExpRec = (ReminderAndExpWrapper)JSON.deserialize(reminderAndExp, ReminderAndExpWrapper.class);
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails((Id)agreementId, new Set<String>{'Id', 'Name', 
            'Docusign_Account_Id__c', 'FF_Agreement_Number__c', 'Status__c', 'Status_Category__c'});
        Integer totalBodyLength = 0;
        Integer totalBodyLengthInKb = 0;
        Integer batchSize = 1;
        String batchId;
        for(ContentVersion att : selectedAttList) {    
            totalBodyLength = totalBodyLength + att.ContentSize;
        }
        totalBodyLengthInKb = totalBodyLength / 1024;
        if(totalBodyLengthInKb > 10000) {
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAIL, CON_CLM.ATTACHMENT_LENGTH_ERROR_MSG);
        }
        else {
            try {
                String Key = 'docusignUserId'+sendAsUserEmail;
                Key = Key.replaceAll('[^a-zA-Z0-9\\s+]', '');
                String docusignUserId = (String)sessionPartiton.get(Key);
                batchId = Database.executeBatch(new BCH_CLM_DocuSignESignatureBatch(CON_CLM.IQ_ENVELOPE_STATUS_CREATED, emailSubject, 
                    emailBlurb, selectedAttList, selectedSignersList, agreement, reminderAndExpRec, sendAsUserEmail, docusignUserId), batchSize);
            }
            catch(Exception e) {
                errorList += e.getmessage();
                System.debug('Exception :'+e.getMessage()+' ::: '+e.getStackTraceString()+' recordId::'+agreementId);                
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAIL, e.getMessage());
            }            
            return new ESignatureResponseWrapper(batchId, CON_CLM.STATUS_SUCCESS, 'PREVIEW');
        }            
    }
    
    /**
    * This method constructs the request body for the DocuSign API call
    * @param Boolean isRunningFromBatch 
    * @param String envelopeStatus
    * @param String emailSubject
    * @param String emailBlurb
    * @param List<ContentVersion> selectedAttachments
    * @param List<DocuSignRecipientsWrapper> selectedRecipients
    * @param IQVIA_Agreement__c agreement
    * @param ReminderAndExpWrapper reminderAndExpRec
    * @param String sendAsUserEmail
    * @return ESignatureResponseWrapper 
    */ 
    public static ESignatureResponseWrapper doDocuSignCallout(Boolean isRunningFromBatch, String envelopeStatus, String emailSubject, 
        String emailBlurb, List<ContentVersion> selectedAttachments, List<DocuSignRecipientsWrapper> selectedRecipients, 
        IQVIA_Agreement__c agreement, ReminderAndExpWrapper reminderAndExpRec, String sendAsUserEmail, String docusignUserId) {
        List<EmailTemplateWrapper> templateWrapperList = getEmailTemplateNames(agreement.Id);
        EmailDataWrapper emailData = getEmailTemplateExecutedBody(agreement.Id,templateWrapperList[0].externalDefault);
        Integer emailSubjectDefaultSize = 100;
        Integer emailSubjectMaxLength = emailSubjectDefaultSize - (agreement.FF_Agreement_Number__c.length() + 1);
        String emailBody = '';
        fflib_StringBuilder body = new fflib_StringBuilder();
        String roleName = null;
        Integer recipientGccSize = 0;
        Integer riIndex = 1;
        Set<Id> attSet = new Set<Id>();
        String accId = agreement.Docusign_Account_Id__c;
        List<DocuSignRecipientsWrapper> recipientsList = new List<DocuSignRecipientsWrapper>();
        String emailSubjectInfo = emailSubject;
        if(!String.isBlank(emailSubjectInfo)) {
            emailSubject = createEmailSubject(emailSubject, agreement.FF_Agreement_Number__c);
        }else {
            emailSubject = emailData.subject;//'Request for eSignatures'; 
        }    
        if(!String.isBlank(emailBlurb)) {
            emailBody = emailBlurb;
        }else {
            if(!String.isBlank(emailData.body)) {
                emailBody = emailData.body;//'You are requested to Review/Sign the attached Document'; 
            }
        }      
        body.add('{"status":"' + envelopeStatus + '", "emailSubject":"' + emailSubject + '", "emailBlurb":"' + emailBody + '","sendAsUserEmail":"'
            + sendAsUserEmail + '","showSendAsAnotherUser": true,');
        for(ContentVersion att : selectedAttachments) {
            attSet.add(att.Id);
        }
        body.add('"documents":[');
        String documentName = '[';        
        Integer docOrder = 1;
        Boolean firstRecord = true;
        for(ContentVersion att : [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion WHERE Id IN: attSet]) {
            if(!firstRecord) {
                body.add(',');
            }
            firstRecord = false;
            String fileExtension = String.isNotBlank(att.FileExtension) ? att.FileExtension : 'pdf';
            String fileName = att.title;
            body.add('{"name":"' + fileName + '","fileExtension": "' + fileExtension + '","documentId":"' + docOrder + '","documentBase64":"'
                + EncodingUtil.base64Encode(att.VersionData) + '"}');
            documentName += '"' + fileName + '",';
            docOrder++;
        }
        documentName = documentName.substring(0, documentName.length()-1);
        body.add('],');
        documentName += ']';
        body.add('"notification": { "useAccountDefaults": "false", "reminders": { "reminderEnabled": "true", ');
        body.add('"reminderDelay": "' + reminderAndExpRec.reminderDelay + '","reminderFrequency": "' + reminderAndExpRec.reminderFrequency + '" }, ');
        body.add('"expirations": { "expireEnabled": "true","expireAfter": "' + reminderAndExpRec.expireAfter + '","expireWarn": "' + reminderAndExpRec.expireWarn+'" } },');
        body.add('"recipients":{');
        for(DocuSignRecipientsWrapper recipient : selectedRecipients) {
            if(String.isBlank(recipient.SigningOrder)) {
                recipientGccSize++;
                recipient.SigningOrder = String.valueOf(recipientGccSize);
            } else {                
                Integer finalRecipientGccSize = Integer.valueOf(recipient.SigningOrder);
                recipient.SigningOrder = String.valueOf(finalRecipientGccSize);
            }
            recipient.RecipientId = String.valueOf(riIndex);                        
            riIndex = riIndex + 1;
            if(!String.isBlank(emailSubjectInfo)) {
                recipient.EmailSubject = emailSubjectInfo;
                recipient.EmailBody = emailBlurb;
            }
            recipientsList.add(recipient);
        }
        body.add(createSignerJSONForDocusign(recipientsList, roleName, emailSubject, emailBody, riIndex));
        if(docusignUserId != null) {
            CNT_CLM_DocuSignESignature.docusignUserId = docusignUserId;
        }
        String authCode = getJWTAccessToken(accId,sendAsUserEmail,false);
        return getResponseForPropOwner(authCode, body, selectedRecipients, agreement, documentName, selectedAttachments, isRunningFromBatch, sendAsUserEmail, envelopeStatus);
    }
    
    /**
    * This method creates the emailSubject with agreement number
    * @param String emailSubject
    * @param String agreementNumber
    * @return String
    */
    public static String createEmailSubject(String emailSubject, String agreementNumber) {
        Integer emailSubjectDefaultSize = 100;
        Integer emailSubjectMaxLength = emailSubjectDefaultSize - (agreementNumber.length() + 1);
        if(emailSubject.length() > emailSubjectMaxLength) {
            emailSubject = emailSubject.substring(0,emailSubjectMaxLength) + '-' + agreementNumber;
        }
        else {
            emailSubject = emailSubject + '-' + agreementNumber;
        } 
        return emailSubject;
    }
    
    /**
    * This method creates Signer JSON for Docusign
    * @param List<DocuSignRecipientsWrapper> recipientsList
    * @param String roleName
    * @param String emailSubject
    * @param String emailBody
    * @param Integer riIndex
    * @return String
    */ 
    public static String createSignerJSONForDocusign(List<DocuSignRecipientsWrapper> recipientsList, String roleName, String emailSubject, 
        String emailBody, Integer riIndex) {
        String body = '';
        String recipientBodySigners = '"signers":[';       
        String recipientBodyCarbonCopies = '"carbonCopies":[';
        String recipientBodyCertifiedDeliveries = '"certifiedDeliveries":['; 
        Integer count = 0;    
        List<DocuSignRecipientsWrapper> selectedRecipientsFiltered = new List<DocuSignRecipientsWrapper>();
        Map<String,List<DocuSignRecipientsWrapper>> orderedMap = new Map<String,List<DocuSignRecipientsWrapper>>();
        Set<Integer> setOfIQVIA = new Set<Integer>();
        Set<Integer> setOfContact = new Set<Integer>();
        for(DocuSignRecipientsWrapper recipient : recipientsList) {  
            if(recipient.RecipientId == null || recipient.RecipientId == '') {
                recipient.RecipientId = String.valueOf(riIndex);                        
                riIndex = riIndex + 1;
            } 
            selectedRecipientsFiltered.add(recipient);
            if(!orderedMap.containsKey(recipient.SigningOrder)) {
                orderedMap.put(recipient.SigningOrder, new List<DocuSignRecipientsWrapper>());
            } 
            orderedMap.get(recipient.SigningOrder).add(recipient);
        }
       
        for(Integer i=1; i < selectedRecipientsFiltered.size()+1; i++) {
            if(orderedMap.containsKey(String.valueOf(i))) {
                for(DocuSignRecipientsWrapper recipient : orderedMap.get(String.valueOf(i))) {
                    emailSubject = recipient.emailSubject;
                    emailBody = recipient.emailBody;
                    count++;
                    if(roleName != null) {
                        recipient.RecipientType = roleName;
                    }            
                    if(CON_CLM.RECIPIENT_TYPE_SIGNER.equalsIgnoreCase(recipient.RecipientType)) {  
                        Integer signerNumber = null;
                        if(recipient.userType == CON_CLM.IQVIA_USER_CONTACT_TYPE) {
                            if(setOfIQVIA.isEmpty()) {
                                signerNumber = 1;
                                setOfIQVIA.add(1);
                            }
                            else {
                                signerNumber = setOfIQVIA.size() + 1;
                                setOfIQVIA.add(signerNumber);
                            }
                        }
                        if(recipient.userType == CON_CLM.AGREEMENT_CONTACT_TYPE_CONTACT) {
                            if(setOfContact.isEmpty()) {
                                signerNumber = 4;
                                setOfContact.add(4);
                            }
                            else {
                                signerNumber = setOfContact.size() + 4;
                                setOfContact.add(signerNumber);
                            }
                        }
                        recipientBodySigners += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.ROLENAME_STR 
                            + recipient.RecipientType + CON_CLM.RECIPIENTID_STR + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder
                            + CON_CLM.NOTE_STR + CON_CLM.EMAIL_NOTIFICATION_STR + emailSubject + CON_CLM.EMAIL_BODY_STR + emailBody + '"}'  
                            + UTL_CLM.setTabPositionByAnchorForDocusign(signerNumber, signerNumber, recipient.privateMessage);                
                    }
                    else if(CON_CLM.RECIPIENT_TYPE_CC.equalsIgnoreCase(recipient.RecipientType)) {
                        recipientBodyCarbonCopies += CON_CLM.EMAIL_STR+recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.ROLENAME_STR + recipient.RecipientType 
                            + CON_CLM.RECIPIENTID_STR + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + CON_CLM.NOTE_STR
                            + CON_CLM.EMAIL_NOTIFICATION_STR + recipient.EmailSubject + CON_CLM.EMAIL_BODY_STR + recipient.EmailBody+'"}},';                                
                    }
                    else if(CON_CLM.RECIPIENT_TYPE_CERTIFIED_DELIVERY.equalsIgnoreCase(recipient.RecipientType)) {
                        recipientBodyCertifiedDeliveries += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.ROLENAME_STR + recipient.RecipientType  
                            + CON_CLM.RECIPIENTID_STR + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + CON_CLM.NOTE_STR
                            + CON_CLM.EMAIL_NOTIFICATION_STR + recipient.EmailSubject + CON_CLM.EMAIL_BODY_STR + recipient.EmailBody+'"}},';          
                    }
                }
            }     
        }
        recipientBodySigners.removeEnd(',');
        recipientBodyCarbonCopies.removeEnd(',');
        recipientBodyCertifiedDeliveries.removeEnd(',');
        recipientBodyCertifiedDeliveries += ']';        
        recipientBodyCarbonCopies += ']';
        recipientBodySigners += ']';
        body += recipientBodySigners + ',' + recipientBodyCarbonCopies + ',' + recipientBodyCertifiedDeliveries + '}}'; 
        return body;
    }

    
    /**
    * This method performs the actual docusign API call  
    * @param String authCode
    * @param String body
    * @param List<DocuSignRecipientsWrapper> selectedRecipients
    * @param IQVIA_Agreement__c agreement 
    * @param String documentName
    * @param List<ContentVersion> attachmentSizeList
    * @param Boolean isRunningFromBatch
    * @param String sendAsUserEmail
    * @param String envelopeStatus
    * @return ESignatureResponseWrapper
    */
    public static ESignatureResponseWrapper getResponseForPropOwner(String authCode, fflib_StringBuilder body, List<DocuSignRecipientsWrapper> selectedRecipients, 
        IQVIA_Agreement__c agreement, String documentName, List<ContentVersion> attachmentSizeList, Boolean isRunningFromBatch, String sendAsUserEmail,  String envelopeStatus) {
        List<DocuSign_Auth_Data__c> docusignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Name'}, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c docuSignIntegrationSettings = docusignAccountSettingList[0];
        HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, 
            CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c + '/envelopes', 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getJWTAccessToken(agreement.Docusign_Account_Id__c, sendAsUserEmail,false);
            response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, 
            CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c + '/envelopes', 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
        }
        if(response.getStatusCode() == 201) {
            String docusignEnvelopId = null;
            DocuSignEnvelopeResponseWrapper docuSignResponse = (DocuSignEnvelopeResponseWrapper)JSON.deserialize(response.getBody(), DocuSignEnvelopeResponseWrapper.class);
            String selectedRecipientsJson = JSON.serialize(selectedRecipients);
            docusignEnvelopId = createDocuSignEnvelope(docuSignResponse.envelopeId, docuSignResponse.status, agreement.id, documentName, 
                attachmentSizeList.size(), docuSignIntegrationSettings.Base_URL__c, authCode, docuSignIntegrationSettings.Account_Id__c, 
                selectedRecipientsJson, sendAsUserEmail, agreement.Docusign_Account_Id__c);
            updateAgreementStatus(agreement, docusignEnvelopId, envelopeStatus);
            return new ESignatureResponseWrapper(docuSignResponse.envelopeId, CON_CLM.STATUS_SUCCESS, '');
        }
        else {
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode + ' : '+resError.message + ',';
            errorList += CON_CLM.RECORDID_ERRORLIST_STR+agreement.Id ;
            system.debug(errorList);
            if(isRunningFromBatch) {
                CalloutException e = new CalloutException();
                e.setMessage(errorList);
                return null;
                //throw new AuraHandledException(JSON.serialize(e));
            }
            else {
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
            }            
        }
    }
    
    /**
    * This method performs callout
    * @param String baseUrl
    * @param String endPoint
    * @param String method
    * @param String authCode
    * @param String body
    * @param String docuSignActAsUser 
    * @return HttpResponse
    */ 
    public static HttpResponse doHttpCallout(String baseUrl, String endPoint, String method, String authCode, fflib_StringBuilder body, 
        String docuSignActAsUser) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl + endPoint);
        request.setMethod(method);
        request.setHeader(CON_CLM.CONTENT_TYPE_STR, 'application/json;charset=UTF-8');
        request.setHeader('Authorization', authCode);
        request.setHeader('X-DocuSign-Act-As-User', docuSignActAsUser);
        request.setTimeout(120000);
        if(method == CON_CLM.POST || method == CON_CLM.PUT) {
            request.setBody(body.toString());
        }
        HttpResponse response = http.send(request);
        return response;
    }

    /**
    * This method creates docusign envelope
    * @param String envelopeId
    * @param String envelopeStatus
    * @param Id agreementId
    * @param String documentName
    * @param Integer noOfDocument
    * @param String baseUrl
    * @param String authCode
    * @param String docuSignAccountId
    * @param String signersJson
    * @param String sendAsUserEmail
    * @param String accountId
    * @return String
    */   
    public static String createDocuSignEnvelope(String envelopeId, String envelopeStatus, Id agreementId, String documentName, Integer noOfDocument, 
        String baseUrl, String authCode, String docuSignAccountId, String signersJson, String sendAsUserEmail, String accountId) {
        String docuSignEnvelopId = null;
        IQ_DocuSignEnvelope__c docuSignEnvelope = new IQ_DocuSignEnvelope__c();
        Map<String, String> docuSignEnvelopeRecipientTitleMap = new Map<String, String>();
        docuSignEnvelope.Name = envelopeId;
        docuSignEnvelope.EnvelopeId__c = envelopeId;
        docuSignEnvelope.Agreement__c = agreementId;
        docuSignEnvelope.DocumentName__c = documentName;
        docuSignEnvelope.ParentId__c = agreementId;
        docuSignEnvelope.NumberOfDocuments__c = noOfDocument;
        docuSignEnvelope.Status__c = (envelopeStatus == CON_CLM.IQ_ENVELOPE_STATUS_CREATED) ? CON_CLM.DRAFT : envelopeStatus;
        docuSignEnvelope.StatusChangeDateTime__c = DateTime.now();
        docuSignEnvelope.Signers__c = signersJson;
        docuSignEnvelope.Send_As_User_Email__c = sendAsUserEmail;
        docuSignEnvelope.Docusign_AccountId__c = docuSignAccountId;
        docuSignEnvelope.Docusign_App_Name__c = accountId;
        if(!System.isBatch()) {
            String Key = 'docusignUserId'+sendAsUserEmail;
            Key = Key.replaceAll('[^a-zA-Z0-9\\s+]', '');
            docuSignEnvelope.DocusignUser_Id__c = (String)sessionPartiton.get(Key);
        }
        HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(baseUrl, CON_CLM.RESTAPI_STR + docuSignAccountId  
            + CON_CLM.ENVELOPE_STR + envelopeId, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        List<DocuSignRecipientsWrapper> selectedSignersList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(signersJson, List<DocuSignRecipientsWrapper>.class);
        for(DocuSignRecipientsWrapper dsw: selectedSignersList){
            docuSignEnvelopeRecipientTitleMap.put(dsw.recipientType + dsw.signingOrder + dsw.email, dsw.privateMessage);
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                IQ_DocuSignEnvelope__c.SObjectType
            }
        );
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                IQ_DocuSignEnvelopeRecipientStatus__c.SObjectType    
            }
        );
        if(response.getStatusCode() == 401) {
            authCode = getJWTAccessToken(accountId, sendAsUserEmail,false);
            response = CNT_CLM_DocuSignESignature.doHttpCallout(baseUrl, CON_CLM.RESTAPI_STR + docuSignAccountId  
            + CON_CLM.ENVELOPE_STR+envelopeId, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        }
        if(response.getStatusCode() == 200) {
            docuSignEnvelope.EnvelopeContent__c = response.getBody();
            createOrUpdateDocuSignEnvelopeRecipientStatus(agreementId, envelopeId, baseUrl, authCode, docuSignAccountId,
                sendAsUserEmail, accountId, docuSignEnvelopId);
            uow.registerNew(docuSignEnvelope);
            uow.commitWork();
            docuSignEnvelopId = docuSignEnvelope.Id;
            for(String key : docuSignEnvelopeRecipientStatusMap.keySet()) {
                if(docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c == null) {
                    docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c = docuSignEnvelope.id;
                }
                if(docuSignEnvelopeRecipientTitleMap.containsKey(key)) {
                    docuSignEnvelopeRecipientStatusMap.get(key).Title__c = docuSignEnvelopeRecipientTitleMap.get(key);
                }
            }
            uow1.registerNew(docuSignEnvelopeRecipientStatusMap.values());
            uow1.commitWork();       
            saveAccessToken(authCode, accountId);
        }
        else {
            System.debug(LoggingLevel.ERROR, 'StatusCode ='+response.getStatusCode()+ ',  Body ='+response.getBody());
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode+' : '+resError.message;
            errorList += CON_CLM.RECORDID_ERRORLIST_STR+agreementId ;
        }
        return docuSignEnvelopId;
    }    
    
    /**
    * This method gets the access token
    * @param String action
    * @param String accId
    * @return String
    */
    public static String getAccessToken(String action, String accId) {
        List<DocuSign_Auth_Data__c> docuSignAuthDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, accId, 1);
        DocuSign_Auth_Data__c docuSignAuthData;
        if(docuSignAuthDataList.size() > 0) {
            docuSignAuthData = docuSignAuthDataList[0];
        }
        else {
            System.debug('No DocuSign Auth Data Available. Please authenticate from the page "/apex/DocuSign_Account_Setting", or contact your system administrator.');
            return null;
        }
        if(action != CON_CLM.ACCESS_TOKEN_NEW) {
            return docuSignAuthData.Access_Token__c;
        }        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(docuSignAuthData.Base_URL__c + '/restapi/v2/oauth2/token');
        request.setMethod('POST');
        request.setHeader(CON_CLM.CONTENT_TYPE_STR, 'application/x-www-form-urlencoded');
        request.setTimeout(120000);
        String password = decryptPassword(docuSignAuthData.DocuSign_Pwd__c);
        request.setBody('grant_type=password&client_id=' + docuSignAuthData.Client_Id__c + '&username=' + docuSignAuthData.User_Name__c 
            + '&password='+password+'&scope=api');
        HttpResponse response = http.send(request);
        String accessToken = '';
        if (response.getStatusCode() == 200) {            
            AccessTokenWrapper accessTokenWrap = (AccessTokenWrapper)JSON.deserialize(response.getBody(), AccessTokenWrapper.class);            
            //New access token generated
            accessToken = accessTokenWrap.accessToken;
            accessTokenChanged = true;            
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode());
        }
        return accessToken;
    }

    /**
    * This method decrypts the password
    * @param String encodedCiperText
    * @return String
    */
    public static String decryptPassword(String encodedCipherText) {
        Blob key = Blob.valueOf(CON_CLM.BLOB_VALUE);
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encodedCipherText);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', key, encodedEncryptedBlob);
        String decryptedClearText = decryptedBlob.toString();               
        return decryptedClearText;
    }
    
    /**
    * This method updates the agreement status
    * @param IQVIA_Agreement__c agreement
    * @param String docuSignEnvId 
    * @param String envStatus
    */ 
    public static void updateAgreementStatus(IQVIA_Agreement__c agreement, String docuSignEnvId, String envStatus) {
        if(docuSignEnvId != null && docuSignEnvId != '') {
            agreement.DocuSign_Envelope_Id__c = docuSignEnvId;   
        }    
        if(envStatus == CON_CLM.SENT_STATUS) {
            agreement.Status__c = (agreement.RecordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID)
                ? CON_CLM.SENT_FOR_SIGNATURES : CON_CLM.STATUS_OTHER_PARTY_SIGNATURE;
            agreement.Status_Category__c = CON_CLM.IN_SIGNATURES;   
        }
        SRV_CLM_Agreement.updateIQVIAAgreement(agreement);
    }
    
    /**
    * This method checks the heap size
    * @return Boolean
    */ 
    @AuraEnabled
    public static Boolean checkHeapSize() {
        if(Limits.getHeapSize() > 10000000) {
            return false;
        }
        return true;
    }
  
    /**
    * This method creates Docusign Envelope Recipient Status
    * @param String agreementId
    * @param String envelopeId
    * @param String baseUrl
    * @param String authCode
    * @param String docuSignAccountId
    * @param String sendAsUserEmail
    * @param String accId 
    */    
    public static void createOrUpdateDocuSignEnvelopeRecipientStatus(String agreementId, String envelopeId, String baseUrl, String authCode, 
        String docuSignAccountId, String sendAsUserEmail, String accId, String evelopeSFID) {
        docuSignEnvelopeRecipientStatusMap = new Map<String, IQ_DocuSignEnvelopeRecipientStatus__c>(); 
        HttpResponse response = doHttpCallout(baseUrl, CON_CLM.RESTAPI_STR + docuSignAccountId  
            + CON_CLM.ENVELOPE_STR + envelopeId + CON_CLM.RECIPIENTS_STR, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getJWTAccessToken(accId, sendAsUserEmail,false);
            response = doHttpCallout(baseUrl, CON_CLM.RESTAPI_STR + docuSignAccountId + CON_CLM.ENVELOPE_STR + envelopeId + CON_CLM.RECIPIENTS_STR,
                'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        }
        if(response.getStatusCode() == 200) {
            UTL_CLM_Docusign.populateIQVIADocuSignEnvelopeRecipientStatusMap(docuSignEnvelopeRecipientStatusMap, agreementId, evelopeSFID,
                response);
        }
        else {
            System.debug(LoggingLevel.ERROR, 'StatusCode ='+response.getStatusCode()+ ',  Body ='+response.getBody());
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode+' : '+resError.message;
            errorList += ', RecordId::'+agreementId ;
        }
    }
    
    /**
    * This method saves access token
    * @param String accessToken
    * @param String accId
    */ 
    public static void saveAccessToken(String accessToken, String accId) {
        if(accessTokenChanged) {
            List<DocuSign_Auth_Data__c> docuSignAuthDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
                'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'Name'}, accId, 1);
            for(DocuSign_Auth_Data__c docuSignAuthData : docuSignAuthDataList) {
                docuSignAuthData.Access_Token__c = accessToken;
            }            
            if(docuSignAuthDataList.size() > 0) {        
                try {  
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            DocuSign_Auth_Data__c.SObjectType
                        }
                    );
                    uow.registerDirty(docuSignAuthDataList);
                    uow.commitWork();
                } catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
            }
            else {
                System.debug('No DocuSign Auth Data Available. Please authenticate from the page "/apex/DocuSign_Account_Setting", or contact your system administrator.');
            }
        }
    }
    
    /**
    * This method retrieves the records
    * @param String searchString
    * @param String objectApiName
    * @param String idFieldApiName
    * @param String valueFieldApiName
    * @param String extendedWhereClause
    * @param Integer maxRecords
    * @param String agrId
    * @return List<SObject>
    */ 
    @AuraEnabled 
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, 
        String extendedWhereClause, Integer maxRecords, String agrId) {
        searchString = String.escapeSingleQuotes(searchString);
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        String relatedFieldInCodition = 'Agreement__c';
        String valueFieldApiNameEmail = 'Email__c';
        extendedWhereClause = 'AND Agreement__c=\'' + agrId + '\'';
        String query = 'SELECT ' + idFieldApiName + ', ' + valueFieldApiName + ', ' + valueFieldApiNameEmail + ', Type__c, Job_Title__c FROM ' 
            + objectApiName + ' WHERE (' + valueFieldApiName + ' LIKE \'%' + searchString + '%\' OR ' + valueFieldApiNameEmail + ' LIKE \'%' 
            + searchString + '%\') ' + extendedWhereClause + ' LIMIT ' + maxRecords;
        return Database.query(query);
    }
    
    /**
    * This method checks the current status of batch process 
    * @param String batchId
    * @return ApexJobWrapper
    */ 
    @AuraEnabled
    public static ApexJobWrapper getBatchCurrentStatus(String batchId) {
        AsyncApexJob aj = new SLT_AsyncApexJob().getJobFieldsForId((Id)batchId, new Set<String>{'ExtendedStatus', 'Status', 
            'JobItemsProcessed', 'TotalJobItems', 'NumberOfErrors' });
        return new ApexJobWrapper(aj.ExtendedStatus, aj.Status, aj.JobItemsProcessed, aj.TotalJobItems, aj.NumberOfErrors);
    }
    
    /**
    * This method returns reminder and expiration wrapper
    * @param String docuSignAccId 
    * @return ReminderAndExpWrapper
    */ 
    @AuraEnabled
    public static ReminderAndExpWrapper getReminderAndExpiration(String docuSignAccId) {
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Reminder_Delay__c', 'Reminder_Frequency__c', 'Expire_After__c', 'Expire_Warn__c', 'Name'}, docuSignAccId, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];        
        ReminderAndExpWrapper reminderWrapper = new ReminderAndExpWrapper(String.valueOf(docuSignIntegrationSettings.Expire_After__c), 
            String.valueOf(docuSignIntegrationSettings.Expire_Warn__c), String.valueOf(docuSignIntegrationSettings.Reminder_Delay__c), 
            String.valueOf(docuSignIntegrationSettings.Reminder_Frequency__c));
        return reminderWrapper;
    }
    
    /**
    * This method returns the wrapper for process finalize in docusign
    * @param String selectedAttJSON
    * @param String selectedSignersJSON
    * @param String emailSubject
    * @param String emailBlurb
    * @param String agreementId
    * @param String reminderAndExp
    * @param String sendAsUserEmail 
    * @return ESignatureResponseWrapper
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper processFinalizeInDocuSign(String selectedAttJSON, String selectedSignersJSON, String emailSubject,
        String emailBlurb, String agreementId, String reminderAndExp, String sendAsUserEmail) {
        errorList = '';        
        Set<Id> selectedAttIds = (Set<Id>)JSON.deserialize(selectedAttJSON, Set<Id>.class);
        List<ContentVersion> selectedAttList = new SLT_ContentVersion().getContentVersionByIds(selectedAttIds, new Set<String>{'Id', 'ContentSize'});
        List<DocuSignRecipientsWrapper> selectedSignersList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(selectedSignersJSON, List<DocuSignRecipientsWrapper>.class);
        ReminderAndExpWrapper reminderAndExpRec = (ReminderAndExpWrapper)JSON.deserialize(reminderAndExp, ReminderAndExpWrapper.class);
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status_Category__c', 
            'FF_Agreement_Number__c', 'Status__c', 'Docusign_Account_Id__c', 'Record_Type_Developer_Name__c', 'RecordTypeId'});
        Integer totalBodyLength = 0;
        Integer totalBodyLengthInKb = 0;
        for(ContentVersion  att : selectedAttList) {
            totalBodyLength = totalBodyLength + att.ContentSize;
        }
        totalBodyLengthInKb = totalBodyLength/1024;
        if(totalBodyLengthInKb > 10000) {
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAIL, CON_CLM.ATTACHMENT_LENGTH_ERROR_MSG);
        }
        else {            
            ESignatureResponseWrapper erw;
            try {                 
                erw = doDocuSignCallout(false, CON_CLM.IQ_ENVELOPE_STATUS_CREATED, emailSubject, emailBlurb, selectedAttList, 
                    selectedSignersList, agreement, reminderAndExpRec, sendAsUserEmail,null);
            }
            catch(Exception e) {
                errorList += e.getmessage();
                System.debug('Exception :'+e.getMessage()+' ::: '+e.getStackTraceString()+' recordId::'+agreementId);                
                erw = new ESignatureResponseWrapper('', CON_CLM.STATUS_FAIL, e.getMessage());
            }
            return erw; 
        }
    }
    
    /**
    * This method returns the wrapper for url finalize in docusign
    * @param String envelopeId
    * @param String agreementId
    * @param String sendAsUserEmail
    * @param String docuSignAccId
    * @return ESignatureResponseWrapper 
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper getUrlForFinalizeInDocuSign(String envelopeId, String agreementId, String sendAsUserEmail, String docuSignAccId){
        String authCode = getJWTAccessToken(docuSignAccId, sendAsUserEmail,false);
        fflib_StringBuilder body = new fflib_StringBuilder();
        body.add('{"returnUrl": "' + URL.getOrgDomainUrl().toExternalForm() + '/c/LXC_CLM_DocuSignSendForESignatureApp.app"}');
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c' , 'Name'}, docuSignAccId, 1);
        DocuSign_Auth_Data__c docuSignIntegrationSettings = docuSignAccountSettingList[0];
        HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, 
            CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + envelopeId
            + '/views/sender', 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getAccessToken(CON_CLM.ACCESS_TOKEN_NEW,docuSignAccId);
            authCode = getJWTAccessToken(docuSignAccId,sendAsUserEmail,false);
            response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
                + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + envelopeId + '/views/sender', 'POST', 
                CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
        }
        if(response.getStatusCode() == 201) {
            DocuSignSenderViewResponseWrapper docuSignResponse = (DocuSignSenderViewResponseWrapper)JSON.deserialize(response.getBody(), DocuSignSenderViewResponseWrapper.class);
            return new ESignatureResponseWrapper(docuSignResponse.url, CON_CLM.STATUS_SUCCESS, '');
        }
        else {
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode+' : '+resError.message+',';
            errorList += CON_CLM.RECORDID_ERRORLIST_STR + agreementId;           
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }            
    }
    
    /**
    * This method returns the wrapper for Docusign preview URL
    * @param String agreementId
    * @param String sendAsUserEmail
    * @param String docuSignAccId
    * @param String recipientId
    * @return ESignatureResponseWrapper 
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper getDocuSignPreviewUrl(String agreementId, String sendAsUserEmail, String docuSignAccId, String recipientId) {
        String authCode = getJWTAccessToken(docuSignAccId, sendAsUserEmail,false);
        fflib_StringBuilder body = new fflib_StringBuilder();
        body.add('{"returnUrl": "' + URL.getOrgDomainUrl().toExternalForm() + '/c/LXC_CLM_DocuSignSendForESignatureApp.app", "authenticationMethod":"HTTPBasicAuth","recipientId":"'+recipientId+'"}');
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c'}, docuSignAccId, 1);
        DocuSign_Auth_Data__c docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, 
            CON_CLM.IQ_ENVELOPE_STATUS_CREATED, agreementId, new Set<String>{'EnvelopeId__c'}, 'CreatedDate', 'DESC', 1);
        if(docuSignEnvelopeList.size() > 0) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            if(docuSignEnvelope != null) {
                HttpResponse response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR_2_1 
                    + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c
                    + '/views/recipient_preview', 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
                if(response.getStatusCode() == 401) {
                    authCode = getJWTAccessToken(docuSignAccId,sendAsUserEmail,false);
                    response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR_2_1+docuSignIntegrationSettings.Account_Id__c+CON_CLM.ENVELOPE_STR+docuSignEnvelope.EnvelopeId__c+'/views/recipient_preview', 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
                }
                if(response.getStatusCode() == 201) {
                    DocuSignSenderViewResponseWrapper docuSignResponse = (DocuSignSenderViewResponseWrapper)JSON.deserialize(response.getBody(), DocuSignSenderViewResponseWrapper.class);
                    return new ESignatureResponseWrapper(docuSignResponse.url, CON_CLM.STATUS_SUCCESS, '');
                }
                else {
                    ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
                    errorList += resError.errorCode+' : '+resError.message+',';
                    errorList += CON_CLM.RECORDID_ERRORLIST_STR+agreementId ;           
                    return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
                }   
            }
            else {
                errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;  
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList);  
            }
        }
        else {            
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }   
    }
    
    /**
    * This method updates Docusign Envelope  
    * @param String envelopeId
    * @return ESignatureResponseWrapper
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper updateDocuSignEnvelope(String envelopeId) {
        try {
            String condition = 'EnvelopeId__c =: firstParam';
            IQ_DocuSignEnvelope__c docuSignEnvelope = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, envelopeId, 
                null, new Set<String>{'Id', 'Status__c', 'Agreement__c'}, '', '', 1)[0];
            docuSignEnvelope.Status__c = CON_CLM.SENT_STATUS;
            docuSignEnvelope.StatusChangeDateTime__c = DateTime.now();
            List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new List<IQ_DocuSignEnvelope__c>{docuSignEnvelope};        
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType});
            if(!docuSignEnvelopeList.isEmpty()) {
                uow.registerDirty(docuSignEnvelopeList);
                uow.commitWork();
            }
            return new ESignatureResponseWrapper(docuSignEnvelope.Agreement__c, CON_CLM.STATUS_SUCCESS, '');
        }
        catch(Exception e) {
            system.debug('Exception :' + e.getMessage() + ' ::: ' + e.getStackTraceString());
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, e.getMessage());
        }        
    }
    
    /**
    * This method checks whether account details are available or not
    * @param String agreementId
    * @return String
    */ 
    @AuraEnabled
    public static String checkIfAccountDetailsAvailable(String agreementId) {
        String mail = null; 
        IQVIA_Agreement__c agr = new IQVIA_Agreement__c();
        List<DocuSign_Auth_Data__c> docuSignAuthDataList = new List<DocuSign_Auth_Data__c>();
        agr = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Docusign_Account_Id__c', 
            'FF_Agreement_Number__c', 'Status__c', 'Status_Category__c'});
        if(agr != null) {
            docuSignAuthDataList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
                'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c' }, agr.Docusign_Account_Id__c, 1);
        }
        if(docuSignAuthDataList.size() > 0) {
            mail = docuSignAuthDataList[0].User_Name__c;
            return mail;
        }
        else {
            return mail;
        }
    } 
    
    /**
    * This method is used to get agreement contacts
    * @param String agrId
    * @return List<SObject>
    */ 
    @AuraEnabled 
    public static List<SObject> getAgreementTeams(String agrId) {
        List<IQVIA_Agreement_Team__c> agrContactList = new List<IQVIA_Agreement_Team__c>();
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agrId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Status_Category__c'});
        String condition = 'Contact__c != null AND Contact__r.Email != null AND Agreement__c IN: agreementIds';
        String orderField = CON_CLM.AGREEMENT_CONTACTS_TYPE;
        agrContactList = new SLT_Agreement_Team().getAgreementTeamListByAgreementId(new Set<Id>{agrId}, new Set<String>{'Id', 'Contact__c', 
            'Type__c', 'Contact__r.FirstName', 'Contact__r.LastName', 'Email__c', 'Job_Title__c', 'DocuSign_Recipient__c'}, condition, null, orderField, 'DESC');
        return agrContactList;
    }
    
    /**
    * This method is used to get email templates names
    * @param String agreementId
    * @return List<EmailTemplateWrapper> 
    */ 
    @AuraEnabled
    public static List<EmailTemplateWrapper> getEmailTemplateNames(String agreementId) {
        String internalDefault = CON_CLM.APPROVAL_NONE;    
        String externalDefault = CON_CLM.APPROVAL_NONE;
        String label = null;
        String value= null;
        String recordTypeName = null;
        EmailTemplateWrapper etw = new EmailTemplateWrapper();
        List<EmailTemplateWrapper> etwList = new List<EmailTemplateWrapper>();
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Recordtype.Name', 'Status__c', 
            'Account__c', 'Status_Category__c','Record_Type_Developer_Name__c'});
        recordTypeName = agreement.Record_Type_Developer_Name__c;
        List<Docusign_Email_Template__mdt> emailTemplateList = Docusign_Email_Template__mdt.getAll().values();
        Boolean emailTemplateFound = false;
        if(!emailTemplateList.isEmpty()) {
            for(Docusign_Email_Template__mdt etm : emailTemplateList) {
                if(etm.Object_API_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME && etm.Record_Type__c == agreement.Record_Type_Developer_Name__c && etm.Default__c == true && etm.Contact_Type__c == CON_CLM.INTERNAL) { 
                    internalDefault = etm.Email_Template_Unique_Name__c;
                }
                if(etm.Object_API_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME && etm.Record_Type__c == agreement.Record_Type_Developer_Name__c && etm.Default__c == true && etm.Contact_Type__c == CON_CLM.EXTERNAL) {
                    externalDefault = etm.Email_Template_Unique_Name__c;
                }
            } 
            for(Docusign_Email_Template__mdt etm : emailTemplateList) {
                if(etm.Object_API_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME && etm.Record_Type__c == agreement.Record_Type_Developer_Name__c){
                    etwList.add(new EmailTemplateWrapper(etm.Email_Template_Label__c, etm.Email_Template_Unique_Name__c, internalDefault, externalDefault, recordTypeName)) ;
                    emailTemplateFound = true;
                }
            }
            if(!emailTemplateFound) {
                etwList.add(new EmailTemplateWrapper('No Email Template available','No Email Template available','None', 'None', null)) ;
            }
        }
        else {
            etwList.add(new EmailTemplateWrapper('No Email Template available','No Email Template available','None', 'None', null)) ;
        }
        return etwList;
    }    
    
    /**
    * This method returns the wrapper of template body
    * @param String agreementId
    * @param List<String> templateNameList
    * @return List<BulkEmailDataWrapper> 
    */ 
    @AuraEnabled
    public static List<BulkEmailDataWrapper> getIndividualEmailTemplateBody(String agreementId, List<String> templateNameList) {
        List<EmailTemplate> etList = new List<EmailTemplate>();
        Set<String> templateSet = new Set<String>();
        for(String str : templateNameList) {
            templateSet.add(str);
        }
        String condition = 'DeveloperName IN: developerNames';
        etList = new SLT_EmailTemplate().selectEmailTemplatesByCondition(templateSet, new Set<String>{'Id', 'DeveloperName', 'Subject'}, condition);
        String emailBody = null;
        String subject= null;
        List<BulkEmailDataWrapper> bedwList = new List<BulkEmailDataWrapper>();
        for(EmailTemplate et : etList) {
            Messaging.SingleEmailMessage res = Messaging.renderStoredEmailTemplate(et.id, UserInfo.getUserId(), agreementId);
            if(res.getHtmlBody() != null) {
                emailBody = res.getHtmlBody();
            }
            else if(res.getPlainTextBody() != null) {
                emailBody = res.getPlainTextBody(); 
            }
            if(etList[0].Subject != NULL){
                subject =  res.getSubject();
            }
            bedwList.add(new BulkEmailDataWrapper(subject, emailBody, et.DeveloperName));
        }
        return bedwList;
    }
    
    /**
    * This method is used to get wrapper for load data for correct recipients
    * @param String agreementId
    * @return DocuSignRecipientsListWrapper
    */ 
    @AuraEnabled
    public static DocuSignRecipientsListWrapper loadDataForCorrectRecipients(String agreementId) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 
            'Status__c', 'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.SENT_STATUS,
            agreementId, new Set<String>{'EnvelopeId__c', 'Send_As_User_Email__c', 'Signers__c',
            'DocusignUser_Id__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            CNT_CLM_DocuSignESignature.docusignUserId = docuSignEnvelope.DocusignUser_Id__c;
            if(docuSignEnvelope != null) {
                String sendAsUserEmail = docuSignEnvelopeList[0].Send_As_User_Email__c;
                return getExistingRecipients(docuSignIntegrationSettings, docuSignEnvelope, sendAsUserEmail);
            }
            else {
                errorList += 'signer information not available';   
                return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList); 
            }
        }
        else {            
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
    
    /**
    * This method is used to get existing recipient wrapper
    * @param DocuSign_Auth_Data__c docuSignIntegrationSettings
    * @param IQ_DocuSignEnvelope__c docuSignEnvelope
    * @param String sendAsUserEmail
    * @return DocuSignRecipientsListWrapper
    */ 
    public static DocuSignRecipientsListWrapper getExistingRecipients(DocuSign_Auth_Data__c docuSignIntegrationSettings, 
        IQ_DocuSignEnvelope__c docuSignEnvelope, String sendAsUserEmail) {
        String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,false);
        HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
            + docuSignIntegrationSettings.Account_Id__c+CON_CLM.ENVELOPE_STR+docuSignEnvelope.EnvelopeId__c
            + CON_CLM.RECIPIENTS_STR, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getAccessToken(CON_CLM.ACCESS_TOKEN_NEW, docuSignIntegrationSettings.Name);
            authCode = getJWTAccessToken(docuSignIntegrationSettings.Name,sendAsUserEmail,false);
            response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
                + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c 
                + CON_CLM.RECIPIENTS_STR, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        }
        if(response.getStatusCode() == 200) {
            List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(docuSignEnvelope.Signers__c, 
                List<DocuSignRecipientsWrapper>.class);
            DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse = (DocuSignEnvelopeRecipientStatusResponseWrapper)JSON.deserialize(response.getBody(),
                DocuSignEnvelopeRecipientStatusResponseWrapper.class);
            return processExistingRecipients(docuSignRecipientsWrapperList, docuSignRecipientsResponse);
        }
        else {
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode + ' : ' + resError.message+',';   
            return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList);  
        }
    }
    
    /**
    * This method is used to get wrapper of existing Docusign recipients
    * @param List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList
    * @param DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse
    * @return DocuSignRecipientsListWrapper
    */ 
    public static DocuSignRecipientsListWrapper processExistingRecipients(List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList, 
        DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse) {
        Map<String, Boolean> docuSignRecipientsStatusMap = new Map<String, Boolean>();
        for(Signers signer: docuSignRecipientsResponse.signers){
            Boolean statusCompleted = checkSignerStatus(signer.status);                       
            docuSignRecipientsStatusMap.put(signer.email + '_' + signer.roleName + '_' + signer.recipientId, statusCompleted);
        }
        for(CarbonCopies carbonCopy : docuSignRecipientsResponse.carbonCopies) {
            Boolean statusCompleted = checkSignerStatus(carbonCopy.status);                        
            docuSignRecipientsStatusMap.put(carbonCopy.email + '_' + carbonCopy.roleName + '_' + carbonCopy.recipientId, statusCompleted);
        }
        for(CertifiedDeliveries certifiedDelivery: docuSignRecipientsResponse.certifiedDeliveries) {
            Boolean statusCompleted = checkSignerStatus(certifiedDelivery.status);  
            docuSignRecipientsStatusMap.put(certifiedDelivery.email+'_'+certifiedDelivery.roleName+'_'+certifiedDelivery.recipientId, statusCompleted);
        }
        for(DocuSignRecipientsWrapper docuSignRecipientsWrapperObj : docuSignRecipientsWrapperList) {
            String mKey = docuSignRecipientsWrapperObj.email + '_' + docuSignRecipientsWrapperObj.RecipientType + '_' + docuSignRecipientsWrapperObj.RecipientId;
            if(docuSignRecipientsStatusMap.containsKey(mKey) && docuSignRecipientsStatusMap.get(mKey)) {     
                docuSignRecipientsWrapperObj.disabled = 'true';                                 
            }                       
        }
        return new DocuSignRecipientsListWrapper(docuSignRecipientsWrapperList, CON_CLM.STATUS_SUCCESS, ''); 
    }
    
    /**
     * This method checks the signer status
     * @param String status
     * @return Boolean
     */ 
    public static Boolean checkSignerStatus(String status) {
        if(status == CON_CLM.SENT_STATUS || status == CON_CLM.IQ_ENVELOPE_STATUS_CREATED 
            || status == CON_CLM.STATUS_AUTO_RESPONDED) {
            return false;
        }
        else{
            return true;
        }
    }
    
    /**
    * This method is used to get wrapper for updating correct E signatures 
    * @param String agreementId
    * @param String recipientsJson
    * @param String sendAsUserEmail 
    * @return ESignatureResponseWrapper
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper updateCorrectESignature(String agreementId, String recipientsJson, String sendAsUserEmail) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,false);
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.SENT_STATUS, 
        agreementId, new Set<String>{'Id', 'Name', 'Status__c', 'Agreement__c',
            'Send_As_User_Email__c','EnvelopeId__c', 'DocusignUser_Id__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            CNT_CLM_DocuSignESignature.docusignUserId = docuSignEnvelope.DocusignUser_Id__c;
            fflib_StringBuilder body = new fflib_StringBuilder();
            body.add(createBodyForUpdateESignature(recipientsJson));
            sendAsUserEmail = docuSignEnvelopeList[0].Send_As_User_Email__c;
            HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, 
                CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c
                + CON_CLM.RECIPIENTS_STR, 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
            if(response.getStatusCode() == 401) {
                authCode = getJWTAccessToken(docuSignIntegrationSettings.Name,sendAsUserEmail,false);
                response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR
                    + docuSignEnvelope.EnvelopeId__c + CON_CLM.RECIPIENTS_STR, 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
            }
            if(response.getStatusCode() == 200) {
                DocuSignSenderViewResponseWrapper docuSignResponse = (DocuSignSenderViewResponseWrapper)JSON.deserialize(response.getBody(), DocuSignSenderViewResponseWrapper.class);
                docuSignEnvelope.Signers__c = recipientsJson;
                createOrUpdateDocuSignEnvelopeRecipientStatus(agreementId, docuSignEnvelope.Name, 
                    docuSignIntegrationSettings.Base_URL__c, authCode, docuSignIntegrationSettings.Account_Id__c,
                    sendAsUserEmail, agreement.Docusign_Account_Id__c, docuSignEnvelope.Id);
                for(String key : docuSignEnvelopeRecipientStatusMap.keySet()) {
                    if(docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c == null) {
                        docuSignEnvelopeRecipientStatusMap.get(key).DocuSignEnvelopeId__c = docuSignEnvelope.id;
                    }
                }   
                
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {IQ_DocuSignEnvelope__c.SObjectType,
                    IQ_DocuSignEnvelopeRecipientStatus__c.SObjectType});
                uow.registerDirty(docuSignEnvelope);
                uow.registerUpsert(docuSignEnvelopeRecipientStatusMap.values());
                uow.commitWork();
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_SUCCESS, '');
            }
            else {
                ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
                errorList += resError.errorCode+' : '+resError.message+',';            
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
            }
        }
        else {
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
    
    /**
    * This method is used to create body for update E signatures 
    * @param String recipientsJson
    * @return String 
    */ 
    public static String createBodyForUpdateESignature(String recipientsJson) {
        String body = '{';        
        String recipientBodySigners = '"signers":[';       
        String recipientBodyCarbonCopies = '"carbonCopies":[';
        String recipientBodyCertifiedDeliveries = '"certifiedDeliveries":[';
        String sub1 = 'Testing';
        String sub2 = 'Testing';
        List<DocuSignRecipientsWrapper> updatedRecipientsList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(recipientsJson, List<DocuSignRecipientsWrapper>.class);
        for(DocuSignRecipientsWrapper recipient : updatedRecipientsList) {
            if(recipient.disabled != 'true') {
                if(CON_CLM.RECIPIENT_TYPE_SIGNER.equalsIgnoreCase(recipient.RecipientType)) {
                    recipientBodySigners += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.RECIPIENTID_STR
                        + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder+'"},';
                }
                else if(CON_CLM.RECIPIENT_TYPE_CC.equalsIgnoreCase(recipient.RecipientType)) {
                    recipientBodyCarbonCopies += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.RECIPIENTID_STR
                        + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + '"},';                                
                }
                else if(CON_CLM.RECIPIENT_TYPE_CERTIFIED_DELIVERY.equalsIgnoreCase(recipient.RecipientType)) { 
                    recipientBodyCertifiedDeliveries += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.RECIPIENTID_STR
                        + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + '"},';          
                }
            }
        }
        recipientBodySigners = recipientBodySigners.substring(0, recipientBodySigners.length() - 1);
        recipientBodyCarbonCopies.removeEnd(',');
        recipientBodyCertifiedDeliveries.removeEnd(',');
        recipientBodyCertifiedDeliveries += ']';        
        recipientBodyCarbonCopies += ']';
        recipientBodySigners += ']';
        body += recipientBodySigners+',';
        body += recipientBodyCarbonCopies+',';
        body += recipientBodyCertifiedDeliveries;
        body += '}';
        return body;
    }
    
    /**
    * This method is used to create wrapper for recall E Signatures   
    * @param String agreementId 
    * @param String voidedReason 
    * @return ESignatureResponseWrapper
    */     
    @AuraEnabled
    public static ESignatureResponseWrapper recallESignature(String agreementId, String voidedReason) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'User_Name__c', 'Name'}, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.SENT_STATUS, 
            agreementId, new Set<String>{'Id', 'Status__c', 'Agreement__c', 'Signers__c', 'EnvelopeId__c', 
                'Send_As_User_Email__c', 'RecallReason__c', 'StatusChangeDateTime__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            voidedReason = voidedReason != null ? voidedReason.stripHtmlTags() : null;
            fflib_StringBuilder body = new fflib_StringBuilder();
            body.add(createBodyForRecallESignature(voidedReason));
            String sendAsUserEmail = docuSignIntegrationSettings.User_Name__c;		
            String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,true);
            HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
                + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR
                + docuSignEnvelope.EnvelopeId__c, 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
            if(response.getStatusCode() == 401) {
                authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,true);
                response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
                    + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c, 'PUT', 
                    CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
            }
            if(response.getStatusCode() == 200) {
                docuSignEnvelope.Status__c = CON_CLM.IQ_VOIDED_STATUS; 
                docuSignEnvelope.RecallReason__c = voidedReason != null ? voidedReason.stripHtmlTags() : voidedReason;
                docuSignEnvelope.StatusChangeDateTime__c = DateTime.now();
                docuSignEnvelope.Signers__c = '';
                IQVIA_Agreement__c agreementToUpdate = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
                    'Account__c', 'Status_Category__c'});
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {IQVIA_Agreement__c.SObjectType, IQ_DocuSignEnvelope__c.SObjectType});
                uow.registerDirty(docuSignEnvelope);
                agreementToUpdate.Status__c = CON_CLM.READY_FOR_SIGNATURES;
                uow.registerDirty(agreementToUpdate);   
                try {
                    uow.commitWork();
                }
                catch(Exception e) {
                    System.debug(e);
                }
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_SUCCESS, '');
            }
            else {
                ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
                errorList += resError.errorCode+' : '+resError.message+',';            
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
            }
        }
        else {
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
    
    /**
    * This method is used to create body for recalling E Signatures 
    * @param String voidedReason
    * @return String
    */  
    @testVisible
    private static String createBodyForRecallESignature(String voidedReason) {
        String body = '{ "status": " ' +CON_CLM.VOIDED_STATUS+ '", "voidedReason": "' + voidedReason + '" }';
        return body;
    }

    /**
    * This method is used to check whether user exist in docusign and to add the account in filter
    * @param String agreementId
    * @param String userEmail
    * @return ESignatureResponseWrapper
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper checkIfUserExistInDocuSign(String agreementId, String userEmail) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, agreement.Docusign_Account_Id__c, 1); 
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String verifyEmail = '';
        if(CON_CLM.LOGGED_IN_USER.equalsIgnoreCase(userEmail)) {
            verifyEmail = UserInfo.getUserEmail();
        }
        else { 
            verifyEmail = userEmail;
        }
        DocuSign_Auth_Data__c dAuthData = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c' }, agreement.Docusign_Account_Id__c, 1)[0];
        String sendAsUserEmail = dAuthData.User_Name__c;
        String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,true);
        HttpResponse response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR 
            + docuSignIntegrationSettings.Account_Id__c + CON_CLM.USER_EMAIL_URL_STR + verifyEmail, 'GET', 
            CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,true);
            response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c
                + CON_CLM.USER_EMAIL_URL_STR + verifyEmail, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        }
        if (response.getStatusCode() == 200) {
            DocuSignUserWrapper docuSignUserWrapper = (DocuSignUserWrapper)JSON.deserialize(response.getBody(), DocuSignUserWrapper.class);
            if(docuSignUserWrapper.resultSetSize == '1') {
                System.JSONParser parser = System.JSON.createParser(response.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'userId')) {
                        parser.nextToken();
                        String Key = 'docusignUserId'+verifyEmail;
                        Key = Key.replaceAll('[^a-zA-Z0-9\\s+]', '');
                        sessionPartiton.put(Key, parser.getText());
                        break;
                    }
                }
                String authCode1 = getJWTAccessToken(docuSignIntegrationSettings.Name, verifyEmail,false);
                HttpResponse response1 = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR 
                    + docuSignIntegrationSettings.Account_Id__c + CON_CLM.USER_EMAIL_URL_STR + verifyEmail, 'GET', 
                    CON_CLM.BEARER_STR + authCode1, null, verifyEmail);

                if (response1.getStatusCode() == 200) {
                    return new ESignatureResponseWrapper('TRUE', CON_CLM.STATUS_SUCCESS, verifyEmail); 
                }
                else{
                    ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response1.getBody(), ResponseErrorWrapper.class);
                    errorList += resError.errorCode + ' : '+resError.message + ',';
                    errorList += CON_CLM.RECORDID_ERRORLIST_STR+agreement.Id ;
                    return new ESignatureResponseWrapper('FALSE', CON_CLM.STATUS_FAILED, errorList); 
                }
            }
            else{
                return new ESignatureResponseWrapper('FALSE', CON_CLM.STATUS_FAILED, 'No User');
            }
        }
        else{
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode + ' : '+resError.message + ',';
            errorList += CON_CLM.RECORDID_ERRORLIST_STR+agreement.Id ;
            return new ESignatureResponseWrapper('FALSE', CON_CLM.STATUS_FAILED, errorList); 
        }
    }

    /**
    * This method is used to get Docusign User Metadata List
    * @param String agreementId 
    * @return List<DocusignUserMetadataWrapper>
    */     
    @AuraEnabled
    public static List<DocusignUserMetadataWrapper> getDocusignUserMetadataList(String agreementId) {   
        String label = '';
        String value= '';
        String defaultValue = '';
        DocusignUserMetadataWrapper dumw = new DocusignUserMetadataWrapper();
        List<DocusignUserMetadataWrapper> dumList = new List<DocusignUserMetadataWrapper>();
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Record_Type_Developer_Name__c'});
        List<Docusign_Send_As_User_Details__mdt> docusignUserMetadataList = Docusign_Send_As_User_Details__mdt.getAll().values(); 
        Boolean docusignUserFound = false;
        if(docusignUserMetadataList != null && !docusignUserMetadataList.isEmpty()) {
            for(Docusign_Send_As_User_Details__mdt dum : docusignUserMetadataList) {
                if(dum.Object_API_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME && dum.Default__c == true && dum.Record_Type__c == agreement.Record_Type_Developer_Name__c) {
                    defaultValue = dum.Docusign_User_Email__c;
                }
            }
            for (Docusign_Send_As_User_Details__mdt dum : DocusignUserMetadataList) {
                if(dum.Object_API_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME && dum.Record_Type__c == agreement.Record_Type_Developer_Name__c) {
                    dumList.add(new DocusignUserMetadataWrapper(dum.MasterLabel, dum.Docusign_User_Email__c, defaultValue)) ;
                    docusignUserFound = true;
                }
            }
            if(!docusignUserFound) {
                dumList.add(new DocusignUserMetadataWrapper('No User Data Available','No User Data Available','')) ;
            }
        }
        else {
            dumList.add(new DocusignUserMetadataWrapper('No User Data Available','No User Data Available','')) ;
        }
        return dumList;
    }
    
    /**
    * This method is used to return wrapper for reminder recipient data
    * @param String agreementId
    * @return DocuSignRecipientsListWrapper
    */  
    @AuraEnabled
    public static DocuSignRecipientsListWrapper loadRecipientsDataForReminder(String agreementId) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0]; 
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition,
            CON_CLM.SENT_STATUS, agreementId, new Set<String>{'Id', 'Status__c', 'Agreement__c', 
                'Signers__c', 'EnvelopeId__c', 'Send_As_User_Email__c', 'DocusignUser_Id__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            CNT_CLM_DocuSignESignature.docusignUserId = docuSignEnvelope.DocusignUser_Id__c;
            if(docuSignEnvelope != null) {
                String sendAsUserEmail = docuSignEnvelopeList[0].Send_As_User_Email__c;
                return getExistingRecipientsFromEnvelope(docuSignIntegrationSettings, docuSignEnvelope, sendAsUserEmail);
            }else{
                errorList += 'signer information not available';   
                return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList); 
            }
        }
        else{            
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
    
    /**
    * This method is used to return wrapper for existing recipients from envelope  
    * @param DocuSign_Auth_Data__c docuSignIntegrationSettings
    * @param IQ_DocuSignEnvelope__c docuSignEnvelope
    * @param String sendAsUserEmail
    * @return DocuSignRecipientsListWrapper
    */ 
    public static DocuSignRecipientsListWrapper getExistingRecipientsFromEnvelope(DocuSign_Auth_Data__c docuSignIntegrationSettings, 
        IQ_DocuSignEnvelope__c docuSignEnvelope, String sendAsUserEmail) {
        String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,false); 
        HttpResponse response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c
            + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c + CON_CLM.RECIPIENTS_STR, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        if(response.getStatusCode() == 401) {
            authCode = getJWTAccessToken(docuSignIntegrationSettings.Name,sendAsUserEmail,false);
            response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c 
                + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c + CON_CLM.RECIPIENTS_STR, 'GET', CON_CLM.BEARER_STR + authCode, null, sendAsUserEmail);
        }
        if (response.getStatusCode() == 200) {
            List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(docuSignEnvelope.Signers__c, List<DocuSignRecipientsWrapper>.class);
            DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse = (DocuSignEnvelopeRecipientStatusResponseWrapper)JSON.deserialize(response.getBody(), DocuSignEnvelopeRecipientStatusResponseWrapper.class);
            return processExistingRecipientsForReminder(docuSignRecipientsWrapperList, docuSignRecipientsResponse);
        }
        else {
            ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
            errorList += resError.errorCode + ' : ' + resError.message + ',';   
            return new DocuSignRecipientsListWrapper(new List<DocuSignRecipientsWrapper>(), CON_CLM.STATUS_FAILED, errorList);
        }
    }
    
    /**
    * This method is used to return wrapper for existing recipients for reminder 
    * @param List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList
    * @param DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse
    * @return DocuSignRecipientsListWrapper
    */ 
    public static DocuSignRecipientsListWrapper processExistingRecipientsForReminder(List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList, 
        DocuSignEnvelopeRecipientStatusResponseWrapper docuSignRecipientsResponse) {
        Map<String, Boolean> docuSignRecipientsStatusMap = new Map<String, Boolean>();
        for(Signers signer : docuSignRecipientsResponse.signers) {
            Boolean statusCompleted = checkSignerStatusForReminder(signer.status);                       
            docuSignRecipientsStatusMap.put(signer.email + '_' + signer.roleName + '_' + signer.recipientId, statusCompleted);
        }
        for(CarbonCopies carbonCopy : docuSignRecipientsResponse.carbonCopies) {
            Boolean statusCompleted = checkSignerStatus(carbonCopy.status);                        
            docuSignRecipientsStatusMap.put(carbonCopy.email + '_' + carbonCopy.roleName + '_' + carbonCopy.recipientId, statusCompleted);
        }
        for(CertifiedDeliveries certifiedDelivery : docuSignRecipientsResponse.certifiedDeliveries) {
            Boolean statusCompleted = checkSignerStatus(certifiedDelivery.status);  
            docuSignRecipientsStatusMap.put(certifiedDelivery.email + '_' + certifiedDelivery.roleName + '_' + certifiedDelivery.recipientId, statusCompleted);
        }
        for(DocuSignRecipientsWrapper docuSignRecipientsWrapperObj : docuSignRecipientsWrapperList) {
            String mKey = docuSignRecipientsWrapperObj.email + '_' + docuSignRecipientsWrapperObj.RecipientType + '_' + docuSignRecipientsWrapperObj.RecipientId;
            if(docuSignRecipientsStatusMap.containsKey(mKey) && docuSignRecipientsStatusMap.get(mKey)) {     
                docuSignRecipientsWrapperObj.disabled = 'true';                                 
            }                       
        }
        return new DocuSignRecipientsListWrapper(docuSignRecipientsWrapperList, CON_CLM.STATUS_SUCCESS, ''); 
    }
    
    /**
    * This method checks the status for reminder
    * @param String status
    * @return Boolean 
    */ 
    public static Boolean checkSignerStatusForReminder(String status) {                       
        if(status == CON_CLM.COMPLETED) {
            return true;
        }
        else {
            return false;
        }
    }
    
    /**
    * This method returns the wrapper for send reminder for E signature 
    * @param String agreementId
    * @param String recipientsJson 
    * @return ESignatureResponseWrapper 
    */        
    @AuraEnabled
    public static ESignatureResponseWrapper sendReminderForESignature(String agreementId, String recipientsJson) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Status_Category__c', 'Docusign_Account_Id__c'});
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c', 'Name' }, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.SENT_STATUS, 
            agreementId, new Set<String>{'Id', 'Status__c', 'Agreement__c', 
                'Signers__c', 'EnvelopeId__c', 'Send_As_User_Email__c', 'DocusignUser_Id__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            CNT_CLM_DocuSignESignature.docusignUserId = docuSignEnvelope.DocusignUser_Id__c;
            fflib_StringBuilder body = new fflib_StringBuilder();
            body.add(createBodyForEsignatureReminder(agreementId, recipientsJson, true));
            String sendAsUserEmail = docuSignEnvelopeList[0].Send_As_User_Email__c;
            String authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,false);
            HttpResponse response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR
                + docuSignIntegrationSettings.Account_Id__c + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c
                + CON_CLM.RECIPIENTS_STR + '?resend_envelope=true', 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
            if(response.getStatusCode() == 401) {
                authCode = getJWTAccessToken(docuSignIntegrationSettings.Name, sendAsUserEmail,false);
                response = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR+docuSignIntegrationSettings.Account_Id__c
                    + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c + CON_CLM.RECIPIENTS_STR, 'PUT', CON_CLM.BEARER_STR
                    + authCode, body, sendAsUserEmail);
            }
            if(response.getStatusCode() == 200) {
                DocuSignSenderViewResponseWrapper docuSignResponse = (DocuSignSenderViewResponseWrapper)JSON.deserialize(response.getBody(), DocuSignSenderViewResponseWrapper.class);
                fflib_StringBuilder resendBody = new fflib_StringBuilder();
                resendBody.add(createBodyForEsignatureReminder(agreementId, recipientsJson, false));
                HttpResponse response2 = doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR + docuSignIntegrationSettings.Account_Id__c
                    + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c + CON_CLM.RECIPIENTS_STR, 'PUT', 
                    CON_CLM.BEARER_STR + authCode, resendBody, sendAsUserEmail);
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_SUCCESS, ''); 
            }
            else{
                ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
                errorList += resError.errorCode + ' : ' + resError.message + ',';            
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
            }
        }
        else {
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
    
    /**
    * This method returns body for E Signature Reminder
    * @param String agreementId
    * @param String recipientsJson
    * @param Boolean resend
    * @return String
    */ 
    public static String createBodyForESignatureReminder(String agreementId, String recipientsJson, Boolean resend) {
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 'Status__c', 
            'Account__c', 'Docusign_Account_Id__c', 'Status_Category__c'});
        List<DocuSign_Auth_Data__c > docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocuSign_Pwd__c', 'Client_Id__c' }, agreement.Docusign_Account_Id__c, 1);
        DocuSign_Auth_Data__c  docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.SENT_STATUS, 
            agreementId, new Set<String>{'Id', 'Status__c', 'Agreement__c', 'Signers__c'}, 'LastModifiedDate', 'DESC', 1);
        IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
        List<DocuSignRecipientsWrapper> docuSignRecipientsWrapperList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(docuSignEnvelope.Signers__c, List<DocuSignRecipientsWrapper>.class);
        String body = '{';        
        String recipientBodySigners = '"signers":[';       
        String recipientBodyCarbonCopies = '"carbonCopies":[';
        String recipientBodyCertifiedDeliveries = '"certifiedDeliveries":[';
        Set<String> routingOrderSet =  new Set<String>();
        List<String> routingOrderList = new List<String>();
        List<DocuSignRecipientsWrapper> updatedRecipientsList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(recipientsJson, List<DocuSignRecipientsWrapper>.class);
        for(DocuSignRecipientsWrapper recipient : updatedRecipientsList) {
            if(recipient.disabled != 'true') {
                routingOrderList.add(recipient.SigningOrder);
            }
        }
        routingOrderList.sort();
        String nextRoutingOrder = routingOrderList[0];
        for(DocuSignRecipientsWrapper recipient : updatedRecipientsList){
            String emailSubject = '';
            if(resend) {
                emailSubject = 'Reminder: ' + recipient.EmailSubject;
            }
            else {
                emailSubject = recipient.EmailSubject;
            }
            String emailBody = recipient.EmailBody;
            if(recipient.disabled != 'true' && recipient.SigningOrder.equalsIgnoreCase(nextRoutingOrder)) {
                if(CON_CLM.RECIPIENT_TYPE_SIGNER.equalsIgnoreCase(recipient.RecipientType)) {
                    recipientBodySigners += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.RECIPIENTID_STR
                        + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + CON_CLM.EMAIL_NOTIFICATION_STR
                        + emailSubject + CON_CLM.EMAIL_BODY_STR + emailBody + '"}},';   
                }
                else if(CON_CLM.RECIPIENT_TYPE_CC.equalsIgnoreCase(recipient.RecipientType)) {
                    recipientBodyCarbonCopies += CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name + CON_CLM.RECIPIENTID_STR
                        + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder + CON_CLM.EMAIL_NOTIFICATION_STR
                        + emailSubject + CON_CLM.EMAIL_BODY_STR + emailBody+'"}},';                                
                }
                else if(CON_CLM.RECIPIENT_TYPE_CERTIFIED_DELIVERY.equalsIgnoreCase(recipient.RecipientType)) { 
                    recipientBodyCertifiedDeliveries +=CON_CLM.EMAIL_STR + recipient.email + CON_CLM.NAME_STR + recipient.Name
                        + CON_CLM.RECIPIENTID_STR + recipient.RecipientId + CON_CLM.ROUTING_ORDER_STR + recipient.SigningOrder
                        + CON_CLM.EMAIL_NOTIFICATION_STR + emailSubject + CON_CLM.EMAIL_BODY_STR + emailBody+'"}},';          
                }
            }
        }
        recipientBodySigners = recipientBodySigners.substring(0, recipientBodySigners.length() - 1);
        recipientBodyCarbonCopies.removeEnd(',');
        recipientBodyCertifiedDeliveries.removeEnd(',');
        recipientBodyCertifiedDeliveries += ']';        
        recipientBodyCarbonCopies += ']';
        recipientBodySigners += ']';
        body += recipientBodySigners+',';
        body += recipientBodyCarbonCopies+',';
        body += recipientBodyCertifiedDeliveries;
        body += '}';
        return body;
    } 
    
    /**
    * This method is used to get JWT Access Token
    * @param String accId
    * @param String userEmail
    * @return String
    */ 
    public static String getJWTAccessToken(String accId, String userEmail, boolean isAdminUser) {        
        DocuSign_Auth_Data__c docuSignIntegrationSettings;
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocusignUser_Id__c', 'Client_Id__c' , 'Private_Key__c', 'Name'}, accId, 1);
        docuSignIntegrationSettings = docuSignAccountSettingList.size() > 0 ? docuSignAccountSettingList[0] : new DocuSign_Auth_Data__c();
        String authBaseUrl = (docuSignIntegrationSettings.Base_URL__c).contains('demo') ? 'account-d.docusign.com' : 'account.docusign.com' ;
        String accessToken = null;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint('https://'+authBaseUrl+'/oauth/token');
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', authBaseUrl);
        String alg = Test.isRunningTest() ? 'none' : 'RS256';
        //add integration key
        String iss = docuSignIntegrationSettings.Client_Id__c;
        String pkey = docuSignIntegrationSettings.Private_Key__c;
        String duserId;
        if(isAdminUser || Test.isRunningTest()) {
            duserId = docuSignIntegrationSettings.DocusignUser_Id__c;
        } else {
            String Key = 'docusignUserId'+userEmail;
            Key = Key.replaceAll('[^a-zA-Z0-9\\s+]', '');
            if(!System.isBatch()) {
                duserId = (String)sessionPartiton.get(Key);
                if(duserId == null) {
                    duserId = CNT_CLM_DocuSignESignature.docusignUserId;
                }
            } else {
                duserId = CNT_CLM_DocuSignESignature.docusignUserId;
                if(duserId == null) {
                    CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
                    duserId = configuration.DocusignUserId__c;
                }
            }
        }
        String scope = 'signature impersonation';
        DocuSignJWT jwtObject = new DocuSignJWT(alg, duserId, iss, pkey, scope, authBaseUrl);
        //Set the request body	
        String requestBody = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwtObject.issue();
        req.setBody(requestBody);
        //call the service
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //Obtain the access token from the Response
        if (res.getStatusCode() == 200) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    accessToken = parser.getText();
                    break;
                }
            }
        }
        return accessToken;
    }
    
    /**
    * This method is used to complete E Signature process
    * @param String selectedAttJSON
    * @param String selectedSignersJSON
    * @param String emailSubject
    * @param String emailBlurb
    * @param String agreementId
    * @param String reminderAndExp
    * @param String sendAsUserEmail
    * @return ESignatureResponseWrapper
    */  
    @AuraEnabled
    public static ESignatureResponseWrapper processESignature(String selectedAttJSON, String selectedSignersJSON, String emailSubject, 
        String emailBlurb, String agreementId, String reminderAndExp, String sendAsUserEmail) {
        errorList = '';        
        Set<Id> selectedAttIds = (Set<Id>)JSON.deserialize(selectedAttJSON, Set<Id>.class);
        List<ContentVersion> selectedAttList = new SLT_ContentVersion().selectById(selectedAttIds); 
        List<DocuSignRecipientsWrapper> selectedSignersList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(selectedSignersJSON, List<DocuSignRecipientsWrapper>.class);
        ReminderAndExpWrapper reminderAndExpRec = (ReminderAndExpWrapper)JSON.deserialize(reminderAndExp, ReminderAndExpWrapper.class);
        IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 
            'Docusign_Account_Id__c', 'FF_Agreement_Number__c', 'Status__c', 'Status_Category__c', 'RecordTypeId'}); 
        Integer totalBodyLength = 0;
        Integer totalBodyLengthInKb = 0;
        Integer batchSize = 1;                                                                                                           
        for(ContentVersion att : selectedAttList) {    
            totalBodyLength = totalBodyLength + att.ContentSize;
        }
        totalBodyLengthInKb = totalBodyLength / 1024;
        if(totalBodyLengthinKb > 10000) {
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAIL, CON_CLM.ATTACHMENT_LENGTH_ERROR_MSG);
        }
        else {
            String Key = 'docusignUserId' + sendAsUserEmail;
            Key = Key.replaceAll('[^a-zA-Z0-9\\s+]', '');
            String docusignUserId = (String)sessionPartiton.get(Key);
            String batchId = Database.executeBatch(new BCH_CLM_DocuSignESignatureBatch(CON_CLM.SENT_STATUS, emailSubject, emailBlurb, 
                selectedAttList, selectedSignersList, agreement, reminderAndExpRec, sendAsUserEmail, docusignUserId), batchSize);
            return new ESignatureResponseWrapper(batchId, CON_CLM.STATUS_SUCCESS, '');
        }            
    }

    /**
    * This method is used to preview recipients
    * @param String selectedSignersJSON
    * @return DocuSignRecipientsListWrapper
    */
    @AuraEnabled
    public static DocuSignRecipientsListWrapper previewRecipents(String selectedSignersJSON) {
        Integer riIndex = 1;
        List<DocuSignRecipientsWrapper> selectedSignersList = (List<DocuSignRecipientsWrapper>)JSON.deserialize(selectedSignersJSON, List<DocuSignRecipientsWrapper>.class);
        for(DocuSignRecipientsWrapper recipient : selectedSignersList) {            
            recipient.recipientId = String.valueOf(riIndex);                        
            riIndex = riIndex + 1;                       
        }
        return new DocuSignRecipientsListWrapper(selectedSignersList, CON_CLM.STATUS_SUCCESS, '');
    }
    
    /**
    * This method is used to send docusign envelope
    * @param String agreementId 
    * @param String sendAsUserEmail
    * @param String docuSignAccId
    * @return ESignatureResponseWrapper
    */ 
    @AuraEnabled
    public static ESignatureResponseWrapper sendDocusignEnv(String agreementId, String sendAsUserEmail, String docuSignAccId) {
        String authCode = getJWTAccessToken(docuSignAccId, sendAsUserEmail,false);
        fflib_StringBuilder body = new fflib_StringBuilder();
        body.add('{"status": " '+ CON_CLM.ENVELOPE_STATUS_SENT+ '"}');
        List<DocuSign_Auth_Data__c> docuSignAccountSettingList = new SLT_DocuSign_Auth_Data().getDocusignAuthDataDetailsByAccountId(new Set<String>{'Id', 
            'Base_URL__c', 'Account_Id__c', 'Access_Token__c', 'User_Name__c', 'DocusignUser_Id__c', 'Client_Id__c' , 'Private_Key__c', 'Name'}, docuSignAccId, 1);
        DocuSign_Auth_Data__c docuSignIntegrationSettings = docuSignAccountSettingList[0];
        String condition = 'Status__c =: firstParam and Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().getDocusignEnvelopeByCondition(condition, CON_CLM.IQ_ENVELOPE_STATUS_CREATED,
            agreementId, new Set<String>{'EnvelopeId__c', 'Send_As_User_Email__c', 'Signers__c'}, 'LastModifiedDate', 'DESC', 1);
        if(!docuSignEnvelopeList.isEmpty()) {
            IQ_DocuSignEnvelope__c docuSignEnvelope = docuSignEnvelopeList[0];
            if(docuSignEnvelope != null) {
                HttpResponse response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR_2_1 + docuSignIntegrationSettings.Account_Id__c
                    + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c, 'PUT', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
                if(response.getStatusCode() == 401) {
                    authCode = getJWTAccessToken(docuSignAccId, sendAsUserEmail,false);
                    response = CNT_CLM_DocuSignESignature.doHttpCallout(docuSignIntegrationSettings.Base_URL__c, CON_CLM.RESTAPI_STR_2_1 + docuSignIntegrationSettings.Account_Id__c
                        + CON_CLM.ENVELOPE_STR + docuSignEnvelope.EnvelopeId__c, 'POST', CON_CLM.BEARER_STR + authCode, body, sendAsUserEmail);
                }
                if(response.getStatusCode() == 200) {
                    IQVIA_Agreement__c  agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agreementId, new Set<String>{'Id', 'Name', 
                        'Status__c', 'Account__c', 'DocuSign_Envelope_Id__c', 'Status_Category__c', 'RecordTypeId'});
                    updateAgreementStatus(agreement, '', CON_CLM.SENT_STATUS);
                    updateDocuSignEnvelope(docuSignEnvelope.EnvelopeId__c);
                    return new ESignatureResponseWrapper('', CON_CLM.STATUS_SUCCESS, '');
                }
                else {
                    ResponseErrorWrapper resError = (ResponseErrorWrapper)JSON.deserialize(response.getBody(), ResponseErrorWrapper.class);
                    errorList += resError.errorCode + ' : ' + resError.message + ',';
                    errorList += CON_CLM.RECORDID_ERRORLIST_STR + agreementId;           
                    return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
                }   
            }
            else {
                errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;  
                return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList);  
            }
        }
        else {            
            errorList += CON_CLM.NO_ACTIVE_ENVELOPE_ERROR_STR;            
            return new ESignatureResponseWrapper('', CON_CLM.STATUS_FAILED, errorList); 
        }    
    }
        
    public class AttachmentWrapper {
        @AuraEnabled
        public String attId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public string lastModifiedBy {get; set;}
        @AuraEnabled
        public string fileType {get; set;}
        @AuraEnabled
        public DateTime lastModifiedDate {get; set;}
        @AuraEnabled
        public String bodyLength {get; set;}
        @AuraEnabled
        public boolean checked {get; set;}
        
        public AttachmentWrapper(String attId, String name, DateTime lastModifiedDate, String bodyLength, String lastModifiedBy, String fileType, boolean checked) {
            this.attId = attId;
            this.name = name;
            this.lastModifiedBy = lastModifiedBy;
            this.fileType = fileType;
            this.lastModifiedDate = lastModifiedDate; 
            Integer bl = Integer.valueOf(bodyLength);
            Decimal blkb = bl/1000;            
            this.bodyLength = String.valueOf(blkb)+' kb';
            this.checked = checked;
        }        
    }
    
    public class EmailDataWrapper {
        @AuraEnabled
        public String subject {get; set;}
        @AuraEnabled
        public String body {get; set;}
        
        public EmailDataWrapper() {
            this.subject = null;
            this.body = null;
        }
        
        public EmailDataWrapper(String subject, String body) {
            this.subject = subject;
            this.body = body;
        }        
    }
    
    public class DocuSignRecipientsWrapper {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String recipientId {get; set;}
        @AuraEnabled
        public String signingOrder {get; set;}
        @AuraEnabled
        public String recipientType {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String email {get; set;}
        @AuraEnabled
        public String privateMessage {get; set;}
        @AuraEnabled
        public String disabled {get; set;}
        @AuraEnabled
        public String userType {get; set;}
        @AuraEnabled
        public String emailTemplate {get; set;}
        @AuraEnabled
        public String emailSubject {get; set;}
        @AuraEnabled
        public String emailBody {get; set;}
        
        public DocuSignRecipientsWrapper(DocuSignRecipientsWrapper obj) {
            this.id = obj.id;
            this.recipientId = obj.recipientId;
            this.signingOrder = obj.signingOrder;
            this.recipientType = obj.recipientType;
            this.name = obj.name;
            this.email = obj.email;
            this.privateMessage = obj.privateMessage;
            this.disabled = 'true';
            this.userType = obj.userType;
            this.emailTemplate = obj.emailTemplate;
            this.emailSubject = obj.emailSubject;
            this.emailBody = obj.emailBody;
        }
        public DocuSignRecipientsWrapper(String Id,String recipientId, String signingOrder, String recipientType, String name, String email, 
            String privateMessage) {
            this.Id = Id;
            this.recipientId = recipientId;
            this.signingOrder = signingOrder;
            this.recipientType = recipientType;
            this.name = name;
            this.email = email;
            this.privateMessage = privateMessage;
            this.disabled = 'true';
            this.UserType = UserType;
            this.emailTemplate = emailTemplate;
            this.emailSubject = emailSubject;
            this.emailBody = emailBody;
        }
    } 
    
    public class ReminderAndExpWrapper {
        @AuraEnabled
        public Integer expireAfter {get; set;}
        @AuraEnabled
        public Integer expireWarn {get; set;}
        @AuraEnabled
        public Integer reminderDelay {get; set;}
        @AuraEnabled
        public Integer reminderFrequency {get; set;}
        
        public ReminderAndExpWrapper(String expireAfter, String expireWarn, String reminderDelay, String reminderFrequency) {
            this.expireAfter = Integer.valueOf(expireAfter);
            this.expireWarn = Integer.valueOf(expireWarn);
            this.reminderDelay = Integer.valueOf(reminderDelay);
            this.reminderFrequency = Integer.valueOf(reminderFrequency);    
        }
    } 
    
    public class ESignatureResponseWrapper {
        @AuraEnabled
        public String batchId {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String message {get; set;}
        
        public ESignatureResponseWrapper(String batchId, String status, String message) {
            this.batchId = batchId;
            this.status = status;
            this.message = message;
        }
    }
    
    public class DocuSignEnvelopeResponseWrapper {
        public String envelopeId {get; set;}
        public String uri {get; set;}
        public String statusDateTime {get; set;}
        public String status {get; set;}
    }
    
    public class DocuSignEnvelopeRecipientStatusResponseWrapper {
        public List<Signers> signers {get; set;}
        public List<CarbonCopies> carbonCopies {get; set;}
        public List<CertifiedDeliveries> certifiedDeliveries {get; set;}
        public String recipientCount {get; set;}
        public String currentRoutingOrder {get; set;}
    }
    
    public class Signers {
        public String creationReason {get; set;}
        public String isBulkRecipient {get; set;}
        public String name {get; set;}
        public String email {get; set;}
        public String recipientId {get; set;}
        public String recipientIdGuid {get; set;}
        public String requireIdLookup {get; set;}
        public String userId {get; set;}
        public String routingOrder {get; set;}
        public String roleName {get; set;}
        public String status {get; set;}
        public String recipientTab {get; set;}
        public DateTime signedDateTime;
        public DateTime deliveredDateTime;
        public Tabs tabs;
    }
    
    public class CarbonCopies {
        public String name {get; set;}
        public String email {get; set;}
        public String recipientId {get; set;}
        public String recipientIdGuid {get; set;}
        public String requireIdLookup {get; set;}
        public String userId {get; set;}
        public String routingOrder {get; set;}
        public String roleName {get; set;}
        public String status {get; set;}
        public String recipientTab {get; set;}
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
    
    public class CertifiedDeliveries {
        public String name {get; set;}
        public String email {get; set;}
        public String recipientId {get; set;}
        public String recipientIdGuid {get; set;}
        public String requireIdLookup {get; set;}
        public String userId {get; set;}
        public String routingOrder {get; set;}
        public String roleName {get; set;}
        public String status {get; set;}
        public String recipientTab {get; set;}
    }
    
    public class EmailTemplateWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String internalDefault {get; set;}
        @AuraEnabled
        public String externalDefault {get; set;}
        @AuraEnabled
        public String recordTypeName {get; set;}
        
        public EmailTemplateWrapper() {
            this.label = null;
            this.value = null;
            this.internalDefault = null;
            this.externalDefault = null;
            this.recordTypeName = null;
        }
        
        public EmailTemplateWrapper(String label, String value, String internalDefault, String externalDefault, String recordTypeName){
            this.label = label;
            this.value = value;
            this.internalDefault = internalDefault;
            this.externalDefault = externalDefault;
            this.recordTypeName = recordTypeName;
        }        
    }
    
    public class AccessTokenWrapper {
        public String accessToken {get; set;}
        public String tokenType {get; set;}
        public String scope {get; set;}        
    }   
    
    public class ResponseErrorWrapper {        
        public String errorCode {get; set;}
        public String message {get; set;}      
    }
    
    public class ApexJobWrapper {
        @AuraEnabled
        public String extendedStatus {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public integer jobItemsProcessed {get; set;}
        @AuraEnabled
        public integer totalJobItems {get; set;}
        @AuraEnabled
        public integer numberOfErrors {get; set;}
        
        public ApexJobWrapper(String extendedStatus, String status, integer jobItemsProcessed, integer totalJobItems, integer numberOfErrors) {
            this.extendedStatus = extendedStatus;
            this.status = status;
            this.jobItemsProcessed = jobItemsProcessed;
            this.totalJobItems = totalJobItems;
            this.numberOfErrors = numberOfErrors;
        }
    }
    
    public class DocuSignUserWrapper {
        public List<Users> users;
        public String resultSetSize;
        public String totalSetSize;
        public String startPosition;
        public String endPosition;
    }
    
    public class Users {
        public String userId;
        public String email;
    }
    
    public class DocusignUserMetadataWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String defaultValue {get; set;}
        
        public DocusignUserMetadataWrapper() {
            this.label = null;
            this.value = null;
            this.defaultValue = null;
        }
        
        public DocusignUserMetadataWrapper(String label, String value,String defaultValue){
            this.label = label;
            this.value = value;
            this.defaultValue = defaultValue;
        }        
    }
    
    public class DocuSignRecipientsListWrapper {
        @AuraEnabled
        public List<DocuSignRecipientsWrapper> recipientList {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String message {get; set;}
        
        public DocuSignRecipientsListWrapper(List<DocuSignRecipientsWrapper> recipientList, String status, String message){
            this.recipientList = recipientList;
            this.status = status;
            this.message = message;
        }        
    }
    
    public class BulkEmailDataWrapper {
        @AuraEnabled
        public String subject {get; set;}
        @AuraEnabled
        public String body {get; set;}
        @AuraEnabled
        public String template {get; set;}
        public BulkEmailDataWrapper(){
            this.subject = null;
            this.body = null;
            this.template = null;
        }
        
        public BulkEmailDataWrapper(String subject, String body,String template){
            this.subject = subject;
            this.body = body;
            this.template = template;
        }        
    }
    
    public class DocuSignSenderViewResponseWrapper{
        @AuraEnabled
        public String url {get; set;}
        
        public DocuSignSenderViewResponseWrapper(String url) {
            this.url = url;
        }
    }
    
    /**
    * This method is used to get existing open docusign Envelope
    * @param String agrId
    * @return List<SObject>
    */ 
    @AuraEnabled 
    public static List<SObject> getOpenDocuSignEnvelope(String agrId) {
        String condition = 'Status__c != \''+ CON_CLM.COMPLETED_STATUS +'\' AND Status__c != \'' + CON_CLM.IQ_VOIDED_STATUS +'\'' +
            'AND Status__c != \'' +CON_CLM.DRAFT +'\' AND Status__c != \''+ CON_CLM.CANCELLED + '\' AND Status__c != \''+ CON_CLM.DECLINED_STATUS+ '\' AND Agreement__c =: secondParam';
        List<IQ_DocuSignEnvelope__c> docuSignEnvelopeList = new SLT_IQDocuSignEnvelope().
            getDocusignEnvelopeByCondition(condition, null, 
            agrId, new Set<String>{'Id', 'Status__c'}, 'LastModifiedDate', 'DESC', 1);	
        return docuSignEnvelopeList;
    }
}