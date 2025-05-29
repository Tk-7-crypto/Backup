/**
 * Queueable Class for attach user detail page on audit log record
 * version : 1.0
 */
public class QUE_CRM_AsyncInsertAttachonAuditLog implements Queueable, Database.AllowsCallouts {
  
    List<User_Audit_Log__c> userAuditLogList = new List<User_Audit_Log__c>();
    List<Contact> contactList = new List<Contact>();
    List<Contact> contactListUserContactSync = new List<Contact>();
    List<User> userListUserContactSync = new List<User>();
    /**
    * Constructor of this class
    * @params userAuditLogList List<User_Audit_Log__c>
    */
    public QUE_CRM_AsyncInsertAttachonAuditLog(List<User_Audit_Log__c> userAuditLogList, List<Contact> contactListToUpdate, List<Contact> contactToUpdateList, List<User> userListToUpdate){  
        this.userAuditLogList = userAuditLogList;
        this.contactList = contactListToUpdate;
		this.contactListUserContactSync = contactToUpdateList;
        this.userListUserContactSync = userListToUpdate;
    }
    
    /**
     * This method is used for add attachment for audit log record.
     * @params  newList List<Contact>,Map<Id,Contact> oldMap
     * @return  void
     */ 
    public void execute(QueueableContext qc) {
        List<Attachment> attachmentList = new List<Attachment>();
        for(User_Audit_Log__c auditLog : userAuditLogList) {
                Attachment att = new Attachment();
                Blob pdfContent;
                PageReference pgref = new PageReference('/apex/VFP_CRM_UserDetailPDF?id=' + auditLog.User__c); 
                if(!Test.isRunningTest()) {
                    pdfContent = pgref.getContent();
                } else {
                    pdfContent = Blob.valueOf('Test Attachment Body');
                }
                att.ParentId = auditLog.Id;
                att.Body = pdfContent;
                att.ContentType = 'application/pdf';
                att.Name = auditLog.User__c + '.pdf';
                attachmentList.add(att);
        }
        if(attachmentList.size() > 0) {
            insert attachmentList;
        }
		if((contactList.size()>0 || contactListUserContactSync.size()>0 || userListUserContactSync.size()>0) && !Test.isRunningTest()) {
            System.enqueueJob(new QUE_CRM_Contact_Resource_Active_Updated(contactList, contactListUserContactSync, userListUserContactSync));
        }   
    }
}