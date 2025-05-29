public class CNT_CRM_Attachment {
    
    public List<Attachment> attachmentList{get;private set;}
    public String parentName{get;private set;}
    public String parentId{get;private set;}
    
    public CNT_CRM_Attachment() {
        this.parentId = ApexPages.currentPage().getParameters().get('parentId');
        this.attachmentList = [SELECT Id, Name, Parent.Id, Parent.Name, Description, CreatedDate, LastModifiedDate, Owner.alias FROM Attachment WHERE ParentId = :parentId];
        if(this.attachmentList.size() > 0) {
            this.parentName = this.attachmentList[0].parent.Name;
        }
    }
    
    public PageReference deleteAttachment() {
        Id deleteId = System.currentPageReference().getParameters().get('attachmentId');
        try {
         delete new Attachment(Id = deleteId);
        } catch(DmlException ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getDmlMessage(0)));
        }
        return null;
    }
}