trigger TGR_Milestone on pse__Milestone__c (before insert, before update,before delete, after insert, after update, after delete) {
/**
 * This trigger is used for Milestone object.
 * version : 1.0
 */
    
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Milestone_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Milestone.class);
}