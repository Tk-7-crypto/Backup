/**
* This is Attachment DAO helper class.
* version:1.0
*/
public class DAOH_Attachment {
    private static CDA_Request__c cdaRequest;
    static TGRH_TPAAttachment tpaTriggerHelper = new TGRH_TPAAttachment();
    static List<Attachment> dsStatusAttachments = new List<Attachment>();
    static List<Attachment> listTpaNewAttachments = new List<Attachment>();
    static List<Attachment> listTpaOldAttachments = new List<Attachment>();
    static Map<Id, Attachment> mapTpaNewAttachments = new Map<Id, Attachment>();
    static Map<Id, Attachment> mapTpaOldAttachments = new Map<Id, Attachment>();
    static List<String> tpaRequestAttachmentIds = new List<String>();
    
    public static Boolean isNegotiator {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }

    public static Boolean isEndStatus {
        get {
            if(cdaRequest != null) {
                return (cdaRequest.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED || cdaRequest.Status__c == UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR || cdaRequest.Status__c == UTL_CDAUtility.STATUS_DISCLOSUREPERIODENDED);    //Updated by Vikram Singh under Item #254
            }
            return false;
        }
        set;
    }

    /**
    * This method is used to handle on before insert changes for attachment object.
    * @param newList List<Attachment>
    * @return  void
    */
    public static void handleOnBeforeInsertAttachment(List<Attachment> newList) {
        Set<Id> parentIdSet = new Set<Id>();
        dsStatusAttachments = new List<Attachment>();
        listTpaNewAttachments = new List<Attachment>();
        //Map<Id, dsfs__DocuSign_Status__c> dsStausMapWithId;
        for(Attachment attach: newList) {
            parentIdSet.add(attach.parentId);
            if(attach.parentId.getSObjectType().getDescribe().getName() == 'TPA_Request__c') {
                listTpaNewAttachments.add(attach);
                tpaRequestAttachmentIds.add(attach.Id);
            }
            else if(attach.parentId.getSObjectType().getDescribe().getName() == 'dsfs__DocuSign_Status__c') {
                listTpaNewAttachments.add(attach);
                tpaRequestAttachmentIds.add(attach.parentId);
                dsStatusAttachments.add(attach);
            }
        } 
        
        List<dsfs__DocuSign_Status__c> dsRecords;
        List<dsfs__DocuSign_Status__c> tpaDsRecords = new List<dsfs__DocuSign_Status__c>();
        if(dsStatusAttachments.size() > 0) {
            dsRecords = [SELECT Id, TPA_Request__c, dsfs__Envelope_Status__c, TPA_Request__r.name  FROM dsfs__DocuSign_Status__c  where id IN : tpaRequestAttachmentIds];
            if(dsRecords != null && dsRecords.size() > 0) {
                for(dsfs__DocuSign_Status__c dsObj: dsRecords) {
                    if(dsObj.TPA_Request__c != null) {
                        tpaDsRecords.add(dsObj);
                    }
                }
            }
        }

        
        if(!UTL_CDAUtility.isSkipCDATriggers) {
            /*if(parentIdSet != null && parentIdSet.size() > 0) {
                //dsStausMapWithId = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id, CDA_Request__c, CDA_Request__r.CDA_Id__c, CDA_Request__r.id, CDA_Request__r.CDA_Type__c, CDA_Request__r.Recipient_Account_Name_Formula__c, CDA_Request__r.CDA_Format__c, dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE Id In: parentIdSet and CDA_Request__c != null ORDER BY createddate desc]);
                String query = 'SELECT id, CDA_Request__c, CDA_Request__r.CDA_Id__c, CDA_Request__r.id, CDA_Request__r.CDA_Type__c, CDA_Request__r.Recipient_Account_Name_Formula__c, CDA_Request__r.CDA_Format__c, dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE Id In: parentIdSet and CDA_Request__c != null ORDER BY createddate desc';
                dsStausMapWithId = new Map<Id, dsfs__DocuSign_Status__c>((List<dsfs__DocuSign_Status__c>)Database.query(query));
            }
            if(dsStausMapWithId != null && dsStausMapWithId.size() > 0) {
                for(Attachment attach: newList) {
                    if(dsStausMapWithId.containsKey(attach.ParentId)) {
                        attach.Name = UTL_CDAUtility.getDocumentName(dsStausMapWithId.get(attach.ParentId).CDA_Request__r, UTL_CDAUtility.COMPLETED_KEYWORD);
                        SRV_CDA_DocusignStatus.splitSignedDocument(dsStausMapWithId.get(attach.ParentId).CDA_Request__r.id, dsStausMapWithId.get(attach.ParentId).dsfs__DocuSign_Envelope_ID__c);
                        attach.ParentId = dsStausMapWithId.get(attach.ParentId).CDA_Request__c;
                    }
                }
            }*/
            TGRH_CDAAttachment.handleOnBeforeInsertAttachment(newList, parentIdSet);
        }
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && (tpaDsRecords.size() > 0 || listTpaNewAttachments.size() > 0)) {
            tpaTriggerHelper.OnBeforeInsert(listTpaNewAttachments, tpaDsRecords);
        }
    }



    /**
    * This method is used to handle on after Insert changes for attachment object.
    * @param newList List<Attachment>
    * @return  void
    */
    
    public static void handleOnAfterInsertAttachment(List<Attachment> newList) {
        listTpaNewAttachments = new List<Attachment>();
        for(Attachment attach: newList) {
            if(attach.parentId.getSObjectType().getDescribe().getName() == 'TPA_Request__c') {
                listTpaNewAttachments.add(attach);
            }
        }
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && listTpaNewAttachments.size() > 0) {
            tpaTriggerHelper.OnAfterInsert(listTpaNewAttachments);
        }
    }

    public static void handleOnBeforeUpdateAttachment(List<Attachment> newRecords, List<Attachment> oldRecords, Map<Id, Attachment> newMap, Map<Id, Attachment> oldMap) {
        tpaTriggerHelper.OnBeforeUpdate(oldRecords, newRecords, newMap, oldMap);
    } 
    
    

    /**
    * This method is used to handle on before delete changes for attachment object.
    * @param existingRecords Map<Id, Attachment>
    * @return  void
    */
    public static void handleOnBeforeDeleteAttachment(List<Attachment> attachmentList) {
        Set<Id> parentIdSet = new Set<Id>();
        List<CDA_Request__c> cdaRequestList;
        for (Attachment attach: attachmentList) {
            parentIdSet.add(attach.parentId);
        }
        if(parentIdSet != null && parentIdSet.size() > 0 && !UTL_CDAUtility.isSkipCDATriggers) {
            /*cdaRequestList = [SELECT id, Name, Status__c, Owner.Id, Owner.Name FROM CDA_Request__c WHERE Id IN :parentIdSet];
            if(cdaRequestList != null && cdaRequestList.size() > 0) {

                for(Attachment attach: attachmentList) {
                    for(CDA_Request__c cdaReq : cdaRequestList) {
                        cdaRequest = cdaReq;
                        if(attach.ParentId == cdaReq.Id && (isEndStatus  || (!isNegotiator && attach.OwnerId != UserInfo.getUserId()))) {
                            attach.ParentId.addError('You are not authorized to delete this attachment.');
                        }
                    }
                }
            }*/
            TGRH_CDAAttachment.handleOnBeforeDeleteAttachment(attachmentList, parentIdSet);
        }
    }

    /**
    * This method is used to handle on after update changes for attachment object.
    * @param newList List<Attachment>
    * @return  void
    */
    public static void handleOnAfterUpdateAttachment(List<Attachment> oldRecords, List<Attachment> newList, Map<Id, Attachment> newMap, Map<Id, Attachment> oldMap) {
        Set<Id> parentIdSet = new Set<Id>();
        listTpaNewAttachments = new List<Attachment>();
        listTpaOldAttachments = new List<Attachment>();
        mapTpaNewAttachments = new Map<Id, Attachment>();
        mapTpaOldAttachments = new Map<Id, Attachment>();
        for (Attachment attach: newList) {
            if(attach.parentId.getSObjectType().getDescribe().getName() == 'CDA_Request__c') {
                parentIdSet.add(attach.parentId);
            }
            if(attach.parentId.getSObjectType().getDescribe().getName() == 'TPA_Request__c') {
                listTpaNewAttachments.add(attach);
                listTpaOldAttachments.add(oldMap.get(attach.Id));
                mapTpaNewAttachments.put(attach.Id, newMap.get(attach.Id));
                mapTpaOldAttachments.put(attach.Id, oldMap.get(attach.Id));
            }
        }
        system.debug('####inside DAOH_Attachment.AfterUpdate attach.parentId: '+parentIdSet);
        if(parentIdSet != null && parentIdSet.size() > 0 && !UTL_CDAUtility.isSkipCDATriggers) {
            /*String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
            List<CDA_Request__c> cdaRequestList = Database.query('SELECT ' + fieldStr + ' FROM CDA_Request__c WHERE id in: parentIdSet and Status__c = \'' + UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING + '\'');
            if(cdaRequestList != null && cdaRequestList.size() > 0) {
                for (Attachment attach: newList) {
                    system.debug('####inside DAOH_Attachment.AfterUpdate attach: '+attach);
                    system.debug('####inside DAOH_Attachment.AfterUpdate CDARequest: '+cdaRequestList[0]);
                    if(attach.Name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && attach.Name.contains(cdaRequestList[0].Name) && cdaRequestList[0].Status__c == UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING) {
                        system.debug('####inside DAOH_Attachment.AfterUpdate Calling Docusign');
                        //Once CDA generated let's submit the request for further processing
                        QUE_CDA_AsyncSendCDADoc asyncSendDocQue = new QUE_CDA_AsyncSendCDADoc();
                        asyncSendDocQue.cdaRequest = cdaRequestList[0];
                        System.enqueueJob(asyncSendDocQue);
                    }
                }
            }*/
            TGRH_CDAAttachment.handleOnAfterUpdateAttachment(newList, parentIdSet);
        }
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && listTpaNewAttachments.size() > 0) {
            tpaTriggerHelper.OnAfterUpdate(listTpaOldAttachments, listTpaNewAttachments, mapTpaOldAttachments, mapTpaNewAttachments);
        }
    }

    /**
    * This method is used to handle on after delete changes for attachment object.
    * @param newList List<Attachment>
    * @return  void
    */

    public static void handleOnAfterDeleteAttachment(List<Attachment> newList, Map<Id, Attachment> newMap) {
        listTpaNewAttachments = new List<Attachment>();
        mapTpaNewAttachments = new Map<Id, Attachment>();
        for (Attachment attach: newList) {
            if(attach.parentId.getSObjectType().getDescribe().getName() == 'TPA_Request__c') {
                listTpaNewAttachments.add(attach);
                mapTpaNewAttachments.put(attach.Id, newMap.get(attach.Id));
            }
        }
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c && listTpaNewAttachments.size() > 0) {
            tpaTriggerHelper.OnAfterDelete(listTpaNewAttachments, mapTpaNewAttachments);
        }
    }

    public static void updateContractOnAttachment(List<Attachment> attachmentList){
        Set<Id> docusignStatusId = new Set<Id>();
        for(Attachment att : attachmentList){
            //Check if added attachment is related to Account or not
            if(att.ParentId.getSobjectType() == dsfs__DocuSign_Status__c.SobjectType){
                docusignStatusId.add(att.ParentId);
            }
        }
        
        List<Contract> contractList = getContractList(docusignStatusId);
            //[select id, Date_executed_signed_contract_received__c, SOW_status__c, Agency_Program__c, Agency_Program__r.Name, ContractNumber, DocusignStatusId__c from Contract 
                                       //where DocusignStatusId__c in : docusignStatusId LIMIT 1];
        
        List<Contract> contractListToUpdate = new List<Contract>();
        
        //To update the attachment Name and Contract Status                                                     
        if(contractList !=null && contractList.size()>0){
            for(Attachment att : attachmentList){
                att.ParentId = contractList[0].Id;
                att.Name = contractList[0].Agency_Program__r.Name +'_'+ contractList[0].ContractNumber +'.pdf';
                contractList[0].SOW_status__c = 'Signed';
                contractList[0].Date_executed_signed_contract_received__c = date.today();
                contractListToUpdate.add(contractList[0]);
            }
        }
        
        if(contractListToUpdate.size() > 0){
            //Database.update(contractListToUpdate,true);
            updateContractList(contractListToUpdate);
        }
    }
    
    @testVisible private static List<Contract> testContractList;
    @testVisible private static Boolean useMock=False;
    @testVisible private static List<Contract> getContractList(Set<Id> docusignStatusId) {
        List<Contract> listOfContract; 
        if(useMock) {
      listOfContract = testContractList;            
        } else {
           listOfContract = [select id, Date_executed_signed_contract_received__c, SOW_status__c, Agency_Program__c, Agency_Program__r.Name, ContractNumber, DocusignStatusId__c from Contract 
                                       where DocusignStatusId__c in : docusignStatusId LIMIT 1];
        }
        return listOfContract;
    }
    
    @testVisible private static void updateContractList(List<Contract> contractListToUpdate) {
        if(!useMock) {
            Database.update(contractListToUpdate,true);  
        }
    }

    public static void updateCaseStatusToAbandoned(List<Attachment> newList){
        Set<id> emailMessageId = new Set<id>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Attachment newAttachment : newList) {
            if(newAttachment.parentId != null && newAttachment.ContentType == 'audio/wav' && newAttachment.BodyLength/1000 <= 25)
            emailMessageId.add(newAttachment.parentId);
        }
        if(!emailMessageId.isEmpty()) {
            List<emailMessage> listOfEmailMessage = [Select ParentId from EmailMessage where Id in : emailMessageId];
            for(emailMessage newEmailMessage : listOfEmailMessage) {
                caseIdSet.add(newEmailMessage.parentId);   
            }
            List<Case> caseList = new SLT_Case().selectById(caseIdSet);  
            if(!caseList.isEmpty()) {
                for(case newCase : caseList){
                    if(newCase.RecordTypeName__C == CON_CSM.S_RDCASE || newCase.RecordTypeName__C == CON_CSM.S_ACTIVITY_R_T)
                        newCase.status = CON_CSM.S_CASE_ABANDONED;
                }
                update caseList;
            }
        }
    }
    
    public static void deleteSignatureImageFromInboundEmail(List<Attachment> attachmentList){
        Set<Id> emailIds = new Set<Id>();
        for(Attachment attachmentRecord : attachmentList){
            if(attachmentRecord != null && attachmentRecord.ParentId != null && attachmentRecord.ParentId.getSObjectType().getDescribe().getName().equalsIgnoreCase(CON_CSM.S_EMAILMESSAGE)){
                emailIds.add(attachmentRecord.ParentId);
            }
        }
        if(emailIds != null && emailIds.size() > 0){
            List<EmailMessage> emailList = new SLT_EmailMessage().getEmailRecordsById(emailIds);
            Set<Id> parentIds = new Set<Id>();
            if(emailList != null && !emailList.isEmpty()){
                for(EmailMessage emailRecord : emailList){
                    if(emailRecord.Incoming && emailRecord.HasAttachment && emailRecord.Parent.RecordTypeName__c != CON_CSM.S_TECHNOLOGY_R_T){
                        parentIds.add(emailRecord.Id);
                    }
                }
                List<Attachment> emailAttachmentList = new SLT_Attachment().selectAttachmentsByParentId(parentIds);
                if(emailAttachmentList != null && !emailAttachmentList.isEmpty()){
                    List<Attachment> attachmentDeletionList = new List<Attachment>();
                    for(Attachment attachmentRecord : emailAttachmentList){
                        if(attachmentRecord.BodyLength != null && (attachmentRecord.BodyLength/1024) <= 12 && (attachmentRecord.ContentType == 'image/bmp' || attachmentRecord.ContentType == 'image/jpeg' || attachmentRecord.ContentType == 'image/png')){
                            Attachment newRecord = new Attachment(Id = attachmentRecord.Id);
                            attachmentDeletionList.add(newRecord);
                        }
                    }
                    if(attachmentDeletionList != null && attachmentDeletionList.size() > 0){
                        try{
                            delete attachmentDeletionList;
                        }
                        catch(Exception ex){
                            ex.getStackTraceString();
                        }
                    }
                }
            }
        }
    }
    
    public static void updateAttachmentCountOnCase(List<Attachment> attachmentList){
        Set<Id> emailIds = new Set<Id>();
        for(Attachment attachmentRecord : attachmentList){
            if(attachmentRecord != null && attachmentRecord.ParentId != null && attachmentRecord.ParentId.getSObjectType().getDescribe().getName().equalsIgnoreCase(CON_CSM.S_EMAILMESSAGE)){
                emailIds.add(attachmentRecord.ParentId);
            }
        }
        if(emailIds != null && emailIds.size() > 0){
            List<EmailMessage> emailList = new SLT_EmailMessage().getEmailRecordsById(emailIds);
            if(emailList != null && !emailList.isEmpty()){
                Set<Id> parentIds = new Set<Id>();
                for(EmailMessage emailRecord : emailList){
                    if(emailRecord.Incoming && emailRecord.HasAttachment){
                        parentIds.add(emailRecord.Id);
                    }
                }
                if(parentIds != null && parentIds.size() > 0){
                    List<EmailMessage> emailMessageCaseList = new SLT_EmailMessage().getCaseAttachmentListOnEmails(parentIds);
                    if(emailMessageCaseList != null && emailMessageCaseList.size() > 0){
                        List<Case> caseList = new List<Case>();
                        for(EmailMessage emailRecord : emailMessageCaseList){
                            if(emailRecord.Attachments != null && emailRecord.Attachments.size() > 0 && emailRecord.ParentId != null){
                                Case caseRecord = new Case();
                                caseRecord.Id = emailRecord.ParentId;
                                Double attachmentCount = 0;
                                if(emailRecord.Parent.Attachments__c == null){
                                    attachmentCount = emailRecord.Attachments.size();
                                }
                                else{
                                    attachmentCount = emailRecord.Attachments.size() + emailRecord.Parent.Attachments__c;
                                }
                                caseRecord.Attachments__c = attachmentCount;
                                caseList.add(caseRecord);
                            }
                        }
                        if(caseList != null && caseList.size() > 0){
                            try{
                                update caseList;
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
    
    public static void updateDeletedAttachmentCountOnCase(List<Attachment> attachmentList){
        Map<Id, List<Attachment>> emailIdAttachmentMap = new Map<Id, List<Attachment>>();
        for(Attachment attachmentRecord : attachmentList){
            if(attachmentRecord != null && attachmentRecord.ParentId != null && attachmentRecord.ParentId.getSObjectType().getDescribe().getName().equalsIgnoreCase(CON_CSM.S_EMAILMESSAGE)){
                if(emailIdAttachmentMap.containsKey(attachmentRecord.ParentId)){
                    emailIdAttachmentMap.get(attachmentRecord.ParentId).add(attachmentRecord);
                }
                else{
                    emailIdAttachmentMap.put(attachmentRecord.ParentId, new List<Attachment>{attachmentRecord});
                }
            }
        }
        
        if(emailIdAttachmentMap != null && !emailIdAttachmentMap.isEmpty()){
            List<EmailMessage> emailMessageCaseList = new SLT_EmailMessage().getCaseAttachmentListOnEmails(emailIdAttachmentMap.keySet());
            if(emailMessageCaseList != null && emailMessageCaseList.size() > 0){
                List<Case> caseList = new List<Case>();
                for(EmailMessage emailRecord : emailMessageCaseList){
                    if(emailRecord.Incoming){
                        for(Attachment attachmentRecord : emailIdAttachmentMap.get(emailRecord.Id)){
                            if(attachmentRecord.BodyLength != null && (attachmentRecord.BodyLength/1024) < 8 && (attachmentRecord.ContentType == 'image/bmp' || attachmentRecord.ContentType == 'image/jpeg' || attachmentRecord.ContentType == 'image/png')){}
                            else{
                                Case caseRecord = new Case();
                                caseRecord.Id = emailRecord.ParentId;
                                Double attachmentCount = 0;
                                if(emailRecord.Parent.Attachments__c != null){
                                    attachmentCount = emailRecord.Parent.Attachments__c - emailIdAttachmentMap.get(emailRecord.Id).size();
                                }
                                caseRecord.Attachments__c = attachmentCount;
                                caseList.add(caseRecord);
                            }
                        }
                    }
                }
                if(caseList != null && caseList.size() > 0){
                    try{
                        update caseList;
                    }
                    catch(Exception ex){
                        ex.getStackTraceString();
                    }
                }
            }
        }
    }
}