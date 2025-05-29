/**
* This is Partner Contact trigger handler class.
* version : 1.0 
*/
public class DAOH_PSA_Partner_Contact {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Partner Contact
    **/
    public static void insertAuditLogOnUpdate(List<Partner_Contact__c> updatedList,Map<Id,Partner_Contact__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Partner Contact
    **/
    public static void insertAuditLog(List<Partner_Contact__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 
    
    /**
    * This method will set the Deactivate Date field on a Partner Contact record
    **/
    public static void setDeactivatedDate(List<Partner_Contact__c> updatedList,Map<Id,Partner_Contact__c> existingRecords) {
        for(Partner_Contact__c pc : updatedList) {
            if(pc.Active__c && (existingRecords == null || 
                ( existingrecords.containsKey(pc.id) 
                && (pc.Active__c != existingRecords.get(pc.id).Active__c 
                ||pc.Deactivated_Date__c != existingRecords.get(pc.id).Deactivated_Date__c)))){
                
                pc.Deactivated_Date__c = null;
            }
            if(!pc.Active__c && pc.Deactivated_Date__c == null && (existingRecords == null || 
                ( existingrecords.containsKey(pc.id) && pc.Active__c != existingRecords.get(pc.id).Active__c)
                )) {
             
                pc.Deactivated_Date__c = Date.today(); 
            }
        }
    }

}