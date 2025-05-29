/**
 * @description Service Class for Attachment
 */
public class SRV_GBL_Attachment {

    /**
     * @description gets the attachment from parentid and checks for the description that it is uploaded from LXC_GBL_FileUpload.
     * @param  lstContentDocumentId lstContentDocumentId is the set contains the content documents ids.
     * @param  parentId             parentId is the parent of content documents.
     * @return List<UTL_Sharepoint.FileInstance> list of FileInstance which are going to be saved on share point.
     */ 
    public static List<UTL_Sharepoint.FileInstance> getAttachmentsByParentId(Set<Id> lstContentDocumentId, String parentId) {
        List<UTL_Sharepoint.FileInstance> lstFileInstance = new List<UTL_Sharepoint.FileInstance>();

        try {
            for(Attachment attach : fetchListOfAttachment(lstContentDocumentId, parentId)) {
                UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
                objFileInstance.parentId = parentId;
                objFileInstance.fileBody = attach.Body;
                objFileInstance.fileName = attach.Name;
                objFileInstance.fileLength = attach.BodyLength;
                objFileInstance.fileUrl = '';
                lstFileInstance.add(objFileInstance);
            }
        } catch(Exception e) {
            throw new SRV_GBL_Attachment_Exception(new List<String>{e.getMessage()});
        }
        return lstFileInstance;
    }

    /**
     * fetchListOfAttachment method fetches the attachments bases on parentID and description.
     * @param  lstContentDocumentId is contentdocument Id
     * @param  parentId             attachment's parent Id.
     * @return                      a list of attachments which is also a list to delete after sharepoint work is done.
     */ 
    public static List<Attachment> fetchListOfAttachment(Set<Id> lstContentDocumentId, String parentId) {
        SLT_Attachment sltAttachment = new SLT_Attachment();
        List<Attachment> lstAttachment = new List<Attachment>();
        for (Attachment attach : sltAttachment.selectAttachmentsByParentId(new Set<Id>{parentId})) {
            if(String.isNotBlank(attach.Description) && lstContentDocumentId.contains(attach.Description)) {
                lstAttachment.add(attach);
            }
        }
        return lstAttachment;
    }

    /**
     * deleteAttachments deletes the attachments.
     * @param  lstAttachment list of attachments to be deleted.
     * @return               Boolean.
     */
    public static Boolean deleteAttachments(List<Attachment> lstAttachment) {
        if(lstAttachment != null && !lstAttachment.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Attachment.SObjectType});
                uow.registerDeleted(lstAttachment);
                uow.commitWork();
            } catch(Exception e) {
                throw new SRV_GBL_Attachment_Exception(new List<String>{e.getMessage()});
            }
        }
        return true; 
    }

    /**
     * Exception class for SRV_GBL_Attachment
     */
    public class SRV_GBL_Attachment_Exception extends Exception {
        public List<String> lstError = new List<String>();
        
        public SRV_GBL_Attachment_Exception(List<String> lstError) {
            this.lstError = lstError;
        }
    }

}