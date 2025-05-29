/**
 * This trigger is used for Assignment object.
 * version : 1.0
 */
trigger TGR_Assignment on pse__Assignment__c (before insert,before update,before delete, after insert, after update, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Assignment_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Assignment.class);
}