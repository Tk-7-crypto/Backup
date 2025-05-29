/**
* This is HA_Websites_Review__c trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_HA_Websites_Review {
	
    /**
    * This method will insert record in Audit Log on Inserting/Updating HA_Websites_Review__c record
    **/
    public static void insertAuditLogOnUpdate(List<HA_Websites_Review__c> updatedList,Map<Id,HA_Websites_Review__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting HA_Websites_Review__c
    **/
    public static void insertAuditLog(List<HA_Websites_Review__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
}