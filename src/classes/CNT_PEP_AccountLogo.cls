public with sharing class CNT_PEP_AccountLogo {
    @AuraEnabled
    public static void appendFileName(String contentDocumentId, String appendString){
        try {
            Set<String> fieldSet = new Set<String>{'Id', 'Title'};
            List<ContentVersion> contentVersionList = 
                new SLT_ContentVersion().getContentVersionFromDocumentId(new Set<String>{contentDocumentId}, fieldSet);
            System.debug('List - ' + contentVersionList);
            if(contentVersionList.size() > 0){
                ContentVersion contentVersionObj = new ContentVersion();
                contentVersionObj.Id = contentVersionList[0].Id;
                contentVersionObj.Title = contentVersionList[0].Title + appendString;
                update contentVersionObj;
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static String isLogoAvailable(String recordId){
        try {
            Set<String> fieldSet = new Set<String>{'Id', 'ContentDocumentId' };
            List<ContentDocumentLink> logoAttachmentsList = 
                new SLT_ContentDocumentLink().getContentDocumentLinkByLinkedEntityAndTitle(
                    new Set<String> {recordId},
                    '%_LOGO',
                    fieldSet
                );
            return logoAttachmentsList.size() > 0 ? logoAttachmentsList[0].ContentDocumentId : null;
        } catch (Exception e) {
            System.debug('Error occured !!!!!' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLogoContentVersionId(String documentId){
        try {
            Set<String> fieldSet = new Set<String>{'Id', 'Title'};
            List<ContentVersion> contentVersionList = 
                new SLT_ContentVersion().getContentVersionFromDocumentId(new Set<String>{documentId}, fieldSet);

            return contentVersionList.size() > 0 ? contentVersionList[0].Id : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteLogoById(String docId){
        try {
            ContentDocument docToDelete = new ContentDocument(Id=docId);
            delete docToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
