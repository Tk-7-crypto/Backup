/**
 * @description Service Class for ContentVersion
 */
public class SRV_GBL_ContentVersion {
    /**
     * @description Method to get the ContentVersion by ContentDocument Id
     * @param  setContentDocumentId Set<Id> Set for ContentDocument Id
     * @return List of ContentVersion
     * @exception SRV_GBL_ContentVersion_Exception throws when QueryException occurs
     */
    public static List<ContentVersion> getContentVersionByContentDocumentId(Set<Id> setContentDocumentId){
        SLT_ContentVersion sltContentVersion = new SLT_ContentVersion();
        try{
            return sltContentVersion.getContentVersionByContentDocumentId(setContentDocumentId);
        }catch(Exception e){
            throw new SRV_GBL_ContentVersion_Exception(new List<String>{e.getMessage()});
        }
    }

    /**
     * @description Method to get the FileInstance List
     * @param  setContentDocumentId Set<Id> Set of ContentDocument Id
     * @param  parentId             String  Parent object Id
     * @return List of UTL_Sharepoint.FileInstance
     */
    public static List<UTL_Sharepoint.FileInstance> getFileInstanceList(Set<Id> setContentDocumentId, String parentId){
        List<UTL_Sharepoint.FileInstance> lstFileInstance = new List<UTL_Sharepoint.FileInstance>();
        
        for(ContentVersion objContentVersion : getContentVersionByContentDocumentId(setContentDocumentId)){
            UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
            objFileInstance.parentId = parentId;
            objFileInstance.fileBody = objContentVersion.VersionData;
            objFileInstance.fileName = objContentVersion.Title + '.' + objContentVersion.FileExtension;
            objFileInstance.fileLength = objContentVersion.ContentSize;
            objFileInstance.fileUrl = '';
            lstFileInstance.add(objFileInstance);
        }

        return lstFileInstance;
    }

    /**
     * Exception Class for SRV_GBL_ContentVersion
     */
    public class SRV_GBL_ContentVersion_Exception extends Exception{
        public List<String> lstError = new List<String>();
        public SRV_GBL_ContentVersion_Exception(List<String> lstError){
            this.lstError = lstError;
        }
    }
}