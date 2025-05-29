/**
 * This trigger is used for Event Journals (Event_Journals__c) object.
 * version : 1.0
 */
trigger TGR_Event_journals on Event_Journals__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Event_Journals_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_PSA_Event_Journals.class);
}