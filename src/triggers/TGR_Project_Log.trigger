/**
 * This trigger is used for Project_Log (Project_Log__c) object.
 * version : 1.0
 */
trigger TGR_Project_Log on Project_Log__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Log_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Project_Log.class);
    
    }
}