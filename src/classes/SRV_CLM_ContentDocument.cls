/*
 * Version       : 1.0
 * Description   : Service Class for ContentDocument sObject.
*/
public class SRV_CLM_ContentDocument {
    /**
    * This method use to delete list of ContentDocument
    * @param List<ContentDocument> contentDocumentsToDel
    * @return Boolean
    */
    public static Boolean deleteContentDocuments(List<ContentDocument> contentDocumentsToDel) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {ContentDocument.SObjectType});
        try {
            uow.registerDeleted(contentDocumentsToDel);
            uow.commitWork();
        } catch(Exception ex) {
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
        return true;
    }

    /**
    * This method use to delete list of ContentDocument
    * @param List<ContentDocument> contentDocumentsToDel
    * @return Boolean
    */
    public static List<ContentDocument> getContentDocumentByIds(Set<Id> contentDocumentIds) {
        return new SLT_ContentDocument().selectById(contentDocumentIds);
    }

    /**
    * This method use to update list of ContentDocument
    * @param List<ContentDocument> contentDocumentsToUpdate
    * @return Boolean
    */
    public static Boolean updateContentDocuments(List<ContentDocument> contentDocumentsToUpdate) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {ContentDocument.SObjectType});
        try {
            uow.registerDirty(contentDocumentsToUpdate);
            uow.commitWork();
        } catch(Exception ex) {
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
        return true;
    }
    
    /**
    * This method use to get list of ContentDocument based on condition
    * @param Set<String> fields
    * @param String condition
    * @param Set<Id> docIds
    * @return List<ContentDocument>
    */
    public static List<ContentDocument> getContentDocumentsByIds(Set<String> fields, String condition, Set<Id> docIds) {
        return new SLT_ContentDocument().selectById(fields, condition, docIds);
    }
}