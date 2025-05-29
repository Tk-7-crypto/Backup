/**
 * This trigger is used for Resource Request (pse__Resource_Request__c) object.
 * version : 1.0
 */
trigger TGR_Resource_Request on pse__Resource_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_RR_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Resource_Request.class);
    }
}