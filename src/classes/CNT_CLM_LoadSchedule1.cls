/*
 * Version       : 1.0
 * Description   : Apex Controller for Load Schedule1 lightning component
 */
public class CNT_CLM_LoadSchedule1 {

    @AuraEnabled
    public static Id createAgreementLineItem(Id agreementId, Id contentDocumentId) {
        if (agreementId == null || contentDocumentId == null) {
            return null;
        }
        Id attachmentId = convertContentDocumentToAttachment(contentDocumentId);
        Set<String> fieldSet = new Set<String>{'Id','Name'};
        List<Apttus__AgreementLineItem__c> agreementLineItems = new SLT_AgreementLineItems()
            .selectSchedule1ByAgreementIds(new Set<Id>{agreementId}, fieldSet);
        Apttus__AgreementLineItem__c lineItem;
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
        new Schema.SObjectType[] {
            Apttus__AgreementLineItem__c.SobjectType
        }
        );        
        
        if (!agreementLineItems.isEmpty()) {
            lineItem = agreementLineItems.get(0);
            lineItem.Schedule1_Id__c = attachmentId;
            uow.registerDirty(lineItem);
        }
        else {
            lineItem = new Apttus__AgreementLineItem__c();
            lineItem.Apttus__AgreementId__c = agreementId;
            lineItem.Apttus__Description__c = CON_CLM.FILE_NAME_SCHEDULE1;
            lineItem.Schedule1_Id__c = attachmentId;
            uow.registerNew(lineItem);
        }
        
        uow.commitWork();
        return lineItem.Id;
    }
    
    /**
    * This method is used to convert ContentDocument to Attachment 
    * @param Id contentDocumentId
    * @return Id attachment
    */
    @testVisible
    private static Id convertContentDocumentToAttachment(Id contentDocumentId) {
        Attachment attachmentToInsert = new Attachment();
        ContentDocument contentDocumentToDelete = new ContentDocument();
        Set<String> fieldSet = new Set<String>{'Title', 'Description', 'VersionData', 'FirstPublishLocationId', 'OwnerId', 'FileExtension'};
        List<ContentDocument> lstContentDocument = new SLT_ContentDocument().selectById(new Set<Id>{contentDocumentId});
        if(!lstContentDocument.isEmpty()) {
            contentDocumentToDelete = lstContentDocument.get(0);
        }
        List<ContentVersion> lstContentVersion = new SLT_ContentVersion().getContentVersionByDocumentIds(new Set<Id>
            {contentDocumentId}, fieldSet);
        if(lstContentVersion != null && !lstContentVersion.isEmpty()) {
            ContentVersion contentVersionRecord = lstContentVersion.get(0); 
            attachmentToInsert.ParentId = contentVersionRecord.FirstPublishLocationId;
            attachmentToInsert.Name = contentVersionRecord.Title + '.' + contentVersionRecord.FileExtension;
            attachmentToInsert.Description = contentVersionRecord.Description;
            attachmentToInsert.OwnerId = contentVersionRecord.OwnerId;
            attachmentToInsert.Body = contentVersionRecord.VersionData;
        }
        try {  
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{
                Attachment.SObjectType, ContentDocument.SObjectType});
            uow.registerNew(attachmentToInsert);
            uow.registerDeleted(contentDocumentToDelete);
            uow.commitWork();
        } 
        catch(DMLException dmlExp) {
            System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
        }     
        return attachmentToInsert.Id;  
    }
}