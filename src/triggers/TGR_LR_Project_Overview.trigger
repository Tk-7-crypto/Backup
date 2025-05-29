/**
 * This trigger is used for LR Project Overview (LR_Project_Overview__c) object.
 * version : 1.0
 */
trigger TGR_LR_Project_Overview on LR_Project_Overview__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_LR_Project_Overview_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_LR_Project_Overview.class);
}
