/**
 * CLM Service class to perform DML operations on ContentVersion.
 * 1. Gets ContentVersion by ContentDocumentId
 * 2. Gets ContentVersion by Id
 * 3. inserts ContentVersion
 * @version 1.0 
 */
public class SRV_CLM_ContentVersion {

    public static List<ContentVersion> getContentVersionByContentDocumentId(Set<Id> docIds, Set<String> fields) {
        return new SLT_ContentVersion().getContentVersionByDocumentIds(docIds, fields);
    }

    public static List<ContentVersion> getContentVersionById(Set<Id> docId) {
        return new SLT_ContentVersion().selectById(docId);
    }

    public static ContentVersion insertContentVersion(ContentVersion doc) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                ContentVersion.SObjectType
            }
        );

        try {
            uow.registerNew(doc);
            uow.commitWork();
        } catch(Exception ex) {
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
        return doc;
    }
    
    /**
     * This method used to get ContentVersion by Ids and a condition
     * @param String condition
     * @param Set<Id> docIds
     * @return  List<ContentVersion>
     */
    public static List<ContentVersion> getContentVersions(String condition, Set<Id> docIds) {
        return new SLT_ContentVersion().getContentVersions(condition, docIds);
    }
}