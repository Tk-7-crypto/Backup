public with sharing class DAOH_ContentDocumentLink {

    public static void defineSharingRuleCTRPRM(List<ContentDocumentLink> newList){
        Set<Id> parentIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id','RecordTypeId'};
        Map<Id, Contract> contractMap;
        Id prmCtrRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
        
        for(ContentDocumentLink cntDocLnk : newList){
            if(cntDocLnk.LinkedEntityId != null){
                String parentId = cntDocLnk.LinkedEntityId;
                if(parentId.substring(0,3) == Contract.SObjectType.getDescribe().getKeyPrefix())
                {
                    parentIdSet.add(cntDocLnk.LinkedEntityId);
                }
            }
        }
            
        if(parentIdSet.size() > 0){
            contractMap = new Map<Id, Contract>(new SLT_Contract().selectByContractIdList(parentIdSet,fieldSet));
        }
        
        if(contractMap !=null && contractMap.size() > 0){
            for(ContentDocumentLink cntDocLnk : newList){
                if(cntDocLnk.LinkedEntityId != null
                   && contractMap.get(cntDocLnk.LinkedEntityId) !=null 
                   && contractMap.get(cntDocLnk.LinkedEntityId).RecordTypeId == prmCtrRecTypeId){
                       cntDocLnk.Visibility = 'AllUsers';//sharing with all internal and external users
                       cntDocLnk.ShareType = 'I';//Inferred permission : based on related permission on contract
                   }
            }
        }
    }

    public static void sendEmailNotificationOnNewAttachment(List<ContentDocumentLink> documentList){
        if(documentList != null){
            Map<Id, Id> contentDocumentIdCaseMap = new Map<Id, Id>();
            List<ContentDocument> contentDocumentList = new List<ContentDocument>();
            Set<Id> caseIdSet = new Set<Id>();
            List<Case> caseList = new List<Case>();
            Map<Id, Case> caseIdRecordMap = new Map<Id, Case>();
            Map<Id, Case> documentIdCaseMap = new Map<Id, Case>();
            List<User> userList = new List<User>();
            List<Case> caseToUpdate = new List<Case>();
            
            for(ContentDocumentLink documentRecord : documentList){
                if(documentRecord.LinkedEntityId != null && documentRecord.ContentDocumentId != null){
                    String parentId = documentRecord.LinkedEntityId;
                    String parentIdString = String.valueOf(parentId).substring(0,3);
                    if(parentIdString.equalsIgnoreCase('500') && documentRecord.Visibility.EqualsIgnoreCase('AllUsers')){
                        contentDocumentIdCaseMap.put(documentRecord.ContentDocumentId, documentRecord.LinkedEntityId);
                        caseIdSet.add(documentRecord.LinkedEntityId);
                    }
                }
            }

            if((contentDocumentIdCaseMap != null && !contentDocumentIdCaseMap.isEmpty()) && (caseIdSet != null && !caseIdSet.isEmpty())){
                caseList = new SLT_Case().selectById(caseIdSet);
                for(Case caseRecord : caseList){
                    caseIdRecordMap.put(caseRecord.Id, caseRecord);
                }
                contentDocumentList = new SLT_ContentDocument().selectById(contentDocumentIdCaseMap.keySet());
                for(ContentDocument contentRecord : contentDocumentList){
                    if(contentRecord.CreatedById != null && contentDocument.Id != null){
                        documentIdCaseMap.put(contentRecord.CreatedById, caseIdRecordMap.get(contentDocumentIdCaseMap.get(contentRecord.Id)));
                    }
                }
                if(documentIdCaseMap != null && !documentIdCaseMap.isEmpty()){
                    userList = new SLT_User().selectById(documentIdCaseMap.keySet());
                    for(User userRecord : userList){
                        if(userRecord.ProfileId == CON_CSM.S_COMMUNITY_PLUS_USER_PROFILEID){
                            documentIdCaseMap.get(userRecord.Id).CSH_Attachment__c = TRUE;
                            documentIdCaseMap.get(userRecord.Id).New_Attachment__c = TRUE;
                            caseToUpdate.add(documentIdCaseMap.get(userRecord.Id));
                        }
                        else if(userRecord.ProfileId == CON_CSM.S_SERVICE_USER_PROFILEID){
                            documentIdCaseMap.get(userRecord.Id).CSH_Attachment__c = FALSE;
                            documentIdCaseMap.get(userRecord.Id).New_Attachment__c = TRUE;
                            caseToUpdate.add(documentIdCaseMap.get(userRecord.Id));
                        }
                    }
                }
            }
            
            if(caseToUpdate != null && !caseToUpdate.isEmpty()){
                update caseToUpdate;
            }
        }
    }

    public static void onAfterInsert(List<ContentDocumentLink> newRecords) {
        System.debug('DAOH: ContentDocumentLink After Insert Called.');

        // Key: ContentDocumentLink Id, Value: parentId
        Map<Id, Id> parentIdsMap = new Map<Id, Id>();
        
        for(ContentDocumentLink cdl : newRecords) {
            if((!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && cdl.LinkedEntityId.getSObjectType() == Schema.TPA_Request__c.getSObjectType()) || (!UTL_CDAUtility.isSkipCDATriggers && cdl.LinkedEntityId.getSObjectType() == Schema.CDA_Request__c.getSObjectType())) {
                parentIdsMap.put(cdl.ContentDocumentid, cdl.LinkedEntityId); 
            }
        }

        system.debug('parentIdsMap: ' + parentIdsMap);
        if(parentIdsMap != Null && parentIdsMap.size() > 0) {
            processCdaTpaFiles(newRecords, parentIdsMap);
        }
    }
    
    public static void processCdaTpaFiles(List<ContentDocumentLink> newRecords, Map<Id, Id> parentIdsMap) {        
        List<Attachment> attachListToInsertTpa = new List<Attachment>();
        List<Attachment> attachListToInsertCda = new List<Attachment>();
        boolean isCdaTemplateFileGenerated = false;
        boolean isCdaTPAFilesNeedToDelete = true;
        
        for(ContentVersion cversion: [SELECT title, 
                                             PathOnClient, 
                                             versiondata,
                                             ContentDocumentId,
                                             FileExtension 
                                      FROM contentversion 
                                      WHERE ContentDocumentId IN :parentIdsMap.keySet()]) {
            blob fileBody = cversion.versiondata;
            
            // Create a attachment for each file
            Attachment attach = new Attachment();
            attach.Body = fileBody;
            attach.IsPrivate = false;
            attach.ParentId = parentIdsMap.get(cversion.ContentDocumentId);
            
            if(parentIdsMap.get(cversion.ContentDocumentId) != Null && parentIdsMap.get(cversion.ContentDocumentId).getSObjectType() == Schema.CDA_Request__c.getSObjectType()) {
                isCdaTemplateFileGenerated = false;
                if(UTL_CDAUtility.settingObject != null && !UTL_Validate.isEmptyOrNull(UTL_CDAUtility.settingObject.CDA_Template_Names__c)) {
                    for(string strTemplateName: UTL_CDAUtility.settingObject.CDA_Template_Names__c.split(';')) {
                        if(cversion.title.indexOf(strTemplateName) != -1) {
                            isCdaTemplateFileGenerated = true;
                            isCdaTPAFilesNeedToDelete = false;
                            break;
                        }
                    }
                }
                if(!isCdaTemplateFileGenerated) {
                    attach.Name = cversion.title;
                    String extension = attach.Name.substring(attach.Name.lastIndexOf('.')+1);
                    system.debug('extension '+extension);
                    if(extension != null && extension != cversion.FileExtension){
                        attach.Name = attach.Name +'.'+cversion.FileExtension;
                    }
                    attachListToInsertCda.add(attach);
                }
            }
            else {
                attach.Name = cversion.title;
                String extension = attach.Name.substring(attach.Name.lastIndexOf('.')+1);
                system.debug('extension '+extension);
                if(extension != null && extension != cversion.FileExtension){
                    attach.Name = attach.Name +'.'+cversion.FileExtension;
                }
                attachListToInsertTpa.add(attach);
            }
        }

        system.debug('attachListToInsertCda: ' + attachListToInsertCda);
        system.debug('attachListToInsertTpa: ' + attachListToInsertTpa);

        if(attachListToInsertCda != null && attachListToInsertCda.size() > 0) {
            insert attachListToInsertCda;
        }
        if(attachListToInsertTpa != null && attachListToInsertTpa.size() > 0) {
            insert attachListToInsertTpa;
        }
        // Delete all files after inserting corresponding attachments
        if(isCdaTPAFilesNeedToDelete) {
            deleteContentdocLink(parentIdsMap);
        }
    }

    @future
    public static void deleteContentdocLink(Map<Id, Id> parentIdsMap) {
        System.debug('DAOH: deleteContentdocLink Called.');
        List<ContentDocument> contentDocumentToDel = new List<ContentDocument>();
        contentDocumentToDel = [SELECT Id FROM ContentDocument WHERE Id IN :parentIdsMap.keySet()];
        system.debug('contentDocumentToDel before delete: ' + contentDocumentToDel);
        
        if(contentDocumentToDel.size() > 0) {
            delete contentDocumentToDel;
        } 
    }
    
    public static void callOutBISMAttachmentforCase(String contentDocumentId, String linkedEntityId){
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> caseList = new SLT_Case().selectById(new Set<Id>{linkedEntityId});
        String strExtType = null;
        for(Case c : caseList){
            if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Service_Now_Incident_Number__c != null && c.External_System_Type__c != null && (c.External_System_Type__c == CON_CSM.S_BISM || c.External_System_Type__c == CON_CSM.S_ROCHE_SN)){
                caseMap.put(contentDocumentId, c);
                strExtType = c.External_System_Type__c;
            }
            
        }
        if(strExtType != null){
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(strExtType);
            if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && !caseMap.isEmpty() && !System.isFuture() && !System.isBatch()){
                if(strExtType == CON_CSM.S_BISM){
                    WSC_CSM_BISMSOAPCallout.UpdateTicketCSM2BISMAttachment(JSON.serialize(caseMap));  
                }else if(strExtType == CON_CSM.S_ROCHE_SN){
                    WSC_CSM_ROCHERestCallout.addIncidentAttachment(JSON.serialize(caseMap));
                }
            }
        }
    }
    
    public static void countForAttachmentOnRDCaseActivities(List<ContentDocumentLink> newRecords){
        Set<Id> activityIds = new Set<Id>();
        Map<Id,Integer> linkedIdEntityMap = new Map<Id,Integer>();
        for(ContentDocumentLink cdRecord : newRecords){
            String linkid = String.valueof(cdRecord.LinkedEntityId);
            if(linkid.startsWith('a00')){
                activityIds.add(cdRecord.LinkedEntityId);
                linkedIdEntityMap.put(cdRecord.LinkedEntityId,0);
            }
        }
        if(activityIds != null && !activityIds.isEmpty()){
            List<Activity__c> actList = new SLT_ActivityC().getActivityById(activityIds);
            List<ContentDocumentLink> contentList = new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(activityIds);
            if(contentList != null && !contentList.isEmpty()){
                for(ContentDocumentLink cdlRecord : contentList){
                    Integer count = linkedIdEntityMap.get(cdlRecord.LinkedEntityId);
                    count = count+1;
                    linkedIdEntityMap.remove(cdlRecord.LinkedEntityId);
                    linkedIdEntityMap.put(cdlRecord.LinkedEntityId, count);
                }
            }
            for(Activity__c actRecord : actList){
                if(linkedIdEntityMap.containsKey(actRecord.Id)){
                    actRecord.Attachments__c =linkedIdEntityMap.get(actRecord.Id);
                }
            }
            if(actList != null && actList.size()>0){
                update actList;
            }
        }
    }
    
    public static void deleteSignatureImageFromInboundEmail(List<ContentDocumentLink> newRecords){
        Map<Id,Id> emailMap = new Map<Id,Id>();
        for(ContentDocumentLink cdl : newRecords){
            if(cdl != null && cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == CON_CSM.S_EMAILMESSAGE){
                emailMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
        }
        if(emailMap != null && emailMap.size() > 0){
            List<Id> emailIds = emailMap.values();
            List<EmailMessage> emailList = Database.query('SELECT Id, ParentId,Parent.RecordTypeName__c, CreatedDate, MessageDate, Incoming, Subject, TextBody, HasAttachment, ToAddress, FromAddress FROM EmailMessage WHERE Id IN :emailIds and ParentId != null and Incoming = true');
            Set<Id> parentIds = new Set<Id>();
            if(emailList != null && !emailList.isEmpty()){
                for(EmailMessage emailRecord : emailList){
                    if(emailRecord.Incoming && emailRecord.HasAttachment && emailRecord.ParentId != null && emailRecord.Parent.RecordTypeName__c != CON_CSM.S_TECHNOLOGY_R_T){
                        parentIds.add(emailRecord.Id);
                    }
                }
                Set<id> docIdSet = emailMap.keySet();
                List<ContentDocument> emailAttachmentList = Database.query('SELECT Id, Title, PublishStatus, LatestPublishedVersionId, ParentId, LastViewedDate, LastReferencedDate, Description, ContentSize, FileType, FileExtension, SharingOption, SharingPrivacy, ContentModifiedDate, ContentAssetId FROM ContentDocument where Id in:docIdSet');
                if(emailAttachmentList != null && !emailAttachmentList.isEmpty()){
                    Map<Id,Id> attachmentDeletionList = new Map<Id,Id>();
                    for(ContentDocument attachmentRecord : emailAttachmentList){
                        if(emailMap.containsKey(attachmentRecord.Id) && parentIds.contains(emailMap.get(attachmentRecord.Id)) && attachmentRecord.ContentSize != null && (attachmentRecord.ContentSize/1024) <= 12 && (attachmentRecord.FileType == 'bmp' || attachmentRecord.FileType == 'jpeg' || attachmentRecord.FileType == 'jpg' || attachmentRecord.FileType == 'png')){
                            attachmentDeletionList.put(attachmentRecord.Id,attachmentRecord.Id);
                        }
                    }
                    if(attachmentDeletionList != null && attachmentDeletionList.size() > 0){
                        try{
                            deleteContentdocLink(attachmentDeletionList);
                        }
                        catch(Exception ex){
                            ex.getStackTraceString();
                        }
                    }
                }
            }
        }
    }
}