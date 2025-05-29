/**
* This is Responsibilities and Maintenance trigger handler class.
* version : 1.0
*/
public class DAOH_Responsibilities_and_Maint {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Responsibilities and Maintenance
    **/
    public static void insertAuditLogOnUpdate(List<Responsibilities_and_Maintenance__c> updatedList,Map<Id,Responsibilities_and_Maintenance__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Responsibilities and Maintenance
    **/
    public static void insertAuditLog(List<Responsibilities_and_Maintenance__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
 
}