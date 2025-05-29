/**
 * This trigger is used for RA Issue (RA_Issue__c) object.
 * version : 1.0
 */
trigger TGR_RA_Issue on RA_Issue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Aggregate_Report_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_RA_Issue.class);
    } 
}