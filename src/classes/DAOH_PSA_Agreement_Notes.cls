/**
* This is Agreement Notes trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Agreement_Notes {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Agreement Notes
    **/
    public static void insertAuditLogOnUpdate(List<Agreement_Notes__c> updatedList,Map<Id,Agreement_Notes__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }
 
    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Agreement Notes
    **/
    public static void insertAuditLog(List<Agreement_Notes__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }

}