/**
* This is iCSR Exchange Timeline trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_iCSR_Exchange_Timeline {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating iCSR Exchange Timeline
    **/
    public static void insertAuditLogOnUpdate(List<iCSR_Exchange_Timeline__c> updatedList,Map<Id,iCSR_Exchange_Timeline__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting iCSR Exchange Timeline
    **/
    public static void insertAuditLog(List<iCSR_Exchange_Timeline__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}