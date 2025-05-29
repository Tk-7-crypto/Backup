/**
 * @description Controller for lwc_clm_fileRelatedList Lightning Component
 */
public with sharing class CNT_CLM_EnhancedFileRelatedList {
    /**
     * @description Method to fetch File Data
     * @param  recordId String 
     * @return list of FileWrapper
     */
    @AuraEnabled(cacheable=true)
    public static List<FileWrapper> getUploadedFiles(Id recordId) {
        try {
            List<FileWrapper> filesList = new List<FileWrapper>();
            List<ContentDocumentLink> docLinks = new SLT_ContentDocumentLink().getCDLByLinkedEntityWithLimitAndOrder(
                new Set<String>{'Id', 'ContentDocument.Id', 'ContentDocument.Title', 'ContentDocument.Description', 'ContentDocument.ContentSize', 'ContentDocument.CreatedDate', 'ContentDocument.LastModifiedDate', 'ContentDocument.Owner.Name', 'ContentDocument.FileExtension','ContentDocument.LatestPublishedVersion.FileType'},
            	new Set<Id>{recordId}, null, 'ContentDocument.CreatedDate');
            for(ContentDocumentLink docLink: docLinks) {
                if(docLink.ContentDocument.LatestPublishedVersion.FileType != 'SNOTE') {
                	filesList.add(new FileWrapper(docLink));
                }
            }
            return filesList;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

    /**
     * @description Method to delete file records when lightning component delete method called.
     * @param  contentDocumentId String
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static void deleteContentDocument(String contentDocumentId){
        try {
            CNT_CLM_EnhancedFileRelatedListHelper deleteFile = new CNT_CLM_EnhancedFileRelatedListHelper();
            deleteFile.deleteContentDocumentWithoutSharing(contentDocumentId);
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

    /**
     * @description Without Sharing Helper Class
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    public class CNT_CLM_EnhancedFileRelatedListHelper {
        public void deleteContentDocumentWithoutSharing(String contentDocumentId){
            try {
                List<ContentDocument> contentDocumentList = new SLT_ContentDocument().selectById(new Set<String>{'Id'}, 'Id =:docIds', new Set<Id>{contentDocumentId});
                DELETE contentDocumentList;
            } catch (Exception e) {
                throw new CustomException(e.getMessage());
            }
        }
    }

    /**
     * @description method to update content document
     * @param  contentDocumentId String
     * @param description String
     * @param title String
     * @param skipValidate Boolean
     * @exception throws AuraHandledException On Exception occur to Notify Ligthning Component
     */
    @AuraEnabled
    public static void updateContentDocument(String contentDocumentId,String description, String title){
        try {
            ContentDocument cd = new ContentDocument(Id = contentDocumentId, Description = description);
            if(title != null) {
                cd.Title = title;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {ContentDocument.SObjectType}
            );
            uow.registerDirty(cd);
            uow.commitWork();
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    /**
     * @description Method to check whether edit or delete is allowed
     * @param  contentDocumentId String
     * @exception throws CustomExpection
     */
    @AuraEnabled
    public static Boolean isEditDeleteAllowed(String contentDocumentId){
        try {
            Map<Id, Id> mapCDAGRId = new Map<Id, Id>();
            Map<Id,Profile> mapAdminProfiles = new Map<Id,Profile>(new SLT_Profile().getAdminProfiles(new Set<String> {'Id', 'Name'}));
            if(!mapAdminProfiles.containsKey(UserInfo.getProfileId()) || Test.isRunningTest()) {
                Map<Id, IQVIA_Agreement__c> agreementMap = UTL_CLM.getAgreementMapFromCD(new Set<Id>{contentDocumentId},mapCDAGRId);  
                if(!agreementMap.isEmpty()) {  
                    if(mapCDAGRId.containsKey(contentDocumentId) && agreementMap.containsKey(mapCDAGRId.get(contentDocumentId))) {
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    
    //Custom Exception class
    public class CustomException extends Exception {}
    /**
     * @description File Wrapper Class
     */
    public class FileWrapper {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String FullTitle {get; set;}
        @AuraEnabled
        public String Title {get; set;}
        @AuraEnabled
        public String Description {get; set;}
        @AuraEnabled
        public Integer Size {get; set;}
        @AuraEnabled
        public DateTime CreatedDate {get; set;}
        @AuraEnabled
        public DateTime LastModifiedDate {get; set;}
        @AuraEnabled
        public String IconName {get; set;}
        @AuraEnabled
        public String OwnerId {get; set;}
        @AuraEnabled
        public String OwnerName {get; set;}
        
        public FileWrapper(ContentDocumentLink cdl) {
            this.Id = cdl.ContentDocument.Id;
            this.FullTitle = cdl.ContentDocument.Title;
            this.Title = cdl.ContentDocument.Title;
            this.Description = cdl.ContentDocument.Description;
            this.Size = cdl.ContentDocument.ContentSize;
            this.LastModifiedDate = cdl.ContentDocument.LastModifiedDate;
            this.CreatedDate = cdl.ContentDocument.CreatedDate;
            this.OwnerName = cdl.ContentDocument.Owner.Name;
            this.OwnerId = cdl.ContentDocument.Owner.Id;
            this.IconName = cdl.ContentDocument.FileExtension;
    	}
    }
}