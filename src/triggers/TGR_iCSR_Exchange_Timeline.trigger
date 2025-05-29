/**
 * This trigger is used for iCSR Exchange Timeline (iCSR_Exchange_Timeline__c) object.
 * version : 1.0
 */
trigger TGR_iCSR_Exchange_Timeline on iCSR_Exchange_Timeline__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Target_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_iCSR_Exchange_Timeline.class);
    } 
}