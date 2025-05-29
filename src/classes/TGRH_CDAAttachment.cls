public class TGRH_CDAAttachment {
    private static CDA_Request__c cdaRequest;
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
    
    public static void handleOnBeforeInsertAttachment(List<Attachment> newList, Set<Id> parentIdSet) {
        Map<Id, dsfs__DocuSign_Status__c> dsStausMapWithId;
        if(parentIdSet != null && parentIdSet.size() > 0) {
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
        }
    }
    
    public static void handleOnBeforeDeleteAttachment(List<Attachment> attachmentList, Set<Id> parentIdSet) {
        List<CDA_Request__c> cdaRequestList = [SELECT id, Name, Status__c, Owner.Id, Owner.Name FROM CDA_Request__c WHERE Id IN :parentIdSet];
        if(cdaRequestList != null && cdaRequestList.size() > 0) {
            
            for(Attachment attach: attachmentList) {
                for(CDA_Request__c cdaReq : cdaRequestList) {
                    cdaRequest = cdaReq;
                    if(!UTL_CDAUtility.forceUpdateStatus && attach.ParentId == cdaReq.Id && (isEndStatus  || (!isNegotiator && attach.OwnerId != UserInfo.getUserId()))) {
                        attach.ParentId.addError('You are not authorized to delete this attachment.');
                    }
                }
            }
        }
    }
    
    public static void handleOnAfterUpdateAttachment(List<Attachment> newList, Set<Id> parentIdSet) {
        if(UTL_CDAUtility.isBatchProcessing){
            String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
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
            }
        }
    }
}