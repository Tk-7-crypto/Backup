/*
 * Version       : 1.0
 * Description   : Service Class for ContentDocumentLink sObject.
*/
public class SRV_CLM_ContentDocumentLink {
    /**
     * This method used to get ContentDocumentLink by linked Entity Ids
     * @param Set<Id> linkedEntityIds
     * @return List<ContentDocumentLink>
     */
    public static List<ContentDocumentLink> getContentDocumentBasedOnLinkedEntity(Set<Id> linkedEntityIds) {
        return new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(linkedEntityIds);
    }
    
    /**
     * This method used to insert ContentDocumentLink
     * @param ContentDocumentLink cdl
     * @return ContentDocumentLink
     */
    public static ContentDocumentLink insertContentDocumentLink(ContentDocumentLink cdl) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {ContentDocumentLink.SObjectType});
        try {
            uow.registerNew(cdl);
            uow.commitWork();
        } catch(Exception ex) {
            throw new AuraHandledException('Something went wrong: ' + ex.getMessage());
        }
        return cdl;
    }
}