/**
* This is RA Recommendation trigger handler class.
* version : 1.0
*/
public class DAOH_RA_Recommendation {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating RA Recommendation
    **/
    public static void insertAuditLogOnUpdate(List<RA_Recommendation__c> updatedList,Map<Id,RA_Recommendation__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting RA Recommendation
    **/
    public static void insertAuditLog(List<RA_Recommendation__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 

}