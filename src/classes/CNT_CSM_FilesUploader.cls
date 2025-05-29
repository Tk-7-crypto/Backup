/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_CSM_FilesUploader Lightning component 
 */ 
public class CNT_CSM_FilesUploader {
    /**
     * This method used to update visibility in ContentDocumentLink
     * @params String contentDocumentId
     * @params String visibility,
     */
    @AuraEnabled
    public static void updateContentDocumentLinkVisibility(String contentDocumentId, String linkedEntityId, String visibility){
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl = [SELECT Id,Visibility FROM ContentDocumentLink where ContentDocumentId =:contentDocumentId and LinkedEntityId =:linkedEntityId];
        String oldVisible = cdl[0].Visibility;
        cdl[0].Visibility = visibility;
        update cdl[0];
        if(!cdl.isEmpty() && contentDocumentId != null && linkedEntityId != null && oldVisible != visibility && visibility == CON_CSM.S_ALL_USERS){
            DAOH_ContentDocumentLink.callOutBISMAttachmentforCase(contentDocumentId, linkedEntityId);  
        }
    }
    
    /**
     * This method used to return a number of attachments by recordId
     * @params String recordId
     */ 
    @AuraEnabled
    public static double countAttachment(String recordId){
        double total =0;
        Set<Id> parentIdSet = new Set<Id>();
        parentIdSet.add(recordId);
        List<EmailMessage> emails = new SLT_EmailMessage().getEmailsByParendIds(parentIdSet);
        if (emails != null && emails.size() >0 ){
            for(EmailMessage e : emails) {
                parentIdSet.add(e.Id);
            }
        }        
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl = [SELECT Id FROM ContentDocumentLink where LinkedEntityId IN:parentIdSet];
        List<Attachment> al = new List<Attachment>();
        al= [SELECT Id FROM Attachment WHERE ParentId IN:parentIdSet];
        total+=cdl.size() + al.size();
        return total;
    }
    
}