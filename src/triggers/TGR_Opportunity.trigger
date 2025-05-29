/**
 * This trigger is used for opportunity object.
 * version : 1.0
 */
trigger TGR_Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Control_For_Migration__c triggerControlSetting = Trigger_Control_For_Migration__c.getInstance();
    if(!UTL_ExecutionControl.stopTriggerExecution && triggerControlSetting != null && !triggerControlSetting.Disable_Opportunity_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Opportunity.class);
}