public without sharing class SRV_CLM_Attachment {

    /**
    * This method use to get Attachments
    * @param fields and conditions
    * @return  List
    */
    public static List<Attachment> getAttachments(Set<String> fields, String condition) {
        return new SLT_Attachment().getAttachments(fields, condition);
    }

    /**
    * This method use to get Attachments by parentid
    * @param fields and parentId
    * @return  List
    */
    public static List<Attachment> getAttachmentByParent(Set<String> fields, Id parentId) {
        return new SLT_Attachment().getAttachmentListByParentId(fields, parentId);
    }

    public static List<Attachment> getAttachmentById(Set<String> fields, Set<Id> attachId) {
        return new SLT_Attachment().selectAttachmentFieldsById(fields, attachId);
    }
    
    /**
    * This method use to get Attachments by parentIds and Condition
    * @param condition and parentIds
    * @return  List
    */
    public static List<Attachment> getLatestAttachments(String condition, Set<Id> parentIds) {
        return new SLT_Attachment().getLatestAttachments(condition, parentIds);
    }

    /**
    * This method use to update Attachments record
    * @param attachmentList
    * @return  Boolean
    */
    public static Boolean updateListOfAttachments(List<Attachment> attachmentList) {
        try {
            if(attachmentList.isEmpty()) {
                return false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Attachment.SObjectType
                }
            );
        
            for (Attachment attachmentRecord : attachmentList) {
                if(attachmentRecord.Id == null) {
                    uow.registerNew(attachmentRecord);
                } else {
                    uow.registerDirty(attachmentRecord);
                }
            }
            uow.commitWork();
        }catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
                errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Attachment_Exception(new List<String>(errorMsgList));
        } 
        return true;
    }

    /**
    * This method used to delete Attachment records
    * @param List<Attachment> listOfAttachmentToBeDeleted is used to delete the records if exist
    * @return  Boolean for Data is deleted successfully or not
    */
    public static Boolean deleteListOfAttachments(List<Attachment> listOfAttachmentToBeDeleted) {
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
                uow.registerDeleted(listOfAttachmentToBeDeleted);
            }
            uow.commitWork();
        } catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
                errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Attachment_Exception(new List<String>(errorMsgList));
        }
        return true;
    }

    /**
    * This method use to update Attachment record
    * @param attachmentRecord
    * @return  Attachment
    */
    public static Attachment updateAttachment(Attachment attach){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Attachment.SObjectType
            }
        );
        try {
            uow.registerDirty(attach);
            uow.commitWork();
        }catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CLM_Attachment_Exception(new List<String>(errorMsgList));
        } 
        return attach;
    }

    /**
    * Exception class for SRV_CRL_Attachment
    */
    public class SRV_CLM_Attachment_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
        * constructor of SRV_CLM_Attachment_Exception
        */
        public SRV_CLM_Attachment_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }
}