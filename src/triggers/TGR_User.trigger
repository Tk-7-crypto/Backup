/**
 * This trigger is used for User object.
 * version : 1.0
 */
trigger TGR_User on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Control_For_Migration__c triggerControlSetting = Trigger_Control_For_Migration__c.getInstance();
    if(!UTL_ExecutionControl.stopTriggerExecution && (triggerControlSetting != null && !triggerControlSetting.Disable_User_Trigger__c))
        fflib_SObjectDomain.triggerHandler(DAO_User.class);
}