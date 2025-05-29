/**
* This is Agreement Products trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Agreement_Products {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Agreement Products
    **/
    public static void insertAuditLogOnUpdate(List<Agreement_Products__c> updatedList,Map<Id,Agreement_Products__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Agreement Products
    **/
    public static void insertAuditLog(List<Agreement_Products__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
 
}