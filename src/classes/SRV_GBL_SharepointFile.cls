/**
 * @description Service Class for Sharepoint_File__c Object 
 */
public class SRV_GBL_SharepointFile {
    /**
     * @description Method to get the related Sharepoint File by Parent Id
     * @param  setParentId Set<Id> Set of Parent Id
     * @return List of Sharepoint_File__c
     */
    public static List<Sharepoint_File__c> getSharepointFilesByParentId(Set<Id> setParentId) {
        return getSharepointFilesByParentId(setParentId, 0);
    }
    
    /**
     * @description Method to get the related Sharepoint File by Parent Id
     * @param  setParentId Set<Id> Set of Parent Id
     * @return List of Sharepoint_File__c
     * @exception Throws SRV_GBL_SharepointFile_Exception when QueryException occur
     */
    public static List<Sharepoint_File__c> getSharepointFilesByParentId(Set<Id> setParentId, Integer numberOfRecords){
        List<Sharepoint_File__c> lstSharepointFile = new List<Sharepoint_File__c>();
        try{
            SLT_SharepointFile sltSharepointFile = new SLT_SharepointFile();
            lstSharepointFile = sltSharepointFile.getSharepointFileByParentId(setParentId, numberOfRecords);
        }catch(Exception e){
            String errorMsg = e.getMessage();
            throw new SRV_GBL_SharepointFile_Exception(new List<String> {errorMsg});
        }

        return lstSharepointFile;
    }

    /**
     * @description Method to get the related Sharepoint File by Parent Id
     * @param  setParentId Set<Id> Set of Parent Id
     * @param  numberOfRecords number of records being fetched.
     * @param  folderName is the folder from where record being fetched.
     * @return List of Sharepoint_File__c
     * @exception Throws SRV_GBL_SharepointFile_Exception when QueryException occur
     */
    public static List<Sharepoint_File__c> getSharepointFilesByParentIdAndFolder(Set<Id> setParentId, Integer numberOfRecords, 
        String folderName) {
        List<Sharepoint_File__c> lstSharepointFile = new List<Sharepoint_File__c>();
        try {
            SLT_SharepointFile sltSharepointFile = new SLT_SharepointFile();
            lstSharepointFile = sltSharepointFile.getSharepointFileByParentIdAndFolder(setParentId, numberOfRecords, folderName);
        } catch(Exception e) {
            String errorMsg = e.getMessage();
            throw new SRV_GBL_SharepointFile_Exception(new List<String> {errorMsg});
        }
        return lstSharepointFile;
    }
    
    /**
     * @descrption Method to Create the Sharepoint_File__c record
     * @param  lstFileInstance List<UTL_Sharepoint.FileInstance> List of FileInstance which needs to be insert
     * @return List of Sharepoint_File__c
     * @exception Throws SRV_GBL_SharepointFile_Exception when DMLException occurs. 
     */
    public static List<Sharepoint_File__c> createRecord(List<UTL_Sharepoint.FileInstance> lstFileInstance){
        List<Sharepoint_File__c> lstSharepointFiles = new List<Sharepoint_File__c>();
        
        for(Integer i = 0;i< lstfileInstance.size(); i++){
            Sharepoint_File__c objFile = new Sharepoint_File__c();
            objFile.File_Name__c = lstFileInstance[i].fileName;
            objFile.File_Url__c = lstFileInstance[i].fileUrl;
            objFile.Parent_Id__c = lstFileInstance[i].parentId;
            lstSharepointFiles.add(objFile);
        }
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Sharepoint_File__c.SObjectType
            }
        );
        try {
            uow.registerNew(lstSharepointFiles);
            uow.commitWork();
        }catch(Exception e) {
            List<String> lstErrorMsg = new List<String>();   
            if(e.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < e.getNumDml(); i++) {
                    lstErrorMsg.add(e.getDmlMessage(i));
                }
            }
            else {
                lstErrorMsg.add(e.getMessage() + ' ' + e.getStackTraceString());
            }
            throw new SRV_GBL_SharepointFile_Exception(lstErrorMsg);
        } 
        return lstSharepointFiles;
    }
    
    /**
     * @descrption Method to Delete the Sharepoint_File__c records
     * @param  Set<Id> Set for Sharepoint_File__c Id
     * @param folderName is the folderName if files are being deleted from folder.
     * @return True if Records deleted successfully, else false
     * @exception Throws SRV_GBL_SharepointFile_Exception when DMLException occurs. 
     */
    public static boolean deleteRecord(Set<Id> setSharepointFileId, String folderName) {
        try {
            List<Sharepoint_File__c> lstSharepointFile = new SLT_SharepointFile().selectById(setSharepointFileId);
            return UTL_Sharepoint.deleteRelatedFile(lstSharepointFile, folderName);
        } catch(Exception e) {
            List<String> lstErrorMsg = new List<String>();   
            if(e.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < e.getNumDml(); i++) {
                    lstErrorMsg.add(e.getDmlMessage(i));
                }
            } else {
                lstErrorMsg.add(e.getMessage() + ' ' + e.getStackTraceString());
            }
            throw new SRV_GBL_SharepointFile_Exception(lstErrorMsg);
        }
    }

    /**
     * Exception Class for SRV_GBL_SharepointFile
     */
    public class SRV_GBL_SharepointFile_Exception extends Exception{
        List<String> lstError = new List<String>();

        public SRV_GBL_SharepointFile_Exception(List<String> lstError){
            this.lstError = lstError;
        }

        public override String getMessage(){
            return String.join(lstError, '\n');
        }
    }
}