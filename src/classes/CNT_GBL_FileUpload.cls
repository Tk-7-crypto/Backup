/**
 * @description Controller class for LXC_GBL_FileUpload Component
 */
public class CNT_GBL_FileUpload {

    /**
     * @description Method to trigger uploading the documents from Salesforce To Sharepoint
     * @param  lstDocumentId List<Id>   List of Documents Id 
     * @param  parentId      String     Parent Object Id
     * @param isUploadFromAttachment Boolean if true then attachment will be stored on share point otherwise content version.
     * @param folderName is the folder in which files going to be saved.
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component 
     */
    @AuraEnabled
    public static void uploadFileToSharepoint(List<Id> lstDocumentId, String parentId, 
        Boolean isUploadFromAttachment, String folderName) {
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        List<UTL_Sharepoint.FileInstance> lstFileInstance = new List<UTL_Sharepoint.FileInstance>();
        List<Sharepoint_File__c> lstSharepointFile = new List<Sharepoint_File__c>();
        Map<String, String> parentObjDetails = UTL_Sharepoint.getParentObjectApiName(parentId);
        
        if(String.isNotBlank(folderName)) {
            lstSharepointFile = SRV_GBL_SharepointFile.getSharepointFilesByParentIdAndFolder(new Set<Id>{parentId}, 
                0, 'File_Url__c LIKE \'%/' + parentId + '/' + folderName + '/%\'');
        } else {
            lstSharepointFile = SRV_GBL_SharepointFile.getSharepointFilesByParentId(new Set<Id>{parentId});
        }

        try {
            UTL_Sharepoint.createFolder(parentObjDetails.get('objName'), config);
            if(lstSharepointFile.size() == 0) {
                UTL_Sharepoint.createFolder(parentObjDetails.get('objName') + '/' + parentId, config);
                if(String.isNotBlank(folderName)) {
                    UTL_Sharepoint.createFolder(parentObjDetails.get('objName') + '/' + parentId + '/' + folderName, config);
                }
            }
            if(isUploadFromAttachment) {
                lstFileInstance = SRV_GBL_Attachment.getAttachmentsByParentId(new Set<Id>(lstDocumentId), parentId);
            } else {
                lstFileInstance = SRV_GBL_ContentVersion.getFileInstanceList(new Set<Id>(lstDocumentId), parentId);
            }
            for(Integer i = 0; i < lstFileInstance.size(); i++) {
                if(String.isNotBlank(folderName)) {
                    lstFileInstance.get(i).folderName = folderName.replace(' ', '%20');
                }
                UTL_Sharepoint.FileInstance objFileInstance = UTL_Sharepoint.createFile(lstFileInstance.get(i), config);
                lstFileInstance.set(i, objFileInstance);
            }
            SRV_GBL_SharepointFile.createRecord(lstFileInstance);
            deleteContentDocument(lstDocumentId, parentId, isUploadFromAttachment);
        }
        catch(Exception e) {
            throw new AuraHandledException(JSON.serialize(e));
        }
    }

    /**
     * @description Method to Delete the Content Document.
     * @param  lstDocumentId List<Id> List of Content Document Id
     * @param  parentId      String     Parent Object Id
     * @param isUploadFromAttachment Boolean if true then attachment will be stored on share point otherwise content version.
     * @return True if ContentDocument Deleted successfully, else False
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static boolean deleteContentDocument(List<Id> lstDocumentId, String parentId, Boolean isUploadFromAttachment) {
        try{
            if(isUploadFromAttachment) {
                List<Attachment> lstAttachment = SRV_GBL_Attachment.fetchListOfAttachment(new Set<Id>(lstDocumentId), parentId);
                return ((lstAttachment != null && !lstAttachment.isEmpty()) ? SRV_GBL_Attachment.deleteAttachments(lstAttachment) : false);
            } else {
                return SRV_GBL_ContentDocument.deleteRecord(new Set<Id>(lstDocumentId));
            }
        }catch(Exception e){
            throw new AuraHandledException(JSON.serialize(e));
        }
    }
}