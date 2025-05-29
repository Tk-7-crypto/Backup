public without sharing class CNT_CSM_CreateInformationOffering {
    @AuraEnabled
    public static InformationOfferingWrapper getInformationOffering(String caseId) {
        String condition = 'Case__c = \'' +caseId + '\'';
        List<Information_Offering_Forms__c> offerings = new SLT_InformationOfferingForm().getInformationOfferingByCondition(new Set<String>{'Id', 'Name', 'Form_Request_Type__c'}, condition);
        InformationOfferingWrapper offeringsWrapper = new InformationOfferingWrapper();
        if(offerings != null && offerings.size() > 0) {
            offeringsWrapper.offering = offerings;
            for(Information_Offering_Forms__c o : offerings){
                if(o.Form_Request_Type__c == CON_CSM.S_PATIENT_OFF || o.Form_Request_Type__c == CON_CSM.S_DATA_INT || o.Form_Request_Type__c == 'FIA/LAAD Additional Info'){
                    offeringsWrapper.isOfferingAvailable = true;
                }else{
                    offeringsWrapper.isOfferingAvailable = false;
                }
                
            }
            
        }
        return offeringsWrapper;
    }
    
    public class InformationOfferingWrapper {
        @AuraEnabled
        public List<Information_Offering_Forms__c> offering {get; set;}
        @AuraEnabled
        public Boolean isOfferingAvailable {get; set;}
        public InformationOfferingWrapper() {
            this.isOfferingAvailable = false;
        }
    }
    
     @AuraEnabled
    public static CreateWrapper getCreate(String caseId) {
        String condition = 'Case__c = \'' +caseId + '\'';
        List<CSM_Create_Forms__c> offerings = new SLT_CreateForm().getCreateFormByCondition(new Set<String>{'Id', 'Name', 'Form_Request_Type__c','Action__c','Audit_Type__c','MarketToCopyFrom__c','File_Code_Market_Description__c','ReportAction__c','Request_ID__c','ClientNumber_ReportNumber__c','Count_of_Client_Report_Numbers__c'}, condition);
        CreateWrapper CreateWrapper = new CreateWrapper();
        if(offerings != null && offerings.size() > 0) {
            CreateWrapper.offering = offerings;
            for(CSM_Create_Forms__c o : offerings){
                if(o.Form_Request_Type__c == 'Report Maintenance' || o.Form_Request_Type__c == 'Market Maintenance' || o.Form_Request_Type__c == 'Product Report' || o.Form_Request_Type__c == 'Unit Reports'){
                    CreateWrapper.isOfferingAvailable = true;
                }else{
                    CreateWrapper.isOfferingAvailable = false;
                }
                
            }
            
        }
        return CreateWrapper;
    }

    @AuraEnabled
    public static CreatePreviewWrapper getCreatHistoryPreview(String caseId) {
        CreatePreviewWrapper createWrapper = new CreatePreviewWrapper();
        String condition = 'Case__c = \'' +caseId + '\'';
        List<CSM_Create_Forms__c> offerings = new SLT_CreateForm().getCreateFormByCondition(new Set<String>{'Id', 'Name', 'Form_Request_Type__c','Action__c','Audit_Type__c','MarketToCopyFrom__c','File_Code_Market_Description__c','ReportAction__c','Request_ID__c','ClientNumber_ReportNumber__c','Count_of_Client_Report_Numbers__c'}, condition);
        List<TimeSheet__c> sheetList = Database.query('Select Id, Name,CreatedDate,CreatedBy.Name, Timeinhours__c,StartTime__c,Status__c,Time_Type__c,Case__c,Comment__c From TimeSheet__c Where Case__c = :caseId and Status__c = \'stop\'');
        if(sheetList != null && !sheetList.isEmpty()){
            createWrapper.timesheets = sheetList;
            createWrapper.isTimeAvailable = true;
        }
        List<CaseHistory> historyList = Database.query('select Id, IsDeleted, CaseId, CreatedById,CreatedBy.Name, CreatedDate, Field, DataType, OldValue, NewValue from CaseHistory where CaseId = :caseId and DataType != \'EntityId\' Order by CreatedDate Desc');
        if(historyList != null && !historyList.isEmpty()){
            createWrapper.histories = historyList;
            createWrapper.isHistoryAvailable = true;
        }
        List<EmailMessage> emailList = Database.query('SELECT Id,ToAddress,FromAddress,Subject,Incoming,MessageDate,ParentId,toLabel(Status) Status FROM EmailMessage WHERE ParentId= :caseId AND parentId != null');
        if(emailList != null && !emailList.isEmpty()){
            createWrapper.emails = emailList;
            createWrapper.isEmailAvailable = true;
        }
        List<casecomment> commentList = new SLT_CaseComment().selectByParentId(new Set<Id>{caseId});
        if(commentList != null && !commentList.isEmpty()){
            createWrapper.comments = commentList;
            createWrapper.isCommentAvailable = true;
        }
        List<FeedItem> postList = Database.query('select Id, ParentId, Type, CreatedDate, CreatedBy.Name, Title, Body, LinkUrl, IsRichText, RelatedRecordId, InsertedById, NetworkScope, Visibility,Status from FeedItem where ParentId = :caseId and Type in (\'TextPost\',\'ContentPost\')');
        if(postList != null && !postList.isEmpty()){
            createWrapper.posts = postList;
            createWrapper.isPostAvailable = true;
        }
        List<ContentDocumentLink> cdlList = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedById, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId= :caseId');     
       if(cdlList != null && !cdlList.isEmpty()){
            createWrapper.attachments = cdlList;
            createWrapper.isAttachmentAvailable = true;
        }
        if(offerings != null && offerings.size() > 0) {
            CreateWrapper.offering = offerings;
            for(CSM_Create_Forms__c o : offerings){
                if(o.Form_Request_Type__c == 'Report Maintenance' || o.Form_Request_Type__c == 'Market Maintenance' || o.Form_Request_Type__c == 'Product Report' || o.Form_Request_Type__c == 'Unit Reports'){
                    createWrapper.isOfferingAvailable = true;
                }
            }
            
        }
        return createWrapper;
    }
    
    @AuraEnabled
    public static string submitBulkForms(String jsonString) {
        List<CSM_Create_Forms__c> offerings = (List<CSM_Create_Forms__c>) JSON.deserialize(jsonString, List<CSM_Create_Forms__c>.class);
        if(offerings != null && offerings.size() > 0) {
             insert offerings;
        }
        return 'Ok';
    }
    
     public class CreateWrapper {
        @AuraEnabled
        public List<CSM_Create_Forms__c> offering {get; set;}
        @AuraEnabled
        public Boolean isOfferingAvailable {get; set;}
        public CreateWrapper() {
            this.isOfferingAvailable = false;
        }
    }
    
    public class CreatePreviewWrapper {
        @AuraEnabled
        public List<CSM_Create_Forms__c> offering {get; set;}
        @AuraEnabled
        public List<CaseHistory> histories {get; set;}
        @AuraEnabled
        public List<TimeSheet__c> timesheets {get; set;}
        @AuraEnabled
        public List<EmailMessage> emails {get; set;}
        @AuraEnabled
        public List<CaseComment> comments {get; set;}
        @AuraEnabled
        public List<FeedItem> posts {get; set;}
        @AuraEnabled
        public List<ContentDocumentLink> attachments {get; set;}
        @AuraEnabled
        public Boolean isOfferingAvailable {get; set;}
        @AuraEnabled
        public Boolean isHistoryAvailable {get; set;}
        @AuraEnabled
        public Boolean isTimeAvailable {get; set;}
        @AuraEnabled
        public Boolean isEmailAvailable {get; set;}
        @AuraEnabled
        public Boolean isCommentAvailable {get; set;}
        @AuraEnabled
        public Boolean isPostAvailable {get; set;}
        @AuraEnabled
        public Boolean isAttachmentAvailable {get; set;}
        public CreatePreviewWrapper() {
            this.isOfferingAvailable = false;
            this.isHistoryAvailable = false;
            this.isTimeAvailable = false;
            this.isEmailAvailable = false;
            this.isCommentAvailable = false;
            this.isPostAvailable = false;
            this.isAttachmentAvailable = false;
        }
    }
    
}