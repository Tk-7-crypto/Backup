public class CNT_CSM_CaseAttachmentController {
    @AuraEnabled(cacheable=true)
    public static List<AttachmentWrapper> fetchAttachmentList(Id caseId){
        Set<String> setOfParentAttachmentId = new Set<String>();
        Map<String, EmailContentWrapper> uniqueNameRecords = new Map<String, EmailContentWrapper>();
        for(EmailMessage em : [SELECT Id FROM EmailMessage WHERE RelatedToId = :caseId]){
            setOfParentAttachmentId.add(em.Id);
        }
        setOfParentAttachmentId.add(caseId);
        for(Attachment att :[Select id,body, name,contentType from attachment where parentId in : setOfParentAttachmentId]){
            EmailContentWrapper e = new EmailContentWrapper();
            e.name = att;
            uniqueNameRecords.put(att.name,e);
        }
        List<AttachmentWrapper> listOfWrapperRecord = new List<AttachmentWrapper>();
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN :setOfParentAttachmentId]){
            EmailContentWrapper e = new EmailContentWrapper();
            e.doc = cdl;
            uniqueNameRecords.put(cdl.ContentDocument.Title + '.' + cdl.ContentDocument.FileExtension,e);
        }
        for(EmailContentWrapper cdl : uniqueNameRecords.values()){
            if(cdl.doc != null)
            {
                AttachmentWrapper wrapper = new AttachmentWrapper();
                wrapper.id = cdl.doc.Id;
                wrapper.name = cdl.doc.ContentDocument.Title + '.' + cdl.doc.ContentDocument.FileExtension;
                wrapper.fileExtension = cdl.doc.ContentDocument.FileExtension;
                wrapper.fileType = cdl.doc.ContentDocument.FileType;
                wrapper.isSelected = false;
                wrapper.nameUrl = '/'+cdl.doc.Id;
                listOfWrapperRecord.add(wrapper);
            }
            if(cdl.name != null)
            {
                AttachmentWrapper wrapper = new AttachmentWrapper();
                wrapper.id = cdl.name.Id;
                wrapper.name = cdl.name.name;
                wrapper.fileExtension = cdl.name.contentType;
                wrapper.fileType = cdl.name.contentType;
                wrapper.isSelected = false;
                wrapper.nameUrl = '/'+cdl.name.Id;
                listOfWrapperRecord.add(wrapper);
            }
            
        }
        return listOfWrapperRecord;
    }
    @AuraEnabled
    public static void sendDraftEmail(Id caseId){
        
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        List<EmailMessage> listOfEmailMessage = new List<EmailMessage>();
        for(EmailMessage em : [SELECT Id,BccAddress, ContentDocumentIds,ToAddress, FromAddress, HtmlBody, Subject FROM EmailMessage WHERE RelatedToId = :caseId and Status ='5']){
            listOfEmailMessage.add(em);
        }
        EmailMessage draftEmail;
        if(listOfEmailMessage.size() > 0){
            draftEmail = listOfEmailMessage[0];
        }
        List<ContentDocumentLink> contentDoc= [SELECT Id,ContentDocument.LastModifiedDate,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.FileType,ContentDocument.FileExtension,ContentDocument.Title FROM ContentDocumentLink where LinkedEntityId =:draftEmail.id];
        List<Id> cIds = new List<Id>();
        List<Messaging.EmailFileAttachment> emailAttachmentata = new List<Messaging.EmailFileAttachment>();
        for(ContentDocumentLink documentData :contentDoc){
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            Blob myBlob = documentData.ContentDocument.LatestPublishedVersion.VersionData;
            attach.filename = documentData.ContentDocument.Title+'.'+documentData.ContentDocument.FileExtension;
            attach.setBody(myBlob);
            attach.setInline(false);
            cIds.add(documentData.ContentDocument.id);
            emailAttachmentata.add(attach);
        }
        Messaging.EmailFileAttachment[] array1 = new List<Messaging.EmailFileAttachment>();
        for (integer i=0;i<emailAttachmentata.size();i++){
            array1.add(emailAttachmentata[i]);
        }
        
        string fromAddressss = draftEmail.FromAddress;
        List<OrgWideEmailAddress> orgWideList = Database.query('SELECT Id FROM OrgWideEmailAddress WHERE address = :fromAddressss');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        List<String> toAddresses = new List<String>();
        if(draftEmail.ToAddress != null) {
            toAddresses.addAll(draftEmail.ToAddress.split('; '));
        }
        mail.setToAddresses(toAddresses);
        mail.setSubject(draftEmail.Subject);//Set Subject
        mail.setCharset('UTF-8');                          
        if(draftEmail.BccAddress != null){
            List<String> bccAddresses = new List<String>();
            bccAddresses.addAll(draftEmail.BccAddress.split('; '));
            mail.setBccAddresses(bccAddresses);
        } 
        if(orgWideList != null && orgWideList.size()>0){
            mail.setOrgWideEmailAddressId(orgWideList[0].id);
        }
        mail.setHtmlBody(draftEmail.HtmlBody);//Set HTML Body
        mail.setFileAttachments(array1 );//Set File Attachment
        EmailMessage sentMail = new EmailMessage();
        sentMail.FromAddress = draftEmail.FromAddress;
        sentMail.FromName = draftEmail.FromAddress;
        sentMail.ToAddress = draftEmail.ToAddress;
        sentMail.Subject = draftEmail.Subject;
        sentMail.HtmlBody =draftEmail.HtmlBody;
        sentMail.RelatedToId = caseId;
        sentMail.BccAddress = draftEmail.BccAddress;
        
        
       // sentMail.ContentDocumentIds = cIds;
        insert sentMail;
        List<ContentDocumentLink> linkData = new List<ContentDocumentLink>();
        for(Id conId : cIds ){
            ContentDocumentLink conDocLink1 = New ContentDocumentLink();
            conDocLink1.LinkedEntityId = sentMail.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink1.ContentDocumentId = conId;  //ContentDocumentId Id from ContentVersion
            conDocLink1.shareType = 'V';
            linkData.add(conDocLink1);
        }
        
        insert linkData;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
        delete draftEmail;
        
        
        
    }
    @AuraEnabled
    public static List<ContentDocumentLink> saveAttachmentToDraftEmail(String attachments, Id caseId){
        List<String> listOfAttachmentId = attachments.split(',');
        List<EmailMessage> listOfEmailMessage = new List<EmailMessage>();
        for(EmailMessage em : [SELECT Id, ContentDocumentIds, IsClientManaged FROM EmailMessage WHERE RelatedToId = :caseId and Status ='5']){
            listOfEmailMessage.add(em);
        }
        EmailMessage draftEmail;
        if(listOfEmailMessage.size() > 0){
            draftEmail = listOfEmailMessage[0];
        }
        else{
            return null;
        }
        List<ContentVersion> listOfVersion = new List<ContentVersion>();
        Boolean withContentDoc = false;
        for(ContentDocumentLink documentData : [SELECT Id,LinkedEntityId,ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink where Id IN :listOfAttachmentId]){
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = documentData.ContentDocument.Title+'.'+documentData.ContentDocument.FileExtension;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            //cVersion.OwnerId = draftEmail.id;//Owner of the file
            cVersion.Title = documentData.ContentDocument.Title;//Name of the file
            cVersion.VersionData = documentData.ContentDocument.LatestPublishedVersion.VersionData;//File content
            listOfVersion.add(cVersion);
            withContentDoc = true;
        }
        
        for(Attachment documentData : [SELECT Id,Name,Body,contentType FROM Attachment where Id IN :listOfAttachmentId]){
            Blob myBlob = documentData.Body;
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = documentData.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            //cVersion.OwnerId = draftEmail.id;//Owner of the file
            integer pos = documentData.Name.lastIndexOf('.');
            string withoutEx = documentData.Name.substring(0, pos);
            cVersion.Title = withoutEx;//Name of the file
            cVersion.VersionData = myBlob;//File content
            listOfVersion.add(cVersion);
            
        }
        Insert listOfVersion;
        set<ID> versionIDs = new set<ID>();
        List<ContentDocumentLink> conLink = new List<ContentDocumentLink>();
        List<ContentVersion> conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id  in :listOfVersion];
        for(ContentVersion cv : conDoc){
            versionIDs.add(cv.ContentDocumentId);
        }
        for(Id conId : versionIDs ){
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = draftEmail.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conId;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            conLink.add(conDocLink);  
        }
        insert conLink;
        return conLink;
    }
    
    public class AttachmentWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String fileType;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public String nameUrl; 
    }
    public class EmailContentWrapper{
        @AuraEnabled public ContentDocumentLink doc;
        @AuraEnabled public Attachment name;
        
    }
}
