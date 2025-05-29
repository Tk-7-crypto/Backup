/**
* This is RA Request trigger handler class.
* version : 1.0
*/
public class DAOH_RA_Request {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating RA Request
    **/
    public static void insertAuditLogOnUpdate(List<RA_Request__c> updatedList,Map<Id,RA_Request__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting RA Request
    **/
    public static void insertAuditLog(List<RA_Request__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}