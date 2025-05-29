/**
 * This trigger is used for Task object.
 * version : 1.0
 */
trigger TGR_Task on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(userinfo.getName() != 'tpa Site Guest User' && !UTL_ExecutionControl.stopTriggerExecution) {
        fflib_SObjectDomain.triggerHandler(DAO_Task.class);
    }
}