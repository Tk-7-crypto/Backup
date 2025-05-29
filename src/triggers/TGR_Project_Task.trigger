/**
 * This trigger is used for Project Task object.
 * version : 1.0
 */
trigger TGR_Project_Task on pse__Project_Task__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Task_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Project_Task.class);
    }
}
