/**
* This is RA Issue trigger handler class.
* version : 1.0
*/
public class DAOH_RA_Issue {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating RA Issue
    **/
    public static void insertAuditLogOnUpdate(List<RA_Issue__c> updatedList,Map<Id,RA_Issue__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting RA Issue
    **/
    public static void insertAuditLog(List<RA_Issue__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}