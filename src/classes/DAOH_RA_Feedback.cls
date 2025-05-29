/**
* This is RA Feedback trigger handler class.
* version : 1.0
*/
public class DAOH_RA_Feedback {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating RA Feedback
    **/
    public static void insertAuditLogOnUpdate(List<RA_Feedback__c> updatedList,Map<Id,RA_Feedback__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting RA Feedback
    **/
    public static void insertAuditLog(List<RA_Feedback__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}