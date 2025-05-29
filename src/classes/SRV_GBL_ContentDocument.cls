/**
 * @description Service Class for ContentDocument
 */
public class SRV_GBL_ContentDocument {
    /**
     * @description Method to Delete Records of ContentDocument
     * @param  setContentDocumentId Set<Id> Set for ContentDocument
     * @return True if record delete successfully, else false
     * @exception Throws SRV_GBL_ContentDocument_Exception if DMLException occur.
     */
    public static boolean deleteRecord(Set<Id> setContentDocumentId){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                ContentDocument.SObjectType
            }
        );
        try {
            List<ContentDocument> lstContentDocument = new SLT_ContentDocument().selectById(setContentDocumentId);
            uow.registerDeleted(lstContentDocument);
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
            throw new SRV_GBL_ContentDocument_Exception(lstErrorMsg);
        }
        return true;
    }

    /**
     * Exception Class for SRV_GBL_ContentDocument
     */
    public class SRV_GBL_ContentDocument_Exception extends Exception{
        public List<String> lstError = new List<String>();
        public SRV_GBL_ContentDocument_Exception(List<String> lstError){
            this.lstError = lstError;
        }
    }
}