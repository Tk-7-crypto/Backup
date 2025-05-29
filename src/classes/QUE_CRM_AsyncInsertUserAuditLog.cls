public class QUE_CRM_AsyncInsertUserAuditLog implements Queueable{
  
    List<User_Audit_Log__c> userAuditLogList = new List<User_Audit_Log__c>();
    List<Contact> contactList = new List<Contact>();
	List<Contact> contactListUserContactSync = new List<Contact>();
    List<User> userListUserContactSync = new List<User>();
    String strState = '';  
  
    public QUE_CRM_AsyncInsertUserAuditLog(List<User_Audit_Log__c> userAuditLogList, List<Contact> contactListToUpdate, List<Contact> contactToUpdateList, List<User> userListToUpdate) {  
        this.userAuditLogList = userAuditLogList;
        this.contactList = contactListToUpdate;
		this.contactListUserContactSync = contactToUpdateList;
        this.userListUserContactSync = userListToUpdate;
    }  
  
    public void execute(QueueableContext qc) {
		if(userAuditLogList.size() > 0){
        	insert userAuditLogList;
        } 
        List<User_Audit_Log__c> auditLogInactiveUserList = new List<User_Audit_Log__c>();
        for(User_Audit_Log__c auditLog : userAuditLogList) {
            if(auditLog.Field_Name__c == 'IsActive' && auditLog.New_Value__c == 'false' && auditLog.Old_Value__c == 'true') {
                auditLogInactiveUserList.add(auditLog);
            }
        }
        if((auditLogInactiveUserList.size()>0 || contactListUserContactSync.size()>0 || userListUserContactSync.size()>0) && !Test.isRunningTest()) {
            System.enqueueJob(new QUE_CRM_AsyncInsertAttachonAuditLog(auditLogInactiveUserList, contactList, contactListUserContactSync, userListUserContactSync));
        }
    }
}
