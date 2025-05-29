public class CNT_CSM_RelatedList {
    public class CSM_Attachment {
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String latestPublishedVersionId {get;set;}
        @AuraEnabled
        public DateTime lastModified {get;set;}
        @AuraEnabled
        public DateTime createdDate {get;set;}
        @AuraEnabled
        public String created {get;set;}
        @AuraEnabled
        public String fileType {get;set;}
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

    @AuraEnabled(cacheable=true)
    public static List<CSM_Attachment> getContentDocumentLinks(String recordId ){
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
                al= [SELECT Id, Name ,LastModifiedDate, CreatedDate, CreatedBy.Id, CreatedBy.Name, ContentType, IsPrivate, ParentId, Parent.name FROM Attachment WHERE ParentId IN:parentIdSet];
                
                for(Integer i=0; i< al.size();i++){
                    a =new CSM_Attachment();
                    a.id = al[i].Id;
                    a.type = 'Attachment';
                    a.title = al[i].Name;
                    a.lastModified = al[i].LastModifiedDate;
                    a.createdDate = al[i].CreatedDate;
                    a.created = al[i].CreatedBy.Name;
                    a.fileType = al[i].ContentType;
                    a.contentSize = '-';
                    a.parentId = al[i].ParentId;
                    a.parentType = 'email';
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
        cdl = [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId,ContentDocument.FileType, ContentDocument.LastModifiedDate, ContentDocument.CreatedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId IN:parentIdSet];     
        for(Integer i=0; i< cdl.size();i++){
            a =new CSM_Attachment();
            a.id = cdl[i].ContentDocumentId;
            a.type = 'Attachment';
            a.title = cdl[i].ContentDocument.Title;
            a.latestPublishedVersionId = cdl[i].ContentDocument.LatestPublishedVersionId;
            a.lastModified = cdl[i].ContentDocument.LastModifiedDate;
            a.createdDate = cdl[i].ContentDocument.CreatedDate;
            a.created = cdl[i].ContentDocument.CreatedBy.Name;
            a.fileType = cdl[i].ContentDocument.FileType;
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

    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getEmailMessages (String recordId ){
        List<EmailMessage> em = new List<EmailMessage>();
        em = [select Id, ParentId, Subject, HtmlBody, LastModifiedDate, CreatedDate, CreatedBy.Name, FromName, FromAddress, ToAddress from EmailMessage where ParentId =:recordId];
        return em;
    }

    @AuraEnabled(cacheable=true)
    public static List<CaseArticle> getCaseArticles(String recordId){
        List<CaseArticle> CaseArticles = new List<CaseArticle>();
        caseArticles = [SELECT Id, KnowledgeArticleVersion.ArticleNumber, KnowledgeArticleVersion.Title, KnowledgeArticleVersion.UrlName, KnowledgeArticleVersion.LastModifiedDate, KnowledgeArticleVersion.CreatedDate FROM CaseArticle WHERE caseId=:recordId order by CreatedDate desc];
        return caseArticles;
    }

    @AuraEnabled
    public static void deleteContentDocumentById(String contentDocumentId, String recordId){
        List<ContentDocument> cdList = new List<ContentDocument>();
        cdList = [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id=:contentDocumentId];
        if(cdList != null && cdList.size()>0) {
            String oldValue= cdList[0].Title + '.' +cdList[0].FileExtension;
            Database.DeleteResult[] drList = Database.delete(cdList, false);
            if (drList[0].isSuccess()) {
                CSM_QI_Data_Audit_Trail__c auditTrail = new CSM_QI_Data_Audit_Trail__c(Action__c = CON_CSM.S_DELETED,Name = CON_CSM.S_CONTENTDOCUMENT, Old_Value__c=oldValue,Case__c = recordId);
                insert auditTrail;
            } else {
                throw new AuraHandledException('INSUFFICIENT_ACCESS_OR_READONLY');
            }
        }
    }
}
