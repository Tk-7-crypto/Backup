/**
 * This trigger is used for Project (pse__Proj__c) object.
 * version : 1.0
 */
trigger TGR_Proj on pse__Proj__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Proj.class);
}