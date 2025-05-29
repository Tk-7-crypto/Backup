/*
 * Version       : 1.0
 * Description   : Apex Controller for RecordAttachments component.
 */
 
public without sharing class CNT_CSM_RecordAttachments {
    public class CSM_Attachment {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime lastModifiedDate {get;set;}
        @AuraEnabled
        public String createdById {get;set;}
        @AuraEnabled
        public String createdByName {get;set;}
        @AuraEnabled
        public String fileExtension {get;set;}
        @AuraEnabled
        public String contentSize {get;set;}
        @AuraEnabled
        public String parentId {get;set;}
        @AuraEnabled
        public String parentType {get;set;}
        @AuraEnabled
        public String parentName {get;set;}
        @AuraEnabled
        public String  visibility {get;set;}
    }

    @AuraEnabled
    public static boolean getPermissionSets(){
        List<PermissionSetAssignment> permissionAssign = [SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment where PermissionSet.Name = :CON_CSM.S_KB_ARTICLE_MANAGER_PERMISSION_SET and AssigneeId = :UserInfo.getUserId()];
        if(permissionAssign.size()>0){
            return true;
            
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean getPublishStatus(String recordId){
        List<Knowledge__kav> knowledgelist = [select id,PublishStatus from Knowledge__kav where id =:recordId AND PublishStatus =:'Draft'  ];
        if(knowledgelist.size()>0){
            return true;    
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static List<CSM_Attachment> getAttachments(String recordId ){
        CSM_Attachment a;
        List<CSM_Attachment> csm_al = new List<CSM_Attachment>();
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        Set<Id> parentIdSet = new Set<Id>();
        parentIdSet.add(recordId);
        List<EmailMessage> emails = new SLT_EmailMessage().getEmailsByParendIds(parentIdSet);
        if (emails != null && emails.size() >0 ){
            for(EmailMessage e : emails) {
                parentIdSet.add(e.Id);
            }
            if(parentIdSet != null){
                List<Attachment> al = new List<Attachment>();
                al= [SELECT Id, Name ,LastModifiedDate, CreatedBy.Id, CreatedBy.Name, ContentType, IsPrivate, ParentId, Parent.name FROM Attachment WHERE ParentId IN:parentIdSet];
                
                for(Integer i=0; i< al.size();i++){
                    a =new CSM_Attachment();
                    a.id = al[i].Id;
                    a.title = al[i].Name;
                    a.lastModifiedDate = al[i].LastModifiedDate;
                    a.createdById = al[i].CreatedBy.Id;
                    a.createdByName = al[i].CreatedBy.Name;
                    a.fileExtension = al[i].ContentType;
                    a.contentSize = '-';
                    a.parentId = al[i].ParentId;
                    a.parentType = 'emailOld';
                    a.parentName = al[i].Parent.name;
                    if(al[i].IsPrivate==false){ 
                        a.visibility = 'AllUsers';
                    }else{
                        a.visibility = 'Internal';
                    }
                    csm_al.add(a);
                }
            }
        }

        cdl = [SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId IN:parentIdSet];     
        for(Integer i=0; i< cdl.size();i++){
            a =new CSM_Attachment();
            a.id = cdl[i].ContentDocumentId;
            a.title = cdl[i].ContentDocument.Title;
            a.lastModifiedDate = cdl[i].ContentDocument.LastModifiedDate;
            a.createdById = cdl[i].ContentDocument.CreatedBy.Id;
            a.createdByName = cdl[i].ContentDocument.CreatedBy.Name;
            a.fileExtension = cdl[i].ContentDocument.FileExtension;
            a.contentSize =  String.valueOf(cdl[i].ContentDocument.ContentSize);
            a.parentId = cdl[i].LinkedEntityId;
            if (cdl[i].LinkedEntity.Type == 'EmailMessage'){
                a.parentType = 'email';
            } else {
                a.parentType = cdl[i].LinkedEntity.Type.toLowerCase();    
            }
            a.parentName = cdl[i].LinkedEntity.Name;
            a.visibility = cdl[i].Visibility;
            csm_al.add(a);
        }
        
        return csm_al;
    }

    @AuraEnabled
    public static void deleteContentDocumentById(String contentDocumentId){
        ContentDocument cd = New ContentDocument (Id=contentDocumentId);
        delete cd;
    }
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
    
    @AuraEnabled 
    public static ID currentUser(){
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static Id downloadFilesAsZip(List<Id> fileIds, String caseId) {
        List<ContentVersion> versions = [
            SELECT Title, VersionData, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIds
        ];
    
        UTL_CSM_Zippex zip = new UTL_CSM_Zippex();
        if (versions.isEmpty()) {
            throw new AuraHandledException('No files found with the provided IDs.');
        }
    
        for (ContentVersion version : versions) {
            if (version.VersionData != null) {
                Blob fileContent = version.VersionData;
                String fileName = version.Title + '.' + version.FileExtension;
                zip.addFile(fileName, fileContent, null);
            }
        }
        Blob zipBlob = zip.getZipArchive();
        if (zipBlob == null || zipBlob.size() == 0) {
            throw new AuraHandledException('The ZIP archive is empty. No files have been added.');
        }
    
        ContentVersion zipVersion = new ContentVersion();
        zipVersion.Title = caseId + '_ Selected_Files';
        zipVersion.PathOnClient = caseId + 'selected_files.zip';
        zipVersion.VersionData = zipBlob;
    
        insert zipVersion;
        zipVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :zipVersion.Id];
        return zipVersion.ContentDocumentId;
    }
    

        
}