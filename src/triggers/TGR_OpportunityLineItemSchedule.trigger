/**
 * This trigger is used for OpportunityLineItemSchedule object.
 * version : 1.0
 */
trigger TGR_OpportunityLineItemSchedule on OpportunityLineItemSchedule (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_OpportunityLineItemSchedule.class);
}