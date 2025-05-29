/**
* This is Project Log trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Project_Log {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Project Log
    **/
    public static void insertAuditLogOnUpdate(List<Project_Log__c> updatedList,Map<Id,Project_Log__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Project Log
    **/
    public static void insertAuditLog(List<Project_Log__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }

    /**
    * This method will validate on deletion validation rules
    **/
    public static void projectLogValidationsRDS(List<Project_Log__c> newList, Map<Id, Project_Log__c> oldMap) {
        for(Project_Log__c pl : newList) {
            if(trigger.isDelete) { 
                if(pl.Reason_for_Deletion__c  == null){
                    pl.addError('This Project Log cannot be deleted. Please enter the Reason For Deletion before you delete');
                }
            }
        }
    }
}