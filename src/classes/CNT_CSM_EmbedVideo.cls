public class CNT_CSM_EmbedVideo {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getVideos(String recordId) {
        return Database.query('select ContentDocumentId,ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.FileType from ContentDocumentLink where LinkedEntityId =:recordId and ContentDocument.FileType in (\'MP4\')');
    }

    @AuraEnabled
    public static void updateContentDocumentLinkVisibility(String contentDocumentId, String linkedEntityId){
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl = [SELECT Id,Visibility FROM ContentDocumentLink where ContentDocumentId =:contentDocumentId and LinkedEntityId =:linkedEntityId];
        if (cdl != null && cdl.size() >0 ) {
            try {
                cdl[0].Visibility = CON_CSM.S_ALL_USERS;
                update cdl[0];
            } catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }
}
