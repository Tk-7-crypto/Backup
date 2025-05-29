/**
* This is Reconciliation trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Reconciliation {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Reconciliation
    **/
    public static void insertAuditLogOnUpdate(List<Reconciliation__c> updatedList,Map<Id,Reconciliation__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Reconciliation
    **/
    public static void insertAuditLog(List<Reconciliation__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}