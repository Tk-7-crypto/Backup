/**
 * This trigger is used for RA Request (RA_Request__c) object.
 * version : 1.0
 */
trigger TGR_RA_Request on RA_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Aggregate_Report_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_RA_Request.class);
    } 
}