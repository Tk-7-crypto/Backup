public class DAOH_PSA_CFI_Meetings {
    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Drug
    **/
    public static void insertAuditLog(List<CFI_Meetings__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Drug
    **/
    public static void insertAuditLogOnUpdate(List<CFI_Meetings__c> updatedList,Map<Id,CFI_Meetings__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }
}
