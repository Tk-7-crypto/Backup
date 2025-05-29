public with sharing class CNT_PEP_Attachments {
    @AuraEnabled
    public static List<sObject> getContentDoc(Id aParentId){
        List<sObject> sObjLst = new List<sObject>();
        List<sObject> cntDocList = new List<sobject>();
        List<sObject> attachmentLst =Database.query('SELECT Id,Name, Description FROM Attachment WHERE ParentId =: aParentId');
        
        List<ContentDocumentLink> cntDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink where LinkedEntityId = : aParentId];
     
        List<Id> docIds = new List<Id>();
        if(cntDocLink.size() > 0) {
            for(ContentDocumentLink relDoc : cntDocLink) {
                docIds.add(relDoc.ContentDocumentId);
            }
            cntDocList = Database.query('SELECT ID, Description , Title, FileType, ContentSize, ParentId, PublishStatus, SharingOption, FileExtension FROM ContentDocument WHERE Id =: docIds');
        }
       
        if ( attachmentLst != null && attachmentLst.size() > 0){

            for(sObject attch : attachmentLst){
                attch.put('Description', 'Attachment');
            }
            sObjLst.addAll(attachmentLst);

        }
           
        if(cntDocList != null && cntDocList.size() > 0){
            for(sObject cntDoc : cntDocList){
                cntDoc.put('Description', 'ContentDocument');
            }
            sObjLst.addAll(cntDocList);

        }
        
        return sObjLst;

    }
    
}