/**
* This is Project Contact trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Project_Contact {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Project Contact
    **/
    public static void insertAuditLogOnUpdate(List<Project_Contact__c> updatedList,Map<Id,Project_Contact__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Project Contact
    **/
    public static void insertAuditLog(List<Project_Contact__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}