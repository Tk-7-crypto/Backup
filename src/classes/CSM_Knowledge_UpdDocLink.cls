public class CSM_Knowledge_UpdDocLink {
    @InvocableMethod
    public static void updateContentDocumentLinkKnowledgeRecord(List<String> articleVersionIds){
        List<ContentDocumentLink> contentDocumentLinkToUpdate =new List<ContentDocumentLink>();
        Set<Id> articleVersionId = new Set<Id>{(Id)articleVersionIds[0]};
        List<ContentDocumentLink> cdlList = [SELECT Id, Visibility FROM ContentDocumentLink where LinkedEntityId =: articleVersionId];
        if(cdlList.size()>0) {
            for(ContentDocumentLink cdl : cdlList ){
                cdl.Visibility = 'AllUsers';
                contentDocumentLinkToUpdate.add(cdl);
            }
            update contentDocumentLinkToUpdate;
        }
    }
}