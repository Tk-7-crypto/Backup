/*
* Version       : 1.0
* Description   : Apex Utility class for CLM. 
*/ 
public class UTL_CLM {
    
    /*
     * getPicklistEntryValue Used to bind picklist
     * @param  objectName 
     * @param  fieldName  
     * @return return map of labels and values.         
     */ 
    public static Map<String, String> getPicklistEntryValue(String objectName, String fieldName, Boolean valueToLabelMap) {
        Map<String, String> mapPicklistLabelValue = new Map<String, String>();
        String[] types = new String[] {objectName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for (Schema.DescribeSobjectResult res: results) {
            for (Schema.PicklistEntry entry: res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    if(valueToLabelMap) {
                        mapPicklistLabelValue.put(entry.getValue(), entry.getLabel());
                    }else {
                        mapPicklistLabelValue.put(entry.getLabel(), entry.getValue());
                    }
                }
            }
        }
        return mapPicklistLabelValue;
    }
    
    /*
     * getPicklistValues Used to bind picklist
     * @param  objectType    
     * @param  selectedField 
     * @return List of labels
     */ 
    public static List<String> getPicklistValues(String objectType, String selectedField) {
        List<String> picklistValuesList = new List<String>();
        Schema.SObjectType objectDetail = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult objectResult = objectDetail.getDescribe();
        Schema.DescribeFieldResult fieldResult = objectResult.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : ple) {
            picklistValuesList.add(picklistVal.getLabel());
        }
        return picklistValuesList; 
    }

    /**
    * This method used to get map of field name and label  by object type
    * @return  Map<String,String>
    */
    public static Map<String,String> getFieldAPINameLabelMap(String objectType) {
        Map<String,String> mapFieldAPILabel = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectType);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            String fieldAPIName = fieldMap.get(fieldName).getDescribe().getName();
            mapFieldAPILabel.put(fieldAPIName,fieldLabel); 
        }
        return mapFieldAPILabel;
    }

    /**
     * This function iterates through the object provides as argument and converts them in a query.
     * @param  objectApiName is the API name of SObject
     * @param condition is the where clause of SOQL
     * @return               a string of SOQL query of all fields.
     */
    public static String queryStringOfAllFieldsOfSObject(String objectApiName, String condition) {
        Map<String, String> fields = getFieldAPINameLabelMap(objectApiName);
        String query = null;
        if(fields != null && !fields.isEmpty()) {
            query = 'SELECT ';
            List<String> fieldsAPINameList = new List<String>(fields.keySet());
            for (Integer i = 0; i < fieldsAPINameList.size(); i++) { 
                query += fieldsAPINameList.get(i);
                if(i != fieldsAPINameList.size() - 1) {
                    query += ', ';
                }
            }
            query += ' FROM ' + objectApiName;
            if(String.isNotBlank(condition)) {
                query += condition;
            }
        }
        return query;
    }

    public static String getSessionIdFromVFPage() {
        if(Test.isRunningTest()) {
            return 'SESSION_ID';
        } else {
            String SESSION_ID_START = 'SESSION_ID_START';
            String SESSION_ID_END = 'SESSION_ID_END';
            String pageContent = Page.VFP_CLM_SessionId.getContent().toString();
            Integer startIndex = pageContent.indexOf(SESSION_ID_START) + SESSION_ID_START.length();
            Integer endIndex = pageContent.indexOf(SESSION_ID_END);
            return pageContent.substring(startIndex, endIndex);
        }
    }

    public static Map<String,String> getPicklistOptionsByRecordTypeId(String objectType, String recordTypeId, String fieldName) {
        //Endpoint
        String endpoint = URL.getOrgDomainUrl().toExternalForm();
        endpoint += '/services/data/v41.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{ objectType, recordTypeId, fieldName });
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        
        //HTTP Request send
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'OAuth ' + getSessionIdFromVFPage()); 
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //Parse response
        Map<String,String> result = new Map<String,String>();
        Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(res.getBody().replaceAll('&amp;','&'));
        if(!root.containsKey('values')){ 
            return result; 
        }
        List<Object> pValues = (List<Object>)root.get('values');
        for(Object pValue : pValues){
            Map<String,Object> pValueMap = (Map<String,Object>)pValue;
            result.put((String)pValueMap.get('value'), (String)pValueMap.get('label'));
        }
        
        return result;
    }

    /*
    * This method is used to create single email message.
    * @param List<String> toAddresses
    * @param String subject
    * @param String htmlBody
    * @param String senderDisplayName
    * @param String orgWideEmailAddressId
    * @param List<Messaging.Emailfileattachment> fileAttachments
    * @return Messaging.SingleEmailMessage
    */
    public static Messaging.SingleEmailMessage createSingleEmailMessage(List<String> toAddresses, String subject, 
        String htmlBody, String senderDisplayName,
        String orgWideEmailAddressId, List<Messaging.Emailfileattachment> fileAttachments) {
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        if(senderDisplayName != null) {
            mail.setSenderDisplayName(senderDisplayName);
        }
        if (orgWideEmailAddressId != null) {
            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        }   
        if(fileAttachments != null) {
            mail.setFileAttachments(fileAttachments);
        }
        return mail;
    }
    
    /*
    * This method is used to send the emails.
    * @param List<Messaging.SingleEmailMessage> mails
    */
    public static void sendEmail(List<Messaging.SingleEmailMessage> mails) {
        if(!Test.isRunningTest()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        }
    }

    /*
    * This method is used to get the record type info by Name
    * @param Set<String> recordTypeNames
    */
    public static List<RecordType> getAGRRecordTypeListByDevName(Set<String> recordTypeNames) {
        List<RecordType> listRecordType = new List<RecordType>();
        Map<String,Schema.RecordTypeInfo>  rtMapByName = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName();
        for(String recordTypeName : recordTypeNames){
            Schema.RecordTypeInfo recordTypeInfo = rtMapByName.get(recordTypeName);
            if(recordTypeInfo.isActive()){
                listRecordType.add(new RecordType(Id = recordTypeInfo.getRecordTypeId(), Name = recordTypeInfo.getName() ,
                    DeveloperName = recordTypeInfo.getDeveloperName()));
            }
        }
        return listRecordType;
    }

    /*
    * This method is used to get the record type info by Id
    * @param Set<Id> recordTypeNames
    */
    public static List<RecordType> getAGRRecordTypeListById(Set<Id> recordTypeIds) {
        List<RecordType> listRecordType = new List<RecordType>();
        Map<Id,Schema.RecordTypeInfo>  rtMapById = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosById();
        for(Id recordTypeId : recordTypeIds){
            Schema.RecordTypeInfo recordTypeInfo = rtMapById.get(recordTypeId);
            if(recordTypeInfo.isActive()){
                listRecordType.add(new RecordType(Id = recordTypeInfo.getRecordTypeId(), Name = recordTypeInfo.getName(),
                    DeveloperName = recordTypeInfo.getDeveloperName()));
            }
        }
        return listRecordType;
    }
    
    /*
    * This method is used to fetch the record type name for Agreement status automation
    * @return List of record type names
    */
    public static List<String> fetchRecordTypeNameInAgrStatusAutomation() {
        CLM_Configuration__c recordTypeClmConfOrgDefault = CLM_Configuration__c.getOrgDefaults();
        String clmRecordTypes = recordTypeClmConfOrgDefault.RecordTypeForStatusAutomation__c;
        List<String> clmRecordTypeList = new List<String>();
        if (clmRecordTypes != null) {
            clmRecordTypeList = clmRecordTypes.split(';');
        }
        return clmRecordTypeList;
    }

    /*
    * This method is used to create agreement record from quote record
    * @param Id recId
    * @return Id
    */
    public static Id createPreliminaryRecordFromQuote(Id quoteId) {
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        Apttus_Proposal__Proposal__c proposalRecord = new SLT_Proposal().getProposalDetails(quoteId, new Set<String>
            {'Apttus_Proposal__Account__c', 'Apttus_Proposal__Opportunity__c', 'CurrencyIsoCode', 'Name', 
            'Apttus_Proposal__Opportunity__r.Legacy_Quintiles_Opportunity_Number__c','Apttus_Proposal__Proposal_Name__c'});

        agreement.RecordTypeId = CON_CLM.PRELIMINARY_RECORDTYPEID;
        agreement.Name = proposalRecord.Apttus_Proposal__Proposal_Name__c;
        agreement.Apttus_QPComply__RelatedProposalId__c = proposalRecord.Id;
        agreement.Apttus__Account__c = proposalRecord.Apttus_Proposal__Account__c;
        agreement.Apttus__Related_Opportunity__c = proposalRecord.Apttus_Proposal__Opportunity__c;
        agreement.CurrencyIsoCode = proposalRecord.CurrencyIsoCode;
        agreement.Project_Number__c = proposalRecord.Apttus_Proposal__Opportunity__r.Legacy_Quintiles_Opportunity_Number__c;
            
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Agreement__c.SObjectType
            }
        );
        uow.registerNew(agreement);
        try {
            uow.commitWork();
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        return agreement.Id;
    }

    /**
     * This method performs operation on given sobjectType to get all createable and accessible fields
     * @param sobjType is SObjectType for which fields are going to be fetched
     * @return Set<String> contains the API Names of all fields.
     */
    public static Set<String> getSObjectTypeFields(Schema.SObjectType sobjType, Boolean editableFields) {
        Set<String> fields = new Set<String>();
        Map<String, Schema.SObjectField> mapOfFieldAPINameAndField = sobjType.getDescribe().fields.getMap();
        if(mapOfFieldAPINameAndField != null) {
            for(Schema.SObjectField field : mapOfFieldAPINameAndField.values()) {
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                if((fieldResult.isAccessible() && !Test.isRunningTest()) || Test.isRunningTest()) {
                    if(editableFields && fieldResult.isCreateable()) {
                        fields.add(fieldResult.getName());
                    } else if(!editableFields){
                        fields.add(fieldResult.getName());
                    }
                    
                }
            }
        }
        return fields;
    }

    /**
    * This method is used to return Set of Field API Names based on object API name which are to be excluded while cloning
    * @param String objectAPIName
    * @return Set<String> 
    */
    public static Set<String> getFieldAPINameSetForExcludedFields(String objectAPIName) {
        Set<String> setOfFieldAPIName = new Set<String>();
        List<CLM_Quote_Agreement_Clone_Excluded_Field__c> lstExcludedFields = CLM_Quote_Agreement_Clone_Excluded_Field__c.getAll().values();                
        if(!lstExcludedFields.isEmpty()) {
            for(CLM_Quote_Agreement_Clone_Excluded_Field__c field : lstExcludedFields) {
                if(field.Object_Name__c == objectAPIName && field.Field_API_Name__c != null) {
                    setOfFieldAPIName.add(field.Field_API_Name__c);
                }
            }    
        }
        return setOfFieldAPIName;
    }
    
    /**
    * This method is used to prevent cloning of field values while amending an agreement through amend button
    * @param String objectAPIName
    * @param Apttus__APTS_Agreement__c agreement
    * @return Set<String> 
    */
    public static Set<String> excludeFieldsFromCloningWhileAmendingAgreement(String objectAPIName) {
        Set<String> setOfFieldAPIName = new Set<String>();
        List<CLM_Amend_Agreement_Clone_Excluded_Field__c> lstExcludedFields = CLM_Amend_Agreement_Clone_Excluded_Field__c.getAll().values();
        Map <String,Schema.SObjectField> allobjFields = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap();
        
        if(!lstExcludedFields.isEmpty()) {
            for(CLM_Amend_Agreement_Clone_Excluded_Field__c field : lstExcludedFields) {
                if(field.Object_Name__c == objectAPIName && field.Field_API_Name__c != null 
                    && allobjFields.containsKey(field.Field_API_Name__c)) {
                    setOfFieldAPIName.add(field.Field_API_Name__c);
                }
            }    
        }
        return setOfFieldAPIName;
    }
    
    /**
    * This method is used to concatenate several messages for an exception 
    * @param Exception exceptionThrown 
    * @return String 
    */ 
    public static String concatenateException(Exception exceptionThrown) {
        String result = null;
        if(exceptionThrown != null) {
            String lineNumber = String.valueOf(exceptionThrown.getLineNumber());
            String message = exceptionThrown.getMessage();     
            String stackTrace = exceptionThrown.getStackTraceString();
            String typeOfException = exceptionThrown.getTypeName();
            result = lineNumber + ' ' + message + ' ' + stackTrace + ' ' + typeOfException;   
        }    
        return result; 
    }
    
    /**
    * This method is used to convert attachments into Salesforce Files
    * @param List<Attachment> attachments
    */ 
    public static void convertAttachmentsIntoFiles(List<Attachment> attachments, Boolean isFromTrigger) {
        Map<Id, Id> attachmentIdtoAttachmentParentIdMap = new Map<Id, Id>();
        Map<Id, ContentVersion> attachmentIdtoContentVersion = new Map<Id, ContentVersion>();
        for(Attachment attachment : attachments) {
            ContentVersion newFileVersion = new ContentVersion(
                versionData = attachment.body, title = attachment.name,
                description = attachment.description, pathOnClient = '/' + attachment.name,
                sharingPrivacy = (attachment.isPrivate ? 'P' : 'N' ), createdById = attachment.ownerId,
                createdDate = attachment.createdDate, lastModifiedById = attachment.lastModifiedById,
                lastModifiedDate = attachment.lastModifiedDate, OwnerId	= attachment.OwnerId,
                Origin = 'C', ContentLocation = 'S', Legacy_Attachment_Id__c = attachment.Id);
            attachmentIdtoContentVersion.put(attachment.Id, newFileVersion);
            attachmentIdtoAttachmentParentIdMap.put(attachment.Id, attachment.ParentId);
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType> {ContentVersion.SObjectType}
        );
        if(!attachmentIdtoContentVersion.isEmpty()) {
            uow.registerNew(attachmentIdtoContentVersion.values());
            uow.commitWork();
        }
        Set<Id> contentVersionSet = new Set<Id>();
        Map<Id, Id> contentVersionIdToAttachmentParentIdMap = new Map<Id, Id>();
        for(Id attachmentId: attachmentIdtoAttachmentParentIdMap.keySet()) {
            contentVersionSet.add(attachmentIdtoContentVersion.get(attachmentId).Id);
            contentVersionIdToAttachmentParentIdMap.put(attachmentIdtoContentVersion.get(attachmentId).Id, 
                attachmentIdtoAttachmentParentIdMap.get(attachmentId));
        }
        copyContentDocumentLink(contentVersionSet, contentVersionIdToAttachmentParentIdMap);
        UTL_CLM.deleteListOfAttachments(attachmentIdtoAttachmentParentIdMap.keySet(),isFromTrigger);
        
    }
    
    /**
    * This method is used to create ContentDocumentLink for ContentVersions
    * @param Set<Id> contentVersionSet
    * @param Map<Id, Id> contentVersionIdToAttachmentParentIdMap
    */ 
    @TestVisible
    private static void copyContentDocumentLink(Set<Id> contentVersionSet, Map<Id, Id> contentVersionIdToAttachmentParentIdMap) {
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        List<Log_History__c> lstLogForInfo = new List<Log_History__c>();
        for(ContentVersion cv: [SELECT ContentDocumentId, Id, Title FROM ContentVersion WHERE Id IN :contentVersionSet]){
            ContentDocumentLink cdl	= new ContentDocumentLink(); 
            cdl.ContentDocumentId = cv.ContentDocumentId; 
            cdl.LinkedEntityId = contentVersionIdToAttachmentParentIdMap.get(cv.Id); 
            cdl.ShareType = 'I';
            contentDocumentLinkList.add(cdl);
            Log_History__c logHistory = UTL_LogFactory.generateAndCommitLog(false, false, null, cv.Id, 'CLM', 'Custom', 'INFO',
                cv.title, contentVersionIdToAttachmentParentIdMap.get(cv.Id));
            if(logHistory != null) {
                lstLogForInfo.add(logHistory);
            }
        }
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
            new List<SObjectType> {ContentDocumentLink.SObjectType, Log_History__c.SObjectType}
        );
        if(!contentDocumentLinkList.isEmpty()) {
            uow1.registerNew(contentDocumentLinkList);
            if(lstLogForInfo != null && !lstLogForInfo.isEmpty()){
                uow1.registerNew(lstLogForInfo);
            }
            uow1.commitWork();
        }
        
    }
    
    /**
    * This method used to delete Attachment records
    * @param List<Attachment> listOfAttachmentToBeDeleted is used to delete the records if exist
    * @return  Boolean for Data is deleted successfully or not
    */
    public static Boolean deleteListOfAttachments(Set<Id> setOfAttachmentToBeDeleted,Boolean isFromTrigger) {
        List<Attachment> listOfAttachmentToBeDeleted = new List<Attachment>();
        for(Id attachID: setOfAttachmentToBeDeleted) {
            Attachment attachment = new Attachment();
            attachment.Id = attachID;
            if(!isFromTrigger){
                attachment.Description = 'Processed Successfully';
            }
            listOfAttachmentToBeDeleted.add(attachment);
        }
        try {
            if(listOfAttachmentToBeDeleted.isEmpty()) {
                return false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Attachment.SObjectType
                }
            );
            if(!listOfAttachmentToBeDeleted.isEmpty()) {
                if(isFromTrigger){
                    uow.registerDeleted(listOfAttachmentToBeDeleted);
                }
                else{
                    uow.registerDirty(listOfAttachmentToBeDeleted);//update the attachments
                }
            }
            uow.commitWork();
        } catch(DMLException dmlExp) {
            System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
        }
        return true;
    }

    /**
     * This function is use to attach the Supporting Document for future callout.
     * @param  agreementId        is the Apttus__APTS_Agreement__c record's Id datatype is String.
     * @param  templateId         is the Apttus__APTS_Template__c record's Id datatype is String.
     * @return                    void
     */ 
    @future(callout =  true)
    public static void createContractDocument(String agreementId, String templateId) {
        try {
            List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
            SLT_Agreement sltAgreement = new SLT_Agreement();
            Apttus__APTS_Agreement__c agreementRec = sltAgreement.getAgreementDetails(Id.valueOf(agreementId), new Set<String>{'Id', 'Name'});
            lstAgreement.add(agreementRec);
            createContractVersionForBulkAgreement(lstAgreement, templateId);
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }

    /**
     * This function is use to attach the Supporting Document for bulk agreements.
     * @param  lstAgreement       is the list of Apttus__APTS_Agreement__c records.
     * @param  templateId         is the Apttus__APTS_Template__c record's Id datatype is String.
     * @return                    void
     */ 
    public static void createContractVersionForBulkAgreement(List<Apttus__APTS_Agreement__c> lstAgreement, String templateId) {
        try { 
            ContentVersion doc = null;
            Apttus__DocumentVersion__c documentVersion = new Apttus__DocumentVersion__c();
            Set<Id> setDocId = new Set<Id>();
            Set<String> fieldSet = new Set<String> {'Id','Apttus__LatestVersionId__c'};
            Map<Id,Id> contentDocIdAGRId = new Map<Id,Id>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            Map<Id,ContentVersion> oldDocIdCV = new Map<Id,ContentVersion>();
            Map<Id,Id> cvIdOldDocId = new Map<Id,Id>();
            for(Apttus__APTS_Agreement__c agreement: lstAgreement) {
                String strDocId = createContentDocument(templateId, agreement.Id);
                contentDocIdAGRId.put(strDocId, agreement.Id);
            }
            if(!contentDocIdAGRId.isEmpty()) {
                Set<Id> setDocIds = contentDocIdAGRId.keySet();
                oldDocIdCV = cloneContentVersion(setDocIds);
            }
            if(oldDocIdCV.size() > 0) {
                Set<Id> cvIds = new Set<Id>();
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                try {  
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            ContentVersion.SObjectType
                        }
                    );
                    uow.registerNew(oldDocIdCV.values());
                    uow.commitWork();
                } 
                catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
                for(Id oldDocId : oldDocIdCV.keySet()) {
                    ContentVersion rec = oldDocIdCV.get(oldDocId);
                    cvIdOldDocId.put(rec.Id,oldDocId);
                    cvIds.add(rec.Id);
                }
                List<ContentVersion> cvNewList = new SLT_ContentVersion().selectById(cvIds);
                createDocumentVersionDetailsWithCV(cvNewList, contentDocIdAGRId, cvIdOldDocId);
                List<Apttus__APTS_Agreement__c> lstSCCAgreement = new List<Apttus__APTS_Agreement__c>();
                List<ContentDocument> lstContentDocument = new List<ContentDocument>();
                for(Apttus__APTS_Agreement__c agreement: lstAgreement) {
                    if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment) {
                        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
                        agreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;
                        lstSCCAgreement.add(agreement);
                    }   
                } 
                for(Id contentDocId : contentDocIdAGRId.keySet()) {
                    lstContentDocument.add(new ContentDocument(Id = contentDocId));
                } 
                try {  
                    fflib_SObjectUnitOfWork uow4 = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            ContentDocument.SObjectType, Apttus__APTS_Agreement__c.SObjectType
                        }
                    );
                    uow4.registerDeleted(lstContentDocument);
                    uow4.registerDirty(lstSCCAgreement);
                    uow4.commitWork();
                } catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
            }       
        }
        catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }
    
    private static void createDocumentVersionDetailsWithCV(List<ContentVersion> cvNewList,Map<Id,Id> contentDocIdAGRId, Map<Id,Id> cvIdOldDocId) {
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        List<Apttus__DocumentVersion__c> docVerList = new List<Apttus__DocumentVersion__c>();
        Map<Id, Apttus__DocumentVersion__c> contentVersionIdToDocumentVersionMap = new Map<Id, Apttus__DocumentVersion__c>();
        Map<Id, Apttus__DocumentVersionDetail__c> contentVersionIdToDocumentVersionDetailMap = new Map<Id, Apttus__DocumentVersionDetail__c>();  
        for(ContentVersion cv : cvNewList) {
            Apttus__DocumentVersion__c docVer = new Apttus__DocumentVersion__c();
            docVer.Apttus__Title__c = cv.Title;
            docVer.Name = Apttus.AgreementGenerateController.ACTION_GENERATE;
            docVer.Apttus__AgreementId__c = contentDocIdAGRId.get(cvIdOldDocId.get(cv.Id));
            docVer.Apttus__LatestVersion__c = '1.0.0';
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
                docVersionDetail.Apttus__Action2__c = Apttus.AgreementGenerateController.ACTION_GENERATE;
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
            system.debug(contentVersionIdToDocumentVersionDetailMap);
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
    /**
     * Calls the Apttus webservice to Generate Supporting Document. This method creates ContentDocument.
     * @param  templateId datatype String
     * @param  agreementId datatype String
     * @return a String which denotes the document Id.
     */
    @testVisible
    private static String createContentDocument(String templateId, String agreementId) {
        if(!Test.isRunningTest()){
            String accessLevel = 'Full access';
            String sessionId = UTL_CLM.getSessionIdFromVFPage();
            String serverUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/50.0/' + UserInfo.getOrganizationId();
            return Apttus.MergeWebService.generateDoc2(templateId, agreementId, accessLevel, 'DOCX', false, sessionId, serverUrl);
        } else {
            return '';
        }
    } 

    /**
     * This method copies the ContentVersion.
     * @param  docId  
     * @return ContentVersion
     */
    @testVisible
    private static Map<Id,ContentVersion> cloneContentVersion(Set<Id> docIds) {
        Map<Id,ContentVersion> oldDocIdCV = new Map<Id,ContentVersion>();
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        try {
            Set<String> fields = new Set<String>{'Id', 'Title', 'VersionData', 'PathOnClient','OwnerId','ContentLocation','ContentDocumentId'};
            for(ContentVersion agrCV: SRV_CLM_ContentVersion.getContentVersionByContentDocumentId(docIds, fields)) {
                ContentVersion contentVersionDoc = new ContentVersion();
                contentVersionDoc.Title = agrCV.Title;
                contentVersionDoc.VersionData = agrCV.VersionData;
                contentVersionDoc.PathOnClient = agrCV.PathOnClient;
                contentVersionDoc.OwnerId = agrCV.OwnerId;
                contentVersionDoc.ContentLocation = agrCV.ContentLocation; 
                oldDocIdCV.put(agrCV.ContentDocumentId, contentVersionDoc);
            }
        } catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage()); 
        }
        return oldDocIdCV;
    }

    /**
     * This method deletes the ContentDocument.
     * @param  docId  
     * @return void
     */
    public static void deleteDocument(Id docId) {
        try {
            Set<Id> setDocId = new Set<Id>();
            setDocId.add(docId); 
            SRV_GBL_ContentDocument.deleteRecord(setDocId);
        } catch(Exception ex) {
            system.debug('Exception:'+ex.getMessage());
        }
    }
    
    /** Create activity record with dependencies
    * @param AgreementId
    * @param ContactId
    * @param subject string
    **/ 
    public static List<Task> setupActivity(Id agreementId, Id contactId, String subject, String description){
        List<Task> newActivities = new List<Task>();
        List<Group> queueGroup = new SLT_Groups().getGroupWithGroupName(new Set<String>{CON_CLM.AMA_CONTRACT_QUEUE},'Queue');
        Task activity = new Task();
        activity.WhoId = contactId;
        activity.WhatId = agreementId;
        //replace this with custom label
        if(!queueGroup.isEmpty()) {
            activity.OwnerId = queueGroup.get(0).Id; 
        }
        activity.Subject = subject;
        activity.Status = 'Open';
        activity.Description = Label.AMA_Client_Response_Review + '\n'+description;
        activity.ActivityDate = date.today();
        newActivities.add(activity);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Task.SObjectType
            }
        );
        uow.registerNew(newActivities);
        try {
            uow.commitWork();
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        return newActivities;
    }
    
    /**
    * This method used to Amend the agreement
    * @param Id agreementId is used to Amend the agreement
    * @param Id contractId
    * @param String action
    * @param String recordTypeDeveloperName
    * @param Apttus__APTS_Agreement__c clinicalAgr
    * @param Opportunity selectedOpp
    * @return Id
    */
    public static Id amendContract(AgreementWrapper.AmendAgreementWrapper agrWrapper) {
        if(agrWrapper.action == CON_CLM.AMEND) {
            Set<String> agreementFields = UTL_CLM.getSObjectTypeFields(Apttus__APTS_Agreement__c.SObjectType, false);
            agreementFields.add('Agreement_Year_Plus_One__c');
            Apttus__APTS_Agreement__c agreement = new SLT_Agreement().getAgreementDetails(agrWrapper.agreementId, agreementFields);
            List<Apttus__APTS_Agreement__c> listOfRelatedAgreements = new SLT_Agreement().
                getAgreementListByAgreementNumbers(new Set<String>{'Id', 'Apttus__Version_Number__c'}, 
                new Set<String>{agreement.Apttus__Agreement_Number__c});
            Apttus__APTS_Agreement__c clonedAgreement = agreement.clone(false, true, false, false);
            clonedAgreement.Name += ' Amended';
            clonedAgreement.Agreement_Cloned_From__c = agreement.Id;
            clonedAgreement.Apttus__Version_Number__c = listOfRelatedAgreements[0].Apttus__Version_Number__c + 1;
            clonedAgreement.Apttus__Status__c = CON_CLM.REQUEST;
            clonedAgreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
            clonedAgreement.Special_Terms_Included__c = '';
            clonedAgreement.Date_Tracking_Started__c = System.today();
            clonedAgreement.Apttus__Contract_Start_Date__c = date.newInstance(Integer.valueOf(agreement.Agreement_Year_Plus_One__c),1,1);
            clonedAgreement.Apttus__Contract_End_Date__c = date.newInstance(Integer.valueOf(agreement.Agreement_Year_Plus_One__c),12,31);
            clonedAgreement.Sales_Rep_Cost__c = UTL_CLM.getSalesRepRateByRepCount(Integer.valueOf(agreement.Agreement_Year_Plus_One__c), (Integer)agreement.Sales_Rep_Count__c).Sales_Rep_Cost__c;
            clonedAgreement.Record_Based_Cost__c = UTL_CLM.calcRecordBasedCost(agreement, Integer.valueOf(agreement.Agreement_Year_Plus_One__c));
            clonedAgreement.Is_Renewal_Amendment__c = true;
            if(clonedAgreement.Sales_Rep_Cost__c != null && clonedAgreement.Record_Based_Cost__c != null){
                clonedAgreement.Apttus__Total_Contract_Value__c = clonedAgreement.Sales_Rep_Cost__c + clonedAgreement.Record_Based_Cost__c;
            }
            clonedAgreement.Is_Renewal_Amendment__c = true;
            clonedAgreement.CLM_Event__c = CON_CLM.RENEWAL;
            agreement.Apttus__Status__c = CON_CLM.BEING_AMENDED;
            agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
            if(agreement.Apttus__Version_Number__c == 0) {
                clonedAgreement.Original_Agreement__c = agreement.Id;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__APTS_Agreement__c.SObjectType
                }
            );
            uow.registerNew(clonedAgreement);
            uow.registerDirty(agreement);
            uow.commitWork();
            createRelatedAGRRecordsToReplicateAmend(agreement.Id, clonedAgreement, CON_CLM.IS_AMENDED_BY, CON_CLM.IS_AMENDMENT_FOR);
            createActivityOnAmend(new List<Apttus__APTS_Agreement__c>{clonedAgreement});
            return clonedAgreement.id;
        }
        if (agrWrapper.action == CON_CLM.AMEND_BY_FLOW) {
            Set<String> agreementFields = UTL_CLM.getSObjectTypeFields(Apttus__APTS_Agreement__c.SObjectType, false);
            agreementFields.add('Apttus__Related_Opportunity__r.Opportunity_Number__c');
            agreementFields.add('Apttus__Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c');
            Set<String> exclAgreementFields = UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.AGREEMENT_OBJECT_API_NAME);
            exclAgreementFields.add('Regions__c');
            exclAgreementFields.add('OwnerId');
            exclAgreementFields.add('Apttus__Requestor__c');
            agreementFields.removeAll(exclAgreementFields);
            Apttus__APTS_Agreement__c agreement = new SLT_Agreement().getAgreementDetails(agrWrapper.agreementId, agreementFields);
            List<Apttus__APTS_Agreement__c> listOfRelatedAgreements = new SLT_Agreement().
                getAgreementListByAgreementNumbers(new Set<String>{'Id', 'Apttus__Version_Number__c'}, 
                new Set<String>{agreement.Apttus__Agreement_Number__c});
            Apttus__APTS_Agreement__c clonedAgreement = agreement.clone(false, true, false, false);
            if(clonedAgreement.Name.length() >= 73 && clonedAgreement.Name.length() <= 80){
                String clonedAgreementName = clonedAgreement.Name.substring(0, clonedAgreement.Name.length()-8);
                clonedAgreement.Name = clonedAgreementName + ' Amended';
            } else {
                clonedAgreement.Name += ' Amended';
            }
            clonedAgreement.Agreement_Cloned_From__c = agreement.Id;
            clonedAgreement.Apttus__Version_Number__c = listOfRelatedAgreements[0].Apttus__Version_Number__c + 1;
            clonedAgreement.Apttus__Status__c = CON_CLM.REQUEST;
            clonedAgreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
            agreement.Apttus__Status__c = CON_CLM.BEING_AMENDED;
            agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
            if(agreement.RecordTypeId == CON_CLM.RWLP_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID) {
                if(agrWrapper.contractId != null && agrWrapper.contractId != ''){
                    clonedAgreement.Bid_History__c = Id.valueOf(agrWrapper.contractId);
                    clonedAgreement.Date_Tracking_Started__c = agrWrapper.requestDate;
                    clonedAgreement.Contract_Ranking__c = agrWrapper.contractRanking;
                }
                if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_SUWO 
                    || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_LOI
                    || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_MA || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_LOCALRA || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_LRA) {
                    clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT;
                } else {
                    clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER; 
                }
                if(!String.isBlank(agreement.Services__c) && agreement.Services__c.contains('RBU')){
                    String subtypeShort = clonedAgreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER ? 'CO' : 'Amendment';
                    String oppLegacyQuintilesNumber = (agreement.Apttus__Related_Opportunity__c != null) && (!String.isBlank(agreement.Apttus__Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c)) ?  agreement.Apttus__Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c : '';
                    String oppNumber = (agreement.Apttus__Related_Opportunity__c != null) && (!String.isBlank(agreement.Apttus__Related_Opportunity__r.Opportunity_Number__c)) ? agreement.Apttus__Related_Opportunity__r.Opportunity_Number__c : '';
                    if(agreement.Services__c.contains('Late Phase Services')){
                        clonedAgreement.Name = 'HYBRID_' + oppNumber + '_' + oppLegacyQuintilesNumber + '_' + subtypeShort + ' ' + clonedAgreement.Apttus__Version_Number__c;
                    } else {
                        clonedAgreement.Name = 'RBU_' + oppNumber + '_' + subtypeShort + ' ' + clonedAgreement.Apttus__Version_Number__c;
                    }
                }
            } else if(agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID){
                if(agreement.Apttus__Agreement_Category__c == CON_CLM.FULL_SERVICE){
                    clonedAgreement.Planned_Execution_Date__c = agrWrapper.clinicalAgreement.Planned_Execution_Date__c;
                    clonedAgreement.Legal_Entity_1__c = agrWrapper.clinicalAgreement.Legal_Entity_1__c;
                    clonedAgreement.Legal_Entity_Customer__c = agrWrapper.clinicalAgreement.Legal_Entity_Customer__c;
                    clonedAgreement.Client_Address__c = agrWrapper.clinicalAgreement.Client_Address__c;
                } else if(agreement.Apttus__Agreement_Category__c == CON_CLM.STANDALONE){
                    clonedAgreement.Apttus__Account__c = agrWrapper.selectedOpportunity.AccountId;
                    clonedAgreement.Apttus__Related_Opportunity__c = agrWrapper.selectedOpportunity.Id;
                    clonedAgreement.CurrencyIsoCode = agrWrapper.selectedOpportunity.CurrencyIsoCode;
                }
                clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
            } else if(agreement.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID){
                if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_CEVA || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_ONCA 
                    || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_MSA || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_OCA || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT) {
                    clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT;
                } else if(agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_AGREEMENT){
                    clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_AGREEMENT; 
                } else{
                    clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
                }
                if(agrWrapper.contractId != null && agrWrapper.contractId != ''){
                    clonedAgreement.Contract__c = Id.valueOf(agrWrapper.contractId);
                    if(agrWrapper.type == CON_CLM.REQUESTED_CONTRACT_TYPE_TL) {
                        clonedAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_TERMINATION_AGREEMENT;
                    }
                }
                clonedAgreement.Apttus__Status__c = CON_CLM.ASSIGNED;
            }
            if(agreement.Apttus__Version_Number__c == 0) {
                clonedAgreement.Original_Agreement__c = agreement.Id;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__APTS_Agreement__c.SObjectType
                }
            );
            uow.registerNew(clonedAgreement);
            uow.registerDirty(agreement);
            uow.commitWork();
            createRelatedAGRRecordsToReplicateAmend(agreement.Id, clonedAgreement, CON_CLM.IS_AMENDED_BY, CON_CLM.IS_AMENDMENT_FOR);
            if(agreement.RecordTypeId == CON_CLM.RWS_RECORDTYPEID && String.isNotBlank(clonedAgreement.Id)) {
                cloneAgreementTeamOnAmendment(agreement.Id, clonedAgreement.Id);
                if(agreement.Apttus__Agreement_Category__c == CON_CLM.FULL_SERVICE) {
                    createRelatedAGRRecordsToReplicateAmend(agrWrapper.clinicalAgreement.Id, clonedAgreement, CON_CLM.IS_FULL_SERVICE_MASTER_OF, CON_CLM.IS_FULL_SERVICE_CHILD_OF);
                }
            }
            createActivityOnAmend(new List<Apttus__APTS_Agreement__c>{clonedAgreement});
            return clonedAgreement.id;
        }
        return null;
    }

    /**
    * This method is used to amend IQVIA Agreement
    * @param AgreementWrapper agrWrapper 
    * @return Id
    */ 
    public static Id amendIQVIAAgreement(AgreementWrapper agrWrapper) { 
        Boolean isActivated = false;
        if(agrWrapper.action == CON_CLM.IQVIA_AMEND_BY_FLOW) {  
            Set<String> agreementFields = UTL_CLM.getSObjectTypeFields(IQVIA_Agreement__c.SObjectType, false);
	        Set<String> exclAgreementFields = UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.IQVIA_AGR_OBJ_NAME);
            agreementFields.removeAll(exclAgreementFields);
            IQVIA_Agreement__c agreement = new SLT_IQVIA_Agreement().getIQVIAAgreementDetails(agrWrapper.iqviaAgreement.Id, agreementFields);
            IQVIA_Agreement__c clonedAgreement = agreement.clone(false, true, false, false);
            clonedAgreement.Name = agrWrapper.iqviaAgreement.Name;                                            
            clonedAgreement.Agreement_Cloned_From__c = agreement.Id;
            clonedAgreement.Version_Number__c = agrWrapper.iqviaAgreement.Version_Number__c + 1;
            clonedAgreement.Status__c = CON_CLM.REQUEST;
            clonedAgreement.Status_Category__c = CON_CLM.REQUEST;
            clonedAgreement.Subtype__c = agrWrapper.iqviaAgreement.Subtype__c;
            clonedAgreement.Contract_Start_Date__c = agrWrapper.iqviaAgreement.Contract_Start_Date__c;
            clonedAgreement.Contract_End_Date__c = agrWrapper.iqviaAgreement.Contract_End_Date__c;
            clonedAgreement.Perpetual__c = agrWrapper.iqviaAgreement.Perpetual__c == true ? true: false; 
            clonedAgreement.Request_Date__c = Datetime.now();
            clonedAgreement.OwnerId = agrWrapper.iqviaAgreement.OwnerId;
            clonedAgreement.Requestor__c = agrWrapper.iqviaAgreement.Requestor__c;
            clonedAgreement.Related_Opportunity__c = (Id)agrWrapper.iqviaAgreement.Related_Opportunity__c;
            if(agrWrapper.iqviaAgreement.Version_Number__c == 0 || agrWrapper.iqviaAgreement.Original_Agreement__c == null) {
                clonedAgreement.Original_Agreement__c = agrWrapper.iqviaAgreement.Id;
            }                                             
            clonedAgreement.Legal_Entity_1__c = (Id)agrWrapper.iqviaAgreement.Legal_Entity_1__c;
            clonedAgreement.Primary_Business_Line1__c = agrWrapper.iqviaAgreement.Primary_Business_Line1__c;
            clonedAgreement.Change_Order_Number__c = agrWrapper.coNumber; 
            If(agreement.Status__c == CON_CLM.ACTIVATED) {
                agreement.Status__c = CON_CLM.BEING_AMENDED;
                agreement.Status_Category__c = CON_CLM.IN_EFFECT;
                isActivated = true;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    IQVIA_Agreement__c.SObjectType
                }
            );
           try {
            uow.registerNew(clonedAgreement);  
            If(isActivated) {
                uow.registerDirty(agreement);
            }
            uow.commitWork();
            createActivityOnIQAmend(new List<IQVIA_Agreement__c>{clonedAgreement});
            }
           catch(Exception e) {
                 System.debug(e.getMessage());
            }
            return clonedAgreement.id;
        }
         
        return null;
    }
    
    /**
    * This method is used to create related Agreement record for Amended Agreement
    * @param Id agreementId 
    * @param Apttus__APTS_Agreement__c clonedAgreement
    * @param String fromType
    * @param String toType
    */
    public static void createRelatedAGRRecordsToReplicateAmend(Id agreementId, Apttus__APTS_Agreement__c clonedAgreement, String fromType, String toType) {
        Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
        
        relatedAgreement.Apttus__APTS_Contract_From__c = agreementId;
        relatedAgreement.Apttus__APTS_Contract_To__c = clonedAgreement.Id;
        relatedAgreement.Apttus__Relationship_From_Type__c = fromType;
        relatedAgreement.Apttus__Relationship_To_Type__c = toType;
        relatedAgreement.Name = CON_CLM.CURRENT_AGREEMENT;
        
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
            Apttus__APTS_Related_Agreement__c.SObjectType
        });
        uow1.registerNew(relatedAgreement);
        uow1.commitWork();
    }

	/**
    * This method is used to create Task for Amended Agreement and Amendment Agreement 
    * @param List<Apttus__APTS_Agreement__c> clonedAgrList 
    */    
    public static void createActivityOnAmend(List<Apttus__APTS_Agreement__c> clonedAgrList){
        List<Task> taskList = new List<Task>();
        
        if(!clonedAgrList.isEmpty() && clonedAgrList != null){
            for(Apttus__APTS_Agreement__c cloned: clonedAgrList) {
                Task task = new Task();
                task.ActivityDate = System.today();
                task.Status = CON_CLM.COMPLETED;
                task.WhatId = cloned.Id;
                task.Subject = 'Amended From agreement '+cloned.Apttus__Agreement_Number__c+'.'+(cloned.Apttus__Version_Number__c - 1);
                task.Description = 'Amended From agreement '+cloned.Apttus__Agreement_Number__c+'.'+(cloned.Apttus__Version_Number__c - 1);
                
                Task task2 = new Task();
                task2.ActivityDate = System.today();
                task2.Status = CON_CLM.COMPLETED;
                task2.WhatId = cloned.Agreement_Cloned_From__c;
                task2.Subject = CON_CLM.AMENDED_AGREEMENT;
                task2.Description = CON_CLM.AMENDED_AGREEMENT;
                
                taskList.add(task);
                taskList.add(task2);
            }  
        }
        
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
            Task.SObjectType
        });
        uow1.registerNew(taskList);
        uow1.commitWork();
    }

    /**
     * This method is used to create Task for Amended IQVIA Agreement and Amendment IQVIA Agreement 
     * @param List<IQVIA_Agreement__c> clonedAgrList
     */
    public static void createActivityOnIQAmend(List<IQVIA_Agreement__c> clonedAgrList){
        List<Task> taskList = new List<Task>();
        
        if(!clonedAgrList.isEmpty() && clonedAgrList != null){
            for(IQVIA_Agreement__c cloned: clonedAgrList) {
                Task task = new Task();
                task.ActivityDate = System.today();
                task.Status = CON_CLM.COMPLETED;
                task.WhatId = cloned.Id;
                task.Subject = 'Amended From agreement '+cloned.FF_Agreement_Number__c+'.'+(cloned.Version_Number__c - 1);
                task.Description = 'Amended From agreement '+cloned.FF_Agreement_Number__c+'.'+(cloned.Version_Number__c - 1);
                
                Task task2 = new Task();
                task2.ActivityDate = System.today();
                task2.Status = CON_CLM.COMPLETED;
                task2.WhatId = cloned.Agreement_Cloned_From__c;
                task2.Subject = CON_CLM.AMENDED_AGREEMENT;
                task2.Description = CON_CLM.AMENDED_AGREEMENT;
                
                taskList.add(task);
                taskList.add(task2);
            }  
        }
        
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
            Task.SObjectType
        });
        uow1.registerNew(taskList);
        uow1.commitWork();
    }
    
    /*
    * This method is used to get default the amended contract attributes based on effective year
    * @param Id agreementId
    * @param Integer AMARateYear
    */    
    public static void defaultContract(Id agreementId, Integer AMARateYear){
        Set<String> agreementFields = new Set<String>{'Id', 'Name', 'Apttus__Contract_Start_Date__c', 
        'Apttus__Contract_End_Date__c', 'Apttus__Subtype__c', 'Number_Of_Records__c', 'Record_Based_Cost__c', 
        'Sales_Rep_Cost__c', 'Sales_Rep_Count__c'};
        Apttus__APTS_Agreement__c agr = new SLT_Agreement().getAgreementDetails(agreementId, agreementFields);
        agr.Apttus__Contract_Start_Date__c = date.newInstance(AMARateYear,1,1);
        agr.Apttus__Contract_End_Date__c = date.newInstance(AMARateYear,12,31);
        agr.Sales_Rep_Cost__c = UTL_CLM.getSalesRepRateByRepCount(AMARateYear, (Integer)agr.Sales_Rep_Count__c).Sales_Rep_Cost__c;
        agr.Record_Based_Cost__c = UTL_CLM.calcRecordBasedCost(agr, AMARateYear);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
            Apttus__APTS_Agreement__c.SObjectType
        });
        uow.registerDirty(agr);
        uow.commitWork();
    }
    
    /**
    * This method is used to calculate record based cost based on the AMA effective year
    * @param Apttus__APTS_Agreement__c agr
    * @param Integer AMARateYear
    * @return Double Record Based Cost
    */ 
    public static Double calcRecordBasedCost(Apttus__APTS_Agreement__c agr, Integer AMARateYear) {
        Double recordBasedCost = 0;
        Id dfdId;
        List<AMA_Data_File_Definition__mdt> dfdList = AMA_Data_File_Definition__mdt.getAll().values();
        if(dfdList.size()>0){
            for(AMA_Data_File_Definition__mdt dfd: dfdList){
                if(dfd.Rate_Effective_Year__c == AMARateYear && dfd.Active__c == true && dfd.Sub_Category__c == agr.Apttus__Subtype__c){
                    dfdId = dfd.Id;
                    break;
                }
        	}
        }
        List<AMA_Record_Rate__mdt> recordRateList = AMA_Record_Rate__mdt.getAll().values();
        if(recordRateList.size()>0){
            for(AMA_Record_Rate__mdt rec: recordRateList){
                if(rec.AMA_Data_File_Definition__c == dfdId){
                    recordBasedCost = rec.Per_Record_Cost__c * agr.Number_Of_Records__c;
                    break;
                }
            }
        }
        return recordBasedCost;   
    }
    
    /*
    * This method is used to get Sales Rep Rate Custom Metadata on the basis of year and rep count for AMAA
    * @param Integer effectiveYear
    * @param Integer salesRepCount
    * @return AMA_Sales_Rep_Rate__mdt
    */
    public static AMA_Sales_Rep_Rate__mdt getSalesRepRateByRepCount(Integer effectiveYear, Integer salesRepCount) {
        AMA_Sales_Rep_Rate__mdt salesRep = new AMA_Sales_Rep_Rate__mdt(); 
        List<AMA_Sales_Rep_Rate__mdt> lstSalesRepRate = AMA_Sales_Rep_Rate__mdt.getAll().values();
        if(!lstSalesRepRate.isEmpty()) {
            for(AMA_Sales_Rep_Rate__mdt salesRepRate : lstSalesRepRate) {
                if(salesRepRate.Effective_Year__c == effectiveYear && (salesRepRate.Range_Start__c <= salesRepCount 
                    && salesRepRate.Range_End__c >= salesRepCount) && salesRepRate.Active__c == true) {
                    salesRep = salesRepRate;
                    break;
                }
            }
        }
        return salesRep;
    }
    
    /*
    * This method is used to publish Error Log Event And Raise Common Error
    * @param List<SObjects> recordList
    * @param Exception e
    */
    public static void logExceptionAndRaiseCommonError(List<SObject> recordList, Exception e) {
        for(SObject record : recordList) {
            EventBus.publish(new Apex_Error_Log_Event__e(
                Object__c = 'Apttus_Proposal__Proposal__c',
                Error_Message__c = e.getMessage() + '\n' + e.getStackTraceString(),
                Record_Id__c = record.Id,
                Running_User__c = UserInfo.getUserId(),
                Source_Module__c = 'CLM'
            ));
            record.addError(CON_CLM.COMMON_CLM_TRIGGER_ERROR);
        }
    }
    
    /**
    * This method is used to set tab position for docusign recipient by anchor string
    * @param Integer signerNumber
    * @param Integer recipientId 
    * @param String title
    * @return String
    */  
    public static String setTabPositionByAnchorForDocusign(Integer signerNumber, Integer recipientId, String title) {
        String requestBody = ',"tabs":{"dateSignedTabs": [{"anchorString": "\\\\d' + signerNumber + '\\\\","anchorYOffset": "-6","fontSize": ' 
            + '"Size12","name": "Date Signed","recipientId": "' + recipientId + '","tabLabel":' 
            + '"\\\\d' + signerNumber + '\\\\"}],"fullNameTabs": [{"anchorString": "\\\\n' + signerNumber + '\\\\","anchorYOffset": "-6","fontSize": "Size12",' 
            + '"name": "Full Name","recipientId": "' + recipientId + '","tabLabel": "\\\\n'
            + signerNumber +'\\\\"}],"signHereTabs": [{"anchorString": "\\\\s' + signerNumber + '\\\\","anchorUnits": "mms",'
            + '"anchorXOffset": "0","anchorYOffset": "0","name": "Please sign here","optional": "false", "recipientId": "' + recipientId + '","scaleValue": 1,"tabLabel": "\\\\s' 
            + signerNumber + '\\\\"}],"textTabs": [{"anchorString": "\\\\t' + signerNumber + '\\\\","anchorYOffset": "-6","fontSize": "Size12","name": "Title","locked": "false", "value": "' + title + '","recipientId": "'
            + signerNumber + '","required": "false","tabLabel": "Company"}]}},';      
        return requestBody;
    }
    /**
    * This method is used to login with creds in custom setting for callout
    * @return partnerSoapSforceCom.Soap
    */
    public static partnerSoapSforceCom.Soap loginToPartnerSoapforceCom() {
        partnerSoapSforceCom.Soap atPartnerSoap = new partnerSoapSforceCom.Soap();
        partnerSoapSforceCom.LoginResult atPartnerSoapLoginResult;
        partnerSoapSforceCom.SessionHeader_element atPartnerSoapSessionHeader = new partnerSoapSforceCom.SessionHeader_element();
        partnerSoapSforceCom.Soap atUpdate = null;
        try {
            String username = '';
            String password = '';  
            Organization_Default__c securityConfig = Organization_Default__c.getOrgDefaults();
            
            if(securityConfig != null) {
                username = securityConfig.UserName__c != null ? securityConfig.UserName__c : '';
                password = securityConfig.Password__c != null ? UTL_CRM.decryptPassword(securityConfig.Password__c) : '';
            }
            
            atPartnerSoapLoginResult = atPartnerSoap.login(username, password);
            atPartnerSoapSessionHeader.sessionId = atPartnerSoapLoginResult.sessionId;
            atUpdate = new partnerSoapSforceCom.soap();
            atUpdate.sessionHeader = atPartnerSoapSessionHeader;
            return atUpdate;
        } catch(Exception ex) {
            system.debug('Callout failed: ' +  + ex.getMessage());
            return atUpdate;
        }
        
    }
    
    /**
    * This method used to set agreement fields from quote fields
    * @param Apttus_Proposal__Proposal__c quote
    * @param Apttus__APTS_Agreement__c agreement
    * @return void
    */
    public static void setAgreementFields(Apttus_Proposal__Proposal__c quote, Apttus__APTS_Agreement__c agreement) {
        Map<String,String> sourceTargetFieldMap = new Map<String,String>();
        for(CLM_Field_Mappings__c mapping: getFilteredCSMappingList('AMESA','Apttus__APTS_Agreement__c')) {
            sourceTargetFieldMap.put(mapping.Source_Field_API_Name__c,mapping.Target_Field_API_Name__c);
        }
        if(!sourceTargetFieldMap.isEmpty()) {
            Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>(
                new SLT_Proposal().getProposalsById(new Set<Id>{quote.Id}, sourceTargetFieldMap.keySet()));
            if (!proposalMap.isEmpty() && proposalMap.containsKey(quote.Id)) {
                Apttus_Proposal__Proposal__c proposal = proposalMap.get(quote.Id);
                for (String sourceField : sourceTargetFieldMap.keySet()) {
                    String targetField = sourceTargetFieldMap.get(sourceField);
                    if(sourceField == 'CountryCode__c' && targetField == 'Contracting_Country__c'
                        && proposal.get(sourceField) != null) {
                        String proposalCountry = (String) proposal.get(sourceField);
                        Map<String,String> mapOfCountryLabelCode = UTL_CLM.getPicklistEntryValue('Apttus__APTS_Agreement__c','Contracting_Country__c', false);
                        if(!mapOfCountryLabelCode.isEmpty() && mapOfCountryLabelCode.containsKey(proposalCountry)) {
                            agreement.put(targetField, mapOfCountryLabelCode.get(proposalCountry));
                        }
                    } else {
                        agreement.put(targetField, proposal.get(sourceField));
                    }
                }
            }
        }
    }
    
    /**
    * This method used to get the mapping list CLM_Field_Mappings__c based on recordType and object name
    * @param String recordTypeName
    * @param String objectName
    * @return List<CLM_Field_Mappings__c>
    */
    public static List<CLM_Field_Mappings__c> getFilteredCSMappingList(String recordTypeName, String objectName) {
        List<CLM_Field_Mappings__c> mappingList = [SELECT Id,Source_Field_API_Name__c,Target_Field_API_Name__c FROM CLM_Field_Mappings__c WHERE Object_API_Name__c = : objectName 
                                                                  AND Record_Type_Developer_Name__c =: recordTypeName];
        return mappingList;
    }
    
    /**
    * This method is used to add error on agreement field based on null check
    * @params Apttus__APTS_Agreement__c agreement
    * @param String requestedAgreementType
    * @params List<CLM_RecordType_Field_Mapping_Generate__c> fieldMappingRecordList
    * @params String recordTypeDeveloperName
    * @return String isFromTrigger
    */
    public static String addErrorAndGenerateHTMLOnAgreement(Apttus__APTS_Agreement__c agreement,
        String recordTypeDeveloperName,String requestedAgreementType,  
        String statusCategory, String status, Boolean isFromTrigger) {
        Set<String> setOfFieldAPINames = UTL_CLM.getFieldAPINameToValidate(recordTypeDeveloperName, requestedAgreementType, 
            statusCategory, status, agreement.Original_Requested_Agreement_Type__c, isFromTrigger);
        String htmlOfFieldLabels;
        Boolean isPerpetual = false;
        Boolean isAgrEndDate = false;
        Boolean ifValidationFails = false;
        Boolean isFirstPatientInDateBlank = false;
        Boolean isLastPatientOutDateBlank = false;
        if(!isFromTrigger) {
            if(statusCategory == CON_CLM.IN_EFFECT) {
                htmlOfFieldLabels = System.Label.CLM_CL00021_ACTIVATE_CUSTOM_ERROR + '</br>';
            } else {
                htmlOfFieldLabels = System.Label.CLM_CL00015_PSA_CUSTOM_ERROR + '</br>';
            }
        }
        for (String fieldName: setOfFieldAPINames) {
            if(agreement.get(fieldName) == null || agreement.get(fieldName) == false) {
                String labelName = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').
                    getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                if(!String.isBlank(labelName)) {
                    if(labelName == CON_CLM.PERPETUAL) {
                        isPerpetual = true;
                    } else if(labelName == System.Label.Agreement_End_Date) {
                        isAgrEndDate = true;
                    } else if(fieldName == CON_CLM.APINAME_FIRST_PATIENT_IN_DATE) {
                        isFirstPatientInDateBlank = true;
                    } else if(fieldName == CON_CLM.APINAME_LABEL_LAST_PATIENT_OUT_DATE) {
                        isLastPatientOutDateBlank = true;
                    } else {
                        ifValidationFails = true;
                        if(isFromTrigger) {
                            agreement.addError(fieldName,System.Label.CLM_CL0002_Required_Field_Message);
                        } else {
                            htmlOfFieldLabels += labelName + '</br>';
                        }
                    }
                }
            }
        }
        if(isPerpetual == true && isAgrEndDate == true) {
            ifValidationFails = true;
            if(isFromTrigger) {
                agreement.addError('Apttus__Contract_End_Date__c',CON_CLM.PERPETUAL_CHECKBOX_OR_AGR_END_DATE);
                agreement.addError('Apttus__Perpetual__c',CON_CLM.PERPETUAL_CHECKBOX_OR_AGR_END_DATE);
            } else {
                htmlOfFieldLabels += CON_CLM.PERPETUAL_CHECKBOX_OR_AGR_END_DATE + '</br>';
            }
        }
        if(statusCategory == CON_CLM.IN_EFFECT 
            && (agreement.Services__c != null &&  agreement.Services__c.contains('eCOA'))  
            && (isFirstPatientInDateBlank == true || isLastPatientOutDateBlank == true)) {
            ifValidationFails = true;
            if(isFromTrigger) {
                if(isFirstPatientInDateBlank) {
                    agreement.addError(CON_CLM.APINAME_FIRST_PATIENT_IN_DATE, System.Label.CLM_CL0002_Required_Field_Message);
                }
                if(isLastPatientOutDateBlank) {
                    agreement.addError(CON_CLM.APINAME_LABEL_LAST_PATIENT_OUT_DATE, System.Label.CLM_CL0002_Required_Field_Message);
                }
            } else {
                if(isFirstPatientInDateBlank) {
                    htmlOfFieldLabels += CON_CLM.LABEL_FIRST_PATIENT_IN_DATE + '</br>';
                }
                if(isLastPatientOutDateBlank) {
                    htmlOfFieldLabels += CON_CLM.LABEL_LAST_PATIENT_OUT_DATE + '</br>';
                } 
            }
        }
        if(statusCategory != CON_CLM.IN_EFFECT && (recordTypeDeveloperName == CON_CLM.PA_RECORD_TYPE_NAME || recordTypeDeveloperName == CON_CLM.PSA_RECORD_TYPE_NAME
            || (recordTypeDeveloperName == CON_CLM.OSA_RECORD_TYPE_NAME && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_EA
            && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_RA))) {
            if(agreement.Is_This_A_Rescue_Study__c == null || agreement.Prob_to_Execute_in_the_Qtr_Mgrs_Only__c == null || 
                agreement.Planned_Execution_Date__c == null || agreement.IQVIA_Project_Manager_Con__c == null ||
                agreement.IQVIA_Project_Finance_Manager__c == null ) {
                
                String strAgrExtensionFieldsErrorMessage = '';
                if(!isFromTrigger) {
                    if(agreement.Is_This_A_Rescue_Study__c == null && (requestedAgreementType == CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP 
                        || requestedAgreementType == CON_CLM.REQUESTED_AGREEMENT_TYPE_SUWO)){
                        strAgrExtensionFieldsErrorMessage += CON_CLM.IS_THIS_A_RESCUE_STUDY_IN_THE_EXCEPTION_POLICY_SECTION_OF_EXECUTION_PLAN_TAB + '</br>';
                    }
                    if(agreement.Prob_to_Execute_in_the_Qtr_Mgrs_Only__c == null) {
                        strAgrExtensionFieldsErrorMessage += CON_CLM.PROB_TO_EXECUTE_IN_THE_QTR_ON_THE_UNSIGNED_TRACKER_TAB + '</br>';
                    }
                    if(agreement.Prob_to_move_to_High_Confidence_in_Qtr__c == null && requestedAgreementType == CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER){
                        strAgrExtensionFieldsErrorMessage += CON_CLM.PROB_TO_MOVE_TO_HIGH_CONFIDENCE_IN_QTR_ON_THE_UNSIGNED_TRACKER_TAB + '</br>';
                    }
                    if(agreement.Planned_Execution_Date__c == null) {
                        strAgrExtensionFieldsErrorMessage += CON_CLM.PLANNED_EXECUTION_DATE_IN_THE_EXECUTION_PLAN_SECTION_OF_EXECUTION_PLAN_TAB + '</br>';
                    }
                    if(agreement.IQVIA_Project_Manager_Con__c == null) {
                        strAgrExtensionFieldsErrorMessage += CON_CLM.IQVIA_PROJECT_MANAGER_ON_THE_TEAM_TAB + '</br>';
                    }
                    if(agreement.IQVIA_Project_Finance_Manager__c == null) {
                        strAgrExtensionFieldsErrorMessage += CON_CLM.IQVIA_PROJECT_FINANCE_MANAGER_ON_THE_TEAM_TAB + '</br>';
                    }
                    if(strAgrExtensionFieldsErrorMessage != '') {
                        htmlOfFieldLabels = htmlOfFieldLabels.replace(System.Label.CLM_CL00015_PSA_CUSTOM_ERROR + '</br>', System.Label.CLM_CL00015_PSA_CUSTOM_ERROR + '</br>' + strAgrExtensionFieldsErrorMessage);
                        ifValidationFails = true;
                    }
                }
            }
            if(ifValidationFails && statusCategory != CON_CLM.IN_EFFECT && requestedAgreementType != null 
                && (requestedAgreementType == CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP
                || ((agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_WO
                && !requestedAgreementType.contains(CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA)
                && !requestedAgreementType.contains(CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA)
                && !requestedAgreementType.contains(CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER))
                || (agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_EA
                && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_RA)))) {
                if(isFromTrigger) {
                    agreement.addError(CON_CLM.ASSOCIATED_MSA,CON_CLM.ASSOCIATED_MSA_IF_AN_MSA_EXISTS);
                } 
                else {
                    htmlofFieldLabels += CON_CLM.ASSOCIATED_MSA_IF_AN_MSA_EXISTS;
                }
            }
        }  
        if(!ifValidationFails) {
            htmlOfFieldLabels = null;
        }
        return htmlOfFieldLabels;
    }
    
    /**
    * This method is used to return Fields of Agreement based on Record Type and Requested Agreement Type
    * @param String recordTypeDeveloperName
    * @param String requestedAgreementType
    * @param List<CLM_RecordType_Field_Mapping_Generate__c> fieldMappingRecordList
    * @param String originalSubtype
    * @return Set<String> setOfFieldAPINames
    */
    public static Set<String> getFieldAPINameToValidate(String recordTypeDeveloperName, String requestedAgreementType, 
        String statusCategory, String status, String originalSubtype, Boolean isFromTrigger) {
        Set<String> setOfFieldAPINames = new Set<String>();
        Set<String> fields = new Set<String>{'Field_API_Name__c', 'Status__c', 'Requested_Agreement_Type__c',
            'Show_Different_Message_On_VF__c'};
        String condition = 'Record_Type__c =: recordTypeDeveloperName AND Status_Category__c=:statusCategory AND Is_Active__c = true';
        List<CLM_FieldMapping_Validation__mdt> CLM_FieldMapping_Validation_List = new SLT_CLM_FieldMapping_Validation().getCLMFieldMappingValidationByCondition(fields,
            condition, recordTypeDeveloperName, statusCategory);
        for(CLM_FieldMapping_Validation__mdt fieldMappingRecord: CLM_FieldMapping_Validation_List) {
            if((fieldMappingRecord.Requested_Agreement_Type__c == null
                || (requestedAgreementType != null && fieldMappingRecord.Requested_Agreement_Type__c != null 
                && fieldMappingRecord.Requested_Agreement_Type__c.contains(requestedAgreementType)))
                && (fieldMappingRecord.Status__c == null 
                || (status != null && fieldMappingRecord.Status__c != null 
                && fieldMappingRecord.Status__c.contains(status)))) {
                setOfFieldAPINames.add(fieldMappingRecord.Field_API_Name__c);    
            }
        }
        if(originalSubtype == CON_CLM.REQUESTED_AGREEMENT_TYPE_MA && setOfFieldAPINames.contains(CON_CLM.FROM_CONTRACTING_COUNTRY_FIELD_API_NAME)) {
            setOfFieldAPINames.remove(CON_CLM.FROM_CONTRACTING_COUNTRY_FIELD_API_NAME);     
        }
        return setOfFieldAPINames ;
    }

    /**
    * This method is used to get contact from user
    * @param Set<id> userIds 
    * @return Map<Id, Id>
    */
    public static Map<Id, Id> getContactFromUser(Set<Id> userIds) {
        Map<String, Id> emailToUserIdMap = new Map<String, Id>();
        Map<Id, Id> userIdToContactIdMap = new Map<Id, Id>();
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(CON_CLM.CONTACT_CONTACT_RECORDTYPEID);
        recordTypeIds.add(CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID);
        List<User> lstUser = new SLT_User().selectContactDetailByUser(userIds, new Set<String>{'Email', 'Id'});
        for(User u : lstUser) {
            emailToUserIdMap.put(u.email, u.Id);
        }
        List<Contact> lstContact = new SLT_Contact().getContactsByEmails(emailToUserIdMap.keySet(), recordTypeIds);
        for(Contact c : lstContact) {
            if(emailToUserIdMap.containsKey(c.Email)) {
                userIdToContactIdMap.put(emailToUserIdMap.get(c.Email), c.Id);
            }
        } 
        return userIdToContactIdMap;
    }
    
    /**
    * This method is used to add error on agreement field based on null check
    * @params Apttus__APTS_Agreement__c agreement
    * @param String requestedAgreementType
    * @params List<CLM_RecordType_Field_Mapping_Generate__c> fieldMappingRecordList
    * @params String recordTypeDeveloperName
    * @return String isFromTrigger
    */
    public static String addErrorAndGenerateHTMLOnAgreementClone(Apttus__APTS_Agreement__c agreement,
        String recordTypeDeveloperName,String requestedAgreementType,  
        String statusCategory, String status, Boolean isFromTrigger) {
        Map<Id, List<String>> quoteIdToAgreementErrorListMap = new Map<Id, List<String>>();
        Set<String> setOfFieldAPINames = UTL_CLM.getFieldAPINameToValidate(recordTypeDeveloperName, requestedAgreementType, 
            statusCategory, status, agreement.Original_Requested_Agreement_Type__c, isFromTrigger);
        String htmlOfFieldLabels = '';
        Boolean isPerpetual = false;
        Boolean isAgrEndDate = false;
        Boolean ifValidationFails = false;
        Boolean isFirstPatientInDateBlank = false;
        Boolean isLastPatientOutDateBlank = false;
        for (String fieldName: setOfFieldAPINames) {
            if(agreement.get(fieldName) == null || agreement.get(fieldName) == false) {
                String labelName = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').
                    getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                if(!String.isBlank(labelName)) {
                    if(labelName == CON_CLM.PERPETUAL) {
                        isPerpetual = true;
                    } else if(labelName == System.Label.Agreement_End_Date) {
                        isAgrEndDate = true;
                    } else if(fieldName == CON_CLM.APINAME_FIRST_PATIENT_IN_DATE) {
                        isFirstPatientInDateBlank = true;
                    } else if(fieldName == CON_CLM.APINAME_LABEL_LAST_PATIENT_OUT_DATE) {
                        isLastPatientOutDateBlank = true;
                    } else {
                        ifValidationFails = true;
                        if(isFromTrigger) {
                            agreement.addError(fieldName,System.Label.CLM_CL0002_Required_Field_Message);
                        } else { 
                            htmlOfFieldLabels += fieldName + '-';
                        }
                    }
                }
            }
        } 
        if(isPerpetual == true && isAgrEndDate == true) {
            ifValidationFails = true;
            if(isFromTrigger) {
                agreement.addError('Apttus__Contract_End_Date__c',CON_CLM.PERPETUAL_CHECKBOX_OR_AGR_END_DATE);
                agreement.addError('Apttus__Perpetual__c',CON_CLM.PERPETUAL_CHECKBOX_OR_AGR_END_DATE);
            } else {
                htmlOfFieldLabels += 'Apttus__Contract_End_Date__c' + '-' + 'Apttus__Perpetual__c' + '-';
            }
        }
        if(statusCategory == CON_CLM.IN_EFFECT 
            && (agreement.Services__c != null &&  agreement.Services__c.contains('eCOA'))  
            && (isFirstPatientInDateBlank == true || isLastPatientOutDateBlank == true)) {
            ifValidationFails = true;
            if(isFromTrigger) {
                if(isFirstPatientInDateBlank) {
                    agreement.addError(CON_CLM.APINAME_FIRST_PATIENT_IN_DATE, System.Label.CLM_CL0002_Required_Field_Message);
                }
                if(isLastPatientOutDateBlank) {
                    agreement.addError(CON_CLM.APINAME_LABEL_LAST_PATIENT_OUT_DATE, System.Label.CLM_CL0002_Required_Field_Message);
                }
            } else {
                if(isFirstPatientInDateBlank) {
                    htmlOfFieldLabels += CON_CLM.APINAME_FIRST_PATIENT_IN_DATE + '-';
                }
                if(isLastPatientOutDateBlank) {
                    htmlOfFieldLabels += CON_CLM.APINAME_LABEL_LAST_PATIENT_OUT_DATE + '-';
                } 
            }
        }
        if(ifValidationFails && statusCategory != CON_CLM.IN_EFFECT && (requestedAgreementType == CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP
            || (agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_WO
            || (agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_EA
            && requestedAgreementType != CON_CLM.REQUESTED_AGREEMENT_TYPE_RA))) && isFromTrigger) {
            agreement.addError(CON_CLM.ASSOCIATED_MSA,CON_CLM.ASSOCIATED_MSA_IF_AN_MSA_EXISTS);
        }
        if(!isFromTrigger && statusCategory == CON_CLM.IN_EFFECT)  {                                                          
            Map<Id, Profile> systemAdminProfileMap = new Map<Id, Profile>(new SLT_Profile().getAdminProfiles(new Set<String> {'Id', 'Name'}));
            if(agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID
                || (agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID
                && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment)
                || agreement.RecordTypeId == CON_CLM.MSA_RECORDTYPEID 
                || agreement.RecordTypeId == CON_CLM.RWLP_RECORDTYPEID
                || agreement.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID
                || (agreement.RecordTypeId == CON_CLM.OSA_RECORDTYPEID && (agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_LRA 
                || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_LOCALRA 
                || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_MA
                || agreement.Apttus__Subtype__c == CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT ))) {
                if(!systemAdminProfileMap.containsKey(UserInfo.getProfileId()) || Test.isRunningTest()) {
                    List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>(new SLT_PermissionSetAssignment().selectByPermissionSetsForUserId(
                        new Set<String>{'Id'}, new Set<Id>{UserInfo.getUserId()}, new Set<String>{CON_CLM.PERM_SET_CONTRACT_IN_OUT_LOG}));
                    if(permissionSetAssignments != null && permissionSetAssignments.isEmpty() 
                        && (agreement.RecordTypeId != CON_CLM.VENDOR_RECORDTYPEID 
                        || (agreement.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID && !agreement.Legal_Entity_1__r.Q_Squared_Legal_Entity__c))) {
                        ifValidationFails = true;
                        htmlOfFieldLabels += '<b>' + System.Label.CLM_CL_0001_Activate_Error_Msg + '</b>' + '-';
                    }
                }
            }
            if((agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID || (agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID
                && agreement.Apttus__Subtype__c != CON_CLM.REQUESTED_AGREEMENT_TYPE_SCCAmendment)) && agreement.Apttus_QPComply__RelatedProposalId__c != null) {
                quoteIdToAgreementErrorListMap = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(new Map<Id, Apttus__APTS_Agreement__c>{agreement.Apttus_QPComply__RelatedProposalId__c => agreement}, false);
                if(quoteIdToAgreementErrorListMap.containsKey(agreement.Apttus_QPComply__RelatedProposalId__c) && !(quoteIdToAgreementErrorListMap.get(agreement.Apttus_QPComply__RelatedProposalId__c)).isEmpty()) {
                    ifValidationFails = true;
                    htmlOfFieldLabels += CON_CLM.ACTIVATE_QUOTE_ERROR + '<br/>' + String.join(quoteIdToAgreementErrorListMap.get(agreement.Apttus_QPComply__RelatedProposalId__c), '<br/>')
                        +  '<br/><br/><b>Quote Owner Details</b><br/>' 
                        + 'Name  :  ' + agreement.Apttus_QPComply__RelatedProposalId__r.Owner.Name + '<br/>' 
                        + 'Email  :  ' + agreement.Apttus_QPComply__RelatedProposalId__r.Owner.Email + '<br/>' + '-';
                }            
            }
        }  
        return htmlOfFieldLabels;
    }
    
    /**
    * This method returns API names of fields of fieldset
    * @param String fieldSet
    * @return List<String>
    */
    public static List<String> getFieldSetValues(String fieldSet) {
        List<String> apiList = new List<String>();
        List<Schema.FieldSetMember> fieldSetMemberList = Schema.SObjectType.Apttus__APTS_Agreement__c.fieldSets.getMap().get(fieldSet).getFields();
        for(Schema.FieldSetMember sf : fieldSetMemberList) {
            apiList.add(sf.getFieldPath());
        }
        return apiList;
    }
    
    /**
    * This method is used to create copy of file from the flow
    * @param AgreementWrapper agreementWrapper
    * @return List<ContentDocument>
    */
    public static List<ContentVersion> createContentDocument(AgreementWrapper agreementWrapper) { 
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        try {
            List<ContentVersion> lstContentVersions = new List<ContentVersion>();
            Set<Id> contentVersionIds = new Set<Id>();
            IQVIA_Agreement__c iqviaAgr = agreementWrapper.iqviaAgreement;
            
            for(ContentVersion cv: new SLT_ContentVersion().getContentVersionByIds(new Set<Id>(agreementWrapper.contentVersionIds), new Set<String>{'Id', 'ContentLocation', 'Description', 'VersionData', 'Title', 'PathOnClient'})){
                ContentVersion cvNew = new ContentVersion();
                cvNew.Title = cv.Title;
                cvNew.VersionData = cv.VersionData;
                cvNew.PathOnClient = cv.PathOnClient;
                cvNew.ContentLocation = cv.ContentLocation;
                cvNew.Description = agreementWrapper.docType;
                lstContentVersions.add(cvNew);
            }
                    
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType> {ContentVersion.SObjectType}
            );
            uow.registerNew(lstContentVersions);
            uow.commitWork();
            
            for(ContentVersion cvId: lstContentVersions){
                contentVersionIds.add(cvId.Id);
            }
            
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            for(ContentVersion cvNew : new SLT_ContentVersion().getContentVersionByIds(contentVersionIds, new Set<String>{'ContentDocumentId', 'Title'})){
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = cvNew.ContentDocumentId;
                cDocLink.LinkedEntityId = iqviaAgr.Id;
            	cDocLink.ShareType = 'I';
                lstCDL.add(cDocLink);
                contentVersions.add(cvNew);
            }
            
            fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
        	    new List<SObjectType> {ContentDocumentLink.SObjectType}
            );
            uow1.registerNew(lstCDL);
            uow1.commitWork();
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        return contentVersions;
    }
    
    /**
    * This method is used to upload files using the custom file component
    * @param List<String> lstFile
    * @param String agrId
    */ 
    @future
    public static void uploadFiles(List<String> lstFile, String agrId) {
        Set<Id> idSet = new Set<Id>();
        List<ContentDocumentLink> lstConDocLink = new List<ContentDocumentLink>();
        Map<Id, String> contentVersionIdToDescriptionMap = new Map<Id, String>();
        if(lstFile != null) {
            for(String f : lstFile) {
                if(!String.isBlank(f) && !f.startsWith('~')) {
                    String descr = f.substringAfterLast('~');
                    List<FileWrapper> fileWrap = (List<FileWrapper>)JSON.deserialize(f.substringBeforeLast('~'), List<FileWrapper>.Class);
                    for(FileWrapper file : fileWrap) {
                        if(String.isNotBlank(file.conVerId)) {
                            contentVersionIdToDescriptionMap.put(file.conVerId, descr);                
                        }           
                    }
                }
            }
        }
        List<ContentVersion> cvList = new SLT_ContentVersion().getContentVersionByIds(contentVersionIdToDescriptionMap.keySet(), new Set<String>{'ContentDocumentId', 'Description'});
        for(ContentVersion cv : cvList) {
            if(contentVersionIdToDescriptionMap.containsKey(cv.Id)) {
                cv.Description = contentVersionIdToDescriptionMap.get(cv.Id);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = agrId;
                cdl.Visibility = 'AllUsers';      
                lstConDocLink.add(cdl);
            }
        }    
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    ContentVersion.SObjectType, ContentDocumentLink.SObjectType
                }
            );          
            if(!cvList.isEmpty() && !lstConDocLink.isEmpty()) {
                uow.registerDirty(cvList);
                uow.registerNew(lstConDocLink);
                uow.commitWork();              
            }
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }    
    }
    
    /**
    * This method is used to return a map which contains ownerIds based on agreement team contact's (Contract Analyst or Team Lead) of agreement
    * @param Set<Id> iqvAgreementIds 
    * @return Map<Id, String>
    */
    public static Map<Id, String> assignOwnerBasedOnAgreementTeam(Set<Id> iqvAgreementIds) {
        Map<Id, IQVIA_Agreement_Team__c> agrTeamsMap = new Map<Id, IQVIA_Agreement_Team__c>();
        Map<Id, String> agreementToContactIdMap = new Map<Id, String>();
        Set<ID> iqvAgreementsWithAgrTeam = new Set<Id>();
        List<User> users = new List<User>();
        Map<String, Id> empNumberToUserIdMap = new Map<String, Id>();
        String condition = 'Contact__c != null AND Type__c=:firstParam AND Agreement__c IN: agreementIds AND Role__c INCLUDES (\'Team Lead\',\'Contract Analyst\') AND Contact__r.Employment_Status_FF__c != \'T\' AND Contact__r.EmployeeNumber__c != \'null\'';
        agrTeamsMap = new Map<Id, IQVIA_Agreement_Team__c>(new SLT_Agreement_Team().getAgreementTeamListByAgreementId(
            iqvAgreementIds, new Set<String>{'Id', 'Contact__c', 'Role__c', 'Agreement__c', 'Contact__r.EmployeeNumber__c'}, condition, 
            CON_CLM.IQVIA_USER_CONTACT_TYPE, null, null));
        if(!agrTeamsMap.isEmpty()){
            for(Id agrTeamId: agrTeamsMap.KeySet()){
                if(agrTeamsMap.get(agrTeamId).Role__c.contains('Contract Analyst')) {
                    iqvAgreementsWithAgrTeam.add(agrTeamsMap.get(agrTeamId).Agreement__c);
                    agreementToContactIdMap.put(agrTeamsMap.get(agrTeamId).Agreement__c, agrTeamsMap.get(agrTeamId).Contact__r.EmployeeNumber__c);
                } else if(!iqvAgreementsWithAgrTeam.contains(agrTeamsMap.get(agrTeamId).Agreement__c) 
                    && agrTeamsMap.get(agrTeamId).Role__c.contains('Team Lead')) {
                    iqvAgreementsWithAgrTeam.add(agrTeamsMap.get(agrTeamId).Agreement__c);
                    agreementToContactIdMap.put(agrTeamsMap.get(agrTeamId).Agreement__c, agrTeamsMap.get(agrTeamId).Contact__r.EmployeeNumber__c);
                }
            }
        }
        if(!agreementToContactIdMap.isEmpty()) {
            Set<String> empNums = new Set<String>();
            empNums.addAll(agreementToContactIdMap.values());
            users = new SLT_User().selectUserByEmployeeNumber(empNums, new Set<String>{'Id', 'EmployeeNumber'});
        }
        if(!users.isEmpty()){
            for(User u: users){
                empNumberToUserIdMap.put(u.EmployeeNumber, u.Id);
            }
        }
        for(Id agrId: agreementToContactIdMap.KeySet()){
            if(empNumberToUserIdMap.containsKey(agreementToContactIdMap.get(agrId)) && empNumberToUserIdMap.get(agreementToContactIdMap.get(agrId)) != null){
                agreementToContactIdMap.put(agrId, empNumberToUserIdMap.get(agreementToContactIdMap.get(agrId)));
            }
        }
        return agreementToContactIdMap;
    }
    /**
    * This method is used to generate docversion and then file
    * @param Id agreementId 
    * @param Id templateId 
    * @return Id docVersionId
    */
    public static String generateDocument(Id agreementId, Id templateId) {
        Id docVersionId = createDocumentVersion(agreementId,templateId);
        if(docVersionId != null) {
        	generateDocWithVerIdFuture(agreementId, templateId, docVersionId);
        }
        return docVersionId;
    }
    /**
    * This method is used to create document version
    * @param Id agreementId 
    * @param Id templateId 
    * @return Id docVersionId
    */
    public static Id createDocumentVersion(Id agreementId, Id templateId) {
        try {
            String docAction = Apttus.AgreementGenerateController.ACTION_GENERATE;
            String outputFormat = 'DOCX';
            String comments = '';
            Apttus__DocumentVersionDetail__c documentVersionDetail = Apttus.AgreementGenerateController.createDocVersionSO(
                agreementId, templateId, docAction, outputFormat, comments);
            if(documentVersionDetail != null) {
                return documentVersionDetail.Id;
            }
        } 
        catch(Exception ex) {
            system.debug('Exception in createDocumentVersion'+ex.getMessage());
        }
        return null;
    }
    /**
    * Future method to call generateDoc API
    * @param Id agreementId 
    * @param Id templateId 
    * @return Id docVersionId
    */
    @future(callout = true)
    public static void generateDocWithVerIdFuture(Id agreementId, Id templateId, Id docVersionId) {
        generateDocWithVerId(agreementId, templateId, docVersionId);
    }
    /**
    * To call generateDoc API - not future
    * @param Id agreementId 
    * @param Id templateId 
    * @return Id docVersionId
    */
    public static void generateDocWithVerId(Id agreementId, Id templateId, Id docVersionId) {
        try {
            if(!Test.isRunningTest()) {
                String sessionId = UTL_CLM.getSessionIdFromVFPage();
                String serverUrl = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/50.0/' + UserInfo.getOrganizationId();
               	Apttus__APTS_Agreement__c agreementSO = new SLT_Agreement().getAgreementDetails(agreementId, new Set<String>{'Id','Name'});
  				Apttus.AgreementGenerateController contrl = new Apttus.AgreementGenerateController(new ApexPages.StandardController(agreementSO));
                contrl.generateDoc(templateId, 'Full access', 'DOCX', false, docVersionId, sessionId, serverUrl);
            } 
        }
        catch(Exception ex) {
            system.debug('Exception in generateDoc API callout'+ex.getMessage());
        }
    }

    /**
    * This method is used to return Agreement Map  
    * @param Set<Id> contentDocumentId
    * @return Map<Id, Apttus__APTS_Agreement__c> 
    */
    public static Map<Id, IQVIA_Agreement__c> getAgreementMapFromCD(Set<Id> cdIdSet, Map<Id, Id> mapCDAGRId) {
        Map<Id, IQVIA_Agreement__c> activatedAGRMap = new Map<Id, IQVIA_Agreement__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'LinkedEntityId', 'ContentDocumentId'};
        
        for(ContentDocumentLink cdLink : new SLT_ContentDocumentLink().getContentDocumentLinkDetailByContentDocumentId(cdIdSet, fieldSet)) {
            if(cdLink.LinkedEntityId.getSObjectType() == Schema.IQVIA_Agreement__c.getSObjectType()) {
                mapCDAGRId.put(cdLink.ContentDocumentId, cdLink.LinkedEntityId);
            }
        }
        
        if(!mapCDAGRId.isEmpty()) {
            Set<Id> agreementIdSet = new Set<Id>();
            agreementIdSet.addAll(mapCDAGRId.values());
            activatedAGRMap = new Map<Id,IQVIA_Agreement__c>(new SLT_IQVIA_Agreement().getAgreementListByConditions(
                new Set<String>{'Id'},
                new Set<String>{CON_CLM.USBU_IQVIA_RECORDTYPEID, CON_CLM.MSA_IQVIA_RECORDTYPEID},
                agreementIdSet, ' Id IN:agrIds AND RecordTypeId IN: strSet AND (Status_Category__c = \''+CON_CLM.IN_EFFECT+'\' OR Status_Category__c = \''+CON_CLM.AMENDED+'\')'));
        }
        return activatedAGRMap;
    }

    /**
    * This method is used to prevent cloning of field values while amending an agreement through amend button
    * @param String objectAPIName
    * @param Apttus__APTS_Agreement__c agreement
    * @return Set<String> 
    */
    public static void excludeFieldsFromCloningWhileAmendingAgreement(String objectAPIName,
        Apttus__APTS_Agreement__c agreement) {
        Set<String> setOfFieldAPIName = new Set<String>();
        List<CLM_Amend_Agreement_Clone_Excluded_Field__c> lstExcludedFields = CLM_Amend_Agreement_Clone_Excluded_Field__c.getAll().values();
        Map <String,Schema.SObjectField> agrFields = Schema.getGlobalDescribe().get(CON_CLM.AGREEMENT_OBJECT_API_NAME).getDescribe().fields.getMap();
        
        if(!lstExcludedFields.isEmpty()) {
            for(CLM_Amend_Agreement_Clone_Excluded_Field__c field : lstExcludedFields) {
                if(objectAPIName == CON_CLM.AGREEMENT_OBJECT_API_NAME) {
                    if(field.Object_Name__c == CON_CLM.AGREEMENT_OBJECT_API_NAME && field.Field_API_Name__c != null
                        && agrFields.containsKey(field.Field_API_Name__c)) {
                        if(String.valueOf(agrFields.get(field.Field_API_Name__c).getDescribe().getType()) == 'Boolean') {
                            agreement.put(field.Field_API_Name__c, agrFields.get(field.Field_API_Name__c).getDescribe().getDefaultValue());
                        }
                        else {
                            agreement.put(field.Field_API_Name__c, null);
                        }
                    }
                }
            }    
        }
    }
    
    /**
    * This method is used to return services based on Opportunity Product 
    * @param Id opportunityId
    * @return String 
    */
    public static String getServicesFromOpportunity(Id opportunityId) {
        Set<String> oliFieldSet = new Set<String> {'Id', 'Product2.ProductCode', 'Product2.Global_Product_Code__c'};
        List<OpportunityLineItem> oppLineItemList = new SLT_OpportunityLineItems().selectByOpportunityIds(
            new Set<Id> { opportunityId }, oliFieldSet);
        if(oppLineItemList.isEmpty()) {
            return '';
        }
        Map<String, String> productToServiceMap = new Map<String, String>();
        Set<String> productCodes = new Set<String>();
        for(OpportunityLineItem oli : oppLineItemList) {
            if(!String.isEmpty(oli.Product2.ProductCode)) {
                productCodes.add(oli.Product2.ProductCode);
            }
        }
        if(!productCodes.isEmpty()) {
            for(CLM_USBU_Service__mdt exactPCMapping : UTL_CLM.getProductServiceMapping(true, productCodes)) {
                productToServiceMap.put(exactPCMapping.MDM_Hierarchy__c, exactPCMapping.Service__c);
                productCodes.remove(exactPCMapping.MDM_Hierarchy__c);
            }
        }
        if(!productCodes.isEmpty()) {
            List<CLM_USBU_Service__mdt> prefixPCMappings = UTL_CLM.getProductServiceMapping(false, null);
            for(String productCode : productCodes) {
                for(CLM_USBU_Service__mdt prefixPCMapping : prefixPCMappings) {
                    if(productCode.startsWith(prefixPCMapping.MDM_Hierarchy__c)) {
                        productToServiceMap.put(productCode, prefixPCMapping.Service__c);
                        break;
                    }
                }
            }
        }
        Set<String> globalProductCodes = new Set<String>();
        for(OpportunityLineItem oli : oppLineItemList) {
            if(!productToServiceMap.containsKey(oli.Product2.ProductCode) && !String.isEmpty(oli.Product2.Global_Product_Code__c)) {
                globalProductCodes.add(oli.Product2.Global_Product_Code__c);
            }
        }
        if(!globalProductCodes.isEmpty()) {
            for(CLM_USBU_Service__mdt exactGPCMapping : UTL_CLM.getProductServiceMapping(true, globalProductCodes)) {
                productToServiceMap.put(exactGPCMapping.MDM_Hierarchy__c, exactGPCMapping.Service__c);
            }
        }
        Set<String> uniqueServices = new Set<String>(productToServiceMap.values());
        return uniqueServices.isEmpty() ? '' : String.join(new List<String>(uniqueServices), ';');
    }

    /**
     * This method is used to get default project manager.
     * @param String legalEntityId
     * @param String therapyArea
     * @param String accountId
     * @param String parentAccountId
     * @return String
     */
    public static String getDefaultPFM(String legalEntityId, String therapyArea, String accountId, String parentAccountId) {
        String pfm = '';
        boolean qunicfound = false;
        Map<String, String> accMap = new Map<String, String>();
        Map<Id, Finance_IQVIA_Legal_Entity__c> legalEntityMap;
        Set<Id> accountIds = new Set<Id>{accountId};
        if(!String.isBlank(parentAccountId)){
            accountIds.add(parentAccountId);
        }
        if(legalEntityId != null && legalEntityId != '') {
            Set<String> fieldSet = new Set<String> {'Id','Function__c', 'ContactId', 'AccountId'};
            String condition = 'IsActive = true AND Function__c = \'' + CON_CLM.PFM + '\'';
            String parentCondition = 'Effective_Status__c = \'' + CON_CLM.ACTIVE + '\' AND Id IN : ids AND RecordTypeId IN: recordTypeIDs';
            String childCondition = 'Therapy_Area__c IN : therapyArea OR Therapy_Area__c = Null';
            legalEntityMap = new Map<Id, Finance_IQVIA_Legal_Entity__c>(new SLT_Finance_IQVIA_Legal_Entity().getFinanceIQVIALegalEntityDetails(new Set<Id>{legalEntityId},
                new Set<String>{'Legacy_Entity_Code__c', 'Id'}, new Set<String>{'Contact__c', 'Therapy_Area__c'}, parentCondition, childCondition , 
                new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID}, new Set<String>{therapyArea}));
            if(legalEntityMap != null && !legalEntityMap.isEmpty() && legalEntityMap.get(legalEntityId).Legacy_Entity_Code__c != null && legalEntityMap.get(legalEntityId).Legacy_Entity_Code__c.equals(CON_CLM.LEGAL_ENTITY_1_CODE)) {
                List<AccountContactRelation> iqviaAccountTeam = new SLT_AccountContactRelation().getAccountContactRelationsWithCondition(fieldSet, accountIds, condition);
                for(AccountContactRelation accRelattion: iqviaAccountTeam) {
                    accMap.put(accRelattion.AccountId, accRelattion.ContactId);
                }
            }
        }
        if(!accMap.isEmpty()) {
            if(accMap.containsKey(accountId)) {
                pfm = accMap.get(accountId);
                qunicfound = true;
            }
            else if(accMap.containsKey(parentAccountId)) {
                pfm = accMap.get(parentAccountId);
                qunicfound = true;
            }
        }
        if(!legalEntityMap.isEmpty() && legalEntityMap.containsKey(legalEntityId) && !qunicfound) {
            for(Finance_IQVIA_Legal_Entity_Extension__c flee: (legalEntityMap.get(legalEntityId)).Finance_Legal_Entity_Extensions__r){
                if(flee.Therapy_Area__c != null &&  flee.Therapy_Area__c == therapyArea) {
                    pfm = flee.Contact__c;
                    break;
                }
                else if(flee.Therapy_Area__c == null) {
                    pfm = flee.Contact__c;
                }
            }
        }
        return pfm;
    }
    
    private static List<CLM_USBU_Service__mdt> getProductServiceMapping(Boolean isExactMatch, Set<String> MDMHierarchy) {
        if(Test.isRunningTest()){
            return new List<CLM_USBU_Service__mdt>{new CLM_USBU_Service__mdt(MDM_Hierarchy__c = 'GP8MAS',
                Is_Exact_Match__c = true, Service__c = 'Test')};
        } else {
            String condition;
            if(isExactMatch) {
                return [SELECT MDM_Hierarchy__c, Service__c FROM CLM_USBU_Service__mdt 
                    WHERE Is_Exact_Match__c = true AND MDM_Hierarchy__c IN :MDMHierarchy];
            } else {
                return [SELECT MDM_Hierarchy__c, Service__c FROM CLM_USBU_Service__mdt 
                    WHERE Is_Exact_Match__c = false AND MDM_Hierarchy__c != null];
            }
        }
    }
    
    /**
    * This method is used to clone agreement team during amendment
    * @param String agrId
    * @param String amendedAgrId
    */
    public static void cloneAgreementTeamOnAmendment(String agrId, String amendedAgrId) {
        Set<String> fieldSet = new Set<String>{'Type__c', 'Contact__c', 'DocuSign_Recipient__c', 'Role__c'};
        String condition = 'Agreement__c IN: agreementIds';
        List<Agreement_Contacts__c> agrConList = new List<Agreement_Contacts__c>();
        for(Agreement_Contacts__c con : new SLT_Agreement_Contacts().getAgreementContactListByAgreementId(new Set<Id>{agrId}, 
            fieldSet, condition, '', '', '')) {
            agrConList.add(new Agreement_Contacts__c(Agreement__c = amendedAgrId, Type__c = con.Type__c, Contact__c = con.Contact__c, 
                DocuSign_Recipient__c = con.DocuSign_Recipient__c, Role__c = con.Role__c));        
        }
        if(!agrConList.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                    Agreement_Contacts__c.SObjectType
                });
                uow.registerNew(agrConList);
                uow.commitWork();
            }
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }

    /**
    * This method is used to Create Agreement Repository Records
    * @param Apttus__APTS_Agreement__c agreement
    * @param Id contentVersionId
    * @return Id of Agreement Repository
    */
    public static Id createAgreementRepository(AgreementWrapper agreementWrapper) {
        String agreementRepositoryNumber;
        Agreement_Repository__c agreementRepository = new Agreement_Repository__c();
        AR_Document__c ARDocument = new AR_Document__c();
        ContentVersion contentVersion = agreementWrapper.contentVersion;
        if(contentVersion != null) {
            contentVersion.Title = contentVersion.Title.replace('.pdf','');
            agreementRepository.Name = contentVersion.Title;
            if(contentVersion.FileExtension == 'Opportunity') {
                Opportunity opportunity = agreementWrapper.Opportunity;
                agreementRepository.Account__c = opportunity.AccountId;
                agreementRepository.Agreement_Type__c = agreementWrapper.docType;
                agreementRepository.Related_Opportunity__c = opportunity.Id;
            } else if(contentVersion.FileExtension == 'BNF') {
                BNF2__c BNF = agreementWrapper.BNF;
                agreementRepository.Account__c = BNF.Description__c;
                agreementRepository.Agreement_Type__c = agreementWrapper.docType;
                agreementRepository.Related_Opportunity__c = BNF.Opportunity__c;
                agreementRepository.Purchase_BNF__c = BNF.Id;
            } else if(contentVersion.FileExtension == 'MiBNF') {
                MIBNF_Component__c MiBNF = agreementWrapper.MiBNF;
                agreementRepository.Account__c = MiBNF.Description__c;
                agreementRepository.Agreement_Type__c = agreementWrapper.docType;
                agreementRepository.Related_Opportunity__c = MiBNF.Opportunity__c;
                agreementRepository.BNF__c = MiBNF.Id;
            }
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Agreement_Repository__c.SObjectType
                    }
                );
                uow.registerNew(agreementRepository);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
        try {
            if(agreementRepository.Id != null) {			
            	ARDocument.Name = contentVersion != null ? contentVersion.Title : '';
                ARDocument.AR_Name__c = agreementRepository.Id;
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                     new Schema.SObjectType[] {
                        AR_Document__c.SObjectType
                    }
                );
                uow.registerNew(ARDocument);
                uow.commitWork();
            
                Agreement_Repository__c agreementRepository1 = new Agreement_Repository__c();
                agreementRepository1 = [SELECT Id,AR_Number__c FROM Agreement_Repository__c WHERE Id = :agreementRepository.Id][0];
                agreementRepositoryNumber = agreementRepository1.AR_Number__c;
            }
            if(ARDocument.Id != null) {
                if(contentVersion != null) {
                    if(contentVersion.FileType == 'ContentVersion') {
                        Set<String> fieldSet = new Set<String>{'Title','VersionData','PathOnClient','ContentLocation',
                            'FileExtension','ContentDocumentId'};
                        List<ContentVersion> existingContentVersions = new List<ContentVersion>();
                        if(contentVersion.Id != null) {
                            for(ContentVersion cv : [Select Title, VersionData, PathOnClient, ContentLocation,
                                FileExtension, ContentDocumentId from ContentVersion where id = :contentVersion.Id]) {
                                existingContentVersions.add(cv);
                                break;
                            }
                        }
                        ContentVersion existingContentVersion = existingContentVersions.isEmpty() ? new ContentVersion() : existingContentVersions[0];
            			ContentVersion newContentVersion = new ContentVersion();
                        newContentVersion.Title = existingContentVersion.Title;
                        newContentVersion.VersionData = existingContentVersion.VersionData;
                        newContentVersion.PathOnClient = existingContentVersion.PathOnClient;
                        newContentVersion.ContentLocation = existingContentVersion.ContentLocation;
                        Schema.SobjectType contentVersionType = Schema.getGlobalDescribe().get('ContentVersion');
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                            new Schema.SObjectType[] {
                                contentVersionType
                            }
                        );
                        uow.registerNew(newContentVersion);
                        uow.commitWork();
                        AR_Document__c ARDocument1 = new AR_Document__c();
                        if(newContentVersion.Id != null) {
                            for(ContentVersion newCV : new SLT_ContentVersion().selectById(new Set<Id>{newContentVersion.Id})) {
                                ContentDocumentLink cDocLink = new ContentDocumentLink();
                                cDocLink.ContentDocumentId = newCV.ContentDocumentId;
                                cDocLink.LinkedEntityId = ARDocument.Id;
                                cDocLink.ShareType = 'I';
                                fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                                    new List<SObjectType> {ContentDocumentLink.SObjectType}
                                );
                                uow1.registerNew(cDocLink);
                                uow1.commitWork();
            					ARDocument1.Id = ARDocument.Id;
            					ARDocument1.Content_Document_Id__c = newCV.ContentDocumentId;
                                break;
                            }
                        }
            			if(ARDocument1.Id != null) {
                            fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                                new List<SObjectType> {AR_Document__c.SObjectType}
                            );
                            uow1.registerDirty(ARDocument1);
                            uow1.commitWork();
            			}
                        if(contentVersion.Description == 'UploadedFile') {
                            MIBNF_Component__c MiBNF = agreementWrapper.MiBNF;
                            BNF2__c BNF = agreementWrapper.BNF;
                            Opportunity opportunity = agreementWrapper.opportunity;
                            if(MiBNF != null || BNF != null) {
                                Attachment attachmentToInsert = new Attachment();
                                attachmentToInsert.ParentId = (BNF != null) ? BNF.Id : MiBNF.Id;
                                attachmentToInsert.Name = 'CON_EOA_SOW_' + existingContentVersion.Title + '.' + existingContentVersion.FileExtension;
                                attachmentToInsert.OwnerId = (BNF != null) ? BNF.Original_Prior_Opportunity_Id__c : MiBNF.Retainer_Opportunity_Number__c;
                                attachmentToInsert.Body = existingContentVersion.VersionData;
                                attachmentToInsert.ContentType = 'application/pdf';
                                
                                fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType>{
                                    Attachment.SObjectType, ContentDocument.SObjectType});
                                uow2.registerNew(attachmentToInsert);
                                uow2.commitWork();
            
                            } else if(opportunity != null){
                                ContentVersion cvNew = new ContentVersion();
                                cvNew.Title = existingContentVersion.Title;
                                cvNew.VersionData = existingContentVersion.VersionData;
                                cvNew.PathOnClient = existingContentVersion.PathOnClient;
                                cvNew.ContentLocation = existingContentVersion.ContentLocation;
                                fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                                    new Schema.SObjectType[] {
                                        contentVersionType
                                    }
                                );
                                uow1.registerNew(cvNew);
                                uow1.commitWork();
                                List<ContentVersion> newContentVersions = new SLT_ContentVersion().
                                    getContentVersionByIds(new Set<Id>{cvNew.Id}, fieldSet);
                                ContentVersion cvNew1 = newContentVersions.isEmpty() ? new ContentVersion() : newContentVersions[0];
                                ContentDocumentLink cDocLink = new ContentDocumentLink();
                                cDocLink.ContentDocumentId = cvNew1.ContentDocumentId;
                                cDocLink.LinkedEntityId = opportunity.Id;
                                cDocLink.ShareType = 'I';
                                fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(
                                    new List<SObjectType> {ContentDocumentLink.SObjectType}
                                );
                                uow2.registerNew(cDocLink);
                                uow2.commitWork();
                            }
                        }
                    }
                    else if(contentVersion.FileType == 'Attachment') {
                        AR_Document__c ARDocument1 = new AR_Document__c();
                        for(Attachment attachment : [SELECT Id, Body, Name From Attachment where Id = :contentVersion.Id]){
                            ContentVersion newContentVersion = new ContentVersion();
                            newContentVersion.Title = attachment.Name;
                            newContentVersion.VersionData = attachment.Body;
                            newContentVersion.PathOnClient = '/' + attachment.Name;
                            newContentVersion.ContentLocation = 'S';
                            Schema.SobjectType contentVersionType = Schema.getGlobalDescribe().get('ContentVersion');
                            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                                new Schema.SObjectType[] {
                                    contentVersionType
                                }
                            );
                            uow.registerNew(newContentVersion);
                            uow.commitWork();
                            if(newContentVersion.Id != null) {
                                for(ContentVersion cv : new SLT_ContentVersion().selectById(new Set<Id>{newContentVersion.Id})) {
                                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                                    cDocLink.ContentDocumentId = cv.ContentDocumentId;
                                    cDocLink.LinkedEntityId = ARDocument.Id;
                                    cDocLink.ShareType = 'I';
                                    fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                                        new List<SObjectType> {ContentDocumentLink.SObjectType}
                                    );
                                    uow1.registerNew(cDocLink);
                                    uow1.commitWork();
                                    ARDocument1.Id = ARDocument.Id;
                                    ARDocument1.Content_Document_Id__c = cv.ContentDocumentId;
                                    break;
                                }
                            }
                            break;
                        }
                        if(ARDocument1.Id != null) {
                            fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(
                                new List<SObjectType> {AR_Document__c.SObjectType}
                            );
                            uow1.registerDirty(ARDocument1);
                            uow1.commitWork();
            			}
                    }
                    Agreement_Repository_Event__e arEvent = new Agreement_Repository_Event__e();
                    if(contentVersion.FileExtension == 'Opportunity') {
                        Opportunity opportunity = agreementWrapper.Opportunity;
                        if(opportunity != null && opportunity.AR_Comments__c == null) {
                            arEvent.Object_Name__c = 'Opportunity';
                            arEvent.Record_Id__c = opportunity.Id;
                            arEvent.AR_Comments__c = agreementRepositoryNumber;
                        }
                    }
                    else if(contentVersion.FileExtension == 'BNF') {
                        BNF2__c bnf = agreementWrapper.BNF;
                        if(bnf != null && bnf.AR_Comments__c == null) {
                            arEvent.Object_Name__c = 'BNF2__c';
                            arEvent.Record_Id__c = bnf.Id;
                            arEvent.AR_Comments__c = agreementRepositoryNumber;
                        }
                    }
                    else if(contentVersion.FileExtension == 'MiBNF') {
                        MIBNF_Component__c miBNF = agreementWrapper.MiBNF;
                        if(miBNF != null && miBNF.AR_Comments__c == null) {
                            arEvent.Object_Name__c = 'MIBNF_Component__c';
                            arEvent.Record_Id__c = miBNF.Id;
                            arEvent.AR_Comments__c = agreementRepositoryNumber;
                        }
                    }
            		if(arEvent.Record_Id__c != null) {
            			EventBus.publish(arEvent);
            		}
                }
            }
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage() + ' \n ' + e.getStackTraceString());
            Apex_Error_Log__c logRecord = new Apex_Error_Log__c();
            logRecord.Record_Id__c = agreementRepository.Id;
            logRecord.Error_Message__c = e.getTypeName() + ' : ' + e.getStackTraceString();
            logRecord.Object__c = CON_CLM.AR_OBJECT_API_NAME;
            logRecord.Record_Processed__c = false;
            logRecord.Running_User__c = UserInfo.getUserId();
            insert logRecord;
        }
        return agreementRepository.Id;
    }

    public static AgreementWrapper.CPQCLMWrapper isNonInflightAgreement(Id proposalId) {
        AgreementWrapper.CPQCLMWrapper wrapper = new AgreementWrapper.CPQCLMWrapper();
        if(Schema.sObjectType.Apttus__APTS_Agreement__c.isAccessible()) {
            wrapper.hasAGRAccess = true;
            String condition = 'IQVIA_Quote__c IN : agreementIds AND RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID 
                + '\' AND Apttus__Subtype__c IN (\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_WO+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA_SMALL_PROJECTS+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA_SMALL_PROJECTS+'\')'
                + ' AND Original_Requested_Agreement_Type__c IN (\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_WO+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA+'\', \''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GCA_SMALL_PROJECTS+'\',\''+CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA_SMALL_PROJECTS+'\', \'\')';
            Set<String> fields = new Set<String> {'Id', 'Apttus__Status_Category__c', 'IQVIA_Quote__c'};
            Map<Id, Apttus__APTS_Agreement__c> mapProposalIdAgr = UTL_CLM.getRelatedAGRs(fields, condition, new Set<Id> {proposalId});
            if(!mapProposalIdAgr.isEmpty()) {
                wrapper.hasRelatedAgreement = true;
                Apttus__APTS_Agreement__c agr = mapProposalIdAgr.get(proposalId);
                if(CON_CLM.NON_IN_FLIGHT_CATEGORY.contains(agr.Apttus__Status_Category__c)) {
                    wrapper.isNonInflightAgreement = true;
                }
            }
        }
        return wrapper;
    }
    public static AgreementWrapper.CPQCLMWrapper validateAgreement(Set<Id> opportunityIds) {
        AgreementWrapper.CPQCLMWrapper wrapper = new AgreementWrapper.CPQCLMWrapper();
        if(Schema.sObjectType.Apttus__APTS_Agreement__c.isAccessible()) {
            wrapper.hasAGRAccess = true;
            String condition = 'Apttus__Related_Opportunity__c IN : agreementIds AND RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID + '\'';
            Set<String> fields = new Set<String>{'Apttus__Related_Opportunity__c','Apttus__Status__c','Apttus__Status_Category__c','Id', 'Apttus__Subtype__c', 'Original_Agreement__c', 'Original_Requested_Agreement_Type__c'};
            List<Apttus__APTS_Agreement__c> lstAgreement = new SLT_Agreement().getAgreementListByCondition(fields, condition, opportunityIds);
            Map<Id, Integer> oppToInFlightAgrMap = new Map<Id, Integer>();
            
            if(!lstAgreement.isEmpty()) {
                wrapper.hasRelatedAgreement = true;
                for (Apttus__APTS_Agreement__c agreement : lstAgreement) {
                    if ((agreement.Original_Agreement__c == null && CON_CLM.PROJECT_SPECIFIC_SUBTYPES.contains(agreement.Apttus__Subtype__c)
                        || agreement.Original_Agreement__c != null && CON_CLM.PROJECT_SPECIFIC_SUBTYPES.contains(agreement.Original_Requested_Agreement_Type__c))
                        && (agreement.Apttus__Status_Category__c == CON_CLM.AMENDED || agreement.Apttus__Status_Category__c == CON_CLM.IN_EFFECT)) {
                        wrapper.activatedPSAFound = true;
                    }
                    if (!CON_CLM.NON_IN_FLIGHT_CATEGORY.contains(agreement.Apttus__Status_Category__c) && agreement.Apttus__Subtype__c == CON_CPQ.CHNAGE_ORDER) {
                        if (oppToInFlightAgrMap.containsKey(agreement.Apttus__Related_Opportunity__c)) {
                            oppToInFlightAgrMap.put(agreement.Apttus__Related_Opportunity__c, (oppToInFlightAgrMap.get(agreement.Apttus__Related_Opportunity__c) + 1));
                        } else {
                            oppToInFlightAgrMap.put(agreement.Apttus__Related_Opportunity__c, 1);
                        }
                    }
                }
                wrapper.oppToInFlightAgrMap = oppToInFlightAgrMap;
            }
        }
        return wrapper;
    }

    @TestVisible
    private static Map<Id, Apttus__APTS_Agreement__c> getRelatedAGRs(Set<String> fields, String condition, Set<Id> proposalIds) {
        Map<Id, Apttus__APTS_Agreement__c> mapProposalIdAgr = new Map<Id, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agr: new SLT_Agreement().getAgreementListByCondition(fields, condition, proposalIds)) {
            if(!mapProposalIdAgr.containskey(agr.IQVIA_Quote__c)) {
                mapProposalIdAgr.put(agr.IQVIA_Quote__c, agr);
            }
        }
        return mapProposalIdAgr;
    }
    
    
    public static AgreementWrapper.CPQCLMWrapper getRelatedAGRFromProposal(Set<String> fields, String condition, Set<Id> proposalIds) {
        Map<Id, Apttus__APTS_Agreement__c> mapProposalIdAgr = new Map<Id, Apttus__APTS_Agreement__c>();
        AgreementWrapper.CPQCLMWrapper wrapper = new AgreementWrapper.CPQCLMWrapper();
        if(Schema.sObjectType.Apttus__APTS_Agreement__c.isAccessible()) {
            wrapper.hasAGRAccess = true;
            wrapper.mapOfPropIdAGR = getRelatedAGRs(fields, condition, proposalIds);
            if(wrapper.mapOfPropIdAGR != null && !wrapper.mapOfPropIdAGR.isEmpty()) {
                wrapper.hasRelatedAgreement = true;
            }
        }
        return wrapper;
    }
    
}